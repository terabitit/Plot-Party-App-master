import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsServices {

  // service for shared preferences, a plugin that allows one to access local storage
  Future<bool> isFirstTimeDownload () async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = await prefs.getBool('firstTimeDownload');
    if(isFirstTime == null) {
      await prefs.setBool('firstTimeDownload', false);
          return true;
    }
    return false;
  }

  Future<bool> isFirstTimeEnter () async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime =  prefs.getBool('firstTimeEnter');
    if(isFirstTime == null) {
      await prefs.setBool('firstTimeEnter', false);
      return true;
    }
    return false;
  }

 // Introduction Screens for Guest, Security, Host, First Time

  Future<bool> isFirstTimeGuest() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime =  prefs.getBool('firstTimeGuest');
    if(isFirstTime == null) {
      await prefs.setBool('firstTimeGuest', false);
      return true;
    }
    return false;
  }

  Future<bool> isFirstTimeSecurity () async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime =  prefs.getBool('firstTimeSecurity');
    if(isFirstTime == null) {
      await prefs.setBool('firstTimeSecurity', false);
      return true;
    }
    return false;
  }
  Future<bool> isFirstTimeHost () async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime =  prefs.getBool('firstTimeHost');
    if(isFirstTime == null) {
      await prefs.setBool('firstTimeHost', false);
      return true;
    }
    return false;
  }
  Future<bool> isFirstTimeWaitingForApproval () async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime =  prefs.getBool('firstTimeWaitingForApproval');
    if(isFirstTime == null) {
      await prefs.setBool('firstTimeWaitingForApproval', false);
      return true;
    }
    return false;
  }

  Future<void> setAuthID (String authID) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('authID', authID);
  }

  Future<String> getAuthID () async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authID = prefs.getString('authID');
    return authID;
  }



  Future<void> setUsername (String username) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  Future<String> getUsername () async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username');
    return username;
  }

  Future<void> setFCMNotificationToken (String token) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('FCMtoken', token);
  }

  Future<String> getFCMNotificationToken () async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('FCMtoken');
    if(token == null) {
      await prefs.setString('FCMtoken', 'none');
      return token;
    }
    return token;
  }

  Future<void> setPhoneNumber (String phoneNumber) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNumber', phoneNumber);
  }


  Future<String> getPhoneNumber () async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phoneNumber = prefs.getString('phoneNumber');
    return phoneNumber;
  }

  Future<void> setPlotCode (String plotCode) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('plotCode', plotCode);
  }

  Future<String> getPlotCode () async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String plotCode = prefs.getString('plotCode');
    return plotCode;
  }

  Future<void> setPlotStatusJoined () async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('joinedPlot', true);
  }

  Future<void> setPlotStatusNotJoined () async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('joinedPlot', false);
  }

  Future<void> setUserApprovedStatus () async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('approved', true);
  }

  Future<void> setUserNotApprovedStatus () async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('approved', false);
  }

  Future<bool> getInPlotStatus() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool inPlotStatus = prefs.getBool('joinedPlot');
    return inPlotStatus;
  }

  Future<SharedPrefData> makeUserObject() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return SharedPrefData(phoneNumber: prefs.getString('phoneNumber'), FCMtoken: prefs.getString('FCMtoken'), authID: prefs.getString('authID'), joinedPlot: prefs.getBool('joinedPlot'), plotCode: prefs.getString('plotCode'), username: prefs.getString('username'), approved: prefs.getBool('approved'));
  }

  Future<void> setAll ({bool joinedPlot, String authID,String FCMtoken, String username, String phoneNumber, String plotCode, bool approved })async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('joinedPlot', joinedPlot);
    await prefs.setString('username', username);
    await prefs.setString('phoneNumber', phoneNumber);
    await prefs.setString('FCMtoken', FCMtoken);
    await prefs.setString('authID', authID);
    await prefs.setString('plotCode', plotCode);
    await prefs.setBool('approved',approved);
  }

  Future<void> logOut () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('authID');
    prefs.remove('username');
    prefs.remove('FCMtoken');
    prefs.remove('joinedPlot');
    prefs.remove('phoneNumber');
    prefs.remove('approved');
    prefs.remove('plotCode');
  }

  Future<void> deleteAll () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('authID');
    prefs.remove('username');
    prefs.remove('FCMtoken');
    prefs.remove('joinedPlot');
    prefs.remove('phoneNumber');
    prefs.remove('approved');
    prefs.remove('plotCode');
  }

}