import 'package:alaket_ios/listing.dart';
import 'package:alaket_ios/state/feedState.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllTask extends StatefulWidget {
  AllTask({Key key}) : super(key: key);

  @override
  _AllTaskState createState() => _AllTaskState();
}

class _AllTaskState extends State<AllTask> {
  List<String> vehicle_types = [];
  init() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('myTex')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          vehicle_types.add(doc["vehicle_type"]);
        });
      });
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: BackButton(
            color: Colors.black,
          ),
          title: Text(
            'Список заявок',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: StreamProvider<List<Tasks>>.value(
          value: FeedState(type_tex: vehicle_types).allTaskApplications,
          child: Listing(),
        ));
  }
}

class Tasks {
  final String cash;
  final String description;
  final String uidTask;
  final String time;
  final String image;
  final String timeCreated;
  final bool statusConfirm;
  final bool statusDel;
  final String type_cash;
  final double lat;
  final double lng;
  final String vehicle_type;
  final String uidUser;
  Tasks(
      {this.cash,
      this.description,
      this.time,
      this.image,
      this.statusConfirm,
      this.statusDel,
      this.uidTask,
      this.timeCreated,
      this.vehicle_type,
      this.type_cash,
      this.lat,
      this.lng,
      this.uidUser});
}
