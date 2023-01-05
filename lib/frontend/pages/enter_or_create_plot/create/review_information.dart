import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as encoder;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:plots/backend/firestore_functions.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:plots/backend/google_maps_api_key.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/components/custom_button.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:plots/frontend/components/next_button.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/create/share_plot_code.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/create/three_step_widget.dart';
import 'package:plots/frontend/pages/home/party_details/host_view/edit_plot.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

GMAK kGoogleApiKey = GMAK();

class ReviewInformation extends StatefulWidget {
  final SharedPrefData sharedPrefData;
  final String plotName;
  final String plotDescription;
  final String plotAddress;
  final String hostName;
  final String contactDetails;
  final double latitude;
  final double longitude;
  final DateTime startDate;
  final String plotPrivacy;
  final ui.Image signature;
  final File plotImage;
  final bool canBid;
  final int minimumBidPrice;
  final bool free;
  final Map<String, int> ticketLevelsAndPrices;
  final Map<String, String> paymentMethods;

  const ReviewInformation({Key key, this.sharedPrefData, this.signature, this.plotName, this.plotDescription, this.plotAddress, this.hostName, this.contactDetails, this.latitude, this.longitude, this.startDate, this.plotPrivacy, this.plotImage, this.canBid, this.minimumBidPrice, this.free, this.ticketLevelsAndPrices, this.paymentMethods}) : super(key: key);


  @override
  _ReviewInformationState createState() => _ReviewInformationState();
}

