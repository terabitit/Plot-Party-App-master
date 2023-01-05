import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/firestore_plot_data.dart';
import 'package:plots/frontend/classes/guest_info_object.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/home/home.dart';
import 'package:plots/frontend/pages/home/message_board/host_and_guest_dm.dart';
import 'package:plots/frontend/pages/home/party_details/guest_view/list_of_guests_guest_view.dart';
import 'package:plots/frontend/pages/static_pages/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';
import 'package:plots/frontend/services/sync_firestore_shared_prefs.dart';
import 'package:progress_indicators/progress_indicators.dart';

class WaitingForApproval extends StatefulWidget {
  // Party Details Guest View
  final SharedPrefData sharedPrefData;

  const WaitingForApproval({Key key, this.sharedPrefData})
      : super(key: key);

  @override
  _WaitingForApprovalState createState() => _WaitingForApprovalState();
}

class _WaitingForApprovalState extends State<WaitingForApproval> with TickerProviderStateMixin {
  Color _color = Colors.green;
  FirestoreFunctions firestoreFunctions = FirestoreFunctions();
  Future<FirestorePlotData> plotInfo;
  Future<int> unreadMessages;

  // Future<FirestorePlotData> getInformation() async {
  Future<FirestorePlotData> getInformation() async {
    var firestorePlotData = await firestoreFunctions.makePlotObject(widget.sharedPrefData.plotCode);
    return firestorePlotData;
  }

  Future<int> getUnreadMessages() async {
    var unreadMessages = await firestoreFunctions.getUnreadMessagesFromAuthID(widget.sharedPrefData.authID);
    return unreadMessages;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    plotInfo = getInformation();
    unreadMessages = getUnreadMessages();
  }

