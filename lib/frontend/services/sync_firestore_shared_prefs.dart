import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/firestore_user_data.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';

class SyncService {
  // syncs shared preferences and cloud data .
  Future<void> syncSharedPrefsWithFirestore({String authID}) async {
    SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
    FirestoreFunctions firestoreFunctions = FirestoreFunctions();
    FirestoreUserData userData = await firestoreFunctions.makeUserObject(authID);
    await sharedPrefsServices.setAll(joinedPlot: userData.joinedPlot,
        authID: userData.uuid,
        username: userData.username,
        phoneNumber: userData.phoneNumber,
        FCMtoken: userData.FCMtoken,
        plotCode: userData.plotCode,
        approved: userData.approved);
    print("Synced");
  }
}