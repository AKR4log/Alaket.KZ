import 'package:alaket_ios/routes/database.dart';
import 'package:alaket_ios/routes/routes.dart';
import 'package:alaket_ios/state/appState.dart';
import 'package:alaket_ios/state/feedState.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:alaket_ios/home_fragment.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AppState>(create: (_) => AppState()),
          ChangeNotifierProvider<CloudFirestore>(
              create: (_) => CloudFirestore()),
          ChangeNotifierProvider<FeedState>(create: (_) => FeedState()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          routes: Routes.route(),
          onGenerateRoute: (settings) => Routes.onGenerateRoute(settings),
          initialRoute: "SplashPage",
        ));
  }
}