  Future<void> _refresh() async {
    SyncService syncService = SyncService();
    await syncService.syncSharedPrefsWithFirestore(authID:widget.sharedPrefData.authID);
    SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
    SharedPrefData sharedPrefData = await sharedPrefsServices.makeUserObject();
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => Home(
          initialTabIndex: 0,
          sharedPrefData: sharedPrefData,
        ),
        transitionDuration: Duration(seconds: 0),
      ), (route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.blue,
      onRefresh: _refresh,
      child: FutureBuilder(
          future: plotInfo,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done){
              FirestorePlotData plotData = snapshot.data;
              return SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            plotData.flyerURL != '' ? GestureDetector(
                              onTap: (){
                                showDialog(context: context,
                                    barrierDismissible: true,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                          backgroundColor: Colors.transparent,
                                          insetPadding: EdgeInsets.all(10),
                                          child: GestureDetector(
                                            onTap: (){
                                              Navigator.pop(context);
                                            },
                                            child:
                                            InteractiveViewer(
                                              panEnabled: false, // Set it to false
                                              boundaryMargin: EdgeInsets.all(100),
                                              minScale: 0.5,
                                              maxScale: 2,
                                              child:  CachedNetworkImage(
                                                imageUrl: plotData.flyerURL,
                                                imageBuilder: (context, imageProvider) => Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(
                                                        Radius.circular(25)
                                                    ),
                                                    image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                                placeholder: (context, url) => Container(
                                                  alignment: Alignment.center,
                                                  child: CircularProgressIndicator(
                                                      valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                                      strokeWidth: 4.0
                                                  ),
                                                  height: 50.0,
                                                  width: 50.0,
                                                ),
                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                              ),
                                            ),
                                          )
                                      );
                                    }
                                );
                              },
                              child:
                              Container(
                                  constraints: BoxConstraints(
                                    maxHeight: MediaQuery.of(context).size.height / 4 + 25,
                                    minHeight: MediaQuery.of(context).size.height / 4 + 25,
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: plotData.flyerURL,
                                    imageBuilder: (context, imageProvider) => Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) => Container(
                                      alignment: Alignment.center,
                                      color: Colors.black,
                                      constraints: BoxConstraints(
                                        maxHeight: MediaQuery.of(context).size.height / 4 + 25,
                                        minHeight: MediaQuery.of(context).size.height / 4 + 25,
                                      ),
                                      child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                          strokeWidth: 4.0
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  )
                              ),
                            )
                                :
                            Container(
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.height / 4 + 25,
                                minHeight: MediaQuery.of(context).size.height / 4 + 25,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      'assets/images/no_plot_image.jpg',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                                alignment: Alignment.topLeft,
                                child: SafeArea(
                                  child: Container(
                                      padding: EdgeInsets.only(top: 20, left: 5),
                                      child: RawMaterialButton(
                                        onPressed: () {
                                          Scaffold.of(context).openEndDrawer();
                                        }, // needed
                                        child: Icon(Icons.menu, color: Colors.white,size: 32,),
                                        shape: CircleBorder(),
                                        padding: EdgeInsets.all(16),
                                        fillColor: Color(0xff1e1e1e),
                                      )
                                  ),
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 220,
                                  padding: new EdgeInsets.only(right: 13.0, left: 20),
                                  child: Text(
                                    plotData.plotName,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 5,
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 220,
                                  padding: new EdgeInsets.only(right: 13.0, left: 20),
                                  child: Text(
                                    "hosted by ${plotData.hostName}",
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.white
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 220,
                                  padding: new EdgeInsets.only(right: 13.0, left: 20),
                                  child: Text(
                                    plotData.contactDetails,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 5,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.white
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            Column(children: [
                              JumpingText('waiting for', style:TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ) ,),JumpingText('approval...', style:TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ) ,),
                            ],),
                            Expanded(
                              child: Container(),
                            ),
                          ],
                        ),
                        SizedBox(height: 15,),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: ElevatedButton(
                            onPressed: () async{
                              FirestoreFunctions firestoreFunctions = FirestoreFunctions();
                              String flyerURL = await firestoreFunctions.getFlyerURLFromPlotCode(widget.sharedPrefData.plotCode);
                              GuestInfoObject guestInfoObject = await firestoreFunctions.makeAttendRequestObjectFromAuthID(widget.sharedPrefData.plotCode, widget.sharedPrefData.authID);
                              String receivingAuthID = await firestoreFunctions.getHostAuthID(widget.sharedPrefData.plotCode);
                              String receivingNotificationToken = await firestoreFunctions.getHostFCMTokenFromPlotCode(widget.sharedPrefData.plotCode);
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) => HostAndGuestDM(
                                    sharedPrefData: widget.sharedPrefData,
                                    isHost: false,
                                    receivingAuthID: receivingAuthID,
                                    receivingNotificationToken: receivingNotificationToken,
                                    plotFlyer: flyerURL == '' ? 'https://firebasestorage.googleapis.com/v0/b/plots-6e93e.appspot.com/o/no_plot_image.jpg?alt=media&token=44aaa97a-0c79-42d5-b4b3-61966d051224' : flyerURL,
                                    guestInfoObject: guestInfoObject,
                                  )
                              ));
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                padding: EdgeInsets.all(16)),
                            child: Container(
                              width: 330,
                              child: Row(
                                children: [
                                  Stack(
                                    children: <Widget>[
                                      Icon(Icons.email,),
                                      FutureBuilder(
                                          future: unreadMessages,
                                          builder: (context, AsyncSnapshot snapshot) {
                                            if (snapshot.connectionState == ConnectionState.done){
                                              if (snapshot.data == 0) {
                                                return Container();
                                              }
                                              return Positioned(
                                                right: -2,
                                                top: 0,
                                                child: new Container(
                                                  padding: EdgeInsets.all(1),
                                                  decoration: new BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  constraints: BoxConstraints(
                                                    minWidth: 16,
                                                    minHeight: 16,
                                                  ),
                                                  child: new Text(
                                                    '${snapshot.data.toString()}',
                                                    style: new TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 9,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              );
                                            }
                                            return Container();
                                          }
                                      )
                                    ],
                                  ),
                                  SizedBox(width: 10,),
                                  Text(
                                    'messages from host',
                                    textAlign: TextAlign.center,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10,right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                child: ElevatedButton(
                                    style:
                                    ElevatedButton.styleFrom(primary: Colors.deepPurpleAccent),
                                    child: Container(
                                      height: 140,
                                      width: 190,
                                      padding: EdgeInsets.all(5),
                                      child: Row(
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'guest list',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(color: Colors.white, fontSize: 16),
                                              ),
                                              Text(
                                                'view background info\nfor each guest',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(color: Colors.white, fontSize: 14),
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  plotData.guests.length  == 0 ? Container() :
                                                  plotData.guests.length == 1 ? CircleAvatar(
                                                    child: CircleAvatar(
                                                      radius: 25,
                                                      child: CachedNetworkImage(
                                                        imageUrl: plotData.guests[0]['profilePicURL'],
                                                        imageBuilder: (context, imageProvider) => Container(
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: Colors.black,
                                                            image: DecorationImage(
                                                              image: imageProvider,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        placeholder: (context, url) => CircularProgressIndicator(
                                                            valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                                            strokeWidth: 4.0
                                                        ),
                                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                                      ), // Provide your custom image
                                                    ),
                                                  ):
                                                  plotData.guests.length  == 2 ?Container(
                                                    width: 60,
                                                    child:
                                                    Stack(
                                                      children: <Widget>[
                                                        Align(
                                                          alignment: Alignment.centerRight,
                                                          child:
                                                          CircleAvatar(
                                                            child: CircleAvatar(
                                                              radius: 25,
                                                              child: CachedNetworkImage(
                                                                imageUrl: plotData.guests[0]['profilePicURL'],
                                                                imageBuilder: (context, imageProvider) => Container(
                                                                  decoration: BoxDecoration(
                                                                    shape: BoxShape.circle,
                                                                    color: Colors.black,
                                                                    image: DecorationImage(
                                                                      image: imageProvider,
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                                placeholder: (context, url) => CircularProgressIndicator(
                                                                    valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                                                    strokeWidth: 4.0
                                                                ),
                                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                                              ), // Provide your custom image
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: CircleAvatar(
                                                            child: CircleAvatar(
                                                              radius: 25,
                                                              child: CachedNetworkImage(
                                                                imageUrl: plotData.guests[1]['profilePicURL'],
                                                                imageBuilder: (context, imageProvider) => Container(
                                                                  decoration: BoxDecoration(
                                                                    shape: BoxShape.circle,
                                                                    color: Colors.black,
                                                                    image: DecorationImage(
                                                                      image: imageProvider,
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                                placeholder: (context, url) => CircularProgressIndicator(
                                                                    valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                                                    strokeWidth: 4.0
                                                                ),
                                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                                              ), // Provide your custom image
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ):
                                                  plotData.guests.length > 2 ?
                                                  Container(
                                                    width: 80,
                                                    child:
                                                    Stack(
                                                      children: <Widget>[
                                                        Align(
                                                          alignment: Alignment.centerRight,
                                                          child:
                                                          CircleAvatar(
                                                            child: CircleAvatar(
                                                              radius: 25,
                                                              child: CachedNetworkImage(
                                                                imageUrl: plotData.guests[0]['profilePicURL'],
                                                                imageBuilder: (context, imageProvider) => Container(
                                                                  decoration: BoxDecoration(
                                                                    shape: BoxShape.circle,
                                                                    color: Colors.black,
                                                                    image: DecorationImage(
                                                                      image: imageProvider,
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                                placeholder: (context, url) => CircularProgressIndicator(
                                                                    valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                                                    strokeWidth: 4.0
                                                                ),
                                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                                              ), // Provide your custom image
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment.center,
                                                          child: CircleAvatar(
                                                            child: CircleAvatar(
                                                              radius: 25,
                                                              child: CachedNetworkImage(
                                                                imageUrl: plotData.guests[1]['profilePicURL'],
                                                                imageBuilder: (context, imageProvider) => Container(
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.black,
                                                                    shape: BoxShape.circle,
                                                                    image: DecorationImage(
                                                                      image: imageProvider,
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                                placeholder: (context, url) => CircularProgressIndicator(
                                                                    valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                                                    strokeWidth: 4.0
                                                                ),
                                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                                              ), // Provide your custom image
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: CircleAvatar(
                                                            child: CircleAvatar(
                                                              radius: 25,
                                                              child: CachedNetworkImage(
                                                                imageUrl: plotData.guests[2]['profilePicURL'],
                                                                imageBuilder: (context, imageProvider) => Container(
                                                                  decoration: BoxDecoration(
                                                                    shape: BoxShape.circle,
                                                                    image: DecorationImage(
                                                                      image: imageProvider,
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                                placeholder: (context, url) => CircularProgressIndicator(
                                                                    valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                                                    strokeWidth: 4.0
                                                                ),
                                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                                              ), // Provide your custom image
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                      : Container(),
                                                  plotData.guests.length == 0 ? Container() : SizedBox(width: 5,),
                                                  Text(
                                                    "${plotData.guests.length.toString()} attending",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                                  ),
                                                ],)

                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    onPressed: () async {
                                      List guestsUsernames = [];
                                      plotData.guests.forEach((element) {
                                        guestsUsernames.add(element['username']);
                                      });
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  ListOfGuestsGuestView(
                                                    from: 'waitingForApproval',
                                                    sharedPrefData: widget.sharedPrefData,
                                                    plotCode: widget.sharedPrefData.plotCode,
                                                    guestsNames: guestsUsernames,
                                                  )));
                                    }),
                              ),
                              ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.deepPurpleAccent,
                                        padding: EdgeInsets.all(10)),
                                    child: Column(
                                      children: [
                                        Container(
                                            padding: EdgeInsets.all(6),
                                            child: Icon(
                                              Icons.attach_money,
                                              color: Colors.greenAccent,
                                              size: 50,
                                            )),
                                        Text(
                                          "payment\ndetails",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onPressed: ()  async{
                                      FirestoreFunctions firestoreFunctions = FirestoreFunctions();
                                      GuestInfoObject guestInfoObject= await firestoreFunctions.makeAttendRequestObjectFromAuthID(widget.sharedPrefData.plotCode, widget.sharedPrefData.authID);
                                      guestInfoObject == null ?showDialog(context: context,
                                          barrierDismissible: true,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("an error occurred. try refreshing the app."),
                                              actions: <Widget>[
                                                IconButton(icon: Icon(Icons.close),onPressed: (){
                                                  Navigator.pop(context);
                                                })
                                              ],
                                            );
                                          }
                                      ) : showDialog(context: context,
                                          barrierDismissible: true,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              backgroundColor: Color(0xff1e1e1e),
                                              title: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text("\$${guestInfoObject.price}", style: TextStyle(
                                                          fontSize: 32,
                                                          color: Colors.green
                                                      ),),
                                                      Text("${guestInfoObject.status}", style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16
                                                      ),)
                                                    ],
                                                  ),
                                                  Expanded(child: Container(),),
                                                  Text("plus ones\n${guestInfoObject.plusOnes}", style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white
                                                  ),),
                                                ],),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  guestInfoObject.paid ? Text('paid and ready to party!', style: TextStyle(
                                                      fontSize: 32,
                                                      color: Colors.green
                                                  ),) : Text('not approved yet', style: TextStyle(
                                                      fontSize: 32,
                                                      color: Colors.red
                                                  ),),
                                                  Divider(thickness: 2,),
                                                  Text("payment method", style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white
                                                  ),),
                                                  Text("${guestInfoObject.paymentMethod}", style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 16
                                                  ),),
                                                  Divider(thickness: 2,),
                                                  Text("payment details", style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white
                                                  ),),
                                                  Text("${guestInfoObject.paymentDetails}", style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 16
                                                  ),),
                                                  Divider(thickness: 2,),
                                                  Text("note to host", style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white
                                                  ),),
                                                  Text("${guestInfoObject.noteToHost}", style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 16
                                                  ),),
                                                ],
                                              ),
                                              actions: <Widget>[
                                                IconButton(icon: Icon(Icons.close, color: Colors.white,),onPressed: (){
                                                  Navigator.pop(context);
                                                })
                                              ],
                                            );
                                          }
                                      );
                                    }),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Color(0xff1e1e1e),
                                      title: Text('description', style: TextStyle(
                                        color: Colors.white
                                      ),),
                                      content: Text("${plotData.description.toString()}",  style: TextStyle(
                                          color: Colors.white
                                      )),
                                      actions: <Widget>[
                                        IconButton(
                                          icon: Icon(Icons.close, color: Colors.white,),
                                          onPressed: (){
                                            Navigator.pop(context);
                                          },
                                        )
                                      ],
                                    );
                                  }
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Colors.deepPurpleAccent,
                                padding: EdgeInsets.all(16)),
                            child: Container(
                              width: 330,
                              child: Text(
                                plotData.description,
                                textAlign: TextAlign.center,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                          ],
                        ),
                  ),
                   );
            } else {
              return Loading();
            }
          }),
    );

  }
}
