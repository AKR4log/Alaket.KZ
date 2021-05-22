import 'dart:convert';

import 'package:alaket_ios/all_task.dart';
import 'package:alaket_ios/chat.dart';
import 'package:alaket_ios/data.dart';
import 'package:alaket_ios/tasks.dart';
import 'package:alaket_ios/utils/widgets/model_windows.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class Listing extends StatefulWidget {
  Listing({Key key}) : super(key: key);

  @override
  _ListingState createState() => _ListingState();
}

class _ListingState extends State<Listing> {
  @override
  Widget build(BuildContext context) {
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

    createPush(body, uid) async {
      var bodys = {
        'notification': {
          'body': 'Ваша заяка принята подрядчиком',
          'title': 'Ваш заказ принят'
        },
        'priority': 'high',
        'data': {
          'clickaction': 'FLUTTERNOTIFICATIONCLICK',
          'id': '1',
          'status': 'done'
        },
        'to': '/topics/alaket-$uid'
      };
      print(jsonEncode(bodys));
      await http.post('https://fcm.googleapis.com/fcm/send',
          body: jsonEncode(bodys),
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAAvfSzX6c:APA91bF8VFTWSPk4V7w59tYe_-AyY1_f6Hw-rI_C_VYRpO1DBPEqz1DSVH4iNBPcqRGXWhMMMeacC3afotfbu5LLUbRGl4HMAfo5WTQ1g-wVZ86e9FzOIHoPnP4cUoAByEn05aCnEl3a',
          }).then((response) {
        if (response.statusCode == 201) {
          print(response.body);
        } else {
          throw Exception('Failed auth');
        }
      });
    }

    final task = Provider.of<List<Tasks>>(context);
    return Column(
      children: [
        Expanded(
          child: task.length == 0
              ? Center(child: Text('Заявок нет('))
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
                                var uidContract = Uuid().v4();
                                FirebaseFirestore.instance
                                    .collection("tasks")
                                    .doc(task[index].uidTask)
                                    .collection('contractors')
                                    .doc(uidContract)
                                    .set({
                                  "uidUserContractor":
                                      FirebaseAuth.instance.currentUser.uid,
                                  "uidContract": uidContract
                                });
                                FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(
                                      FirebaseAuth.instance.currentUser.uid,
                                    )
                                    .collection('contract')
                                    .doc(uidContract)
                                    .set({
                                  "uidUserContractor":
                                      FirebaseAuth.instance.currentUser.uid,
                                  "uidContract": uidContract,
                                  "uidTask": task[index].uidTask
                                });
                                FirebaseFirestore.instance
                                    .collection("tasks")
                                    .doc(task[index].uidTask)
                                    .update({"statusConfirm": true});
                                createPush(
                                    'Ваш заказ принят', task[index].uidUser);
                                Navigator.pop(context);
                              },
                              child: Text('Принять заказ')),
                          TextButton(
                              onPressed: () {
                                var chatRoomId = getChatRoomIdByUsernames(
                                  FirebaseAuth.instance.currentUser.uid,
                                  task[index].uidUser,
                                );
                                Map<String, dynamic> chatRoomInfoMap = {
                                  "users": [
                                    FirebaseAuth.instance.currentUser.uid,
                                    task[index].uidUser
                                  ]
                                };
                                DatabaseMethods().createChatRoom(
                                    chatRoomId, chatRoomInfoMap);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                              task[index].uidUser,
                                            )));
                              },
                              child: Text('Написать сообщение')),
                          TextButton(
                              onPressed: () {
                                openMap(task[index].lat, task[index].lng);
                              },
                              child: Text('Отследить заказ'))
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
