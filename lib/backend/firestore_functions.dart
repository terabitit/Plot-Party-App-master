import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:plots/frontend/classes/firestore_plot_data.dart';
import 'package:plots/frontend/classes/firestore_user_data.dart';
import 'package:plots/frontend/classes/guest_info_object.dart';
import 'package:plots/frontend/classes/third_party_plot_data.dart';
import 'package:plots/frontend/services/distance_calculator.dart';

class FirestoreFunctions {
  // methods for firestore functions, queries, get requests, updates, writes to firebase cloud
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot<Map<String, dynamic>>> getPlots() async {
    return await _firestore.collection('plots').get();
  }

  Future<bool> checkIfUsernameExists(String username) async{
    var result = await _firestore.collection('appData').doc('records').get();
    if (result.data()['usernames'].contains(username)){
      return true;
    }
    return false;
  }

  Future<bool> checkIfHighlightedPlots() async{
    var result = await _firestore.collection('highlights').get();
    if (result.docs.length == 0){
      return false;
    }
    return true;
  }

  Future<void> writeUsernameRecord(String username) async{
    var result = await _firestore.collection('appData').doc('records').get();
    var tempList = []..addAll(result.data()['usernames']);
    tempList.add(username);
    await _firestore.collection('appData').doc('records').update({'usernames': tempList});
  }

  Future<void> writeBugReport({String authID, String dateWritten, String bug}) async{
    await _firestore.collection('bugs').doc(authID+dateWritten).set({
      'authID': authID,
      'dateWritten': dateWritten,
      'bug': bug,
      'resolved': false,
    }).catchError((onError) => print(onError.toString()));
  }

  Future<void> writePhoneNumberRecord(String phoneNumber) async{
    var result = await _firestore.collection('appData').doc('records').get();
    var tempList = []..addAll(result.data()['phoneNumbers']);
    tempList.add(phoneNumber);
    await _firestore.collection('appData').doc('records').update({'phoneNumbers': tempList});
  }

  Future<List> getSecurityList (String plotCode) async {
    var result = await _firestore.collection('plots').doc(plotCode).get();
    return result['security'];
  }

  void addSecurity(String plotCode, String username) async{
    var result = await _firestore.collection('plots').doc(plotCode).get();
    var tempList = []..addAll(result.data()['security']);
    tempList.add(username);
    await _firestore.collection('plots').doc(plotCode).update({'security': tempList});
  }

  void removeSecurity(String plotCode, String username) async{
    var result = await _firestore.collection('plots').doc(plotCode).get();
    var tempList = []..addAll(result.data()['security']);
    tempList.remove(username);
    await _firestore.collection('plots').doc(plotCode).update({'security': tempList});
  }

  void addAnnouncement(String plotCode, String announcement) async{
    var result = await _firestore.collection('plots').doc(plotCode).get();
    var tempList = []..addAll(result.data()['announcements']);
    tempList.add(announcement);
    await _firestore.collection('plots').doc(plotCode).update({'announcements': tempList});
  }




  Future<void> newApproveRequest({String authID,String instaUsername, String username, String FCMtoken, String noteToHost, int price, String plusOnes,String paymentDetails, String profilePicURL, String paymentMethod, String plotCode, String status}) async{
    var result = await _firestore.collection('plots').doc(plotCode).get();
    var tempList = []..addAll(result.data()['attendRequests']);
    tempList.add({
      'username': username,
      'authID': authID,
      'FCMtoken': FCMtoken,
      'instaUsername': instaUsername,
      'paymentDetails': paymentDetails,
      'price': price,
      'paid': false,
      'noteToHost': noteToHost,
      'plusOnes': plusOnes,
      'status': status,
      'profilePicURL': profilePicURL,
      'paymentMethod': paymentMethod,
    });
    await _firestore.collection('plots').doc(plotCode).update({'attendRequests': tempList});
  }


  Future<void> newMessageForHost({String authID, String profilePicURL, String username, String FCMtoken,String lastMessage,  String plotCode}) async{
    bool messageExists = false;
    var result = await _firestore.collection('plots').doc(plotCode).get();
    List currMessages = []..addAll(result.data()['unreadMessages']);
    for (var i = 0; i < currMessages.length; i++) {
      if (currMessages[i]['authID'] == authID) {
        messageExists = true;
      }
    }
    if (messageExists){
      for (var i = 0; i < currMessages.length; i++) {
        if (currMessages[i]['authID'] == authID) {
          currMessages[i]['lastMessage'] = lastMessage;
          currMessages[i]['numUnread'] += 1;
        }
      }
    } else {
      currMessages.add({
        'username': username,
        'authID': authID,
        'FCMtoken': FCMtoken,
        'profilePicURL': profilePicURL,
        'numUnread': 1,
        'lastMessage': lastMessage,
        // I ahve to change FCM token if changes device for unread Messages
      });
    }
    await _firestore.collection('plots').doc(plotCode).update({'unreadMessages': currMessages});
  }

