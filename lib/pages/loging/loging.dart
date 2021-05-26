import 'package:alaket_ios/home_fragment.dart';
import 'package:alaket_ios/pages/loging/code/confirm_code.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback loginCallback;
  LoginPage({Key key, this.loginCallback}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _controllerNumberPhone;
  String verificationID;
  Duration timeoutVerifyPhone = const Duration(seconds: 5);
  bool error = false, waiting = false;

  @override
  void initState() {
    _controllerNumberPhone = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controllerNumberPhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(247, 247, 249, 1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Ваш номер телефона',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Color.fromRGBO(247, 247, 249, 1),
        elevation: 1,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromRGBO(78, 41, 254, 1),
        child: waiting
            ? Container(
                child: Container(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : Icon(Icons.arrow_forward_ios_outlined),
        onPressed: () {
          setState(() {
            error = false;
            waiting = true;
          });
          verifyPhone(_controllerNumberPhone.text, context);
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                children: [
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 15),
                      child: textFieldPhones(_controllerNumberPhone, error)),
                  Container(
                    width: double.infinity,
                    child: Text(
                      'Укажите код страны и номер телефона.',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withOpacity(0.8)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> verifyPhone(phoneNumber, context) async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential authResult) async {
      UserCredential firebaseResult =
          await FirebaseAuth.instance.signInWithCredential(authResult);
      var uid = FirebaseAuth.instance.currentUser.uid;
      if (firebaseResult.additionalUserInfo.isNewUser) {
        CollectionReference refU =
            FirebaseFirestore.instance.collection("users");
        refU.doc(uid).set({
          "uidUser": uid,
          "phone": FirebaseAuth.instance.currentUser.phoneNumber,
          "name": '',
          "surname": '',
          "avatars": '',
          "pushToken": null,
          "status": false,
          "timeCreated": DateTime.now().toUtc().toString(),
        }).whenComplete(() => Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home())));
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      setState(() {
        error = true;
        waiting = false;
      });
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this.verificationID = verId;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ConfirmCode(
                verificationID: verId,
              )));
      setState(() {
        error = false;
        waiting = true;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout = (String verId) {
      this.verificationID = verId;
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        timeout: const Duration(seconds: 5),
        verificationFailed: verificationFailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoRetrievalTimeout);
  }
}

Widget textFieldPhones(
  TextEditingController controller,
  bool error,
) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      prefixIconConstraints: BoxConstraints(maxHeight: 35, maxWidth: 45),
      prefixIcon: error
          ? Center(
              child: Icon(
                Icons.error_outline_rounded,
                color: Color.fromRGBO(255, 89, 100, 1),
              ),
            )
          : SizedBox(),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10.0),
      ),
      isCollapsed: true,
      filled: true,
      fillColor: error
          ? Color.fromRGBO(255, 89, 100, 0.1)
          : Color.fromRGBO(247, 247, 249, 1),
      hintText: 'Введите номер телефон',
      contentPadding: EdgeInsets.symmetric(vertical: 10),
    ),
    textInputAction: TextInputAction.next,
    inputFormatters: [
      PhoneInputFormatter(
        onCountrySelected: (PhoneCountryData countryData) {
          print(countryData.country);
        },
        allowEndlessPhone: false,
      )
    ],
    style: TextStyle(
      color: error
          ? Color.fromRGBO(255, 89, 100, 1)
          : Color.fromRGBO(13, 2, 33, 1),
      fontSize: 16,
    ),
    textAlign: TextAlign.start,
    keyboardType: TextInputType.phone,
  );
}
