import 'dart:async';

import 'package:alaket_ios/all_task.dart';
import 'package:alaket_ios/state/feedState.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ApplyTasksUI extends StatefulWidget {
  final Contract contract;
  ApplyTasksUI({Key key, this.contract}) : super(key: key);

  @override
  _ApplyTasksUIState createState() => _ApplyTasksUIState();
}

class _ApplyTasksUIState extends State<ApplyTasksUI> {
  String _address, type_cash, type_vehicle, cash, image, description, time;
  Geolocator _geolocator = Geolocator();
  double lat, lng;
  Widget twoColumns(Widget one, Widget two) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [one, two],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    init();

    setAddressToSearch(lat, lng);
  }

  init() {
    var authUser = FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      FirebaseFirestore.instance
          .collection("tasks")
          .doc(widget.contract.uidTask)
          .get()
          .then((value) {
        if (value.data() != null) {
          setState(() {
            lat = value.data()['lat'];
            lng = value.data()['lng'];
            type_cash = value.data()['type_cash'];
            type_vehicle = value.data()['vehicle_type'];
            cash = value.data()['cash'];
            image = value.data()['image'];
            description = value.data()['description'];
            time = value.data()['time'];
          });
        }
      });
    }
  }

  Future<Null> setAddressToSearch(double latitude, double longitude) async {
    List<Placemark> newPlace =
        await _geolocator.placemarkFromCoordinates(latitude, longitude);

    // this is all you need
    Placemark placeMark = newPlace[0];
    String name = placeMark.name;
    String sth = placeMark.thoroughfare;
    String subLocality = placeMark.subLocality;
    String locality = placeMark.locality;
    String administrativeArea = placeMark.administrativeArea;
    String postalCode = placeMark.postalCode;
    String country = placeMark.country;

    String addressFull =
        "${sth} ${name}, ${administrativeArea} ${postalCode}, ${country}";

    setState(() {
      _address = addressFull;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: image,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                placeholderFadeInDuration: Duration(milliseconds: 500),
                placeholder: (context, url) => Container(
                  color: Colors.grey[300].withOpacity(0.3),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            child: Text(
              type_vehicle,
              style: TextStyle(fontSize: 20),
            ),
          ),
          twoColumns(
            Text('Заказ: '),
            Expanded(child: Text("№ " + widget.contract.uidTask)),
          ),
          twoColumns(
            Text('Тип оплаты: '),
            Text(type_cash),
          ),
          twoColumns(
            Text('Описание: '),
            Text(description),
          ),
          twoColumns(
            Text('Время: '),
            Text(time),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 10),
            child: Text(
              _address ?? '',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  Container(
                    child: Text(
                      "₸" + cash,
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('Вы приняли этот заказ')],
              )
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            width: double.infinity,
            color: Colors.grey,
            height: 1.5,
          ),
        ],
      ),
    );
  }
}
