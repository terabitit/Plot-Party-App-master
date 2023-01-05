import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image/image.dart' as encoder;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/backend/google_maps_api_key.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/components/next_button.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/create/create_payment_details.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/create/three_step_widget.dart';
import 'package:plots/frontend/pages/home/map_page/third_party_plot_modal/thank_you_for_contributing.dart';
import 'package:plots/frontend/pages/home/party_details/host_view/edit_plot.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

//  the form to create a plot

GMAK kGoogleApiKey = GMAK();

class CreateThirdPartyPlot extends StatefulWidget {
  final SharedPrefData sharedPrefData;
  final ui.Image signature;

  const CreateThirdPartyPlot({Key key, this.sharedPrefData, this.signature}) : super(key: key);

  @override
  _CreateThirdPartyPlotState createState() => _CreateThirdPartyPlotState();
}

class _CreateThirdPartyPlotState extends State<CreateThirdPartyPlot> {
  final _createThirdPartyPlotDetailsKey = GlobalKey<FormState>();
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  String plotName;
  bool addyProvided = false;
  String plotDescription;
  String instaUsername;
  String contactDetails;
  String priceDetails;
  String plotAddress;
  double latitude;
  double longitude;
  DateTime startDate;
  String plotPrivacy = 'open invite';
  String errorMessage;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  File _image;

  void _postPlot() async {
    Timer(Duration(milliseconds: 300), () async{
      FocusScope.of(context).unfocus();
      if (_createThirdPartyPlotDetailsKey.currentState.validate() && startDate != null && (addyProvided ? plotAddress != null : true) && _image != null) {
        try {
          SharedPrefsServices sharedPrefsServices = SharedPrefsServices();
          String plotCode = UniqueKey().toString();
          await _firestore.collection('thirdPartyPlots').doc(plotCode).set({
            "signature": "",
            "addy": addyProvided ? plotAddress : "none",
            "title": plotName,
            "description": plotDescription,
            "date": startDate,
            "dateCreated": DateTime.now(),
            "contactInfo": contactDetails,
            "price": priceDetails,
            "creatorAuthID": widget.sharedPrefData.authID,
            "lat": addyProvided ? latitude:34.0522,
            "long": addyProvided? longitude: -118.2437,
            "addyProvided": addyProvided,
            "closed": false,
            "likes": 0,
            "dislikes": 0,
            "id": plotCode,
            "picture": "",
            "instagramUsername": instaUsername,
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

              final String picture = "$plotCode-signature-by-${widget.sharedPrefData.authID}.jpg";
              UploadTask task = storage.ref().child(picture).putData(Uint8List.fromList(encodedImage));
              task.then((res) async {
                var str = await res.ref.getDownloadURL();
                await _firestore.collection('thirdPartyPlots').doc(plotCode).update({
                  'signature': str,
                });
              });
            }

            if (_image != null) {
              String filename = '$plotCode.jpg';
              Reference ref = storage.ref().child(filename);
              UploadTask uploadTask = ref.putFile(_image);
              uploadTask.then((res) async {
                var str = await res.ref.getDownloadURL();
                await _firestore.collection('thirdPartyPlots').doc(plotCode).update({
                  'picture': str,
                });
              });
            }

          } catch (e) {
            _btnController.reset();
            print(e.toString());
          }
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => ThankYouForContributing(
                  )));
        } catch (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(failSnackbar);
          _btnController.reset();
          print(e.toString());
        }
      } else if (startDate != null && (addyProvided ? plotAddress != null : true) && _image != null){
        _btnController.reset();
        setState(() {
          errorMessage = '';
        });
      } else {
        _btnController.reset();
          setState(() {
            errorMessage = 'fields are incomplete.';
          });

      }
    });
  }

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

  String validatePriceDetails(String value) {
    if (value == null || value.isEmpty) {
      return "missing price details";
    }
    return null;
  }



  String validateInstagram(String value) {
    if (value == null || value.isEmpty) {
      return "missing instagram";
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
        title: Text("create plot", style: TextStyle(
          color: Colors.white
        ),),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 16, right:16),
        child: Form(
          key: _createThirdPartyPlotDetailsKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 8,),
              Text("a few details first.", style: TextStyle(color: Colors.grey, fontSize: 16),),
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
                                    onChanged: (value) => instaUsername = value,
                                    autocorrect: false,
                                    toolbarOptions: ToolbarOptions(
                                      copy: true,
                                      paste: true,
                                      selectAll: true,
                                      cut: true,
                                    ),
                                    maxLines: null,
                                    validator: (value) => validateInstagram(value),
                                    style: TextStyle(color: Colors.white),
                                    cursorColor: Colors.white,
                                    decoration: InputDecoration(
                                      // flashing container
                                      // unfocus after you click background
                                        filled: true,
                                        fillColor: Colors.black,
                                        labelStyle: TextStyle(color: Colors.white),
                                        labelText: "instagram",
                                        hintText: "@hamesjan",
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
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                      onChanged: (value) => priceDetails = value,
                      autocorrect: false,
                      toolbarOptions: ToolbarOptions(
                        copy: true,
                        paste: true,
                        selectAll: true,
                        cut: true,
                      ),
                      maxLines: null,
                      validator: (value) => validatePriceDetails(value),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white,

                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black,
                          labelStyle: TextStyle(color: Colors.white),
                          labelText: "price details",
                          hintText: "\$5 guys, \$10 girls, \$20 after 10:00 PM",
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
                        child: Icon(addyProvided ? Icons.remove : Icons.add_circle_outline, color: Colors.purpleAccent,),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 5,),
                      Text(addyProvided ? "REMOVE ADDRESS": "PROVIDE ADDRESS" , style: TextStyle(
                          color: Colors.purpleAccent,
                          fontSize: 20
                      ),),
                    ],),
                  onPressed: (){
                    FocusScope.of(context).unfocus();
                    setState(() {
                      addyProvided = !addyProvided;
                    });
                  },
                ),
              ),
              Text("if an address is not provided, the user will be informed to contact the host for the address.",style: TextStyle(
                color: Colors.grey, fontSize: 16
              ),),
              addyProvided ? Row(children: [
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
              ],) : Container(),
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
              errorMessage == null
                  ? Container()
                  : Text(
                errorMessage,
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
              SizedBox(
                height: 10,
              ),
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
