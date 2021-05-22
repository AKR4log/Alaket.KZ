import 'package:alaket_ios/all_task.dart';
import 'package:alaket_ios/my_texnika.dart';
import 'package:alaket_ios/search_page.dart';
import 'package:alaket_ios/state/appState.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedState extends AppState {
  final List<String> type_tex;
  FeedState({this.type_tex});
  List<Tasks> _loadAllTasks(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Tasks(
          cash: doc.get('cash') ?? '',
          description: doc.get('description') ?? '',
          time: doc.get('time') ?? '',
          uidTask: doc.get('uidTask') ?? '',
          statusConfirm: doc.get('statusConfirm') ?? false,
          timeCreated: doc.get('timeCreated') ?? '',
          statusDel: doc.get('statusDel') ?? false,
          image: doc.get('image') ?? '',
          type_cash: doc.get('type_cash') ?? '',
          lat: doc.get('lat') ?? '',
          lng: doc.get('lng') ?? '',
          vehicle_type: doc.get('vehicle_type') ?? '',
          uidUser: doc.get('uidUser') ?? '');
    }).toList();
  }

  Stream<List<Tasks>> get allTaskApplications {
    return FirebaseFirestore.instance
        .collection('tasks')
        .orderBy('timeCreated', descending: true)
        .where("statusConfirm", isEqualTo: false)
        .where('vehicle_type', whereIn: type_tex)
        .snapshots()
        .map(_loadAllTasks);
  }

  List<Contract> _loadAllContract(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Contract(
          uidContract: doc.get('uidContract') ?? '',
          uidTask: doc.get('uidTask') ?? '',
          uidUserContractor: doc.get('uidUserContractor') ?? '');
    }).toList();
  }

  Stream<List<Tasks>> get allMarketApplications {
    return FirebaseFirestore.instance
        .collection('tasks')
        .orderBy('timeCreated', descending: true)
        .where("statusConfirm", isEqualTo: false)
        .snapshots()
        .map(_loadAllTasks);
  }

  Stream<List<Tasks>> get allMyTaskApplications {
    return FirebaseFirestore.instance
        .collection('tasks')
        .orderBy('timeCreated', descending: true)
        .where("statusDel", isEqualTo: false)
        .where("uidUser", isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .snapshots()
        .map(_loadAllTasks);
  }

  Stream<List<Tasks>> get allMyDeteleTaskApplications {
    return FirebaseFirestore.instance
        .collection('tasks')
        .orderBy('timeCreated', descending: true)
        .where("uidUser", isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .where("statusDel", isEqualTo: true)
        .snapshots()
        .map(_loadAllTasks);
  }

  Stream<List<Contract>> get allMyApplyTaskApplications {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('contract')
        .snapshots()
        .map(_loadAllContract);
  }

  List<Texniks> _loadMyTexnik(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Texniks(
          uidUser: doc.get('uidUser') ?? '',
          timeCreated: doc.get('timeCreated') ?? '',
          vehicle_type: doc.get('vehicle_type') ?? '',
          uidTex: doc.get('uidTex') ?? '',
          description: doc.get('description') ?? '');
    }).toList();
  }

  Stream<List<Texniks>> get myTexnika {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('myTex')
        .orderBy('timeCreated', descending: true)
        .snapshots()
        .map(_loadMyTexnik);
  }
}

class Contract {
  final String uidContract;
  final String uidTask;
  final String uidUserContractor;
  Contract({this.uidContract, this.uidTask, this.uidUserContractor});
}
