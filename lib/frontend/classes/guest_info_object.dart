class GuestInfoObject {
  String authID;
  String username;
  bool paid;
  String paymentMethod;
  String plusOnes;
  String profilePicURL;
  int price;
  String FCMtoken;
  String instaUsername;
  String paymentDetails;
  String noteToHost;
  String status;

  // This is a class that creates an object for guests info returned for each guest on guest list on firestore

  GuestInfoObject({this.authID, this.FCMtoken, this.instaUsername, this.paymentDetails, this.noteToHost,this.status, this.profilePicURL, this.username, this.paid, this.paymentMethod, this.plusOnes, this.price});
}