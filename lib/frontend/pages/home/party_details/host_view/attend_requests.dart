import 'package:cached_network_image/cached_network_image.dart';
import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_transition/page_transition.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/firestore_plot_data.dart';
import 'package:plots/frontend/classes/guest_info_object.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/home/home.dart';
import 'package:plots/frontend/pages/home/message_board/host_and_guest_dm.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';

class AttendRequests extends StatefulWidget {
  // Page that can only be accessed by host where you can deny or accept requests given price and guests
  final FirestorePlotData firestorePlotData;
  final List attendRequests;
  final SharedPrefData sharedPrefData;

  const AttendRequests({Key key, this.attendRequests, this.sharedPrefData, this.firestorePlotData}) : super(key: key);
  @override
  _AttendRequestsState createState() => _AttendRequestsState();
}

class _AttendRequestsState extends State<AttendRequests> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<void> sendNotification(String token) async {
    try{
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendApprovalUpdateNotification');
      await callable.call(token);

    } catch(e){
      print(e.toString());
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined),
          onPressed: ()async{
            Navigator.pushAndRemoveUntil(context, PageTransition(
              type: PageTransitionType.leftToRight,
              child: Home(
                initialTabIndex: 0,
                sharedPrefData: widget.sharedPrefData,
              ),
            ), (route) => false);
          },
        ),
        title: Text('attend requests'),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Text('the following people want to attend your party. Approve or decline their request.'),
          ),
          Divider(thickness: 2,),
          widget.attendRequests.length == null || widget.attendRequests.length == 0 ?
          Container(
              padding: EdgeInsets.all(16),
              child: Text('you have no requests.')
          ) :
         Expanded(child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.attendRequests.length,
              itemBuilder: (BuildContext context, int index) {
                final item = widget.attendRequests[index]['authID'];
                return Dismissible(
                    key: Key(item),
                  child: Container(
                  padding: EdgeInsets.all(16),
                  child: Ticket(
                    radius: 25.0,
                    clipShadows: [ClipShadow(color: Colors.black)],
                    child:
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black
                          ),
                padding: EdgeInsets.all(20),
                child:
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          border: Border.all(color: Colors.white)
                        ),
                          child: Row(
                            children: <Widget>[
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xffB53D3D),
                                Color(0xff630094)
                              ]),
                              borderRadius: BorderRadius.all(Radius.circular(15))
                            ),
                            padding: EdgeInsets.all(5),
                            child:ElevatedButton(
                              style: ElevatedButton.styleFrom(primary: Colors.transparent,elevation: 0),
                              child: Icon(Icons.mail,  size: 50 ,color: Colors.white,),
                              onPressed: ()async{
                                FirestoreFunctions firestoreFunctions = FirestoreFunctions();
                                String flyerURL = await firestoreFunctions.getFlyerURLFromPlotCode(widget.sharedPrefData.plotCode);
                                GuestInfoObject guestInfoObject = GuestInfoObject(
                                  authID:  widget.attendRequests[index]['authID'],
                                  username:  widget.attendRequests[index]['username'],
                                  price:  widget.attendRequests[index]['price'],
                                  paymentMethod:  widget.attendRequests[index]['paymentMethod'],
                                  plusOnes:  widget.attendRequests[index]['plusOnes'],
                                  profilePicURL:  widget.attendRequests[index]['profilePicURL'],
                                  paid:  widget.attendRequests[index]['paid'],
                                  FCMtoken:  widget.attendRequests[index]['FCMtoken'],
                                  instaUsername:  widget.attendRequests[index]['instaUsername'],
                                  paymentDetails:  widget.attendRequests[index]['paymentDetails'],
                                  noteToHost:  widget.attendRequests[index]['noteToHost'],
                                  status:  widget.attendRequests[index]['status'],
                                );
                                if(guestInfoObject.username == null){
                                  showDialog(context: context,
                                      barrierDismissible: true, builder: (BuildContext context){
                                        return AlertDialog(
                                          backgroundColor: Color(0xff1e1e1e),
                                          title: Text("this user has left the plot"),
                                        );
                                      });
                                } else{
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) => HostAndGuestDM(
                                      sharedPrefData: widget.sharedPrefData,
                                      receivingAuthID: widget.attendRequests[index]['authID'],
                                      receivingNotificationToken:  widget.attendRequests[index]['FCMtoken'],
                                      isHost: true,
                                      plotFlyer: flyerURL == '' ? 'https://firebasestorage.googleapis.com/v0/b/plots-6e93e.appspot.com/o/no_plot_image.jpg?alt=media&token=44aaa97a-0c79-42d5-b4b3-61966d051224' : flyerURL,
                                      guestInfoObject: guestInfoObject,
                                    )
                                ));}
                              },
                            ),
                          ),
                                SizedBox(height: 5,),
                                GestureDetector(
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
                                                      imageUrl: widget.attendRequests[index]['profilePicURL'],
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
                                    child:Container(
                                        alignment: Alignment.topLeft,
                                        constraints: BoxConstraints(
                                            maxHeight: 100,
                                            minWidth: 100,
                                            maxWidth: 100,
                                            minHeight: 100
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: widget.attendRequests[index]['profilePicURL'],
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
                                                maxHeight: 100,
                                                minWidth: 100,
                                                maxWidth: 100,
                                                minHeight: 100
                                            ),
                                            child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                                                strokeWidth: 4.0
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                        )
                                    )),
                              ],),

                              SizedBox(width: 10,),
                              Container(
                                constraints: BoxConstraints(
                                    minHeight: 175,
                                    minWidth: 175,
                                    maxWidth: 175,
                                    maxHeight: 175
                                ),
                                child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(widget.attendRequests[index]['username'],
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                          child: Row(
                                            children: [
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
                                                      widget.attendRequests[index]['instaUsername'],
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,),
                                                    ),
                                                  ),
                                                ],),
                                              ),
                                            ],
                                          ),
                                        ),
                                        widget.attendRequests[index]['plusOnes'] == "none" ?
                                        Text(
                                          "${widget.attendRequests[index]['status']}",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.grey
                                          ),
                                        ) : Text(
                                          "${widget.attendRequests[index]['status']} x ${(int.parse(widget.attendRequests[index]['plusOnes'][1]) + 1).toString()}",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.grey
                                          ),
                                        ),
                                        Text(
                                          "\$${widget.attendRequests[index]['price'].toString()}",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25,
                                              color: Colors.green
                                          ),
                                        ),
                                         Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ElevatedButton(
                                                  child: Container(
                                                      child:Text("accept", style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white
                                                  ))),
                                                  style: ElevatedButton.styleFrom(primary: Colors.blue),
                                                  onPressed: () async {
                                                    showDialog(context: context,
                                                        barrierDismissible: true,
                                                        builder: (BuildContext context) {
                                                          return AlertDialog(
                                                            backgroundColor: Color(0xff1e1e1e),
                                                            title: widget.attendRequests[index]['paymentMethod'] == "Pay at Door" ?
                                                            Text("${widget.attendRequests[index]['username']} will pay you \$${widget.attendRequests[index]['price']} at the door.\ndon't forget to update his payment status at the door!", style: TextStyle(
                                                                color: Colors.white
                                                            ),)
                                                            : Text("has ${widget.attendRequests[index]['username']} payed you \$${widget.attendRequests[index]['price']} through ${widget.attendRequests[index]['paymentMethod'] == "Other1" ||
                                                                widget.attendRequests[index]['paymentMethod'] == "Other2" ? "${widget.firestorePlotData.paymentMethods[widget.attendRequests[index]['paymentMethod']]}"
                                                                : widget.attendRequests[index]['paymentMethod']}?", style: TextStyle(
                                                                color: Colors.white
                                                            ),),
                                                            content: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Text("payment details", style: TextStyle(
                                                                  fontSize: 20,
                                                                  color: Colors.white
                                                                ),),
                                                                Text("${widget.attendRequests[index]['paymentDetails']}", style: TextStyle(
                                                                  color: Colors.grey,
                                                                  fontSize: 16
                                                                ),),
                                                                Divider(thickness: 2,),
                                                                Text("note to host", style: TextStyle(
                                                                  fontSize: 20,
                                                                  color: Colors.white
                                                                ),),
                                                                Text("${widget.attendRequests[index]['noteToHost']}", style: TextStyle(
                                                                  color: Colors.grey,
                                                                  fontSize: 16
                                                                ),),
                                                              ],
                                                            ),
                                                            actions: <Widget>[
                                                              Row(children: [
                                                                IconButton(
                                                                  icon: Icon(Icons.close, color: Colors.white,),
                                                                  onPressed: (){
                                                                    Navigator.pop(context);
                                                                  },
                                                                ),Expanded(child: Container(),),
                                                                TextButton(child: Text("approve request", style: TextStyle(
                                                                    fontSize: 20,
                                                                    color: Colors.blue
                                                                ),), onPressed: ()async {
                                                                  FirestoreFunctions firestoreFunctions = FirestoreFunctions();
                                                                  bool guestExists = await firestoreFunctions.checkIfGuestExists(widget.sharedPrefData.plotCode, widget.attendRequests[index]['authID']);
                                                                  if (guestExists){
                                                                    setState(() {
                                                                      widget.attendRequests.removeAt(index);
                                                                    });
                                                                    Navigator.pop(context);
                                                                  } else {
                                                                  List tempList = []..addAll(widget.attendRequests);
                                                                  tempList.remove(widget.attendRequests[index]);
                                                                  firestoreFunctions.updatePlotsInfo(plotCode: widget.sharedPrefData.plotCode, field: 'attendRequests', newValue: tempList);
                                                                  // updating guestList
                                                                  var plotInfo = await _firestore.collection('plots').doc(widget.sharedPrefData.plotCode).get();
                                                                  List currGuests = []..addAll(plotInfo.data()['guests']);
                                                                  currGuests.add({
                                                                    'username': widget.attendRequests[index]['username'],
                                                                    'authID':widget.attendRequests[index]['authID'],
                                                                    'paymentMethod':widget.attendRequests[index]['paymentMethod'],
                                                                    'plusOnes':widget.attendRequests[index]['plusOnes'],
                                                                    'profilePicURL': widget.attendRequests[index]['profilePicURL'],
                                                                    'FCMtoken': widget.attendRequests[index]['FCMtoken'],
                                                                    'price':widget.attendRequests[index]['price'],
                                                                    'instaUsername': widget.attendRequests[index]['instaUsername'],
                                                                    'paid': widget.attendRequests[index]['paymentMethod'] == "Pay at Door" ? false : true,
                                                                    'paymentDetails': widget.attendRequests[index]['paymentDetails'],
                                                                    'noteToHost': widget.attendRequests[index]['noteToHost'],
                                                                    'status': widget.attendRequests[index]['status'],
                                                                  });
                                                                  widget.attendRequests[index]['paymentMethod'] == "Pay at Door" ? firestoreFunctions.updateExpectedAmountAtDoor(widget.sharedPrefData.plotCode, widget.attendRequests[index]['price'])
                                                                  :firestoreFunctions.updateProfit(widget.sharedPrefData.plotCode, widget.attendRequests[index]['price']);
                                                                  firestoreFunctions.updatePlotsInfo(plotCode: widget.sharedPrefData.plotCode, field: 'guests', newValue:currGuests);
                                                                  firestoreFunctions.updateUserInfo(authID: widget.attendRequests[index]['authID'], fields: ['approved'], newValues: [true]);
                                                                  sendNotification(widget.attendRequests[index]['FCMtoken']);
                                                                  setState(() {
                                                                    widget.attendRequests.removeAt(index);
                                                                  });
                                                                  Navigator.pop(context);
                                                                  }
                                                                },),
                                                              ],)
                                                            ],
                                                          );
                                                        }
                                                    );
                                                  }
                                              ),
                                              SizedBox(width: 5,),
                                              ElevatedButton(
                                                child: Text("decline", style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white
                                                ),),
                                                  style: ElevatedButton.styleFrom(
                                                    primary: Colors.red
                                                  ),
                                                  onPressed: ()async{
                                                    showDialog(context: context,
                                                        barrierDismissible: true,
                                                        builder: (BuildContext context) {
                                                          return AlertDialog(
                                                            backgroundColor: Color(0xff1e1e1e),
                                                            title: Text("are you sure you want to decline ${widget.attendRequests[index]['username']}'s request?", style: TextStyle(
                                                              color: Colors.white
                                                            ),),
                                                            actions: <Widget>[
                                                              Row(children: [
                                                                IconButton(
                                                                  icon: Icon(Icons.close, color: Colors.white,),
                                                                  onPressed: (){
                                                                    Navigator.pop(context);
                                                                  },
                                                                ),Expanded(child: Container(),),
                                                                TextButton(child: Text("decline Request", style: TextStyle(
                                                                  fontSize: 20,
                                                                  color: Colors.red
                                                                ),), onPressed: ()async{
                                                                  FirestoreFunctions firestoreFunctions = FirestoreFunctions();
                                                                  bool attendRequestExists = await firestoreFunctions.checkIfAttendRequestExists(widget.sharedPrefData.plotCode, widget.attendRequests[index]['authID']);
                                                                  if (attendRequestExists){
                                                                  firestoreFunctions.updateUserInfo(authID: widget.attendRequests[index]['authID'], fields: ['approved', 'joinedPlot', 'plotCode'], newValues: [false,false,'none']);
                                                                  List tempList = []..addAll(widget.attendRequests);
                                                                  tempList.remove(widget.attendRequests[index]);
                                                                  firestoreFunctions.updatePlotsInfo(plotCode: widget.sharedPrefData.plotCode, field: 'attendRequests', newValue:tempList);
                                                                  sendNotification(widget.attendRequests[index]['FCMtoken']);
                                                                  setState(() {
                                                                    widget.attendRequests.removeAt(index);
                                                                  });
                                                                  Navigator.pop(context);
                                                                  } else {
                                                                    setState(() {
                                                                      widget.attendRequests.removeAt(index);
                                                                    });
                                                                    Navigator.pop(context);
                                                                  }
                                                                },),
                                                              ],)
                                                            ],
                                                          );
                                                        }
                                                    );
                                                  }
                                              ),
                                            ],),
                                        ],
                                    )
                                ),
                            ],)
                      ),
                  )
                  )
                  )
                );
              })
         )
        ],
      ),
    );
  }
}