class _ReviewInformationState extends State<ReviewInformation> {
  final _reviewPlotDetailsKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController(
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  final ImagePicker _picker = ImagePicker();
  String errorMessage;
  final failSnackbar = SnackBar(
    content: Text(
      'error. Try again.',
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.red,
  );
  final successSnackbar = SnackBar(
    content: Text(
      'success!',
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.green,
  );
  String editedPlotName;
  String editedPlotDescription;
   String editedPlotAddress;
   String editedHostName;
   String editedContactDetails;
   double editedLatitude;
   double editedLongitude;
   DateTime editedStartDate;
   String editedPlotPrivacy;
   File editedPlotImage;
  FirebaseStorage storage = FirebaseStorage.instance;
  FocusNode plotNameNode = FocusNode();
  FocusNode plotDescriptionNode = FocusNode();
  FocusNode plotHostNameNode = FocusNode();
  FocusNode plotContactDetailsNode = FocusNode();


  Future getImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery,imageQuality: 80,
        maxHeight: 480, maxWidth: 640,
        );
    setState(() {
      editedPlotImage = File(pickedFile.path);
    });
  }

  @override
  void initState() {
    editedPlotPrivacy = widget.plotPrivacy;
    super.initState();
  }

  String validatePlotName(String value) {
    if (value == null || value.isEmpty) {
      return "missing plot name";
    } else if (value.length < 4) {
      return "minimum 5 characters";
    }
    return null;
  }


  void _postPlot() async {
    Timer(Duration(milliseconds: 300), () async{
      if (_reviewPlotDetailsKey.currentState.validate()) {
        try {
          SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
          String plotCode = UniqueKey().toString().substring(2, 7);
          await _firestore.collection('plots').doc(plotCode).set({
            'plotCode': plotCode,
            'plotName': editedPlotName == null ? widget.plotName :editedPlotName,
            'hostName': editedHostName == null ? widget.hostName : editedHostName,
            'contactDetails': editedContactDetails == null ? widget.contactDetails: editedContactDetails,
            'description': editedPlotDescription == null ? widget.plotDescription: editedPlotDescription,
            'closed': false,
            'startDate': editedStartDate == null ? widget.startDate : editedStartDate,
            'plotPrivacy': editedPlotPrivacy != widget.plotPrivacy? editedPlotPrivacy: widget.plotPrivacy,
            'attendRequests': [],
            'guests': [],
            'security': [],
            'unreadMessages': [],
            'announcements': [],
            'hostFCMtoken': widget.sharedPrefData.FCMtoken,
            'plotAddress': editedPlotAddress == null ? widget.plotAddress : editedPlotAddress,
            'lat': editedLatitude == null ? widget.latitude : editedLatitude,
            'long': editedLongitude == null ? widget.longitude: editedLongitude,
            'flyerURL': '',
            'originalHostName': widget.sharedPrefData.username,
            'signature': '',
            'hostAuthID': widget.sharedPrefData.authID,
            'canBid': widget.canBid,
            'minimumBidPrice': widget.minimumBidPrice,
            'free': widget.free,
            'profit': 0,
            'expectedAmountAtDoor': 0,
            'paymentMethods': widget.paymentMethods == null ? {} : widget.paymentMethods,
            'ticketLevelsAndPrices': widget.ticketLevelsAndPrices == null ? {} : widget.ticketLevelsAndPrices,
          });
          try {
            if(widget.signature != null){
              int height = widget.signature.height;
              int width = widget.signature.width;

              ByteData data = await widget.signature.toByteData();
              Uint8List listData = data.buffer.asUint8List();

              encoder.Image toEncodeImage = encoder.Image.fromBytes(width, height, listData);
              encoder.JpegEncoder jpgEncoder = encoder.JpegEncoder();

              List<int> encodedImage = jpgEncoder.encodeImage(toEncodeImage);

              final FirebaseStorage storage = FirebaseStorage.instance;
              final String picture = "$plotCode-signature-by-${widget.sharedPrefData.authID}.jpg";
              UploadTask task = storage.ref().child(picture).putData(Uint8List.fromList(encodedImage));
              task.then((res) async {
                var str = await res.ref.getDownloadURL();
                FirestoreFunctions firestorefunctions =
                FirestoreFunctions();
                firestorefunctions.updatePlotsInfo(
                    plotCode: plotCode,
                    field: 'signature',
                    newValue: str);
              });
            }
            if (editedPlotImage == null){
              if (widget.plotImage != null) {
                String filename = '$plotCode.jpg';
                Reference ref = storage.ref().child(filename);
                UploadTask uploadTask = ref.putFile(widget.plotImage);
                uploadTask.then((res) async {
                  var str = await res.ref.getDownloadURL();
                  FirestoreFunctions firestorefunctions =
                  FirestoreFunctions();
                  firestorefunctions.updatePlotsInfo(
                      plotCode: plotCode,
                      field: 'flyerURL',
                      newValue: str);
                });
              }
            } else {
              String filename = '$plotCode.jpg';
              FirebaseStorage storage = FirebaseStorage.instance;
              Reference ref = storage.ref().child(filename);
              UploadTask uploadTask = ref.putFile(editedPlotImage);
              uploadTask.then((res) async {
                var str = await res.ref.getDownloadURL();
                FirestoreFunctions firestorefunctions =
                FirestoreFunctions();
                firestorefunctions.updatePlotsInfo(
                    plotCode: plotCode,
                    field: 'flyerURL',
                    newValue: str);
              });
            }
          } catch (e) {
            _btnController.reset();
            print(e.toString());
          }
          sharedPrefsServices.setPlotCode(plotCode);
          sharedPrefsServices.setPlotStatusJoined();
          sharedPrefsServices.setUserApprovedStatus();
          FirestoreFunctions firestoreFunctions =
          FirestoreFunctions();
          firestoreFunctions.updateUserInfo(authID: widget.sharedPrefData.authID, fields: ['plotCode', 'approved', 'joinedPlot'], newValues: [plotCode, true, true]);
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => SharePlotCode(
                    plotCode: plotCode,
                  )));
        } catch (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(failSnackbar);
          _btnController.reset();
          print(e.toString());
        }
      } else {
        _btnController.reset();
      }
    });
  }


  String validateField(String value) {
    if (value == null || value.isEmpty) {
      return "missing field";
    }
    return null;
  }


  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      // get detail (lat/lng)
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey.apiKey,
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId);
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;
      setState(() {
        editedPlotAddress = detail.result.formattedAddress;
        editedLatitude = lat;
        editedLongitude = lng;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: ThreeStepWidget(step: 3,),
        elevation: 0,
        backgroundColor: Colors.transparent,
          ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 16, right: 16),
          child:Form(
            key: _reviewPlotDetailsKey,
            child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Review Information", style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: Colors.white
            ),),
            Text("Check it b4 u wreck it", style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 15,
              color: Colors.white
            ),),
            SizedBox(height: 5,),
            widget.free ? Container() : Divider(thickness: 2, color: Colors.white,),
            widget.free ? Container() :  ExpandablePanel(
              theme: ExpandableThemeData(
                iconColor: Colors.white
              ),
              header:  Text("payment info", style: TextStyle(color:Colors.white, fontSize: 25),),
              collapsed:Container() ,
              expanded: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100.0,
                    child:  RawScrollbar(
                      controller: _scrollController,
                      thickness: 4,
                      thumbColor: Colors.white,
                      child: ListView.builder(
                          shrinkWrap: true,
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.ticketLevelsAndPrices.entries.length,
                          itemBuilder: (BuildContext context, int index) => Padding(
                              padding: EdgeInsets.only(right: 10, bottom: 15, top: 15),
                              child:Ticket(radius: 15,
                                  clipShadows: [ClipShadow(color: Colors.black)],
                                  child: Container(
                                      padding: EdgeInsets.only(left: 15),
                                      height: 85,
                                      width: 125,
                                      color:   Color(0xff630094),
                                      child: Row(
                                        children: [
                                          Text("\$${widget.ticketLevelsAndPrices.values.toList()[index]}", style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.greenAccent,
                                              fontWeight: FontWeight.bold
                                          ),),
                                          SizedBox(width: 5,),
                                          Container(
                                            width: 75,
                                            child: Text('${widget.ticketLevelsAndPrices.keys.toList()[index]}', style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white
                                            ),
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                            ),
                                          )

                                        ],)
                                  ))
                          )
                        ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  widget.canBid ? Container(
                    padding: EdgeInsets.all(15),
                    width:350,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        color: Colors.black
                    ),
                    child: Row(children: [
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: 25,
                          minWidth: 25,
                          maxWidth: 25,
                          minHeight: 25,
                        ),
                        child: Container(
                          child: Icon(Icons.attach_money, color: Colors.white,),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Text( "minimum bid price", style: TextStyle(fontSize: 16, color: Colors.white),),
                      Expanded(child: Container(),),
                      Container(
                        width: 100,
                        child: Text(
                          widget.minimumBidPrice.toString(),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:  Colors.white,
                            fontSize: 16,),
                        ),
                      ),
                      SizedBox(width: 5,)
                    ],),
                  ) : Container(),
                  widget.canBid ? SizedBox(height: 10,) : Container(),
                  Column(
                      children:
                      widget.paymentMethods.entries.map((entry) {
                        if(entry.key != "Other1" && entry.key != "Other2"&& entry.key != "Pay at Door"){
                          return Column(children: [
                            GestureDetector(
                              onTap: (){
                                showDialog(context: context, builder: (BuildContext context){
                                  return AlertDialog(
                                    backgroundColor: Color(0xff1e1e1e),
                                    title: Text(entry.key, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                    content:  Text(entry.value, style: TextStyle(color: Colors.white),),
                                    actions: [
                                      IconButton(icon: Icon(Icons.close, color: Colors.white,), onPressed: (){
                                        Navigator.pop(context);
                                      })
                                    ],
                                  );
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(15),
                                width:350,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                    color: Colors.black
                                ),
                                child: Row(children: [
                                  Container(
                                    constraints: BoxConstraints(
                                      maxHeight: 25,
                                      minWidth: 25,
                                      maxWidth: 25,
                                      minHeight: 25,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/images/${entry.key}-Logo.png',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Text(entry.key, style: TextStyle(fontSize: 16, color: Colors.white),),
                                  Expanded(child: Container(),),
                                  Container(
                                    width: 175,
                                    child: Text(
                                      entry.value,
                                      textAlign: TextAlign.right,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,),
                                    ),
                                  ),
                                  SizedBox(width: 5,)
                                ],),
                              ),
                            ),
                            SizedBox(height: 10,)]);
                        }else return Container();
                      }).toList()),
                  Column(
                      children:
                      widget.paymentMethods.entries.map((entry) {
                        if(entry.key == "Other1" || entry.key == "Other2" || entry.key == "Pay at Door"){
                          return Column(children: [
                            GestureDetector(
                              onTap: (){
                                showDialog(context: context, builder: (BuildContext context){
                                  return AlertDialog(
                                    backgroundColor: Color(0xff1e1e1e),
                                    title: Text(entry.key == "Other1" || entry.key == "Other2" ? 'custom ${entry.key[5]}' : "pay at door", style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold),),
                                    content:  Text(entry.value, style: TextStyle(color:Colors.white),),
                                    actions: [
                                      IconButton(icon: Icon(Icons.close, color: Colors.white,), onPressed: (){
                                        Navigator.pop(context);
                                      })
                                    ],
                                  );
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(15),
                                width:350,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                    color: Colors.black
                                ),
                                child: Row(children: [
                                  Container(
                                    constraints: BoxConstraints(
                                      maxHeight: 25,
                                      minWidth: 25,
                                      maxWidth: 25,
                                      minHeight: 25,
                                    ),
                                    child: Container(
                                      child:entry.key == "Other1" || entry.key == "Other2" ? Icon(Icons.info, color: Colors.white,) : Icon(Icons.sensor_door_outlined, color: Colors.white,),
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Text(entry.key == "Other1" || entry.key == "Other2" ? 'custom ${entry.key[5]}' : "pay at door", style: TextStyle(fontSize: 16, color: Colors.white),),
                                  Expanded(child: Container(),),
                                  Container(
                                    width: 175,
                                    child: Text(
                                      entry.value,
                                      textAlign: TextAlign.right,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color:  Colors.white,
                                        fontSize: 16,),
                                    ),
                                  ),
                                  SizedBox(width: 5,)
                                ],),
                              ),
                            ),
                            SizedBox(height: 10,)]);
                        }else return Container();
                      }).toList()),
                ],
              ),
            ),
            widget.free ? Container() :  Divider(thickness: 2, color: Colors.white,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex:  2,
                  child:Text("field", style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),),),
                Expanded(
                  flex: 3,
                  child: Text("your answer", style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold

                  ),),
                ),
                Expanded(
                    flex: 1,
                    child: Container())
              ],
            ),
            Divider(thickness: 2,color: Colors.grey, ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex:  2,
                  child:Text("image", style: TextStyle(
                      fontSize: 20,
                      color: Colors.white
                  ),),),
                Expanded(
                  flex: 3,
                  child: editedPlotImage == null ? widget.plotImage == null ? Text("no image", style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),):GestureDetector(
                      onTap: (){
                        showDialog(context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content:  Container(
                                  constraints: BoxConstraints(
                                      minWidth: MediaQuery.of(context).size.width,
                                      minHeight: MediaQuery.of(context).size.height
                                  ),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              fit: BoxFit.contain,
                                              image: FileImage(widget.plotImage)
                                          ))),
                                ),
                                actions: <Widget>[
                                  IconButton(icon: Icon(Icons.close),onPressed: (){
                                    Navigator.pop(context);
                                  }),

                                ],
                              );
                            }
                        );
                      },
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: 175,
                          maxWidth: 175,
                          minWidth: 175,
                          minHeight: 175,
                        ),
                        child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: FileImage(widget.plotImage)
                                ))),
                      ),) : GestureDetector(
                    onTap: (){
                      showDialog(context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content:  Container(
                                constraints: BoxConstraints(
                                    minWidth: MediaQuery.of(context).size.width,
                                    minHeight: MediaQuery.of(context).size.height
                                ),
                                child: Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: FileImage(editedPlotImage)
                                        ))),
                              ),
                              actions: <Widget>[
                                IconButton(icon: Icon(Icons.close),onPressed: (){
                                  Navigator.pop(context);
                                }),

                              ],
                            );
                          }
                      );
                    },
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: 175,
                        maxWidth: 175,
                        minWidth: 175,
                        minHeight: 175,
                      ),
                      child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(editedPlotImage)
                              ))),
                    ),)
                ),
                Expanded(
                    flex:  1,
                    child: TextButton(
                      child: Text("edit",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline
                        ),
                      ), onPressed: ()async{
                      try {
                        await getImageFromGallery();
                      } catch (e) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(failSnackbar);
                      }
                    },)
                    )
              ],
            ),
            Divider(thickness: 2,color: Colors.grey, ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex:  2,
                  child:Text("plot\nname", style: TextStyle(
                      fontSize: 20,
                      color: Colors.white
                  ),),),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    focusNode: plotNameNode,
                      onChanged: (value) => editedPlotName = value,
                      autocorrect: false,
                      initialValue: widget.plotName,
                      toolbarOptions: ToolbarOptions(
                        copy: true,
                        paste: true,
                        selectAll: true,
                        cut: true,
                      ),
                      cursorColor: Colors.white,
                      maxLines: null,
                      validator: (value) => validatePlotName(value),
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    decoration: InputDecoration(
                        filled: true,
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
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text("edit",
                        style: TextStyle(
                          color: Colors.blue,
                            decoration: TextDecoration.underline
                        ),
                      ),
                      onPressed: () => plotNameNode.requestFocus(),
                    ))
              ],
            ),
            Divider(thickness: 2, color: Colors.grey,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex:  2,
                  child:Text("plot\ndescription", style: TextStyle(
                      fontSize: 20,
                      color: Colors.white
                  ),),),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                      focusNode: plotDescriptionNode,
                      onChanged: (value) => editedPlotDescription = value,
                      autocorrect: false,
                      initialValue: widget.plotDescription,
                      toolbarOptions: ToolbarOptions(
                        copy: true,
                        paste: true,
                        selectAll: true,
                        cut: true,
                      ),
                      maxLines: null,
                      validator: (value) => validateField(value),
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.all(Radius.circular(3))
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.all(Radius.circular(3))
                          ),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.all(Radius.circular(3))
                          )
                      )
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text("edit",
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline
                        ),
                      ),
                        onPressed: () => plotDescriptionNode.requestFocus(),
                        ))
              ],
            ),
            Divider(thickness: 2,color: Colors.grey, ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex:  2,
                  child:Text("plot\naddress", style: TextStyle(
                      fontSize: 20,
                      color: Colors.white
                  ),),),
                Expanded(
                  flex: 3,
                  child: Text(editedPlotAddress == null ? widget.plotAddress: editedPlotAddress,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    ),),
                ),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text("edit",
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline
                        ),
                      ), onPressed: ()async{
                      FocusScope.of(context).unfocus();
                      Prediction p = await PlacesAutocomplete.show(
                        offset: 0,
                        radius: 1000,
                        strictbounds: false,
                        region: "us",
                        language: "en",
                        context: context,
                        mode: Mode.fullscreen,
                        apiKey: kGoogleApiKey.apiKey,
                        sessionToken: Uuid().generateV4(),
                        components: [
                          new Component(Component.country, "us")
                        ],
                        types: [],
                      );
                      displayPrediction(p);

                    },))
              ],
            ),
            Divider(thickness: 2, color: Colors.grey,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex:  2,
                  child:Text("contact\ndetails", style: TextStyle(
                      fontSize: 20,
                      color: Colors.white
                  ),),),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                      focusNode: plotContactDetailsNode,
                      onChanged: (value) => editedContactDetails = value,
                      autocorrect: false,
                      initialValue: widget.contactDetails,
                      toolbarOptions: ToolbarOptions(
                        copy: true,
                        paste: true,
                        selectAll: true,
                        cut: true,
                      ),
                      maxLines: null,
                      validator: (value) => validateField(value),
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.all(Radius.circular(3))
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.all(Radius.circular(3))
                          ),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.all(Radius.circular(3))
                          )
                      )
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text("edit",
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline
                        ),
                      ),
                      onPressed: () => plotContactDetailsNode.requestFocus(),
                    ))
              ],
            ),
            Divider(thickness: 2,color: Colors.grey, ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex:  2,
                  child:Text("host\nname", style: TextStyle(
                      fontSize: 20,
                      color: Colors.white
                  ),),),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                      focusNode: plotHostNameNode,
                      onChanged: (value) => editedHostName = value,
                      autocorrect: false,
                      initialValue: widget.hostName,
                      toolbarOptions: ToolbarOptions(
                        copy: true,
                        paste: true,
                        selectAll: true,
                        cut: true,
                      ),
                      maxLines: null,
                      validator: (value) => validateField(value),
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.all(Radius.circular(3))
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.all(Radius.circular(3))
                          ),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.all(Radius.circular(3))
                          )
                      )
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text("edit",
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline
                        ),
                      ),
                      onPressed: () => plotHostNameNode.requestFocus(),
                    ))
              ],
            ),
            Divider(thickness: 2,color: Colors.grey, ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex:  2,
                  child:Text("start\ndate", style: TextStyle(
                      fontSize: 20,
                      color: Colors.white
                  ),),),
                Expanded(
                  flex: 3,
                  child: Text(
                    DateFormat('MMMM d,  h a').format(editedStartDate == null ? widget.startDate: editedStartDate).toString(),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white
                    ),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: TextButton(
                      child: Text("edit",
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline
                        ),
                      ),
                      onPressed: ()async{
                        FocusScope.of(context).unfocus();
                        DatePicker.showDateTimePicker(
                          context,
                          showTitleActions: true,
                          minTime: DateTime.now(),
                          onChanged: (date) {
                            setState(() {
                              editedStartDate = date;
                            });
                          },
                          currentTime: DateTime.now(),
                        );
                      },
                    ))
              ],
            ),
            Divider(thickness: 2,color: Colors.grey, ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 2,
                  child:Text("plot\nprivacy", style: TextStyle(
                      fontSize: 20,
                      color: Colors.white
                  ),),),
                Expanded(
                  flex: 3,
                  child: DropdownButton<String>(
                    value: editedPlotPrivacy,
                    icon: Icon(Icons.arrow_drop_down,
                        color: Colors.white),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    underline: Container(
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        editedPlotPrivacy = newValue;
                      });
                    },
                    items: <String>[
                      'invite only',
                      'open invite',
                    ].map<DropdownMenuItem<String>>(
                            (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(
                              fontSize: 20,
                              color: Colors.white
                            ),),
                          );
                        }).toList(),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Container())
              ],
            ),
            Divider(color: Colors.grey, thickness: 2,),
            SizedBox(height: 5,),
            Container(
              alignment: Alignment.center,
              child:  RoundedLoadingButton(
                color: Color(0xff630094),
                width: 165,
                height: 50,
                borderRadius: 5,
                child: Text('create', style: TextStyle(fontSize: 16,color: Colors.white)),
                controller: _btnController,
                onPressed: _postPlot,
              )
            ),
          ],
        ),
          ),
      ),
    );
  }
}
