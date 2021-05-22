import 'package:alaket_ios/MyActiveListing.dart';
import 'package:alaket_ios/MyDeteleListing.dart';
import 'package:alaket_ios/all_task.dart';
import 'package:alaket_ios/myApplyActive.dart';
import 'package:alaket_ios/state/feedState.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyRequestsTab extends StatefulWidget {
  @override
  _MyRequests createState() => _MyRequests();
}

class _MyRequests extends State<MyRequestsTab> with TickerProviderStateMixin {
  bool status = false;

  init() {
    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser.uid)
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
    if (FirebaseAuth.instance.currentUser != null) {
      init();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget activityRequest() {
      if (FirebaseAuth.instance.currentUser != null) {
        return status
            ? StreamProvider<List<Contract>>.value(
                value: FeedState().allMyApplyTaskApplications,
                child: MyApplyActiveListing(),
              )
            : StreamProvider<List<Tasks>>.value(
                value: FeedState().allMyTaskApplications,
                child: MyActiveListing(),
              );
      }
    }

    Widget archRequest() {
      if (FirebaseAuth.instance.currentUser != null) {
        return status
            ? Center(
                child: Text('Вы в режиме исполнителя'),
              )
            : StreamProvider<List<Tasks>>.value(
                value: FeedState().allMyDeteleTaskApplications,
                child: MyDeteleListing(),
              );
      }
    }

    if (FirebaseAuth.instance.currentUser != null) {
      return DefaultTabController(
        length: 2,
        child: new Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            elevation: 0,
            title: Text(
              'Сохранённые',
              style: TextStyle(color: Colors.black),
            ),
            bottom: TabBar(
              physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              labelPadding: EdgeInsets.all(15),
              // isScrollable: true,
              labelColor: Color.fromRGBO(78, 41, 254, 1),
              indicatorColor: Color.fromRGBO(78, 41, 254, 1),
              unselectedLabelColor: Colors.blueGrey.shade900,
              tabs: [Text("АКТИВНЫЕ"), Text("АРХИВ")],
            ),
          ),
          body: new TabBarView(
            children: <Widget>[
              activityRequest(),
              archRequest(),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Text(
            'Сохранённые',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Center(
            child: Text(
          "Чтобы видеть сохранённые, для начала нужно авторизоваться",
          textAlign: TextAlign.center,
        )),
      );
    }
  }
}
