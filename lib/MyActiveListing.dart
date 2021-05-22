import 'package:alaket_ios/all_task.dart';
import 'package:alaket_ios/chat.dart';
import 'package:alaket_ios/data.dart';
import 'package:alaket_ios/tasks.dart';
import 'package:alaket_ios/utils/widgets/model_windows.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MyActiveListing extends StatefulWidget {
  MyActiveListing({Key key}) : super(key: key);

  @override
  _MyActiveListingState createState() => _MyActiveListingState();
}

class _MyActiveListingState extends State<MyActiveListing> {
  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = Provider.of<List<Tasks>>(context);
    return Column(
      children: [
        Expanded(
          child: task.length == 0
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                )
              : ListView.builder(
                  physics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  itemCount: task.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        modelMain(context, [
                          TextButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection("tasks")
                                    .doc(task[index].uidTask)
                                    .update({"statusDel": true});
                                Navigator.pop(context);
                              },
                              child: Text('Удалить заказ')),
                          task[index].statusConfirm
                              ? TextButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection("tasks")
                                        .doc(task[index].uidTask)
                                        .collection('contractors')
                                        .snapshots()
                                        .single
                                        .then((value) {
                                      print(value);
                                      if (value.docs[0].data() != null) {
                                        var chatRoomId =
                                            getChatRoomIdByUsernames(
                                                FirebaseAuth
                                                    .instance.currentUser.uid,
                                                value.docs[0].data()[
                                                    'uidUserContractor']);
                                        Map<String, dynamic> chatRoomInfoMap = {
                                          "users": [
                                            FirebaseAuth
                                                .instance.currentUser.uid,
                                            value.docs[0]
                                                .data()['uidUserContractor']
                                          ]
                                        };
                                        DatabaseMethods().createChatRoom(
                                            chatRoomId, chatRoomInfoMap);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatScreen(
                                                      value.docs[0].data()[
                                                          'uidUserContractor'],
                                                    )));
                                      }
                                    });
                                  },
                                  child: Text('Написать подрядчику'))
                              : SizedBox(),
                          task[index].statusConfirm
                              ? TextButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection("tasks")
                                        .doc(task[index].uidTask)
                                        .collection('contractors')
                                        .snapshots()
                                        .single
                                        .then((value) {
                                      print(value);
                                      if (value.docs[0].data() != null) {
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(value.docs[0]
                                                .data()['uidUserContractor'])
                                            .get()
                                            .then((value) =>
                                                {launch(value.get('phone'))});
                                      }
                                    });
                                  },
                                  child: Text('Позвонить подрядчику'))
                              : SizedBox()
                        ]);
                      },
                      child: TasksUI(tasks: task[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
