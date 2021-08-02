import 'package:alaket_ios/enum/enum.dart';
import 'package:alaket_ios/home_fragment.dart';
import 'package:alaket_ios/requesters_tab_winget.dart';
import 'package:alaket_ios/routes/database.dart';
import 'package:alaket_ios/routes/start_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SplashPage extends StatefulWidget {
  static var routeName = '/loging_session';
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      timer();
    });
    super.initState();
  }

  void timer() async {
    Future.delayed(Duration(seconds: 1)).then((_) {
      var state = Provider.of<CloudFirestore>(context, listen: false);
      state.getCurrentUser(context: context);
    });
  }

  Widget _body() {
    var height = 95.0;
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Container(
          height: height,
          width: height,
          alignment: Alignment.center,
          child: Text(
            'Alaket',
            style: TextStyle(
                color: Colors.black, fontSize: 50, fontWeight: FontWeight.bold),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<CloudFirestore>(context);
    print(state.authStatus);
    return Scaffold(
        backgroundColor: Colors.white,
        body: state.authStatus == AuthStatus.NOT_DETERMINED
            ? _body()
            : state.authStatus == AuthStatus.LOGGED_IN
                ? Home()
                : OnBoarding());
  }
}
