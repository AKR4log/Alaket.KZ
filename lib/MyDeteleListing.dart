import 'package:alaket_ios/ApplyTasksUI.dart';
import 'package:alaket_ios/all_task.dart';
import 'package:alaket_ios/chat.dart';
import 'package:alaket_ios/data.dart';
import 'package:alaket_ios/delTask.dart';
import 'package:alaket_ios/state/feedState.dart';
import 'package:alaket_ios/tasks.dart';
import 'package:alaket_ios/utils/widgets/model_windows.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDeteleListing extends StatefulWidget {
  MyDeteleListing({Key key}) : super(key: key);

  @override
  _MyDeteleListingState createState() => _MyDeteleListingState();
}

class _MyDeteleListingState extends State<MyDeteleListing> {
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
                                    .update({"statusDel": false});
                                Navigator.pop(context);
                              },
                              child: Text('Восстановить'))
                        ]);
                      },
                      child: DelTasksUI(tasks: task[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
