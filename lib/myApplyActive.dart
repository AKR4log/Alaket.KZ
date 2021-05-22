import 'package:alaket_ios/ApplyTasksUI.dart';
import 'package:alaket_ios/all_task.dart';
import 'package:alaket_ios/chat.dart';
import 'package:alaket_ios/data.dart';
import 'package:alaket_ios/state/feedState.dart';
import 'package:alaket_ios/tasks.dart';
import 'package:alaket_ios/utils/widgets/model_windows.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MyApplyActiveListing extends StatefulWidget {
  MyApplyActiveListing({Key key}) : super(key: key);

  @override
  _MyApplyActiveListingState createState() => _MyApplyActiveListingState();
}

class _MyApplyActiveListingState extends State<MyApplyActiveListing> {
  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final contract = Provider.of<List<Contract>>(context);
    return Column(
      children: [
        Expanded(
          child: contract.length == 0
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                )
              : ListView.builder(
                  physics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  itemCount: contract.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        modelMain(context, [
                          TextButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection("tasks")
                                    .doc(contract[index].uidTask)
                                    .update({"statusConfirm": false});
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(FirebaseAuth.instance.currentUser.uid)
                                    .collection('contract')
                                    .doc(contract[index].uidContract)
                                    .delete();
                                Navigator.pop(context);
                              },
                              child: Text('Отказаться от заказа')),
                          TextButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection("tasks")
                                    .doc(contract[index].uidTask)
                                    .get()
                                    .then((value) {
                                  print(value);
                                  if (value.data() != null) {
                                    var chatRoomId = getChatRoomIdByUsernames(
                                        FirebaseAuth.instance.currentUser.uid,
                                        value.data()['uidUser']);
                                    Map<String, dynamic> chatRoomInfoMap = {
                                      "users": [
                                        FirebaseAuth.instance.currentUser.uid,
                                        value.data()['uidUser']
                                      ]
                                    };
                                    DatabaseMethods().createChatRoom(
                                        chatRoomId, chatRoomInfoMap);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                                  value.data()['uidUser'],
                                                )));
                                  }
                                });
                              },
                              child: Text('Написать заказчику')),
                          TextButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection("tasks")
                                    .doc(contract[index].uidTask)
                                    .get()
                                    .then((value) {
                                  print(value);
                                  if (value.data() != null) {}
                                  openMap(
                                      value.data()['lat'], value.data()['lng']);
                                });
                              },
                              child: Text('Отследить заказ')),
                          TextButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection("tasks")
                                    .doc(contract[index].uidTask)
                                    .get()
                                    .then((value) {
                                  if (value.data() != null) {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(value.data()['uidUser'])
                                        .get()
                                        .then((value) {
                                      print(value.data()['phone']);
                                      launch('tel://${value.data()['phone']}');
                                    });
                                  }
                                });
                              },
                              child: Text('Позвонить подрядчику'))
                        ]);
                      },
                      child: ApplyTasksUI(contract: contract[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
