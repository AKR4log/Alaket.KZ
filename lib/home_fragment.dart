import 'dart:convert';
import 'dart:io';

import 'package:alaket_ios/all_task.dart';
import 'package:alaket_ios/state/feedState.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'requesters_tab_winget.dart';
import 'my_requests_tab_winget.dart';
import 'chat_widget.dart';
import 'profile_tab_widget.dart';

class Home extends StatefulWidget {
  final String vehicle_type;
  Home({this.vehicle_type});
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

extension ColorExtension on String {
  toColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}

class _HomeState extends State<Home> {
  List<String> vehicle_types = [];
  int _currentIndex = 0;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<Widget> tabs = [
    HomePage(
      sts: false,
    ),
    MyRequestsTab(),
    ChatTab(),
    ProfileTab()
  ];

  init() {
    var authUser = FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      print('init');
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection('myTex')
          .get()
          .then((QuerySnapshot querySnapshot) {
        print('inits');
        print(querySnapshot.docs.length);
        querySnapshot.docs.forEach((doc) {
          setState(() {
            vehicle_types.add(doc["vehicle_type"]);
          });
          tabs = [
            StreamProvider<List<Tasks>>.value(
              value: FeedState(type_tex: vehicle_types).allTaskApplications,
              child: HomePage(sts: true),
            ),
            MyRequestsTab(),
            ChatTab(),
            ProfileTab()
          ];
        });
      });
    }
  }

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      Platform.isAndroid
          ? showNotification(message['notification'])
          : showNotification(message['aps']['alert']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging
        .subscribeToTopic('alaket-${FirebaseAuth.instance.currentUser.uid}');

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .update({'pushToken': token});
    }).catchError((err) {
      print(err.message.toString());
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('llogo');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid ? 'ru.barnlab.alaket' : 'ru.barnlab.alaket',
      'Flutter chat demo',
      'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    print(message);
//    print(message['body'].toString());
//    print(json.encode(message));

    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));

//    await flutterLocalNotificationsPlugin.show(
//        0, 'plain title', 'plain body', platformChannelSpecifics,
//        payload: 'item x');
  }

  @override
  void initState() {
    var authUser = FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      registerNotification();
      init();
      configLocalNotification();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //body: _children[_currentIndex], // new
      body: tabs.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // new
        onTap: onTabTapped, // new
        items: [
          new BottomNavigationBarItem(
            icon: Image.asset('assets/icons/ic_icon_add.png',
                height: 24,
                width: 24,
                color: _currentIndex == 0
                    ? Colors.deepOrange.shade400
                    : Colors.blueGrey.shade700),
            title: Text('Новый'),
          ),
          new BottomNavigationBarItem(
            icon: Image.asset('assets/icons/ic_icon_my_data.png',
                height: 24,
                width: 24,
                color: _currentIndex == 1
                    ? Colors.deepOrange.shade400
                    : Colors.blueGrey.shade700),
            title: Text('Заказы'),
          ),
          new BottomNavigationBarItem(
              icon: Image.asset('assets/icons/ic_icon_chat.png',
                  height: 24,
                  width: 24,
                  color: _currentIndex == 2
                      ? Colors.deepOrange.shade400
                      : Colors.blueGrey.shade700),
              title: Text('Чат')),
          new BottomNavigationBarItem(
              icon: Image.asset('assets/icons/ic_icon_profile.png',
                  height: 24,
                  width: 24,
                  color: _currentIndex == 3
                      ? Colors.deepOrange.shade400
                      : Colors.blueGrey.shade700),
              title: Text('Профиль'))
        ],
        selectedItemColor: Colors.deepOrange.shade400,
        unselectedItemColor: Colors.blueGrey.shade700,
        showUnselectedLabels: true,
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