  Future<void> updateMessageInfo({String plotCode, String authID, String field, dynamic newValue})async{
    var resPlots = await _firestore.collection('plots').doc(plotCode).get();
    List currMessages = []..addAll(resPlots.data()['unreadMessages']);
    for (var i = 0; i < currMessages.length; i++) {
      if (currMessages[i]['authID'] == authID) {
        currMessages[i][field] = newValue;
      }
    }
    await _firestore.collection('plots')
        .doc(plotCode)
        .update({
      'unreadMessages': currMessages,
    });
  }


  Future<int> getTotalUnread({String plotCode})async{
    int total = 0;
    var resPlots = await _firestore.collection('plots').doc(plotCode).get();
    List currMessages = []..addAll(resPlots.data()['unreadMessages']);
    for (var i = 0; i < currMessages.length; i++) {
        total += currMessages[i]['numUnread'];
    }
    return total;
  }


  Future<String> getUsernameFromAuthID(String authID) async {
    var result = await _firestore.collection('users').doc(authID).get();
    return result['username'];
  }
  Future<int> getUnreadMessagesFromAuthID(String authID) async {
    var result = await _firestore.collection('users').doc(authID).get();
    return result['unreadMessages'];
  }

  Future<List> getSearchInfo () async {
    var result = await _firestore.collection('plots').where("closed", isEqualTo: false).where("plotPrivacy", isEqualTo: 'open invite').get();
    List searchInfo = [];
    result.docs.forEach((element) {
      Timestamp time = element['startDate']; //from firebase
      DateTime newTime = DateTime.fromMicrosecondsSinceEpoch(time.microsecondsSinceEpoch);
      searchInfo.add({
        'plotName': element['plotName'],
        'flyerURL': element['flyerURL'],
        'plotCode': element['plotCode'],
        'hostName': element['hostName'],
        'startDate': newTime,
      });
    });
    return searchInfo;
  }


  Future<String> getProfilePicURLFromAuthID (String authID) async {
    var result = await _firestore.collection('users').doc(authID).get();
    return result['profilePicURL'];
  }

  Future<int> getLitness () async {
    Location location = new Location();
    LocationData _locationData = await location.getLocation();
    int lit = 0;
    var result = await _firestore.collection('plots').get();
    result.docs.forEach((element) {
      if (!element['closed']){
        if(getDist(_locationData.latitude, _locationData.longitude, element['lat'], element['long'], getMiles(160934))){
          lit += 1;
        }
      }
    });
    return lit;
  }


  Future<void> incrementUnreadMessages (String authID) async {
    int unreadMessages = await getUnreadMessagesFromAuthID(authID);
    await _firestore.collection('users').doc(authID).update({
      'unreadMessages': unreadMessages + 1
    });
  }

  Future<void> resetUnreadMessages (String authID) async {
    int unreadMessages = await getUnreadMessagesFromAuthID(authID);
    await _firestore.collection('users').doc(authID).update({
      'unreadMessages': 0
    });
  }

  Future<String> getHostFCMTokenFromPlotCode (String plotCode) async {
    var result = await _firestore.collection('plots').doc(plotCode).get();
    return result['hostFCMtoken'];
  }

  Future<List> getGuestListFromPlotCode (String plotCode) async {
    var result = await _firestore.collection('plots').doc(plotCode).get();
    return result['guests'];
  }

  void updateProfit (String plotCode, int price) async {
    var result = await _firestore.collection('plots').doc(plotCode).get();
    int currProfit = result['profit'];
    await _firestore.collection('plots').doc(plotCode).update({
      'profit': currProfit + price
    });
  }
  void updateExpectedAmountAtDoor (String plotCode, int price) async {
    var result = await _firestore.collection('plots').doc(plotCode).get();
    int currExpectedAmountAtDoor = result['expectedAmountAtDoor'];
    await _firestore.collection('plots').doc(plotCode).update({
      'expectedAmountAtDoor': currExpectedAmountAtDoor + price
    });
  }

