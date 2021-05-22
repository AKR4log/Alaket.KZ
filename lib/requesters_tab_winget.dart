import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'dart:ui' as ui;
import 'package:alaket_ios/all_task.dart';
import 'package:alaket_ios/complite.dart';
import 'package:alaket_ios/search_page.dart';
import 'package:alaket_ios/utils/widgets/model_windows.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:google_maps_webservice/places.dart' as places;
import 'package:google_api_headers/google_api_headers.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

const kGoogleApiKey = "AIzaSyBufel5iX9GaTH_P4XVv7A9P1tL88PBbaw";

class HomePage extends StatefulWidget {
  final String vehicle_type;
  HomePage({this.vehicle_type});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final homeScaffoldKey = GlobalKey<ScaffoldState>();

  double _lat = 0;
  double _lng = 0;
  Completer<GoogleMapController> _controller = Completer();
  Location location = new Location();
  bool _serviceEnabled = false;
  bool _media_loaded = false;
  bool _description_added = false;
  bool _budget_added = false, uploaded = false;
  String val_description = 'Нет описания',
      val_time = 'Прямо сейчас',
      val_cash = 'Бюджет',
      type_cash = 'Безналичный',
      media,
      uriDom,
      verificationID;
  PermissionStatus _permissionGranted;
  CameraPosition _currentPosition;
  String _address = "Где искать исполнителя";
  String how_service_search = "Какую технику ищете?";
  Geolocator _geolocator = Geolocator();
  Set<Marker> _markers = {};
  bool status = false;
  BitmapDescriptor pinLocationIcon;
  String _mapStyle = "";
  File _imageFile;
  final picker = ImagePicker();
  BitmapDescriptor customIcon;
  Uint8List iconMarker = null;
  AnimationController animation;
  BuildContext _context;
  Animation<double> _fadeInFadeOut;
  TextEditingController controllerDescription = new TextEditingController();
  TextEditingController controllerCash = new TextEditingController();
  TextEditingController controllerPhone = new TextEditingController();
  TextEditingController controllerCode = new TextEditingController();

