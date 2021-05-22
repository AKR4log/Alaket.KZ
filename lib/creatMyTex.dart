import 'dart:math';

import 'package:alaket_ios/home_fragment.dart';
import 'package:alaket_ios/myCatTex.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CreateMyTex extends StatefulWidget {
  final String myCatTex;
  CreateMyTex({Key key, this.myCatTex}) : super(key: key);

  @override
  _CreateMyTexState createState() => _CreateMyTexState();
}

class _CreateMyTexState extends State<CreateMyTex> {
  TextEditingController controllerDescription = new TextEditingController();
  bool errorTex = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Colors.black,
        ),
        title: Text(
          'Создание техники',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 25, vertical: 35),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => MyCatTexnik()));
                },
                child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      widget.myCatTex ?? 'Выберете технику',
                      style: TextStyle(
                        color: errorTex ? Colors.red : Colors.black,
                      ),
                    )),
              ),
              TextField(
                controller: controllerDescription,
                decoration: const InputDecoration(
                  hintText: "Описание",
                ),
                maxLines: 5,
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
              TextButton(
                  onPressed: () {
                    if (widget.myCatTex != null) {
                      var uidTex = Uuid().v4();
                      var uid = FirebaseAuth.instance.currentUser.uid;
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection('myTex')
                          .doc(uidTex)
                          .set({
                        "description":
                            controllerDescription.text.trim() ?? null,
                        "timeCreated": DateTime.now().toUtc().toString(),
                        "vehicle_type": widget.myCatTex,
                        "uidTex": uidTex,
                        "uidUser": uid
                      });

                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Home()));
                    } else {
                      setState(() {
                        errorTex = true;
                      });
                    }
                  },
                  child: Text('Создать')),
            ],
          ),
        ),
      ),
    );
  }
}