  Future<List> getAnnouncementsFromPlotCode (String plotCode) async {
    var result = await _firestore.collection('plots').doc(plotCode).get();
    return result['announcements'];
  }

  Future<String> getPlotPrivacyFromPlotCode (String plotCode) async {
    var result = await _firestore.collection('plots').doc(plotCode).get();
    return result['plotPrivacy'];
  }

  Future<String> getPlotNameFromPlotCode (String plotCode) async {
    var result = await _firestore.collection('plots').doc(plotCode).get();
    return result['plotName'];
  }

  Future<String> getFlyerURLFromPlotCode (String plotCode) async {
    var result = await _firestore.collection('plots').doc(plotCode).get();
    return result['flyerURL'];
  }

  Future<String> getHostAuthID (String plotCode) async {
    var result = await _firestore.collection('plots').doc(plotCode).get();
    return result['hostAuthID'];
  }


  Future<List> getAttendRequestsFromPlotCode (String plotCode) async {
    var result = await _firestore.collection('plots').doc(plotCode).get();
    return result['attendRequests'];
  }

  Future<bool> checkIfGuestExists(String plotCode, String authID)async{
    bool exists = false;
    var userData = await _firestore.collection('plots').doc(plotCode).get();
    List guestList = userData.data()['guests'];
    guestList.forEach((element) {
      if (element['authID'] == authID){
        exists = true;
      }
    });
    return exists;
  }

  Future<bool> checkIfAttendRequestExists(String plotCode, String authID)async{
    bool exists = false;
    var userData = await _firestore.collection('plots').doc(plotCode).get();
    List attendRequest = userData.data()['attendRequests'];
    attendRequest.forEach((element) {
      if (element['authID'] == authID){
        exists = true;
      }
    });
    return exists;

  }



  Future<GuestInfoObject> makeGuestObjectFromUsername(String plotCode, String username) async{
    var userData = await _firestore.collection('plots').doc(plotCode).get();
    List guestList = userData.data()['guests'];
    GuestInfoObject guestInfoObject;
    guestList.forEach((element) {
      if (element['username'] == username){
        guestInfoObject = GuestInfoObject(
            authID: element['authID'],
        paymentDetails: element['paymentDetails'],
        status: element['status'],
        noteToHost: element['noteToHost'],
        paid: element['paid'],
        FCMtoken: element['FCMtoken'],
        instaUsername: element['instaUsername'],
        username: element['username'],
        paymentMethod: element['paymentMethod'],
        plusOnes: element['plusOnes'],
        profilePicURL: element['profilePicURL'],
        price: element['price']
        );
      }
    });
    return guestInfoObject;
  }

  void closePlot(String plotCode) async {
    var result = await _firestore.collection('plots').doc(plotCode).get();
    List guests = result['guests'];
    List attendRequests = result['attendRequests'];
    updatePlotsInfo(plotCode: plotCode, field: 'closed', newValue: true);
    guests.forEach((element) {
      updateUserInfo(authID: element['authID'], fields: ['approved', 'joinedPlot', 'plotCode'], newValues:[false, false, 'none'] );
    });
    attendRequests.forEach((element) {
      updateUserInfo(authID: element['authID'], fields: ['approved', 'joinedPlot', 'plotCode'], newValues:[false, false, 'none'] );

    });
  }

  Future<GuestInfoObject> makeGuestObjectFromAuthID(String plotCode, String authID) async{
    var userData = await _firestore.collection('plots').doc(plotCode).get();
    List guestList = userData.data()['guests'];
    GuestInfoObject guestInfoObject;
    guestList.forEach((element) {
      if (element['authID'] == authID){
        guestInfoObject = GuestInfoObject(
            authID: element['authID'],
            paid: element['paid'],
            paymentDetails: element['paymentDetails'],
            instaUsername: element['instaUsername'],
            status: element['status'],
            FCMtoken: element['FCMtoken'],
            noteToHost: element['noteToHost'],
            username: element['username'],
            paymentMethod: element['paymentMethod'],
            plusOnes: element['plusOnes'],
            profilePicURL: element['profilePicURL'],
            price: element['price']
        );
      }
    });
    return guestInfoObject;
  }

