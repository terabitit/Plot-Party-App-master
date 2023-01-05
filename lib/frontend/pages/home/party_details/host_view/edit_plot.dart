import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/backend/google_maps_api_key.dart';
import 'package:plots/frontend/classes/firestore_plot_data.dart';
import 'dart:async';
import 'package:google_maps_webservice/places.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:flutter/services.dart';
import 'package:plots/frontend/components/custom_button.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:plots/frontend/components/next_button.dart';
import 'package:plots/frontend/pages/home/home.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';

//  the form to create a plot

GMAK kGoogleApiKey = GMAK();

class EditPlot extends StatefulWidget {
  final SharedPrefData sharedPrefData;
  final FirestorePlotData plotData;


  const EditPlot({Key key, this.sharedPrefData, this.plotData}) : super(key: key);

  @override
  _EditPlotState createState() => _EditPlotState();
}

class _EditPlotState extends State<EditPlot> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _editPlotKey = GlobalKey<FormState>();
  String plotName;
  String plotDescription;
  String plotAddress;
  String contactDetails;
  String hostName;
  double latitude;
  double longitude;
  DateTime startDate;
  String plotPrivacy;
  final ImagePicker _picker = ImagePicker();
  File _image;
  final failSnackbar = SnackBar(content: Text('error. try again.', style: TextStyle(color: Colors.white),), backgroundColor: Colors.red,);
  final successSnackbar = SnackBar(content: Text('success!', style: TextStyle(color: Colors.white),), backgroundColor: Colors.green,);
  FirestoreFunctions firestorefunctions = FirestoreFunctions();


  Future getImageFromGallery() async {
    final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,imageQuality: 80,
        maxHeight: 480, maxWidth: 640,
    );
    setState(() {
      _image = File(pickedFile.path);
    });

  }

  @override
  void initState() {
    plotPrivacy = widget.plotData.plotPrivacy;
    super.initState();
  }

  Future getImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80,
        maxHeight: 480, maxWidth: 640,
        preferredCameraDevice: CameraDevice.front);
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      // get detail (lat/lng)
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey.apiKey,
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;
      print(lat.toString());
      print(lng.toString());
      setState(() {
              plotAddress = detail.result.formattedAddress;
              latitude = lat;
              longitude = lng;
            });
    }
  }


  String validatePlotName(String value) {
    if (value == null || value.isEmpty) {
      return "missing plot name";
    } else if (value.length < 4) {
      return "minimum 5 characters";
    }
    return null;
  }

  String validateHostName(String value) {
    if (value == null || value.isEmpty) {
      return "missing host name";
    }
    return null;
  }
  String validateContactDetails(String value) {
    if (value == null || value.isEmpty) {
      return "missing contact details";
    }
    return null;
  }

  String validatePlotDescription(String value) {
    if (value == null || value.isEmpty) {
      return "missing description";
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
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
        title: Text('edit ${widget.plotData.plotName}'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _editPlotKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: [
          Row(
          children: [
          Column(
          children: [
          widget.plotData.flyerURL == '' ? _image != null ? GestureDetector(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: 150,
                maxWidth: 150,
                minWidth: 150,
                minHeight: 150,
              ),
              child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(_image)
                      ))),
            ),
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
                            child:  Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.contain,
                                        image: FileImage(_image)
                                    ))),
                          ),
                        )
                    );
                  }
              );
            },
          ) : Container(
          constraints: BoxConstraints(
            maxHeight: 150,
            maxWidth: 150,
            minWidth: 150,
            minHeight: 150,
          ),
          child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(
                          'assets/images/no-image-available.jpeg')
                  ))),
        ) : Container(
        constraints: BoxConstraints(
        maxHeight: 150,
        maxWidth: 150,
        minWidth: 150,
        minHeight: 150,
      ),
            child: GestureDetector(
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
                    maxHeight: 150,
                    maxWidth: 150,
                    minWidth: 150,
                    minHeight: 150,
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
                        maxHeight: 150,
                        maxWidth: 150,
                        minWidth: 150,
                        minHeight: 150,
                      ),
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                          strokeWidth: 4.0
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )
              ),
            ),
          ),
        SizedBox(height: 5,),
        Row(
          children: [
            RawMaterialButton(
              onPressed: () async {
                try {
                  await getImageFromCamera();
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(failSnackbar);
                }
              },
              constraints: BoxConstraints(
                minWidth: 75,
                minHeight: 25,

              ),
              elevation: 2.0,
              fillColor: Colors.grey,
              child: Icon(
                Icons.camera_alt,
                size: 30.0,
              ),
              shape: BeveledRectangleBorder(),
            ),
            RawMaterialButton(
              onPressed: () async {
                try {
                  await getImageFromGallery();
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(failSnackbar);
                }
              },
              constraints: BoxConstraints(
                minWidth: 75,
                minHeight: 25,

              ),
              elevation: 2.0,
              fillColor: Colors.grey,
              child: Icon(
                Icons.image,
                size: 30.0,
              ),
              shape: BeveledRectangleBorder(),
            ),
          ],
        ),
        ],
      ),
      Expanded(
        child: Container(),
      ),
      SizedBox(width: 10,),
      Column(
        children: [
          Container(
            width: 180,
            child:Column(
              children: [
                TextFormField(
                    onChanged: (value) => hostName = value,
                    autocorrect: false,
                    toolbarOptions: ToolbarOptions(
                      copy: true,
                      paste: true,
                      selectAll: true,
                      cut: true,
                    ),
                    maxLines: null,
                    initialValue: widget.plotData.hostName,
                    validator: (value) => validateHostName(value),
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      // flashing container
                      // unfocus after you click background
                        filled: true,
                        fillColor: Colors.black,
                        labelStyle: TextStyle(color: Colors.white),
                        labelText: "host name",
                        hintText: "Mr. Money Maker",
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
                            BorderRadius.all(Radius.circular(5))))
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                    onChanged: (value) => contactDetails = value,
                    autocorrect: false,
                    initialValue: widget.plotData.contactDetails,
                    toolbarOptions: ToolbarOptions(
                      copy: true,
                      paste: true,
                      selectAll: true,
                      cut: true,
                    ),
                    cursorColor: Colors.white,
                    maxLines: null,
                    minLines: 5,
                    validator: (value) => validateContactDetails(value),
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black,
                        labelStyle: TextStyle(color: Colors.white),
                        labelText: "contact details",
                        hintText: "insta - @hamesjan\nphone - 123123123",
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
        ],
      ),
      Expanded(
        child: Container(),
      ),
      ],
    ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                      onChanged: (value) => plotName = value,
                      autocorrect: false,
                      toolbarOptions: ToolbarOptions(
                        copy: true,
                        paste: true,
                        selectAll: true,
                        cut: true,
                      ),
                      cursorColor: Colors.white,
                      initialValue: widget.plotData.plotName,
                      maxLines: null,
                      validator: (value) => validatePlotName(value),
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black,
                          labelStyle: TextStyle(color: Colors.white),
                          labelText: "plot name",
                          hintText: "rager at Aryans",
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
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                      onChanged: (value) => plotDescription = value,
                      autocorrect: false,
                      toolbarOptions: ToolbarOptions(
                        copy: true,
                        paste: true,
                        selectAll: true,
                        cut: true,
                      ),
                      maxLines: null,
                      initialValue: widget.plotData.description,
                      validator: (value) => validatePlotDescription(value),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white,

                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black,
                          labelStyle: TextStyle(color: Colors.white),
                          labelText: "plot description",
                          hintText: "BYOE! theme is pajamas. ",
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
              SizedBox(height: 10,),
              Row(children: [
                Container(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Color(0xff630094)),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      Prediction p = await PlacesAutocomplete.show(
                        offset: 0,
                        radius: 1000,
                        strictbounds: false,
                        region: "us",
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelStyle: TextStyle(color: Colors.white),
                            hintStyle: TextStyle(
                                color: Colors.white
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
                                BorderRadius.all(Radius.circular(5)))),
                        language: "en",
                        context: context,
                        mode: Mode.overlay,
                        apiKey: kGoogleApiKey.apiKey,
                        sessionToken: Uuid().generateV4(),
                        components: [
                          new Component(Component.country, "us")
                        ],
                        types: [],
                      );
                      displayPrediction(p);
                    },
                    child: Container(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "add addy",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        )),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 16, right: 16),
                  width:200,
                  height: 70,
                  child: Text(
                    plotAddress == null ? widget.plotData.plotAddress: plotAddress,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ],),
              Row(
                children: [
                  Container(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Color(0xff630094)),
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        DatePicker.showDateTimePicker(
                          context,
                          showTitleActions: true,
                          minTime: DateTime.now(),
                          onChanged: (date) {
                            setState(() {
                              startDate = date;
                            });
                          },
                          currentTime: DateTime.now(),
                        );
                      },
                      child: Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "add date",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          )),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 16, right: 16),
                    width:200,
                    height: 70,
                    child: Text(
                      startDate.toString() == 'null' ? DateFormat('MM/dd  h a').format(widget.plotData.startDate ).toString():DateFormat('MM/dd  h a').format(startDate).toString() ,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
                      style: TextStyle(
                        fontSize: startDate.toString() == 'null'
                            ? 15
                            : 20,
                      ),
                    ),
                  ),
                ],),
              Row(
                children: [
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
                                title: Text('plot privacy',style: TextStyle(
                                    fontSize: 32,
                                    color: Colors.white
                                ),),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('an open invite plot is one where guests can invite their friends. open invite plots are also viewable on the plotmap.',style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white
                                    ),),
                                    Divider(thickness: 2,),
                                    Text('an invite only plot can not be seen on the plotmap and is more lowkey.',style: TextStyle(
                                        fontSize: 20,
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
                    'plot privacy',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  DropdownButton<String>(
                    value: plotPrivacy,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white),
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
                        plotPrivacy = newValue;
                      });
                    },
                    items: <String>[
                      'invite only',
                      'open invite',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              NextButton(
                text: 'upload edits',
                callback: () async{
                  if (_editPlotKey.currentState.validate()) {
                    showDialog(context: context, builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Color(0xff1e1e1e),
                        title: Text("are you sure you want to edit?", style: TextStyle(
                          color: Colors.white
                        ),),
                        actions: [
                          IconButton(icon: Icon(Icons.close, color: Colors.grey,), onPressed: (){
                            Navigator.pop(context);
                          }),
                          TextButton(
                            child: Text("upload edits", style: TextStyle(
                              fontSize: 20, color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),),
                            onPressed: ()async{
                              try {
                                if (_image != null) {
                                  String filename = '${widget.sharedPrefData.plotCode}.jpg';
                                  FirebaseStorage storage = FirebaseStorage.instance;
                                  Reference ref = storage.ref().child(filename);
                                  UploadTask uploadTask = ref.putFile(_image);
                                  uploadTask.then((res) async{
                                    var str = await res.ref.getDownloadURL();
                                    firestorefunctions.updatePlotsInfo(plotCode: widget.sharedPrefData.plotCode, field: 'flyerURL', newValue: str);

                                  });
                                }
                                if (plotName != widget.plotData.plotName && plotName != null){
                                  firestorefunctions.updatePlotsInfo(plotCode: widget.sharedPrefData.plotCode, field: 'plotName', newValue: plotName);
                                }
                                if (hostName != widget.plotData.hostName && hostName != null){
                                  firestorefunctions.updatePlotsInfo(plotCode: widget.sharedPrefData.plotCode, field: 'hostName', newValue: hostName);
                                }
                                if (contactDetails != widget.plotData.contactDetails && contactDetails != null){
                                  firestorefunctions.updatePlotsInfo(plotCode: widget.sharedPrefData.plotCode, field: 'contactDetails', newValue: contactDetails);
                                }
                                if (startDate != widget.plotData.startDate && startDate != null){
                                  firestorefunctions.updatePlotsInfo(plotCode: widget.sharedPrefData.plotCode, field: 'startDate', newValue: startDate);
                                }
                                if (plotPrivacy != widget.plotData.plotPrivacy){
                                  firestorefunctions.updatePlotsInfo(plotCode: widget.sharedPrefData.plotCode, field: 'plotPrivacy', newValue: plotPrivacy);
                                }
                                if (plotAddress != widget.plotData.plotAddress && plotAddress != null){
                                  await _firestore.collection('plots')
                                      .doc(widget.sharedPrefData.plotCode)
                                      .update({
                                    'plotAddress': plotAddress,
                                    'lat': latitude,
                                    'long': longitude,
                                  });
                                }
                                ScaffoldMessenger.of(context).showSnackBar(successSnackbar);
                                Navigator.pop(context);
                              } catch (e){
                                ScaffoldMessenger.of(context).showSnackBar(failSnackbar);
                                print(e.toString());
                              }
                            },
                          )
                        ],
                      );
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Uuid {
  final Random _random = Random();

  String generateV4() {
    final int special = 8 + _random.nextInt(4);

    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}
