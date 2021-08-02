import 'package:alaket_ios/enum/enum.dart';
import 'package:alaket_ios/routes/app_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CloudFirestore extends AppState {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  ConfirmationResult confirmationResult;
  User user;

  Future<User> getCurrentUser({context}) async {
    try {
      await Firebase.initializeApp();
      loading = true;
      user = _firebaseAuth.currentUser;
      if (user != null) {
        authStatus = AuthStatus.LOGGED_IN;
      } else {
        authStatus = AuthStatus.NOT_LOGGED_IN;
      }
      loading = false;
      return user;
    } catch (error) {
      loading = false;
      debugPrint(user.toString());
      debugPrint("ERROR");
      debugPrint(error.toString());
      authStatus = AuthStatus.NOT_LOGGED_IN;
      return null;
    }
  }
}