  Future<GuestInfoObject> makeAttendRequestObjectFromAuthID(String plotCode, String authID) async{
    var userData = await _firestore.collection('plots').doc(plotCode).get();
    List guestList = userData.data()['attendRequests'];
    GuestInfoObject guestInfoObject;
    guestList.forEach((element) {
      if (element['authID'] == authID){
        guestInfoObject = GuestInfoObject(
            authID: element['authID'],
            paid: element['paid'],
            paymentDetails: element['paymentDetails'],
            instaUsername: element['instaUsername'],
            status: element['status'],
            noteToHost: element['noteToHost'],
            FCMtoken: element['FCMtoken'],
            username: element['username'],
            paymentMethod: element['paymentMethod'],
            plusOnes: element['plusOnes'],
            profilePicURL: element['profilePicURL'],
            price: element['price']
        );
      }
    });
    return guestInfoObject;
  }



  Future<FirestoreUserData> makeUserObject(String authID) async{
    var userData = await _firestore.collection('users').doc(authID).get();
    return FirestoreUserData(
        phoneNumber: userData['phoneNumber'],
        plotCode: userData['plotCode'],
        joinedPlot: userData['joinedPlot'],
        dateJoined: userData['dateJoined'],
        username: userData['username'],
        unreadMessages: userData['unreadMessages'],
        FCMtoken: userData['FCMtoken'],
        approved: userData['approved'],
        profilePicURL: userData['profilePicURL'],
        uuid: userData['uuid']);
  }

  Future<FirestorePlotData> makePlotObject(String plotCode) async{
    var plotData = await _firestore.collection('plots').doc(plotCode).get();
    Timestamp time = plotData['startDate']; //from firebase
    DateTime newTime = DateTime.fromMicrosecondsSinceEpoch(time.microsecondsSinceEpoch);
    return FirestorePlotData(
      flyerURL: plotData['flyerURL'],
      plotCode: plotData['plotCode'],
      closed: plotData['closed'],
      guests: plotData['guests'],
      hostName: plotData['hostName'],
      security: plotData['security'],
      announcements: plotData['announcements'],
      contactDetails: plotData['contactDetails'],
      plotAddress: plotData['plotAddress'],
      hostAuthID: plotData['hostAuthID'],
      plotName: plotData['plotName'],
      plotPrivacy: plotData['plotPrivacy'],
      unreadMessages: plotData['unreadMessages'],
      hostFCMtoken: plotData['hostFCMtoken'],
      minimumBidPrice: plotData['minimumBidPrice'],
      canBid:  plotData['canBid'],
      lat: plotData['lat'].toDouble(),
      long: plotData['long'].toDouble(),
      attendRequests: plotData['attendRequests'],
      description: plotData['description'],
      expectedAmountAtDoor: plotData['expectedAmountAtDoor'],
      profit: plotData['profit'],
      free: plotData['free'],
      ticketLevelsAndPrices: plotData['ticketLevelsAndPrices'],
      paymentMethods: plotData['paymentMethods'],
      startDate: newTime,
    );
  }
  Future<List<ThirdPartyPlotData>> makeThirdPartyPlotsObject() async{
    List<ThirdPartyPlotData> thirdPartyPlotDataList = [];
    var thirdPartyPlotData = await _firestore.collection('thirdPartyPlots').get();
    thirdPartyPlotData.docs.forEach((element) {
      Timestamp time = element.data()['date']; //from firebase
      DateTime newTime = DateTime.fromMicrosecondsSinceEpoch(time.microsecondsSinceEpoch);
      Timestamp timeCreated = element.data()['dateCreated']; //from firebase
      DateTime newTimeCreated = DateTime.fromMicrosecondsSinceEpoch(timeCreated.microsecondsSinceEpoch);
      thirdPartyPlotDataList.add(ThirdPartyPlotData(
        addy: element.data()['addy'],
        title: element.data()['title'],
        addyProvided: element.data()['addyProvided'],
        date: newTime,
        closed: element.data()['closed'],
        dateCreated: newTimeCreated,
        contactInfo: element.data()['contactInfo'],
        price: element.data()['price'],
        likes: element.data()['likes'],
        dislikes: element.data()['dislikes'],
        instagramUsername: element.data()['instagramUsername'],
        picture: element.data()['picture'],
        description: element.data()['description'],
        id: element.data()['id'],
        lat: element.data()['lat'],
        long: element.data()['long']
      ));
    });
    return thirdPartyPlotDataList;
  }

  Future<void> removeThirdPartyPlot(String id) async{
    await _firestore.collection('thirdPartyPlots').doc(id).delete();
  }

