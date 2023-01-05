import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/firestore_user_data.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/home/home.dart';
import 'package:plots/frontend/pages/static_pages/loading.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';
import 'package:plots/frontend/services/sync_firestore_shared_prefs.dart';

class FSSPDataWidget extends StatelessWidget {
  // this is just a page where I can see the shared preferences and firestore data at the same time.
  final String authID;
  final bool sync;

  const FSSPDataWidget({Key key, this.authID, this.sync}) : super(key: key);

  Future<List> getInformation() async {
    List info = [];
    SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
    info.add( await sharedPrefsServices.makeUserObject());
    FirestoreFunctions firestoreFunctions = FirestoreFunctions();
    info.add( await firestoreFunctions.makeUserObject(authID));
    return info;
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getInformation(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done){
            SharedPrefData sharedPrefData = snapshot.data[0];
            FirestoreUserData firestoreUserData = snapshot.data[1];
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: ()async{
                    // Navigator.pop(context);
                    SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
                    if(sync){
                      SyncService syncService = SyncService();
                      await syncService.syncSharedPrefsWithFirestore(authID: authID);
                    }
                    SharedPrefData sharedPrefData = await sharedPrefsServices.makeUserObject();
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                        builder: (BuildContext context) => Home(initialTabIndex: 0, sharedPrefData: sharedPrefData,)
                    ), (route) => false);
                  },
                ),
              ),
              body: Column(
                  children: [
                    Text("SharedPref Data", style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    )),
                    Text('Username: ${sharedPrefData.username}'),
                    Text('PlotCode: ${sharedPrefData.plotCode}'),
                    Text('Phone Number: ${sharedPrefData.phoneNumber}'),
                    Text(sharedPrefData.joinedPlot ? 'joined' : 'not Joined'),
                    Text('authID: ${sharedPrefData.authID}'),
                    Text("approved: ${sharedPrefData.approved}"),
                    SizedBox(height: 10,),
                    Divider(thickness: 2,),
                    Text("Firestore Data", style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),),
                    Text('Username: ${firestoreUserData.username}'),
                    Text('PlotCode: ${firestoreUserData.plotCode}'),
                    Text('Phone Number: ${firestoreUserData.phoneNumber}'),
                    Text(firestoreUserData.joinedPlot ? 'joined' : 'not Joined'),
                    Text('authID: ${firestoreUserData.uuid}'),
                    Text("approved: ${firestoreUserData.approved}"),
                  ],
              )
                );
          } else {
            return Loading();
          }
        });  }
}
