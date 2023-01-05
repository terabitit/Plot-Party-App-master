import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/backend/firebase_auth_services.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/pass_home_data.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/join_or_create_plot.dart';
import 'package:plots/frontend/pages/home/map_page/map_page.dart';
import 'package:plots/frontend/pages/home/message_board/message_board.dart';
import 'package:plots/frontend/pages/home/party_details/party_details.dart';
import 'package:plots/frontend/pages/nav/navigation_drawer.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/waiting_for_approval.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';
import 'package:plots/frontend/services/sync_firestore_shared_prefs.dart';


class Home extends StatefulWidget {
  final int initialTabIndex;
  final SharedPrefData sharedPrefData;

  const Home({Key key, this.initialTabIndex, this.sharedPrefData}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  int _currentIndex = 0;
  PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  Future<void> notificationConfig() async {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      if(settings.authorizationStatus == AuthorizationStatus.authorized){
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('Got a message whilst in the foreground!');
          if (message.notification != null) {
            print('Message also contained a notification: ${message.notification}');
          }
        });
        FirebaseMessaging.instance
            .getInitialMessage()
            .then((RemoteMessage message) {
          if (message != null) {
            _handleMessage(message);
          }
        });
        // token handling
        String FCMtoken = await messaging.getToken();
        SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
        String existingToken = await sharedPrefsServices.getFCMNotificationToken();
        FirestoreFunctions firestoreFunctions = FirestoreFunctions();
        if (FCMtoken != null){
          if (existingToken != FCMtoken) {
            print("newTokenSet");
            if(widget.sharedPrefData.joinedPlot) {
              bool isHost = await firestoreFunctions.isHost(widget.sharedPrefData.username, widget.sharedPrefData.plotCode);
              if (isHost) {
                firestoreFunctions.updatePlotsInfo(plotCode: widget.sharedPrefData.plotCode, field: 'hostFCMtoken', newValue: FCMtoken);
              } else {
                if(widget.sharedPrefData.approved){
                  firestoreFunctions.updateGuestInfo(plotCode: widget.sharedPrefData.plotCode, authID: widget.sharedPrefData.authID, field: 'FCMtoken', newValue: FCMtoken);
                } else {
                  firestoreFunctions.updateAttendRequestInfo(plotCode: widget.sharedPrefData.plotCode, authID: widget.sharedPrefData.authID, field: 'FCMtoken', newValue: FCMtoken);
                }
              }
            }
            await sharedPrefsServices.setFCMNotificationToken(FCMtoken);
            await firestoreFunctions.updateUserInfo(authID: widget.sharedPrefData.authID, fields: ['FCMtoken'], newValues: [FCMtoken]);
          }
        }
      }
  }

  Future<void> _handleMessage(RemoteMessage message) async{
    SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
    SyncService syncService = SyncService();
    await syncService.syncSharedPrefsWithFirestore(authID: FirebaseAuth.instance.currentUser.uid);
    SharedPrefData sharedPrefData = await sharedPrefsServices.makeUserObject();
    PassHomeData passHomeData = PassHomeData(
      initalTabIndex: 0,
      sharedPrefData: sharedPrefData
    );
    Navigator.of(context).pushNamed('/home', arguments: passHomeData);
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialTabIndex);
    _currentIndex = widget.initialTabIndex;
    notificationConfig();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawerEdgeDragWidth: 0.0,
      endDrawer: NavigationDrawer(
        sharedPrefData: widget.sharedPrefData,

      ),
      body:
              // using tertiary statements to setup TabBarView {bool statement ? if true do whatever is here : else do this }
      widget.sharedPrefData.joinedPlot && widget.sharedPrefData.approved ?
                PageView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _pageController,
                    children: <Widget>[
                      PartyDetails(sharedPrefData: widget.sharedPrefData,),
                      MessageBoard(plotCode: widget.sharedPrefData.plotCode, name: widget.sharedPrefData.username,),
                      MapPage(),
                    ]
                )
                :
                // Joined but not approved yet
      widget.sharedPrefData.joinedPlot && !widget.sharedPrefData.approved ?
                PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  children: <Widget>[
                    WaitingForApproval(
                      sharedPrefData: widget.sharedPrefData,
                    ),
                    MapPage(),
                  ],
                ):
                PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  children: <Widget>[
                    MapPage(),
                    JoinOrCreatePlot(
                      sharedPrefData: widget.sharedPrefData,
                    ),
                  ],
                ),
              // Not Joined View
      drawer: NavigationDrawer(
        sharedPrefData: widget.sharedPrefData,
      ),
      bottomNavigationBar: SafeArea(
          child:
          widget.sharedPrefData.joinedPlot && widget.sharedPrefData.approved ?
          Container(
            margin: EdgeInsets.all(16),
            child: BottomNavyBar(
              itemCornerRadius: 0,
              iconSize: 25,
              backgroundColor: Colors.transparent,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              selectedIndex: _currentIndex,
              onItemSelected: (index) {
                setState(() => _currentIndex = index);
                _pageController.jumpToPage(index);
              },
              items: <BottomNavyBarItem>[
                BottomNavyBarItem(
                    activeColor: Colors.white,
                    inactiveColor: Colors.grey,
                    textAlign: TextAlign.center,
                    title: Text('info', style: TextStyle(fontSize: 20)),
                    icon: Icon(Icons.celebration)
                ),
                BottomNavyBarItem(
                    activeColor: Colors.blue,
                    textAlign: TextAlign.center,
                    inactiveColor: Colors.grey,
                    title: Text('chat', style: TextStyle(fontSize: 20)),
                    icon: Icon(Icons.message)
                ),
                BottomNavyBarItem(
                    activeColor: Colors.green,
                    textAlign: TextAlign.center,
                    inactiveColor: Colors.grey,
                    title: Text("find", style: TextStyle(fontSize: 20),),
                    icon: Icon(Icons.map)
                ),
              ],
            ),)
              :
          // Joined but not approved yet
          widget.sharedPrefData.joinedPlot && !widget.sharedPrefData.approved ?
          Container(
            margin: EdgeInsets.all(16),
            child: BottomNavyBar(
              backgroundColor: Colors.transparent,
              itemCornerRadius: 0,
              iconSize: 25,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              selectedIndex: _currentIndex,
              onItemSelected: (index) {
                setState(() => _currentIndex = index);
                _pageController.jumpToPage(index);
              },
              items: <BottomNavyBarItem>[
                BottomNavyBarItem(
                    activeColor: Colors.purpleAccent,
                    inactiveColor: Colors.grey,
                    textAlign: TextAlign.center,
                    title: Text('info', style: TextStyle(fontSize: 20)),
                    icon: Icon(Icons.celebration)
                ),
                BottomNavyBarItem(
                    activeColor: Colors.green,
                    textAlign: TextAlign.center,
                    inactiveColor: Colors.grey,
                    title: Text("find", style: TextStyle(fontSize: 20),),
                    icon: Icon(Icons.map)
                ),
              ],
            ),) :
          Container(
            margin: EdgeInsets.all(16),
            child: BottomNavyBar(
              backgroundColor: Colors.transparent,
              itemCornerRadius: 0,
              iconSize: 25,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              selectedIndex: _currentIndex,
              onItemSelected: (index) {
                setState(() => _currentIndex = index);
                _pageController.jumpToPage(index);
              },
              items: <BottomNavyBarItem>[
                BottomNavyBarItem(
                    activeColor: Colors.green,
                    textAlign: TextAlign.center,
                    inactiveColor: Colors.white,
                    title: Text("find", style: TextStyle(fontSize: 20),),
                    icon: Icon(Icons.map, size: 32,)
                ),
                BottomNavyBarItem(
                    activeColor: Colors.purpleAccent,
                    inactiveColor: Colors.white,
                    textAlign: TextAlign.center,
                    title: Text('fun', style: TextStyle(fontSize: 20)),
                    icon: Icon(Icons.celebration, size: 32,)
                ),
              ],
            ),)
        // Not Joined View
      ),
    );
  }
}

