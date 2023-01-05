class FirestorePlotData {
  String plotCode;
  bool closed;
  List guests;
  String hostName;
  String hostAuthID;
  List attendRequests;
  String contactDetails;
  String plotName;
  String plotPrivacy;
  String description;
  String hostFCMtoken;
  int minimumBidPrice;
  List unreadMessages;
  double lat;
  String plotAddress;
  double long;
  String flyerURL;
  DateTime startDate;
  bool canBid;
  List announcements;
  List security;
  Map ticketLevelsAndPrices;
  Map paymentMethods;
  int profit;
  bool free;
  int expectedAmountAtDoor;

  // total amount made
  // free
  // amount owed from pay at Door

  // this class creates an object for plot data returned by firestore

  FirestorePlotData({this.plotCode,
    this.announcements,
    this.flyerURL,
    this.free,
    this.expectedAmountAtDoor,
    this.profit,
    this.security,
    this.attendRequests,
    this.lat,this.long,
    this.unreadMessages,
    this.closed,
    this.hostAuthID,
    this.hostFCMtoken,
    this.description,
    this.guests,
    this.hostName,this.plotAddress,
    this.contactDetails, this.plotName,
    this.plotPrivacy,
    this.minimumBidPrice,
    this.canBid,
    this.startDate,
    this.ticketLevelsAndPrices,
    this.paymentMethods
  });
}