  Future<void> newFieldForPlotsData({String fieldName, dynamic startingVal})async{
    var plotData = await _firestore.collection('plots').get();
    plotData.docs.forEach((element) async{
      await _firestore.collection('plots').doc(element['plotCode']).update({
        fieldName: startingVal
      });
    }
    );
  }

  Future<bool> isHost (String username, String plotCode) async{
    var plotData = await _firestore.collection('plots').doc(plotCode).get();
    if (plotData.data()['originalHostName'] == username){
      return true;
    }
    return false;
  }

  Future<bool> isSecurity (String username, String plotCode) async{
    var plotData = await _firestore.collection('plots').doc(plotCode).get();
    if (plotData.data()['security'].contains(username)){
      return true;
    }
    return false;
  }


  Future<void> updateUserInfo({String authID, List<String> fields, List newValues})async {
    Map<String, dynamic> updateMap = {};
    for (var i = 0; i < fields.length; i++){
      updateMap[fields[i]] = newValues[i];
    }
    await _firestore.collection('users').doc(authID).update(updateMap);
  }

  Future<void> updateGuestInfo({String plotCode, String authID, String field, dynamic newValue})async{
    var resPlots = await _firestore.collection('plots').doc(plotCode).get();
    List currGuests = []..addAll(resPlots.data()['guests']);
    for (var i = 0; i < currGuests.length; i++) {
      if (currGuests[i]['authID'] == authID) {
        currGuests[i][field] = newValue;
      }
    }
    await _firestore.collection('plots')
        .doc(plotCode)
        .update({
      'guests': currGuests,
    });

  }

  Future<void> updateAttendRequestInfo({String plotCode, String authID, String field, dynamic newValue})async{
    var resPlots = await _firestore.collection('plots').doc(plotCode).get();
    List currRequests = []..addAll(resPlots.data()['attendRequests']);
    for (var i = 0; i < currRequests.length; i++) {
      if (currRequests[i]['authID'] == authID) {
        currRequests[i][field] = newValue;
      }
    }
    await _firestore.collection('plots')
        .doc(plotCode)
        .update({
      'attendRequests': currRequests,
    });

  }



  void updatePlotsInfo({String plotCode, String field, dynamic newValue}) async{
    switch (field) {
      case 'flyerURL':
        await _firestore.collection('plots').doc(plotCode).update({
          'flyerURL': newValue,
        });
        break;
      case 'hostFCMtoken':
        await _firestore.collection('plots').doc(plotCode).update({
          'hostFCMtoken': newValue,
        });
        break;
      case 'signature':
        await _firestore.collection('plots').doc(plotCode).update({
          'signature': newValue,
        });
        break;
      case 'hostName':
        await _firestore.collection('plots').doc(plotCode).update({
          'hostName': newValue,
        });
        break;
      case 'contactDetails':
        await _firestore.collection('plots').doc(plotCode).update({
          'contactDetails': newValue,
        });
        break;
        case 'attendRequests':
          await _firestore.collection('plots').doc(plotCode).update({
            'attendRequests': newValue,
          });
          break;
      case 'closed':
        await _firestore.collection('plots').doc(plotCode).update({
          'closed': newValue,
        });
        break;
      case 'description':
        await _firestore.collection('plots').doc(plotCode).update({
          'description': newValue,
        });
        break;
      case 'guests':
        await _firestore.collection('plots').doc(plotCode).update({
          'guests': newValue,
        });
        break;
      case 'hostName':
        await _firestore.collection('plots').doc(plotCode).update({
          'hostName': newValue,
        });
        break;
    case 'location':
      await _firestore.collection('plots').doc(plotCode).update({
        'location': newValue,
      });
    break;
    case 'plotName':
      await _firestore.collection('plots').doc(plotCode).update({
        'plotName': newValue,
      });
      break;
    case 'plotPrivacy':
      await _firestore.collection('plots').doc(plotCode).update({
        'plotPrivacy': newValue,
      });
      break;
    case 'minimumBidPrice':
      await _firestore.collection('plots').doc(plotCode).update({
        'minimumBidPrice': newValue,
      });
      break;
      case 'canBid':
        await _firestore.collection('plots').doc(plotCode).update({
          'canBid': newValue,
        });
        break;
    case 'security':
      await _firestore.collection('plots').doc(plotCode).update({
        'security': newValue,
      });
      break;
    case 'startDate':
      await _firestore.collection('plots').doc(plotCode).update({
        'startDate': newValue,
      });
      break;
      default:
        print('error');
    }
  }
}