  init() {
    var authUser = FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(authUser.uid)
          .get()
          .then((value) {
        if (value.data() != null) {
          setState(() {
            status = value.data()['status'];
          });
        }
      });
    }
  }

  @override
  initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(64, 64)),
            'assets/icons/ic_icon_my_location.png')
        .then((d) {
      customIcon = d;
    });

    init();

    controllerCash = TextEditingController();
    controllerDescription = TextEditingController();
    controllerPhone = TextEditingController();
    controllerCode = TextEditingController();

    _currentPosition = CameraPosition(
      target: LatLng(_lat, _lng),
      zoom: 12,
    );

    animation = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeInFadeOut = Tween<double>(begin: 0.0, end: 1.0).animate(animation);

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animation.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animation.forward();
      }
    });
    animation.forward();
    // _markers.add(
    //     Marker(
    //         markerId: MarkerId('current'),
    //         position: LatLng(_lat, _lng),
    //         icon: customIcon
    //     )
    // );
    getBytesFromAsset();
    rootBundle.loadString('assets/json_values/style_map.txt').then((string) {
      _mapStyle = string;
    });
  }

  Future pickImage() async {
    if (FirebaseAuth.instance.currentUser != null) {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);

      setState(() {
        _imageFile = File(pickedFile.path);
      });
      uploadImageToFirebase(_context);
    } else {
      modelBlock(context, [
        TextField(
          controller: controllerPhone,
          decoration: const InputDecoration(
            hintText: "ТЕЛЕФОН",
          ),
          style: TextStyle(
            fontSize: 14.0,
          ),
        ),
        TextButton(
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ожидается код подтверждения'),
                ),
              );
              final PhoneVerificationCompleted verificationCompleted =
                  (AuthCredential authResult) async {
                UserCredential firebaseResult = await FirebaseAuth.instance
                    .signInWithCredential(authResult);
                var uid = FirebaseAuth.instance.currentUser.uid;
                if (firebaseResult.additionalUserInfo.isNewUser) {
                  CollectionReference refU =
                      FirebaseFirestore.instance.collection("users");
                  refU.doc(uid).set({
                    "uidUser": uid,
                    "phone": FirebaseAuth.instance.currentUser.phoneNumber,
                    "status": false,
                    "name": '',
                    "pushToken": null,
                    "surname": '',
                    "avatars": '',
                    "timeCreated": DateTime.now().toUtc().toString(),
                  });
                  Navigator.pop(context);
                }
                Navigator.pop(context);
              };

              final PhoneVerificationFailed verificationFailed =
                  (FirebaseAuthException authException) {
                print(authException.code);
              };

              final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
                this.verificationID = verId;
              };

              final PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout =
                  (String verId) {
                this.verificationID = verId;
                modelBlock(context, [
                  TextField(
                    controller: controllerCode,
                    decoration: const InputDecoration(
                      hintText: "Введите код",
                    ),
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                  TextButton(
                      onPressed: () async {
                        AuthCredential authCredential =
                            PhoneAuthProvider.credential(
                                verificationId: verificationID,
                                smsCode: controllerCode.text.trim());
                        UserCredential firebaseResult = await FirebaseAuth
                            .instance
                            .signInWithCredential(authCredential);
                        var uid = FirebaseAuth.instance.currentUser.uid;
                        if (firebaseResult.additionalUserInfo.isNewUser) {
                          CollectionReference refU =
                              FirebaseFirestore.instance.collection("users");
                          refU.doc(uid).set({
                            "uidUser": uid,
                            "phone":
                                FirebaseAuth.instance.currentUser.phoneNumber,
                            "status": false,
                            "name": '',
                            "pushToken": null,
                            "surname": '',
                            "avatars": '',
                            "timeCreated": DateTime.now().toUtc().toString(),
                          });
                          Navigator.pop(context);
                        }
                        Navigator.pop(context);
                      },
                      child: Text('Авторизоваться')),
                ]);
              };
              await FirebaseAuth.instance.verifyPhoneNumber(
                  phoneNumber: controllerPhone.text.trim(),
                  verificationCompleted: verificationCompleted,
                  timeout: const Duration(seconds: 5),
                  verificationFailed: verificationFailed,
                  codeSent: smsSent,
                  codeAutoRetrievalTimeout: autoRetrievalTimeout);
            },
            child: Text('Авторизоваться')),
      ]);
    }
  }

  Future uploadImageToFirebase(BuildContext context) async {
    var ran = Random();
    var fileName = ran.nextInt(10000);
    firebase_storage.Reference firebaseStorageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('uploads/$fileName');
    firebase_storage.UploadTask uploadTask =
        firebaseStorageRef.putFile(File(_imageFile.path));
    setState(() {
      uploaded = true;
    });
    uploadTask.snapshotEvents.listen((event) {}).onData((snapshot) {
      if (snapshot.state == firebase_storage.TaskState.success) {
        firebaseStorageRef.getDownloadURL().then((snapshot) {
          setState(() {
            uriDom = snapshot.toString();
          });
          setState(() {
            uploaded = false;
          });
        });
      }
    });
  }

  Future<Uint8List> getBytesFromAsset() async {
    String path = 'assets/icons/ic_icon_my_location.png';
    int width = 48;
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    iconMarker = (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  _locateMe() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    await location.getLocation().then((res) async {
      List<Placemark> newPlace = await _geolocator.placemarkFromCoordinates(
          res.latitude, res.longitude);

      // this is all you need
      Placemark placeMark = newPlace[0];
      String name = placeMark.name;
      String sbt = placeMark.subThoroughfare;
      String sth = placeMark.thoroughfare;
      String subLocality = placeMark.subLocality;
      String locality = placeMark.locality;
      String administrativeArea = placeMark.administrativeArea;
      String postalCode = placeMark.postalCode;
      String country = placeMark.country;
      String address = "${locality}, ${sth}, ${name}";
      String addressFull =
          "${sth}, ${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";

      setAddressToSearch(res.latitude, res.longitude);
    });
  }

  @override
  dispose() {
    animation.dispose();
    controllerDescription?.dispose();
    controllerPhone?.dispose();
    controllerCash?.dispose();
    controllerCode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null && status) {
      final task = Provider.of<List<Tasks>>(context);
      task.forEach((doc) {
        _markers.add(Marker(
            markerId: MarkerId(doc.uidTask),
            position: LatLng(doc.lat, doc.lng),
            icon: BitmapDescriptor.defaultMarker));
      });
    }
    Widget searchService = Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.white,
          ),
          borderRadius: new BorderRadius.only(
            topLeft: const Radius.circular(8.0),
            topRight: const Radius.circular(8.0),
          )),
      child: Container(
        width: double.infinity,
        height: 48,
        margin: EdgeInsets.only(top: 8, left: 8, right: 8),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.blueGrey.shade700, width: 0.25),
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Stack(
          children: <Widget>[
            Row(
              children: [
                Container(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.search,
                          size: 18.0, color: Colors.blueGrey.shade700),
                    ),
                  ),
                ),
                Container(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          _handlePressButton();
                        },
                        child: Text(
                          widget.vehicle_type != null
                              ? widget.vehicle_type
                              : how_service_search,
                          style: TextStyle(
                            color: Colors.blueGrey.shade200,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    Widget _staticLocationSearch = Container(
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Icon(Icons.adjust, size: 24.0, color: Colors.blueGrey.shade700),
        ),
      ),
    );

    Widget _animatedLocationSearch = FadeTransition(
      opacity: _fadeInFadeOut,
      child: Container(
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Icon(Icons.adjust, size: 24.0, color: Colors.blueGrey.shade700),
          ),
        ),
      ),
    );

    Widget searchAddressContainer = Container(
      width: double.infinity,
      height: 48,
      margin: EdgeInsets.only(top: 48, left: 8, right: 8),
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Stack(
        children: <Widget>[
          Row(
            children: [
              Container(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.location_on,
                        size: 18.0, color: Colors.blueGrey.shade700),
                  ),
                ),
              ),
              Container(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        _handlePressButton();
                      },
                      child: Text(
                        _address,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              _locateMe();
            },
            child: _serviceEnabled
                ? _staticLocationSearch
                : _animatedLocationSearch,
          ),
        ],
      ),
    );

    Widget time_and_pay() {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 8, left: 8, right: 8),
        height: 56,
        color: Colors.white,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <
            Widget>[
          GestureDetector(
            onTap: () => modelBlock(context, [
              GestureDetector(
                onTap: () {
                  setState(() {
                    val_time = "Сейчас";
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Text(
                    'Прямо сейчас',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    val_time = "Завтра";
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Text(
                    'Завтра',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final DateTimeRange newDateRange = await showDateRangePicker(
                    context: context,
                    initialDateRange: DateTimeRange(
                      start: DateTime.now(),
                      end: DateTime.now().add(Duration(days: 7)),
                    ),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2055, 7),
                    helpText: 'Select a date',
                  ).then((value) {
                    setState(() {
                      val_time = value.start.day.toString() +
                          '.' +
                          value.start.month.toString() +
                          " --- " +
                          value.end.day.toString() +
                          '.' +
                          value.end.month.toString();
                    });
                    Navigator.pop(context);
                  });
                },
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Text(
                    'Выбрать время',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ]),
            child: Stack(
              children: <Widget>[
                Row(
                  children: [
                    Container(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.timelapse,
                              size: 18.0, color: Colors.blueGrey.shade900),
                        ),
                      ),
                    ),
                    Container(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Text(
                            val_time,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => modelBlock(context, [
              GestureDetector(
                onTap: () {
                  setState(() {
                    type_cash = "Безналичный";
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Text(
                    'Безналичный',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    type_cash = "Наличный";
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Text(
                    'Наличный',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    type_cash = "Всё вместе";
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Text(
                    'Всё вместе',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ]),
            child: Stack(
              children: <Widget>[
                Row(
                  children: [
                    Container(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.credit_card,
                              size: 18.0, color: Colors.blueGrey.shade900),
                        ),
                      ),
                    ),
                    Container(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Text(
                            type_cash,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ]),
      );
    }

    Widget budget_descript_media = Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 8, left: 8, right: 8),
      height: 56,
      color: Colors.white,
      child: Row(children: <Widget>[
        Expanded(
          flex: 1,
          child: InkWell(
            onTap: () {
              modelBlock(context, [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Планируемый бюджет',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Material(
                      child: TextField(
                        controller: controllerCash,
                        decoration: const InputDecoration(
                          hintText: "Сумма",
                        ),
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                val_cash = "5000";
                              });
                              Navigator.pop(context);
                            },
                            child: Text('5 000')),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                val_cash = "10000";
                              });
                              Navigator.pop(context);
                            },
                            child: Text('10 000')),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                val_cash = "15000";
                              });
                              Navigator.pop(context);
                            },
                            child: Text('15 000')),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                val_cash = "20000";
                              });
                              Navigator.pop(context);
                            },
                            child: Text('20 000'))
                      ],
                    ),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            val_cash = controllerCash.text.trim();
                          });
                          Navigator.pop(context);
                        },
                        child: Text('Продолжить'))
                  ],
                ),
              ]);
            },
            child: Container(
              margin: EdgeInsets.all(8),
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: _budget_added
                          ? Colors.deepOrange
                          : Colors.blueGrey.shade900,
                      width: 0.25),
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(Icons.add,
                        size: 18.0, color: Colors.blueGrey.shade700),
                    Expanded(
                        child: Text(val_cash,
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              color: Colors.blueGrey.shade700,
                            ),
                            overflow: TextOverflow.ellipsis))
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: new Material(
            child: new InkWell(
              onTap: () {
                modelBlock(context, [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Добавить информацию',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Material(
                        child: TextField(
                          controller: controllerDescription,
                          decoration: const InputDecoration(
                            hintText: "Описание, важные параметры...",
                          ),
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              val_description =
                                  controllerDescription.text.trim();
                            });
                            Navigator.pop(context);
                          },
                          child: Text('Продолжить'))
                    ],
                  ),
                ]);
              },
              child: Container(
                margin: EdgeInsets.all(8),
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: _description_added
                            ? Colors.deepOrange
                            : Colors.blueGrey.shade900,
                        width: 0.25),
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(Icons.add,
                          size: 18.0, color: Colors.blueGrey.shade700),
                      Expanded(
                          child: Text(
                              val_description != null && val_description != ''
                                  ? 'Добавлено'
                                  : 'Описание',
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                color: Colors.blueGrey.shade700,
                              ),
                              overflow: TextOverflow.ellipsis))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: new Material(
            child: new InkWell(
              onTap: () {
                pickImage();
              },
              child: Container(
                margin: EdgeInsets.all(8),
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: _media_loaded
                            ? Colors.deepOrange
                            : Colors.blueGrey.shade900,
                        width: 0.25),
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      uploaded
                          ? Container(
                              width: 10,
                              height: 10,
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.add,
                              size: 18.0, color: Colors.blueGrey.shade700),
                      Expanded(
                          child: Text(
                              uploaded
                                  ? 'Загрузка'
                                  : uriDom != null && uriDom != ''
                                      ? 'Загруженно'
                                      : 'Медиа',
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                color: Colors.blueGrey.shade700,
                              ),
                              overflow: TextOverflow.ellipsis))
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      ]),
    );

    Widget mapContainer = Container(
        height: double.infinity,
        width: double.infinity,
        child: GoogleMap(
          initialCameraPosition: _currentPosition,
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            GoogleMapController ctrl = controller;
            ctrl.setMapStyle(_mapStyle);
            _controller.complete(ctrl);
            _locateMe();
          },
        ));

    Widget buttonAddRequest = Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 28),
      height: 84,
      color: Colors.white,
      child: new RaisedButton(
        child: Text("СОЗДАТЬ"),
        onPressed: () async {
          if (FirebaseAuth.instance.currentUser != null) {
            await Firebase.initializeApp();
            var uidtask = Uuid().v4();
            String uid = FirebaseAuth.instance.currentUser.uid;
            CollectionReference ref =
                FirebaseFirestore.instance.collection("tasks");
            ref.doc(uidtask).set({
              "uidUser": uid,
              "type_cash": type_cash,
              "cash": val_cash == 'Бюджет' ? '5000' : val_cash,
              "description": val_description,
              "lat": _lat,
              "lng": _lng,
              "uidTask": uidtask,
              "statusDel": false,
              "time": val_time,
              "statusConfirm": false,
              "vehicle_type": widget.vehicle_type ?? '',
              "image": uriDom ?? null,
              "timeCreated": DateTime.now().toUtc().toString(),
            }).whenComplete(() => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => Compalite())));
            // FirebaseAuth.instance.signOut();
            // return;
          } else {
            modelBlock(context, [
              Material(
                child: TextField(
                  controller: controllerPhone,
                  decoration: const InputDecoration(
                    hintText: "ТЕЛЕФОН",
                  ),
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ),
              TextButton(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ожидается код подтверждения'),
                      ),
                    );
                    final PhoneVerificationCompleted verificationCompleted =
                        (AuthCredential authResult) async {
                      UserCredential firebaseResult = await FirebaseAuth
                          .instance
                          .signInWithCredential(authResult);
                      var uid = FirebaseAuth.instance.currentUser.uid;
                      if (firebaseResult.additionalUserInfo.isNewUser) {
                        CollectionReference refU =
                            FirebaseFirestore.instance.collection("users");
                        refU.doc(uid).set({
                          "uidUser": uid,
                          "phone":
                              FirebaseAuth.instance.currentUser.phoneNumber,
                          "name": '',
                          "surname": '',
                          "avatars": '',
                          "pushToken": null,
                          "status": false,
                          "timeCreated": DateTime.now().toUtc().toString(),
                        });
                        Navigator.pop(context);
                      }
                      Navigator.pop(context);
                    };

                    final PhoneVerificationFailed verificationFailed =
                        (FirebaseAuthException authException) {
                      print(authException.code);
                    };

                    final PhoneCodeSent smsSent =
                        (String verId, [int forceResend]) {
                      this.verificationID = verId;
                    };

                    final PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout =
                        (String verId) {
                      this.verificationID = verId;
                      modelBlock(context, [
                        Material(
                          child: TextField(
                            controller: controllerCode,
                            decoration: const InputDecoration(
                              hintText: "Введите код",
                            ),
                            style: TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                        TextButton(
                            onPressed: () async {
                              AuthCredential authCredential =
                                  PhoneAuthProvider.credential(
                                      verificationId: verificationID,
                                      smsCode: controllerCode.text.trim());
                              UserCredential firebaseResult = await FirebaseAuth
                                  .instance
                                  .signInWithCredential(authCredential);
                              var uid = FirebaseAuth.instance.currentUser.uid;
                              if (firebaseResult.additionalUserInfo.isNewUser) {
                                CollectionReference refU = FirebaseFirestore
                                    .instance
                                    .collection("users");
                                refU.doc(uid).set({
                                  "uidUser": uid,
                                  "phone": FirebaseAuth
                                      .instance.currentUser.phoneNumber,
                                  "name": '',
                                  "pushToken": null,
                                  "surname": '',
                                  "avatars": '',
                                  "status": false,
                                  "timeCreated":
                                      DateTime.now().toUtc().toString(),
                                });
                              }
                              Navigator.pop(context);
                            },
                            child: Text('Авторизоваться')),
                      ]);
                    };
                    await FirebaseAuth.instance.verifyPhoneNumber(
                        phoneNumber: controllerPhone.text.trim(),
                        verificationCompleted: verificationCompleted,
                        timeout: const Duration(seconds: 5),
                        verificationFailed: verificationFailed,
                        codeSent: smsSent,
                        codeAutoRetrievalTimeout: autoRetrievalTimeout);
                    Navigator.pop(context);
                  },
                  child: Text('Авторизоваться')),
            ]);
          }
        },
        highlightColor: Colors.deepOrange,
        color: Colors.deepOrange,
        textColor: Colors.white,
        padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        colorBrightness: Brightness.light,
      ),
    );

    Widget optionsContainer = Align(
      alignment: Alignment.bottomCenter,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          searchService,
          time_and_pay(),
          budget_descript_media,
          buttonAddRequest,
        ],
      ),
    );

    return Scaffold(
      key: homeScaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: status
          ? Container(
              height: 75,
              width: 75,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  border: Border.all(width: 1.5, color: Colors.black)),
              child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => AllTask()));
                  },
                  child: Text(
                    'Список\nзаявок',
                    style: TextStyle(color: Colors.black),
                  )),
            )
          : SizedBox(),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            mapContainer,
            searchAddressContainer,
            status ? SizedBox() : optionsContainer,
          ],
        ),
      ),
    );
  }

  void onError(places.PlacesAutocompleteResponse response) {
    String s = response.errorMessage;
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  void _handlePressButton() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Texnik()));
  }

  Future<Null> displayPrediction(
      places.Prediction p, ScaffoldState scaffold) async {
    if (p != null) {
      // get detail (lat/lng)
      places.GoogleMapsPlaces _places = places.GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );
      places.PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;

      // scaffold.showSnackBar(
      //   SnackBar(content: Text("${p.description} - $lat/$lng")),
      // );
      setAddressToSearch(lat, lng);
    }
  }

  Future<Null> setAddressToSearch(double latitude, double longitude) async {
    final GoogleMapController controller = await _controller.future;

    final _position = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 17,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(_position));
    List<Placemark> newPlace =
        await _geolocator.placemarkFromCoordinates(latitude, longitude);

    // this is all you need
    Placemark placeMark = newPlace[0];
    String name = placeMark.name;
    String sbt = placeMark.subThoroughfare;
    String sth = placeMark.thoroughfare;
    String subLocality = placeMark.subLocality;
    String locality = placeMark.locality;
    String administrativeArea = placeMark.administrativeArea;
    String postalCode = placeMark.postalCode;
    String country = placeMark.country;

    String address = "${sth}, ${name}";

    String addressFull =
        "${sth}, ${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";

    setState(() {
      _lat = latitude;
      _lng = longitude;
      _address = address;
      _markers.add(Marker(
          markerId: MarkerId('my_location'),
          position: LatLng(_lat, _lng),
          icon: BitmapDescriptor.fromBytes(iconMarker)));
      if (!_serviceEnabled) {
        animation.dispose();
      }
    });
  }
}
