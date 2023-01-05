import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:plots/frontend/classes/pass_home_data.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/components/blank_page.dart';
import 'package:plots/frontend/pages/home/home.dart';
import 'package:plots/frontend/pages/login/get_started/get_started.dart';
import 'package:plots/backend/firebase_auth_services.dart';
import 'package:plots/frontend/pages/login/login.dart';
import 'package:plots/frontend/pages/static_pages/error_occured.dart';
import 'package:plots/frontend/pages/static_pages/loading.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';
import 'package:plots/frontend/theme/app_colors.dart';
import 'package:plots/frontend/services/sync_firestore_shared_prefs.dart';




void main() async {
  // entry point of app
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp( MyApp());
  });
}

class MyApp extends StatelessWidget {
  Future<Widget> getInformation() async {
    SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
    SyncService syncService = SyncService();
    AuthService authService = AuthService();
    bool firstTime = await sharedPrefsServices.isFirstTimeDownload();
    bool isLoggedIn = await authService.getLoggedInStatus();
    if (firstTime) {
      return GetStarted();
    } else if (isLoggedIn) {
      try {
        await syncService.syncSharedPrefsWithFirestore(authID: FirebaseAuth.instance.currentUser.uid);
        SharedPrefData sharedPrefData = await sharedPrefsServices.makeUserObject();
        return Home(initialTabIndex: 0, sharedPrefData: sharedPrefData,);
      } catch (e){
        await FirebaseAuth.instance.signOut();
        await sharedPrefsServices.logOut();
        print(e.toString());
        return Login();
      }
    } else {
      return Login();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        PassHomeData arguments = settings.arguments;
        return MaterialPageRoute(builder: (context) {
          switch (settings.name) {
            case '/home':
              return Home(
                sharedPrefData: arguments.sharedPrefData,
                initialTabIndex: arguments.initalTabIndex,
              );
              break;
            default:
              return null;
          }
        });
      },
      title: 'plots',
      theme: ThemeData(
        canvasColor: Color(0xff1e1e1e),
        scaffoldBackgroundColor:  Color(0xff1e1e1e),
        primarySwatch: MaterialColor(0xff1e1e1e, color),
        fontFamily: 'Poppins',
        textTheme: TextTheme(
          caption: TextStyle(color: Colors.white),
          bodyText1: TextStyle( color: Colors.white),
          bodyText2: TextStyle( color: Colors.white),
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home:  FutureBuilder(
        future: getInformation(),
        builder: (context, snapshot){
          if (snapshot.hasData) {
            return snapshot.data;
          }
          if (snapshot.connectionState == ConnectionState.waiting){
            return Loading();
          }else {
            return ErrorOccurred();
          }
        },
      ),
    );
  }
}
