import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plots/backend/google_maps_api_key.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/components/next_button.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/create/create_payment_details.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/create/three_step_widget.dart';
import 'package:plots/frontend/pages/home/party_details/host_view/edit_plot.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

//  the form to create a plot

GMAK kGoogleApiKey = GMAK();

class CreatePlot extends StatefulWidget {
  final SharedPrefData sharedPrefData;
  final ui.Image signature;

  const CreatePlot({Key key, this.sharedPrefData, this.signature}) : super(key: key);

  @override
  _CreatePlotState createState() => _CreatePlotState();
}

class _CreatePlotState extends State<CreatePlot> {
  final _createPlotDetailsKey = GlobalKey<FormState>();
  String plotName;
  String plotDescription;
  String hostName;
  String contactDetails;
  String plotAddress;
  double latitude;
  double longitude;
  DateTime startDate;
  String plotPrivacy = 'open invite';
  String errorMessage;
  File _image;

  final ImagePicker _picker = ImagePicker();
  final failSnackbar = SnackBar(
    content: Text(
      'error. try again.',
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


  Future getImageFromGallery() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery,imageQuality: 85,
        maxHeight: 480, maxWidth: 640);
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  Future getImageFromCamera() async {
    final pickedFile = await _picker.getImage(source: ImageSource.camera, imageQuality: 85,
        maxHeight: 480, maxWidth: 640);
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
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;
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
        title: ThreeStepWidget(step: 1,),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 16, right:16),
        child: Form(
          key: _createPlotDetailsKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 8,),
              Text("a few details first.", style: TextStyle(color: Colors.white, fontSize: 16),),
              SizedBox(height: 8,),
              Column(
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          _image != null
                              ? GestureDetector(
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
                          )
                              : Container(
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
                                        image:  AssetImage(
                                                'assets/images/no-image-available.jpeg')))),
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
                                elevation: 2.0,
                                fillColor: Colors.grey,
                                constraints: BoxConstraints(
                                    minHeight: 25,
                                    minWidth: 75
                                ),
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
                                elevation: 2.0,
                                constraints: BoxConstraints(
                                  minWidth: 75,
                                  minHeight: 25,

                                ),
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
                      SizedBox(width: 10),
                      Column(
                        children: [
                          SizedBox(height: 5,),
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
                                        hintText: "Bartholomew",
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
                                    toolbarOptions: ToolbarOptions(
                                      copy: true,
                                      paste: true,
                                      selectAll: true,
                                      cut: true,
                                    ),
                                    cursorColor: Colors.white,
                                    maxLines: null,
                                    minLines: 4,
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
                    plotAddress == null ? "what's the addy?": plotAddress,
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
                        onConfirm: (date) {
                          setState(() {
                            startDate = date;
                          });
                        },
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
                startDate.toString() == 'null'
                ? 'when should people pull up?'
                    : DateFormat('MMMM d,  h a').format(startDate).toString(),
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
              errorMessage == null
                  ? Container()
                  : Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
              SizedBox(
                height: 10,
              ),
              NextButton(
                text: 'next',
                callback: ()async{
                  FocusScope.of(context).unfocus();
                  if (_createPlotDetailsKey.currentState.validate() && startDate != null && plotAddress != null) {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (BuildContext context) => CreatePaymentDetails(
                          plotAddress: plotAddress,
                          plotName: plotName,
                          signature: widget.signature,
                          hostName: hostName,
                          contactDetails: contactDetails,
                          plotDescription: plotDescription,
                          latitude: latitude,
                          sharedPrefData: widget.sharedPrefData,
                          longitude: longitude,
                          startDate: startDate,
                          plotPrivacy: plotPrivacy,
                          plotImage: _image,
                        )
                    ));
                  } else if (startDate != null && plotAddress != null){
                    setState(() {
                      errorMessage = '';
                    });
                  } else {
                    startDate == null &&  plotAddress == null ? setState(() {
                      errorMessage = 'pick a date and address';
                    }) : startDate == null && plotAddress != null ? setState(() {
                      errorMessage = 'pick a date';
                    }) : setState(() {
                      errorMessage = 'pick an address';
                    });
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
