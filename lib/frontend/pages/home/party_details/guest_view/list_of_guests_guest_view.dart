import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/guest_info_object.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/components/guest_info.dart';
import 'package:plots/frontend/pages/home/home.dart';
import 'package:plots/frontend/pages/home/party_details/guest_view/guest_background_guest_view.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';
import 'package:plots/frontend/services/sync_firestore_shared_prefs.dart';

class ListOfGuestsGuestView extends StatefulWidget {
  final List guestsNames;
  final String plotCode;
  final String from;
  final SharedPrefData sharedPrefData;

  const ListOfGuestsGuestView({Key key, this.guestsNames, this.from, this.plotCode, this.sharedPrefData}) : super(key: key);
  @override
  _ListOfGuestsGuestViewState createState() => _ListOfGuestsGuestViewState();
}

class _ListOfGuestsGuestViewState extends State<ListOfGuestsGuestView> {
  FirestoreFunctions firestoreFunctions = FirestoreFunctions();
  Future<List> guestList;
  ScrollController scrollController = ScrollController();

  // Future<FirestorePlotData> getInformation() async {
  Future<List> getGuests() async {
    var guestList = await firestoreFunctions.getGuestListFromPlotCode(widget.plotCode);
    return guestList;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    guestList = getGuests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined),
          onPressed: ()async{
            if(widget.from == 'waitingForApproval') {
              SyncService syncService = SyncService();
              await syncService.syncSharedPrefsWithFirestore(authID:widget.sharedPrefData.authID);
              SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
              SharedPrefData sharedPrefData = await sharedPrefsServices.makeUserObject();
              Navigator.pushAndRemoveUntil(context, PageTransition(
                type: PageTransitionType.leftToRight,
                child: Home(
                  initialTabIndex: 0,
                  sharedPrefData: widget.from == "waitingForApproval" ? sharedPrefData : widget.sharedPrefData,
                ),
              ), (route) => false);
            }else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: widget.guestsNames.length == 0 ? Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("there is no one on the guest list.", textAlign: TextAlign.center, style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),),
          SizedBox(height: 5,),
          Text("invite more people using your plot code!", textAlign: TextAlign.center, style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),),

        ],
      ),):Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              onTap: () {
                showSearch(
                    context: context,
                    delegate: SearchGuestsGV(
                      from: widget.from,
                        plotCode: widget.plotCode,
                        guestsNames: widget.guestsNames,
                        sharedPrefData: widget.sharedPrefData
                    )
                );
              },
              child: Ink(
                height: 75,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.black),
                    borderRadius:
                    BorderRadius.all(Radius.circular(15))
                ),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: <Widget>[
                    Align(
                      child: Icon(Icons.search, color: Colors.white,),
                      alignment: Alignment.centerLeft,
                    ),
                    SizedBox(width: 10,),
                    Align(
                      child: Text(
                        "search guests",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      ),
                      alignment: Alignment.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          FutureBuilder(
              future: guestList,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done){
                  List guests = snapshot.data;
                  return   Expanded(
                    child: RawScrollbar(
                      controller: scrollController,
                      thickness: 4,
                      thumbColor: Colors.white,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: guests.length,
                          itemBuilder: (BuildContext context, int index) {
                            return
                              RawMaterialButton(
                                onPressed: (){
                                  GuestInfoObject guestInfoObject = GuestInfoObject(
                                      authID: guests[index]['authID'],
                                      status: guests[index]['status'],
                                      paymentDetails: guests[index]['paymentDetails'],
                                      noteToHost: guests[index]['noteToHost'],
                                      instaUsername: guests[index]['instaUsername'],
                                      paymentMethod: guests[index]['paymentMethod'],
                                      plusOnes: guests[index]['plusOnes'],
                                      price: guests[index]['price'],
                                      username: guests[index]['username'],
                                      profilePicURL: guests[index]['profilePicURL'],
                                      paid: guests[index]['paid']
                                  );
                                  Navigator.push(context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) => GuestBackgroundGuestView(
                                            guestInfoObject: guestInfoObject,
                                            plotCode: widget.plotCode,
                                            sharedPrefData: widget.sharedPrefData,
                                            guestUsernames: widget.guestsNames,
                                          )
                                      )
                                  );
                                },
                              padding: EdgeInsets.all(5),
                              child: Row(
                                children: <Widget>[
                                  CircleAvatar(
                                      radius: 45,
                                      child: CachedNetworkImage(
                                        imageUrl: guests[index]['profilePicURL'],
                                        imageBuilder: (context, imageProvider) => Container(
                                          width: 90.0,
                                          height: 90.0,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: imageProvider, fit: BoxFit.cover),
                                          ),
                                        ),
                                        placeholder: (context, url) => CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                            strokeWidth: 4.0
                                        ),
                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                      )
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 150,
                                        child: Text(
                                          guests[index]['username'],
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,),
                                        ),
                                      ),
                                      Container(
                                        child: Row(children: [
                                          Container(
                                              constraints: BoxConstraints(
                                                maxHeight: 25,
                                                minWidth: 25,
                                                maxWidth: 25,
                                                minHeight: 25,
                                              ),
                                              child:
                                              Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: AssetImage(
                                                      'assets/images/Instagram-Logo.png',
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              )),
                                          Container(
                                            margin: EdgeInsets.only(right: 5,left:5,top: 4,bottom: 4),
                                            width: 1,
                                            height: 20,
                                            color: Colors.white,
                                          ),
                                          Container(
                                            width: 125,
                                            child: Text(
                                              guests[index]['instaUsername'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,),
                                            ),
                                          ),
                                        ],),
                                      ),
                                    ],),
                                ],
                              ),
                            );
                          }),
                    ),
                  );
                } else {
                  return Container(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                        strokeWidth: 4.0
                    ),
                  );
                }
              })
        ],
      ),
    );
  }
}


class SearchGuestsGV extends SearchDelegate<String> {
  final List guestsNames;
  final String plotCode;
  final String from;
  final SharedPrefData sharedPrefData;

  List<dynamic> recentSearches = [];

  SearchGuestsGV({this.guestsNames,this.from, this.plotCode, this.sharedPrefData});

  @override
  List<Widget> buildActions(BuildContext context) {
    // Actions for Appbar
    return [
//      IconButton(
//        icon: Icon(Icons.clear),
//        onPressed: () {
//          query = "";
//        },
//      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // leading
    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestionList = query.isEmpty
        ? recentSearches
        : guestsNames.where((p) => p.startsWith(query)).toList();
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? recentSearches
        : guestsNames
        .where((p) => p.toUpperCase().startsWith(query.toUpperCase()))
        .toList();

    return ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) => ListTile(
          onTap: () async{
            query = '${suggestionList[index]}';
            FirestoreFunctions firestoreFunctions = FirestoreFunctions();
            GuestInfoObject guestInfoObject = await firestoreFunctions.makeGuestObjectFromUsername(plotCode, query);
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (BuildContext context) => GuestBackgroundGuestView(
                      guestInfoObject: guestInfoObject,
                      plotCode: plotCode,
                      guestUsernames: guestsNames,
                      sharedPrefData: sharedPrefData,
                    )
                ));
          },
          title: RichText(
            text: TextSpan(
                text: suggestionList[index].substring(0, query.length),
                style: TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    style: TextStyle(color: Colors.white, ),
                    text: suggestionList[index].substring(query.length,suggestionList[index].length),
                  )
                ]),
          ),
        ));
  }
}

