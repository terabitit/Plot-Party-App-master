class SharedPrefData {
  String authID;
  String username;
  bool joinedPlot;
  String phoneNumber;
  bool approved;
  String FCMtoken;
  String plotCode;

  // This class creates an object for the shared preferences data

  // when creating another shared pref key, you have to make sure to update shared_pref_service, firestore_functions, and sync_firestore_shared_prefs to account for the update
  // cont: update make User method for shared Prefs and firestore, and go to register and login page to make sure they account for the change

  SharedPrefData({this.authID, this.username, this.FCMtoken, this.approved, this.joinedPlot, this.phoneNumber, this.plotCode});
}