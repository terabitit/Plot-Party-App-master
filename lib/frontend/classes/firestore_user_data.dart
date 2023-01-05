class FirestoreUserData {
  String dateJoined;
  String phoneNumber;
  String username;
  String uuid;
  String FCMtoken;
  String plotCode;
  String profilePicURL;
  int unreadMessages;
  bool approved;
  bool joinedPlot;

  // this class creates an object for the user data returned by firestore a

  FirestoreUserData({this.dateJoined,this.profilePicURL, this.unreadMessages, this.FCMtoken, this.phoneNumber, this.username, this.uuid, this.joinedPlot, this.approved, this.plotCode});
}