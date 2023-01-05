import 'dart:async';
import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/firestore_plot_data.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/components/custom_button.dart';
import 'package:plots/frontend/components/next_button.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/join/make_sure_to_pay.dart';
import 'package:plots/frontend/pages/home/home.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

// bidding page for bidding into parties, included plus ones

class BiddingAndPlusOnes extends StatefulWidget {
  final String plotCode;
  final String instaUsername;
  final SharedPrefData sharedPrefData;
  final bool allowBidding;
  final int minimumBidPrice;
  final bool free;
  final Map ticketLevelsAndPrices;
  final Map paymentMethods;
  final List allTicketLevels;
  final List paymentMethodsList;
  final String firstPaymentMethod;
  final String firstTicketLevel;

  const BiddingAndPlusOnes({Key key, this.instaUsername, this.plotCode, this.sharedPrefData, this.allowBidding, this.minimumBidPrice, this.free, this.ticketLevelsAndPrices, this.paymentMethods, this.allTicketLevels, this.paymentMethodsList, this.firstPaymentMethod, this.firstTicketLevel}) : super(key: key);


  @override
  _BiddingAndPlusOnesState createState() => _BiddingAndPlusOnesState();
}

class _BiddingAndPlusOnesState extends State<BiddingAndPlusOnes> {
  int bidPrice;
  String plusOnes = 'none';
  String paymentDetails;
  String paymentMethod;
  String noteToHost = '';
  String ticketLevel;
  bool addANote = false;
  List<String> paymentMethodsList;
  List<String> allTicketLevels;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final failSnackbar = SnackBar(
    content: Text(
      'error. Try again.',
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.red,
  );
  FirestoreFunctions firestoreFunctions = FirestoreFunctions();
  final _paymentDetailsKey = GlobalKey<FormState>();


  // Future<FirestorePlotData> getInformation() async {
  Future<FirestorePlotData> getInformation() async {
    var firestorePlotData = await firestoreFunctions.makePlotObject(widget.plotCode);
    return firestorePlotData;
  }

  String validatePaymentDetails(String value) {
    if (value == null || value.isEmpty) {
      return "Missing Details";
    } else if (value.length < 5) {
      return "Minimum 5 characters";
    }
    return null;
  }

  void _requestPlot() async {
    FocusScope.of(context).unfocus();
    Timer(Duration(milliseconds: 300), () async{
        if(_paymentDetailsKey.currentState.validate()) {
          try {
            FirebaseMessaging messaging = FirebaseMessaging.instance;
            SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
            FirestoreFunctions firestoreFunctions = FirestoreFunctions();
            await sharedPrefsServices.setPlotCode(widget.plotCode);
            await sharedPrefsServices.setPlotStatusJoined();
            await sharedPrefsServices.setUserNotApprovedStatus();
            String profilePicURL = await firestoreFunctions
                .getProfilePicURLFromAuthID(widget.sharedPrefData.authID);
            await firestoreFunctions.updateUserInfo(
                authID: widget.sharedPrefData.authID,
                fields: ['plotCode', 'joinedPlot', 'approved'],
                newValues: [widget.plotCode, true, false]);
            int numberOfPlusOnes = 0;
            if (plusOnes != 'none') {
              numberOfPlusOnes = int.parse(plusOnes[1]);
            }
            int totalCost = 0;
            totalCost = widget.ticketLevelsAndPrices[ticketLevel] +
                widget.ticketLevelsAndPrices[ticketLevel] * numberOfPlusOnes;
            String FCMtoken = await messaging.getToken();
            await firestoreFunctions.newApproveRequest(
              FCMtoken: widget.sharedPrefData.FCMtoken != null ? widget.sharedPrefData.FCMtoken : FCMtoken == null ? '' : FCMtoken,
              authID: widget.sharedPrefData.authID,
              username: widget.sharedPrefData.username,
              noteToHost: addANote ? noteToHost : "none",
              plotCode: widget.plotCode,
              price: widget.allowBidding ? bidPrice : totalCost,
              profilePicURL: profilePicURL,
              plusOnes: plusOnes,
              instaUsername: widget.instaUsername,
              paymentMethod: paymentMethod,
              paymentDetails: paymentDetails,
              status: ticketLevel,
            );
            String fcmtoken = await firestoreFunctions.getHostFCMTokenFromPlotCode(widget.plotCode);
            await sendNotification(fcmtoken);
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        MakeSureToPay(
                          totalCost: widget.allowBidding ? bidPrice : totalCost,
                          paymentDetails: paymentDetails,
                          allTicketLevelsAndPrices: widget.ticketLevelsAndPrices,
                          ticketLevel: ticketLevel,
                          allPaymentMethods: widget.paymentMethods,
                          paymentMethod: paymentMethod,
                          plusOnes: plusOnes,
                          status: ticketLevel,
                        )
                ));
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(failSnackbar);
            _btnController.reset();
            print(e.toString());
          }
        }
       else {
        _btnController.reset();
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    paymentMethod = widget.firstPaymentMethod;
    ticketLevel = widget.firstTicketLevel;
    paymentMethodsList = widget.paymentMethodsList;
    allTicketLevels = widget.allTicketLevels;
  }

  String validatePrice(String value) {
    if (value == null || value.isEmpty) {
      return "Missing Number";
    }
    return null;
  }


  Future<void> sendNotification(String token) async {
    try{
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendNewAttendRequestNotification');
      await callable.call(token);
    } catch(e){
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(elevation: 0, title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Container(),),
            Text("Select a ticket", style: TextStyle(
                color: Colors.white,
                fontSize: 16
            )),
            SizedBox(width: 30,),
            Container(width: 25, height: 25, color: Color(0xff630094),),
            Text(" = selected", style: TextStyle(
                color: Colors.white,
                fontSize: 14
            ),),
            Expanded(child: Container(),),
          ],),),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    children: [
                      Text("IMPORTANT: plots does not take any money out of your pocket. you are not directly paying the host through the app. instead, you will be selecting a payment method and then paying the host through that method if needed.", style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),),
                      SizedBox(height: 5,),
                      Column(
                        children: widget.ticketLevelsAndPrices.entries.map((entry) {
                          return Column(children: [ Ticket(radius: 15,
                            clipShadows: [ClipShadow(color: Colors.black)],
                            child: GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  ticketLevel = entry.key;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.only(left: 15),
                                height: 100,
                                  width: 200,
                                  color:  ticketLevel == entry.key ? Color(0xff630094) : Colors.grey,
                                  child: Row(
                                    children: [
                                Text("\$${entry.value}", style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold
                                ),),
                                SizedBox(width: 20,),
                                Container(
                                  width: 120,
                                  child: Text('${entry.key}', style: TextStyle(
                                  fontSize: 20,
                                    color: Colors.white
                                ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                                  )

                              ],)
                            ))), SizedBox(height: 10,)]);
                        }
                        ).toList(),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 16,right: 16),
                        child: Row(
                          children: [
                            Expanded(child: Container(),),
                            Text(
                              'Payment Method',
                              style: TextStyle(
                                  fontSize: 20),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            DropdownButton<String>(
                              value: paymentMethod,
                              icon: Icon(Icons.arrow_drop_down,
                                  color: Colors.white),
                              iconSize: 24,
                              elevation: 16,
                              style: TextStyle(color: Colors.white),
                              dropdownColor: Color(0xff1e1e1e),
                              underline: Container(
                                height: 2,
                                color: Color(0xff630094),
                              ),
                              onChanged: (String newValue) {
                                setState(() {
                                  paymentMethod = newValue;
                                });
                              },
                              items: paymentMethodsList.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    if (value == "Other1" || value == "Other2"){
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text("${widget.paymentMethods[value].length > 14 ? widget.paymentMethods[value].substring(0,15) : widget.paymentMethods[value] }...", style: TextStyle(
                                            fontWeight: FontWeight.normal
                                        ),),
                                      );
                                    } else {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value, style: TextStyle(
                                            fontWeight: FontWeight.normal
                                        ),),
                                      );
                                    }
                                  }).toList(),
                            ),
                            Expanded(child: Container(),)
                          ],
                        ),
                      ),
                          Form(
                            key: _paymentDetailsKey,
                            child: Column(
                              children: [
                            widget.allowBidding ?  Container(
                                  padding: EdgeInsets.all(16),
                                  child:Row(
                                    children: [
                                      Expanded(child: Container()),
                                      Container(
                                        child:Text("Enter the price you\nwant to pay to get in"),
                                      ),
                                      SizedBox(width: 20,),
                                      Container(
                                        width: 100,
                                        child:TextFormField(
                                            onChanged: (value) => bidPrice = int.parse(value),
                                            autocorrect: false,
                                            cursorColor: Colors.white,
                                            validator: (value) => validatePrice(value.toString()),
                                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(color: Colors.white),
                                            decoration: InputDecoration(
                                              // flashing container
                                              // unfocus after you click background
                                                filled: true,
                                                fillColor: Colors.black,
                                                labelStyle: TextStyle(color: Colors.white),
                                                labelText: "bid price",
                                                errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
                                                    BorderRadius.all(Radius.circular(5))))
                                        ),),
                                      Expanded(child: Container()),
                                    ],
                                  ),
                                ): Container(),
                                Container(
                                  child: Row(
                                    children: [
                                      Expanded(child: Container(),),
                                      RawMaterialButton(
                                          elevation: 2.0,
                                          constraints: BoxConstraints(
                                              maxWidth: 50,
                                              minWidth: 50
                                          ),
                                          child: Icon(
                                            Icons.info,
                                            size: 25.0,
                                            color: Colors.white,
                                          ),
                                          shape: CircleBorder(),
                                          onPressed: (){
                                            FocusScope.of(context).unfocus();
                                            showDialog(context: context,
                                                barrierDismissible: true,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    backgroundColor: Color(0xff1e1e1e),
                                                    title: Text('plus ones',style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white
                                                    ),),
                                                    content: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Text('how many people are you bringing?',style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white
                                                        ),),
                                                      ],
                                                    ),
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

                                          }),
                                      Text(
                                        'Plus ones',
                                        style: TextStyle(
                                            fontSize: 20),
                                      ),

                                      SizedBox(
                                        width: 10,
                                      ),
                                      DropdownButton<String>(
                                        value: plusOnes,
                                        icon: Icon(Icons.arrow_drop_down,
                                            color: Colors.white),
                                        iconSize: 24,
                                        elevation: 16,
                                        style: TextStyle(color: Colors.white),
                                        dropdownColor: Color(0xff1e1e1e),
                                        underline: Container(
                                          height: 2,
                                          color: Color(0xff630094),
                                        ),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            plusOnes = newValue;
                                          });
                                        },
                                        items: <String>[
                                          'none',
                                          '+1',
                                          '+2',
                                          '+3',
                                          '+4',
                                          '+5',
                                        ].map<DropdownMenuItem<String>>(
                                                (String value) {
                                              return DropdownMenuItem<String>(

                                                value: value,
                                                child: Text(value, style: TextStyle(
                                                    fontWeight: FontWeight.normal
                                                ),),
                                              );
                                            }).toList(),
                                      ),
                                      Expanded(child: Container(),)
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10,),
                                TextFormField(
                                    onChanged: (value) => paymentDetails = value,
                                    autocorrect: false,
                                    toolbarOptions: ToolbarOptions(
                                      copy: true,
                                      paste: true,
                                      selectAll: true,
                                      cut: true,
                                    ),
                                    maxLines: null,
                                    cursorColor: Colors.white,
                                    validator: (value) => validatePaymentDetails(value),
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      // flashing container
                                      // unfocus after you click background
                                        filled: true,
                                        fillColor: Colors.black,
                                        labelStyle: TextStyle(color: Colors.white),
                                        labelText: "payment details",
                                        hintText: "My venmo is @hamesjan",
                                        hintStyle: TextStyle(
                                            color: Colors.grey
                                        ),
                                        errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
                                            BorderRadius.all(Radius.circular(5))))),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.transparent,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    child: Icon(addANote ? Icons.remove : Icons.add_circle_outline, color: Colors.purpleAccent,),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(addANote ? "REMOVE NOTE": "ADD NOTE" , style: TextStyle(
                                        color: Colors.purpleAccent,
                                        fontSize: 16
                                      ),),
                                      Text("optional", style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 8
                                      ),),
                                    ],
                                  ),
                              ],),
                              onPressed: (){
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  addANote = !addANote;
                                });
                              },
                            ),
                          ),
                      SizedBox(height: 10,),
                      addANote? TextFormField(
                              onChanged: (value) => noteToHost = value,
                              autocorrect: false,
                              toolbarOptions: ToolbarOptions(
                                copy: true,
                                paste: true,
                                selectAll: true,
                                cut: true,
                              ),
                              maxLines: null,
                              minLines: 3,
                              cursorColor: Colors.white,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                // flashing container
                                // unfocus after you click background
                                  filled: true,
                                  fillColor: Colors.black,
                                  labelStyle: TextStyle(color: Colors.white),
                                  hintText: "i am a celebrity",
                                  labelText: "note to host",
                                  hintStyle: TextStyle(
                                      color: Colors.grey
                                  ),
                                  errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
                                      BorderRadius.all(Radius.circular(5))
                                  ))) : Container(),
                      SizedBox(height: 20,),
                      Container(
                          alignment: Alignment.center,
                          child:  RoundedLoadingButton(
                            color: Color(0xff630094),
                            width: 165,
                            height: 50,
                            borderRadius: 5,
                            child: Text('request', style: TextStyle(fontSize: 20,color: Colors.white)),
                            controller: _btnController,
                            onPressed: _requestPlot,
                          )
                      ),


                        ],
                      ),

                ));

  }
}
