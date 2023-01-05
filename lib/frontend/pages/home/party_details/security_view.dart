import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/firestore_plot_data.dart';
import 'package:plots/frontend/classes/guest_info_object.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/components/send_message_button.dart';
import 'package:plots/frontend/pages/home/message_board/host_and_guest_dm.dart';
import 'package:plots/frontend/pages/home/party_details/host_view/attend_requests.dart';
import 'package:plots/frontend/pages/home/party_details/host_view/edit_plot.dart';
import 'package:plots/frontend/pages/home/party_details/host_view/list_of_guests_host_view.dart';
import 'package:plots/frontend/pages/home/party_details/host_view/manage_payments.dart';
import 'package:plots/frontend/pages/home/party_details/host_view/manage_security.dart';
import 'package:plots/frontend/pages/home/qr_ticket_process/qr_scanner.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/frontend/pages/home/qr_ticket_process/scanned_guest_info.dart';
import 'package:plots/frontend/pages/static_pages/intro_screens/intro_screens_security.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';

class SecurityView extends StatefulWidget {
  // Party details host view
  final FirestorePlotData plotData;
  final SharedPrefData sharedPrefData;
  final DateTime startDate;
  final int unreadMessages;

  const SecurityView({Key key, this.plotData, this.sharedPrefData, this.unreadMessages, this.startDate})
      : super(key: key);

  @override
  _SecurityViewState createState() => _SecurityViewState();
}

class _SecurityViewState extends State<SecurityView> with TickerProviderStateMixin {
  final snackBar = SnackBar(content: Text('code copied to clipboard'));
  SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
  String announcement;
  TextEditingController controller = TextEditingController();
  final _enterAnnouncementKey = GlobalKey<FormState>();
  final failSnackbar = SnackBar(content: Text('error. try again.', style: TextStyle(color: Colors.white),), backgroundColor: Colors.red,);
  final successSnackbar = SnackBar(content: Text('success!', style: TextStyle(color: Colors.white),), backgroundColor: Colors.green,);
  FirestoreFunctions firestoreFunctions = FirestoreFunctions();
  TabController _nestedTabController;

  String validateAnnouncement(String value,) {
    if (value.isEmpty) {
      return "the announcement can not be empty.";
    }
    return null;
  }

