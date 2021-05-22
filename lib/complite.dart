import 'package:flutter/material.dart';

class Compalite extends StatefulWidget {
  Compalite({Key key}) : super(key: key);

  @override
  _CompaliteState createState() => _CompaliteState();
}

class _CompaliteState extends State<Compalite> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[400],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            child: Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 84,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 25),
            child: Text(
              'Заявка успешно создана',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 25, left: 25, right: 25),
            child: Text(
              'Дождитесь пока вашу заявку одобрят',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 25),
            padding: EdgeInsets.symmetric(horizontal: 25),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), color: Colors.white),
            child: TextButton(
              child: Text(
                'Понятно',
                style: TextStyle(color: Colors.green[400], fontSize: 20),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          )
        ],
      ),
    );
  }
}
