import 'dart:math';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:intl/intl.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/firestore_plot_data.dart';
import 'package:plots/frontend/classes/guest_info_object.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/home/message_board/host_and_guest_dm.dart';
import 'package:plots/frontend/pages/home/party_details/guest_view/list_of_guests_guest_view.dart';
import 'package:plots/frontend/pages/home/qr_ticket_process/guest_qr_code.dart';
import 'package:plots/frontend/pages/static_pages/intro_screens/intro_screens_guest.dart';
import 'package:plots/frontend/services/launch_apple_maps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';
import 'package:progress_indicators/progress_indicators.dart';

class GuestView extends StatefulWidget {
  // Party Details Guest View
  final FirestorePlotData plotData;
  final SharedPrefData sharedPrefData;
  final DateTime startDate;
  final int unreadMessages;

  const GuestView({Key key, this.plotData, this.unreadMessages, this.sharedPrefData, this.startDate})
      : super(key: key);

  @override
  _GuestViewState createState() => _GuestViewState();
}

class _GuestViewState extends State<GuestView> with TickerProviderStateMixin {
  TabController _nestedTabController;
  SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100)).then((_) async{
      if (await sharedPrefsServices.isFirstTimeGuest() ){
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
            builder: (BuildContext context) => IntroScreensGuest( sharedPrefData: widget.sharedPrefData,)
        ), (route) => false);      }
    });
    _nestedTabController = new TabController(length: 4, vsync: this);
  }
  @override
  void dispose() {
    super.dispose();
    _nestedTabController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final snackBar = SnackBar(content: Text('code copied to clipboard'));
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
              widget.plotData.flyerURL != '' ? GestureDetector(
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
                                  imageUrl: widget.plotData.flyerURL,
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
                      imageUrl: widget.plotData.flyerURL,
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
          Container(
            padding: EdgeInsets.all(10),
            child: CountdownTimer(
              endTime: widget.plotData.startDate.millisecondsSinceEpoch +
                  1000 * 30,
              widgetBuilder: (_, CurrentRemainingTime time) {
                if (time == null) {
                  return Container(
                    width: 350,
                    height: 75,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.purpleAccent,
                            Colors.deepPurpleAccent
                          ]),
                      borderRadius:
                      BorderRadius.all(Radius.circular(25)),
                    ),
                    child: JumpingText(
                      "time to rage!!!",
                      style: TextStyle(
                        fontSize: 32,
                      ),
                    ),
                    // Define how long the animation should take.
                  );
                }
                return Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      child:
                      Column(
                        children: [
                          Text(
                            '${time.days == null ? 0.toString() : time.days > 9 ? '': '0'}${time.days == null ?0.toString(): time.days}',
                            style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'days',
                            style: TextStyle(fontSize: 16,color: Colors.white),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          color: Colors.black38
                      ),
                      padding: EdgeInsets.only(left: 20,right: 20,top: 15,bottom: 15),
                    ),
                    Container(
                      child:
                      Column(
                        children: [
                          Text(
                            '${time.hours == null ? 0.toString() : time.hours>9 ? '': '0'}${time.hours == null ?0.toString(): time.hours}',
                            style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'hrs',
                            style: TextStyle(fontSize: 16,color: Colors.white),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          color: Colors.black38
                      ),
                      padding: EdgeInsets.only(left: 20,right: 20,top: 15,bottom: 15),
                    ),
                    Container(
                      child:
                      Column(
                        children: [
                          Text(
                            '${time.min == null ? 0.toString() : time.min>9 ? '': '0'}${time.min == null ?0.toString(): time.min}',
                            style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'mins',
                            style: TextStyle(fontSize: 16,color: Colors.white),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          color: Colors.black38
                      ),
                      padding: EdgeInsets.only(left: 20,right: 20,top: 15,bottom: 15),
                    ),
                    Container(
                      child:
                      Column(
                        children: [
                          Text(
                            '${time.sec == null ? 0.toString() : time.sec>9 ? '': '0'}${time.sec == null ?0.toString(): time.sec}',
                            style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'secs',
                            style: TextStyle(fontSize: 16,color: Colors.white),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          color: Colors.black38
                      ),
                      padding: EdgeInsets.only(left: 20,right: 20,top: 15,bottom: 15),
                    ),
                  ],
                );
              },
            ),
          ),
          Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 225,
                    padding: new EdgeInsets.only(right: 13.0, left: 20),
                    child: Text(
                      widget.plotData.plotName,
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
                    width: 225,
                    padding: new EdgeInsets.only(right: 13.0, left: 20),
                    child: Text(
                      "hosted by\n${widget.plotData.hostName}",
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
                    width: 225,
                    padding: new EdgeInsets.only(right: 13.0, left: 20),
                    child: Text(
                      widget.plotData.contactDetails,
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
              SizedBox(
                width: 20,
              ),
              Column(children: [
                Text("your ticket", style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16
                ),),
                SizedBox(height: 5,),

            Container(
                constraints: BoxConstraints(minWidth: 100, minHeight: 100),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    gradient: LinearGradient(
                        colors: [
                          Color(0xffB53D3D),
                          Color(0xff630094)
                        ]
                    )
                ),
                child: ElevatedButton(
                  onPressed:() {
                Navigator.push(
                context,
                MaterialPageRoute(
                builder: (BuildContext context) => GuestQRCode(
                sharedPrefData: widget.sharedPrefData,
                )));
                },
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      primary: Colors.transparent
                  ),
                  child: Icon(Icons.qr_code,
                    color: Colors.white,
                    size: 75,),
                ),
            ),
              ],),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
          SizedBox(height: 15,),
              TabBar(
                controller: _nestedTabController,
                indicatorColor: Colors.white,
                automaticIndicatorColorAdjustment: true,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                isScrollable: true,
                tabs: <Widget>[
                  Tab(
                    child: Container(
                      height: 80,
                      child: Column(
                        children: [
                          Icon(Icons.people, size:20,),
                          Text("guest list", style: TextStyle(
                              fontSize: 16,
                          ),),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      height: 80,
                      child: Column(
                        children: [
                          Icon(Icons.celebration, size: 20,),
                          Text("party info", style: TextStyle(
                              fontSize: 16,
                          ),),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      height: 80,
                      child: Column(
                        children: [
                          Stack(
                            children: <Widget>[
                              Icon(Icons.email, size: 20,),
                              widget.unreadMessages > 0 ? Positioned(
                                right: -4,
                                top: -4,
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
                                    '${widget.unreadMessages.toString()}',
                                    style: new TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ): Container(),
                            ],
                          ),
                          Text("messages", style: TextStyle(
                            fontSize: 16,
                          ),),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    child:Container(
                      height: 80,
                      child: Column(
                        children: [
                          Icon(Icons.attach_money, size: 20,),
                          Text("payments", style: TextStyle(
                              fontSize: 16,
                          ),),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Container(
                height: 150,
                margin: EdgeInsets.only(left: 5, right: 5.0),
                child: TabBarView(
                  controller: _nestedTabController,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                                Color(0xffB53D3D),
                                Color(0xff630094)
                              ]
                          )
                      ),
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                          style:
                          ElevatedButton.styleFrom(primary: Colors.transparent, elevation: 0),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'guest list',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Colors.white, fontSize: 20),
                                    ),
                                    Text(
                                      'view background info for each guest',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                    SizedBox(height: 10,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                      widget.plotData.guests.length  == 0 ? Container() :
                                      widget.plotData.guests.length == 1 ? CircleAvatar(
                                        child: CircleAvatar(
                                          radius: 25,
                                          child: CachedNetworkImage(
                                            imageUrl: widget.plotData.guests[0]['profilePicURL'],
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
                                      widget.plotData.guests.length  == 2 ?Container(
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
                                                    imageUrl: widget.plotData.guests[0]['profilePicURL'],
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
                                                    imageUrl: widget.plotData.guests[1]['profilePicURL'],
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
                                      widget.plotData.guests.length > 2 ?
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
                                                    imageUrl: widget.plotData.guests[0]['profilePicURL'],
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
                                                    imageUrl: widget.plotData.guests[1]['profilePicURL'],
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
                                                    imageUrl: widget.plotData.guests[2]['profilePicURL'],
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
                                      widget.plotData.guests.length == 0 ? Container() : SizedBox(width: 15,),
                                      Text(
                                        "${widget.plotData.guests.length.toString()} attending",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                    ],)

                                  ],
                                ),
                              ],
                            ),
                          ),
                          onPressed: () async {
                            List guestsUsernames = [];
                            widget.plotData.guests.forEach((element) {
                              guestsUsernames.add(element['username']);
                            });
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ListOfGuestsGuestView(
                                          from: 'guestView',
                                          sharedPrefData: widget.sharedPrefData,
                                          plotCode: widget.sharedPrefData.plotCode,
                                          guestsNames: guestsUsernames,
                                        )));
                          }),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Color(0xff630094)),
                          child: Container(
                            padding: EdgeInsets.all(5),
                            child: Row(
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'party info',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Colors.white, fontSize: 20),
                                    ),
                                    Text(
                                      'addy, description, privacy, etc.',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          onPressed: () async {
                            FirestoreFunctions firestoreFunctions = FirestoreFunctions();
                            String hostProfilePic = await firestoreFunctions.getProfilePicURLFromAuthID(widget.plotData.hostAuthID);
                            showDialog(context: context, builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Color(0xff1e1e1e),
                                actions: [
                                  IconButton(icon: Icon(Icons.close, color: Colors.white,), onPressed: (){
                                    Navigator.pop(context);
                                  })
                                ],
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                  Text(widget.plotData.plotName, style: TextStyle(color: Colors.white),),
                                  Row(children: [
                                    widget.plotData.plotPrivacy == "open invite" ? Icon(Icons.lock_open, color: Colors.white,) : Icon(Icons.lock, color: Colors.white,),
                                    SizedBox(width: 5,),
                                    Text(widget.plotData.plotPrivacy, style: TextStyle(
                                        fontSize: 16, color: Colors.white
                                    ),),
                                  ],),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text("plot code: ", style: TextStyle(fontSize: 16, color: Colors.white), ),
                                      Text(widget.sharedPrefData.plotCode, style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      )),
                                      IconButton(
                                          icon: Icon(Icons.copy, color: Colors.white,),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(text: widget.sharedPrefData.plotCode))
                                                .then((value) { //only if ->
                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                            },
                                            );
                                          }
                                      )
                                    ],
                                  ),
                                ],),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Text("about event", style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      fontWeight: FontWeight.bold
                                    ),),
                                    Text(widget.plotData.description, style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16
                                    ),),
                                    SizedBox(height: 10,),
                                    Row(children: [
                                      Container(
                                        child:Icon(Icons.calendar_today, size: 50, color: Colors.white,),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: Color(0xff630094),
                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                        ),
                                      ),
                                      SizedBox(width: 15,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(DateFormat('dd MMMM, y').format(widget.plotData.startDate ).toString(), style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 16
                                          ),),
                                          SizedBox(height: 5,),
                                          Text(DateFormat('EEEE, hh:mm a').format(widget.plotData.startDate ).toString(), style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 16
                                          ),),
                                        ],)
                                    ],),
                                    SizedBox(height: 10,),
                                    GestureDetector(
                                      onTap: (){
                                        MapUtils.openMap(
                                            widget.plotData.lat, widget.plotData.long, context);
                                      },
                                      child: Row(children: [
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          constraints: BoxConstraints(
                                              minHeight: 72,maxWidth: 72,
                                              minWidth: 72,
                                              maxHeight: 72
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(0xff630094),
                                            borderRadius: BorderRadius.all(Radius.circular(15))
                                          ),
                                          child: Icon(Icons.place,
                                            color: Colors.white,
                                            size: 50,),
                                        ),
                                        SizedBox(width: 15,),
                                        Expanded(child:Container(child:Text("${widget.plotData.plotAddress}", style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 16
                                        ),
                                          maxLines: 5,
                                          overflow: TextOverflow.ellipsis,
                                        ), ),
                                        ),
                                        SizedBox(width: 25,),
                                      ],),
                                    ),
                                    SizedBox(height: 10,),
                                    Row(children: [
                                      GestureDetector(
                                          onTap: (){
                                            showDialog(context: context,
                                                barrierDismissible: true,
                                                builder: (BuildContext context) {
                                                  return Dialog(
                                                      backgroundColor: Colors.transparent,
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
                                                            imageUrl: hostProfilePic,
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
                                                      ),
                                                  );
                                                }
                                            );
                                          },
                                          child:Container(
                                              constraints: BoxConstraints(
                                                  maxHeight: 75,
                                                  minWidth: 75,
                                                  maxWidth: 75,
                                                  minHeight: 75
                                              ),
                                              child: CachedNetworkImage(
                                                imageUrl: hostProfilePic,
                                                imageBuilder: (context, imageProvider) => Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.all(
                                                        Radius.circular(15)
                                                    ),
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
                                                      maxHeight: 75,
                                                      minWidth: 75,
                                                      maxWidth: 75,
                                                      minHeight: 75
                                                  ),
                                                  child: CircularProgressIndicator( valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                                      strokeWidth: 4.0),
                                                ),
                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                              )
                                          )),
                                      SizedBox(width: 15,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 125,
                                            child: Text("hosted by\n${widget.plotData.hostName}",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(height: 5,),
                                          Container(
                                            width: 125,
                                            child:Text(widget.plotData.contactDetails, style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16
                                            ),
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                            ), ),
                                        ],
                                      ),
                                      SizedBox(width: 25,),
                                    ],)
                                ],),
                              );
                            });

                          }),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.blue),
                          child: Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.all(5),
                                  child: Icon(Icons.email, color: Colors.white, size: 50,)
                              ),
                              Text("messages from host",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),),
                            ],
                          ),
                          onPressed: () async {
                            FirestoreFunctions firestoreFunctions = FirestoreFunctions();
                            String flyerURL = await firestoreFunctions.getFlyerURLFromPlotCode(widget.sharedPrefData.plotCode);
                            GuestInfoObject guestInfoObject = await firestoreFunctions.makeGuestObjectFromAuthID(widget.sharedPrefData.plotCode, widget.sharedPrefData.authID);
                            String receivingAuthID = await firestoreFunctions.getHostAuthID(widget.sharedPrefData.plotCode);
                            String receivingNotificationToken = await firestoreFunctions.getHostFCMTokenFromPlotCode(widget.sharedPrefData.plotCode);
                            Navigator.push(context, MaterialPageRoute(
                                builder: (BuildContext context) => HostAndGuestDM(
                                  sharedPrefData: widget.sharedPrefData,
                                  receivingAuthID: receivingAuthID,
                                  receivingNotificationToken: receivingNotificationToken,
                                  isHost: false,
                                  plotFlyer: flyerURL == '' ? 'https://firebasestorage.googleapis.com/v0/b/plots-6e93e.appspot.com/o/no_plot_image.jpg?alt=media&token=44aaa97a-0c79-42d5-b4b3-61966d051224' : flyerURL,
                                  guestInfoObject: guestInfoObject,
                                )
                            ));
                          }),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Color(0xff630094)),
                          child: Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.all(5),
                                  child: Icon(Icons.attach_money, color: Colors.greenAccent, size: 50,)
                              ),
                              Text("payment details",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),),
                            ],
                          ),
                          onPressed: () async {
                            print(widget.sharedPrefData.username);
                            FirestoreFunctions firestoreFunctions = FirestoreFunctions();
                            GuestInfoObject guestInfoObject= await firestoreFunctions.makeGuestObjectFromAuthID(widget.sharedPrefData.plotCode, widget.sharedPrefData.authID);
                            showDialog(context: context,
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
                                                fontSize: 25,
                                                color: Colors.green
                                            ),),
                                            Text("${guestInfoObject.status}", style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16
                                            ),)
                                          ],
                                        ),
                                        Expanded(child: Container(),),
                                        Text("plus ones\n${guestInfoObject.plusOnes}",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white
                                        ),),
                                      ],),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        guestInfoObject.paid ? Text('paid and ready to party!',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 32,
                                            color: Colors.green
                                        ),) : Text('not paid yet',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
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
                    ),



                  ],
                ),
              ),
          SizedBox(
            height: 10,
          ),
      ],
    ),
        ));
  }
}