  @override
  void dispose() {
    super.dispose();
    _nestedTabController.dispose();
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nestedTabController = new TabController(length: 3, vsync: this);
    Future.delayed(Duration(milliseconds: 100)).then((_) async{
      if (await sharedPrefsServices.isFirstTimeSecurity() ){
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
            builder: (BuildContext context) => IntroScreensSecurity( sharedPrefData: widget.sharedPrefData,)
        ), (route) => false);      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
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
                    child: SafeArea(child:Container(
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

                    ))),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 275,
                      padding: EdgeInsets.only(right: 13.0, left: 20),
                      child: Text(
                        widget.plotData.plotName,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 5,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      padding: EdgeInsets.only(right: 13.0, left: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("plot code: ", style: TextStyle(fontSize: 16, color: Colors.white),),
                          Text(widget.sharedPrefData.plotCode, style: TextStyle(
                              fontSize: 16,
                              color: Colors.white
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
                    ),
                  ],),
                InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  onTap: () async{
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => QRScanner(
                              sharedPrefData: widget.sharedPrefData,
                            )));
                  },
                  child: Ink(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 4.0),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xffB53D3D),
                                  Color(0xff630094)
                                ]
                            )                    ),
                        child: Icon(
                          Icons.qr_code,
                          color: Colors.white,
                          size: 50,
                        ),
                      )),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _enterAnnouncementKey,
                child: Row(children: [
                  Container(
                    width: 275,
                    child:
                    TextFormField(
                      controller: controller,
                      onChanged: (value) => announcement = value,
                      validator: (value) => validateAnnouncement(value),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black,
                          labelStyle: TextStyle(color: Colors.white),
                          hintText: 'addy has been moved! check party info....',
                          labelText: 'post announcement',
                          hintStyle: TextStyle(
                              color: Colors.grey
                          ),
                          errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          hoverColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                              borderSide:  BorderSide(color: Colors.transparent),
                              borderRadius:
                              BorderRadius.all(Radius.circular(5))),
                          focusedBorder: OutlineInputBorder(
                              borderSide:  BorderSide(color: Colors.transparent),
                              borderRadius:
                              BorderRadius.all(Radius.circular(5))),
                          border: OutlineInputBorder(
                              borderSide:  BorderSide(color: Colors.transparent),
                              borderRadius:
                              BorderRadius.all(Radius.circular(5)))),

                    )
                    ,),
                  SizedBox(width: 10,),
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(15))
                      ),
                      child: SendMessageButton(
                        icon: Icon(Icons.send, color: Colors.white,),
                        callback: ()async{
                          if (_enterAnnouncementKey.currentState.validate()){
                            try{
                              FirestoreFunctions firestoreFunctions = FirestoreFunctions();
                              firestoreFunctions.addAnnouncement(widget.plotData.plotCode, announcement);
                              controller.clear();
                              setState(() {
                                announcement = null;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(successSnackbar);

                            } catch(e){
                              ScaffoldMessenger.of(context).showSnackBar(failSnackbar);
                            }

                          }                  },
                      )
                  ),
                ],),
              ),
            ),

            Container(
              color: Colors.black,
              padding: EdgeInsets.only(top: 10,bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(children: [
                    Text("earned",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 22
                      ),),
                    SizedBox(width: 10,),
                    Text('\$${widget.plotData.profit}',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 22
                      ),),
                  ],),
                  Text("expecting \$${widget.plotData.expectedAmountAtDoor}",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white54
                    ),),
                ],
              ),
            ),
            SizedBox(height: 10,),
            Padding(
              padding:  EdgeInsets.only(left: 16,right: 16,),
              child: Column(children: [
              TabBar(
              controller: _nestedTabController,
              indicatorColor: Color(0xff630094),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Color(0xff630094),
              unselectedLabelColor: Colors.white,
              isScrollable: true,
              tabs: <Widget>[
                Tab(
                  child: Column(
                      children: [
                        Icon(Icons.people, ),
                        Text("guest list", style: TextStyle(
                            fontSize: 12,
                            color: Colors.white
                        ),),
                      ]
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
                  child: Column(
                    children: [
                      Stack(
                        children: <Widget>[
                          Icon(Icons.notifications),
                          widget.plotData.attendRequests.length > 0 ? Positioned(
                            right: 0,
                            child: new Container(
                              padding: EdgeInsets.all(1),
                              decoration: new BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              child: new Text(
                                '${widget.plotData.attendRequests.length}',
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ): Container(),
                        ],
                      ),
                      Text("attend requests", style: TextStyle(
                          fontSize: 12,
                          color: Colors.white
                      ),),
                    ],
                  ),
                ),
                ]
              ),
                Container(
                height: 150,
                margin: EdgeInsets.only(left: 5, right: 5.0),
    child: TabBarView(
    controller: _nestedTabController,
    children: <Widget>[
      Container(
        padding: EdgeInsets.all(10),
        child: DecoratedBox(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color(0xffB53D3D),
                    Color(0xff630094)
                  ]
              )
          ),
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
                            ListOfGuestsHostView(
                              sharedPrefData: widget.sharedPrefData,
                              guestsNames: guestsUsernames,
                            )));
              }),
        ),
      ),
      Container(
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: () async{
            FirestoreFunctions firestoreFunctions = FirestoreFunctions();
            String flyerURL = await firestoreFunctions.getFlyerURLFromPlotCode(widget.sharedPrefData.plotCode);
            GuestInfoObject guestInfoObject = await firestoreFunctions.makeGuestObjectFromAuthID(widget.sharedPrefData.plotCode, widget.sharedPrefData.authID);
            String receivingAuthID = await firestoreFunctions.getHostAuthID(widget.sharedPrefData.plotCode);
            String receivingNotificationToken = await firestoreFunctions.getHostFCMTokenFromPlotCode(widget.sharedPrefData.plotCode);
            Navigator.push(context, MaterialPageRoute(
                builder: (BuildContext context) =>
                    HostAndGuestDM(
                      sharedPrefData: widget.sharedPrefData,
                      isHost: false,
                      receivingAuthID: receivingAuthID,
                      receivingNotificationToken: receivingNotificationToken,
                      plotFlyer: flyerURL == ''
                          ? 'https://firebasestorage.googleapis.com/v0/b/plots-6e93e.appspot.com/o/no_plot_image.jpg?alt=media&token=44aaa97a-0c79-42d5-b4b3-61966d051224'
                          : flyerURL,
                      guestInfoObject: guestInfoObject,
                    )
            ));
          },
          style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              padding: EdgeInsets.all(16)),
          child: Container(
            child: Row(
              children: [
                Icon(Icons.email, color: Colors.white,size: 35,),
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
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.deepPurpleAccent),
            child: Container(
              padding: EdgeInsets.all(5),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'attend requests',
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        'accept or deny people',
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          widget.plotData.attendRequests.length  == 0 ? Container() :
                          widget.plotData.attendRequests.length == 1 ? CircleAvatar(
                            child: CircleAvatar(
                              radius: 25,
                              child: CachedNetworkImage(
                                imageUrl: widget.plotData.attendRequests[0]['profilePicURL'],
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
                          widget.plotData.attendRequests.length  == 2 ?Container(
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
                                        imageUrl: widget.plotData.attendRequests[0]['profilePicURL'],
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
                                        imageUrl: widget.plotData.attendRequests[1]['profilePicURL'],
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
                          widget.plotData.attendRequests.length > 2 ?
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
                                        imageUrl: widget.plotData.attendRequests[0]['profilePicURL'],
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
                                        imageUrl: widget.plotData.attendRequests[1]['profilePicURL'],
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
                                        imageUrl: widget.plotData.attendRequests[2]['profilePicURL'],
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
                          widget.plotData.attendRequests.length == 0 ? Container() : SizedBox(width: 15,),
                          Text(
                            "${widget.plotData.attendRequests.length.toString()} attend requests",
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
              List attendRequests = await firestoreFunctions
                  .getAttendRequestsFromPlotCode(
                  widget.plotData.plotCode);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => AttendRequests(
                          firestorePlotData: widget.plotData,
                          sharedPrefData: widget.sharedPrefData,
                          attendRequests: attendRequests)));
            }),
      ),
    ] ))
              ],),
            ),
          ],
        ),
      ),
    );
  }
}
