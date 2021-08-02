import 'package:alaket_ios/home_fragment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConfirmCode extends StatefulWidget {
  ConfirmCode({Key key, this.verificationID}) : super(key: key);
  final String verificationID;

  @override
  _ConfirmCodeState createState() => _ConfirmCodeState();
}

class _ConfirmCodeState extends State<ConfirmCode> {
  TextEditingController _controllerCodes = TextEditingController();
  bool waiting = false;

  @override
  void initState() {
    _controllerCodes = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controllerCodes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        onPressed: () async {
          setState(() {
            waiting = true;
          });
          print('val 1');
          AuthCredential authCredential = PhoneAuthProvider.credential(
              verificationId: widget.verificationID,
              smsCode: _controllerCodes.text);
          print('val 2');
          UserCredential firebaseResult =
              await FirebaseAuth.instance.signInWithCredential(authCredential);
          print('val 3');
          var uid = FirebaseAuth.instance.currentUser.uid;
          print('val 4');
          if (firebaseResult.additionalUserInfo.isNewUser) {
            CollectionReference refU =
                FirebaseFirestore.instance.collection("users");
            refU.doc(uid).set({
              "uidUser": uid,
              "phone": FirebaseAuth.instance.currentUser.phoneNumber,
              "name": '',
              "pushToken": null,
              "surname": '',
              "avatars": '',
              "status": false,
              "timeCreated": DateTime.now().toUtc().toString(),
            });
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => Home()));
          }
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Home()));
        },
      ),
      backgroundColor: Color.fromRGBO(247, 247, 249, 1),
      appBar: AppBar(
        leading: BackButton(color: Colors.black87),
        title: Text(
          'Проверка телефона',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Color.fromRGBO(247, 247, 249, 1),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 35),
                    child: Icon(
                      Icons.sms_outlined,
                      size: 52,
                      color: Color.fromRGBO(78, 41, 254, 1),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      'Мы отправили SMS с кодом на ваш телефон.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.8)),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: TextField(
                      controller: _controllerCodes,
                      decoration: const InputDecoration(
                        hintText: "Код подтверждения введите",
                      ),
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                      keyboardType: TextInputType.phone,
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
}
