import 'package:alaket_ios/all_task.dart';
import 'package:alaket_ios/my_texnika.dart';
import 'package:alaket_ios/tasks.dart';
import 'package:alaket_ios/utils/widgets/model_windows.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyListing extends StatefulWidget {
  MyListing({Key key}) : super(key: key);

  @override
  _MyListingState createState() => _MyListingState();
}

class _MyListingState extends State<MyListing> {
  @override
  Widget build(BuildContext context) {
    final tex = Provider.of<List<Texniks>>(context);
    return Column(
      children: [
        Expanded(
          child: tex.length == 0
              ? Center(
                  child: Container(
                    child: Text('Здесь будет список вашей техники'),
                  ),
                )
              : ListView.builder(
                  physics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  itemCount: tex.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        modelMain(context, [
                          TextButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser.uid)
                                    .collection('myTex')
                                    .doc(tex[index].uidTex)
                                    .delete();
                              },
                              child: Text('Удалить технику'))
                        ]);
                      },
                      child: MyTexnikUI(tex: tex[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class MyTexnikUI extends StatefulWidget {
  final Texniks tex;
  MyTexnikUI({Key key, this.tex}) : super(key: key);

  @override
  _MyTexnikUIState createState() => _MyTexnikUIState();
}

class _MyTexnikUIState extends State<MyTexnikUI> with TickerProviderStateMixin {
  Widget twoColumns(Widget one, Widget two) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [one, two],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Text(
              widget.tex.vehicle_type,
              style: TextStyle(fontSize: 20),
            ),
          ),
          twoColumns(
            Text('Описание: '),
            Text(widget.tex.description != ''
                ? widget.tex.description
                : 'Нет описания'),
          ),
        ],
      ),
    );
  }
}
