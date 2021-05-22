import 'package:alaket_ios/MyListing.dart';
import 'package:alaket_ios/creatMyTex.dart';
import 'package:alaket_ios/myCatTex.dart';
import 'package:alaket_ios/state/feedState.dart';
import 'package:alaket_ios/utils/widgets/model_windows.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyTex extends StatefulWidget {
  MyTex({
    Key key,
  }) : super(key: key);

  @override
  _MyTexState createState() => _MyTexState();
}

class _MyTexState extends State<MyTex> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Container(
        height: 55,
        width: 55,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(55),
            color: Colors.white,
            border: Border.all(width: 1.5, color: Colors.black)),
        child: TextButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => CreateMyTex()));
            },
            child: Icon(
              Icons.car_rental,
              color: Colors.black,
            )),
      ),
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        title: Text(
          'Моя техника',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: StreamProvider<List<Texniks>>.value(
        value: FeedState().myTexnika,
        child: MyListing(),
      ),
    );
  }
}

class Texniks {
  final String description;
  final String vehicle_type;
  final String timeCreated;
  final String uidTex;
  final String uidUser;
  Texniks(
      {this.description,
      this.timeCreated,
      this.uidTex,
      this.vehicle_type,
      this.uidUser});
}
