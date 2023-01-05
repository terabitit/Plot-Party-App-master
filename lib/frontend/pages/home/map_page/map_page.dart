import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/firestore_plot_data.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/classes/third_party_plot_data.dart';
import 'package:plots/frontend/components/next_button.dart';
import 'package:plots/frontend/components/plots_error.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/join/plot_preview.dart';
import 'package:plots/frontend/pages/home/map_page/help_pages/help_bottom_modal.dart';
import 'package:plots/frontend/pages/home/map_page/third_party_plot_modal/third_party_plot_details.dart';
import 'package:plots/frontend/pages/home/map_page/third_party_plot_modal/third_party_plot_modal.dart';
import 'package:plots/frontend/services/distance_calculator.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class MapPage extends StatefulWidget {
  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  String _darkMapStyle;
  double zoomVal = 5.0;
  bool _serviceEnabled;
  String findPlotButtonMessage = "find a party!";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirestoreFunctions firestoreFunctions = FirestoreFunctions();
  PermissionStatus _permissionGranted;
  Location location = new Location();
  List<Marker> markerList = [];
  final RoundedLoadingButtonController _findPlotButton =
  RoundedLoadingButtonController();
  final RoundedLoadingButtonController _morePlotsButton = RoundedLoadingButtonController();
  BitmapDescriptor regularPlotMarker;
  BitmapDescriptor thirdPartyMarker;
  BitmapDescriptor poppinMarker;

  FirestorePlotData firestorePlotData;
  bool clickedOnce = false;
  MinMaxZoomPreference minMaxZoomPreference = MinMaxZoomPreference(8, 800);
  bool noPlot = false;

  Future<void> _loadMapStyles() async {
    _darkMapStyle = await rootBundle.loadString('assets/map_styles/dark.json');
    final controller = await _controller.future;
    controller.setMapStyle(_darkMapStyle);
  }

  Future<void> goLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 17,
      tilt: 0,
      bearing: 0.0,
    )));
  }

  @override
  void initState() {
    super.initState();
    _loadMapStyles();
    checkPermissions();
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 0.5),
            'assets/images/regular-plot-marker.png')
        .then((onValue) {
      regularPlotMarker = onValue;
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 0.5),
        'assets/images/tpp-marker.png')
        .then((onValue) {
      thirdPartyMarker = onValue;
    });BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 0.5),
        'assets/images/poppin.png')
        .then((onValue) {
      poppinMarker = onValue;
    });
  }

  Future<int> getLitness() async {
    int plotPrivacy = await firestoreFunctions.getLitness();
    return plotPrivacy;
  }

  @override
  void dispose() {
    super.dispose();
  }

  checkPermissions() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  // Widgets
  Widget _buildBottomButtons() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            firestorePlotData == null ? beforeSelect() : Container(),
            Container(
                padding: EdgeInsets.only(bottom: 50, left: 5),
                child: RoundedLoadingButton(
                  color: Color(0xff630094),
                  controller: _morePlotsButton,
                  onPressed: () async {
                    List<ThirdPartyPlotData> thirdPartyPlots = await firestoreFunctions.makeThirdPartyPlotsObject();
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return ThirdPartyPlotModal(
                            thirdPartyPlots: thirdPartyPlots,
                          );
                        });
                    _morePlotsButton.reset();
                  },
                  child: Text(
                    'party billboard',
                    style: TextStyle(fontSize: 21, color: Colors.white),
                  ),
                ))
          ],
        ));
  }

  Widget _upperBar() {
    return Align(
        alignment: Alignment.topCenter,
        child: SafeArea(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 10,
              ),
              Container(
                  height: 65,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xffB53D3D), Color(0xff630094)])),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        )),
                    onPressed: () async {
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return HelpBottomModal(
                              locationEnabled: _permissionGranted.toString() == 'PermissionStatus.granted'
                                  ? true
                                  : false,
                            );
                          });
                    },
                    child: Icon(
                      Icons.help,
                      color: Colors.white,
                      size: 32,
                    ),
                  )),
              SizedBox(
                width: 10,
              ),
              Container(
                height: 65,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xffB53D3D), Color(0xff630094)],
                    )),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(15),
                      primary: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)))),
                  onPressed: () async {
                    List searchInfo = await firestoreFunctions.getSearchInfo();
                    showSearch(
                        context: context,
                        delegate: SearchPlots(
                          closestPlots: [],
                          searchInfo: searchInfo,
                        ));
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Text(
                        "search plots",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        ));
  }

  Widget beforeSelect() {
    return clickedOnce
        ? Container(
            padding: EdgeInsets.all(5),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xffB53D3D), Color(0xff630094)
                    ]
                  )
                ),
                padding: EdgeInsets.all(16),
                child: Text(
                  noPlot
                      ? 'there are no parties right now.\ntell your friends to download plots and throw parties!'
                      : 'tap on the marker to pull up details.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 21, color: Colors.white),
                )))
        : Container(
            padding: EdgeInsets.only(bottom: 20, left: 5),
            child: RoundedLoadingButton(
              color: Color(0xff630094),
              controller: _findPlotButton,
              onPressed: () async {
                bool highlightExists = await firestoreFunctions.checkIfHighlightedPlots();
                if (highlightExists) {
                  var highLightData =
                      await _firestore.collection('highlights').get();
                  double highlightLat = highLightData.docs[0].get('lat');
                  double highlightLong = highLightData.docs[0].get('long');
                  goLocation(highlightLat, highlightLong);
                  setState(() {
                    clickedOnce = true;
                  });
                } else {
                  if (_permissionGranted.toString() ==
                      "PermissionStatus.granted") {
                    var firestoredata = await _firestore
                        .collection('plots')
                        .where("closed", isEqualTo: false)
                        .where("plotPrivacy", isEqualTo: 'open invite')
                        .get();
                    if (firestoredata.docs.length == 0) {
                      setState(() {
                        clickedOnce = true;
                        noPlot = true;
                      });
                    } else {
                      LocationData _locationData = await location.getLocation();
                      double lowestmiles = 100;
                      double closestPlotLat = 34.0522;
                      double closestPlotLong = -118.2437;
                      firestoredata.docs.forEach((element) {
                        double tempMiles = getMilesBetweenTwo(
                            _locationData.latitude,
                            _locationData.longitude,
                            element['lat'],
                            element['long']);
                        if (tempMiles < lowestmiles) {
                          lowestmiles = tempMiles;
                          closestPlotLat = element['lat'];
                          closestPlotLong = element['long'];
                        }
                      });
                      goLocation(closestPlotLat, closestPlotLong);
                      setState(() {
                        clickedOnce = true;
                      });
                    }
                  } else {
                    _findPlotButton.reset();
                    setState(() {
                      findPlotButtonMessage = "enable location";
                    });
                  }
                }
              },
              child: Text(
                findPlotButtonMessage,
                style: TextStyle(fontSize: 21, color: findPlotButtonMessage == "find a party!" ? Colors.white: Colors.grey),
              ),
            ));
  }

  Future<Widget> buildMap(BuildContext context) async {
    markerList.clear();
    var allPlotsData = await _firestore
        .collection('plots')
        .where("closed", isEqualTo: false)
        .where("plotPrivacy", isEqualTo: 'open invite')
        .get();
    FirestoreFunctions firestoreFunctions = FirestoreFunctions();
    List<ThirdPartyPlotData> allTPP = await firestoreFunctions.makeThirdPartyPlotsObject();
    allTPP.forEach((element) {
      if(element.addyProvided){
      markerList.add(Marker(
        flat: true,
        onTap: () async {
          Navigator.push(context,
              MaterialPageRoute(
            builder: (BuildContext context) => ThirdPartyPlotDetails(
              thirdPartyPlotData: element,
            )
          ));
        },
        markerId: MarkerId(element.id),
        position: LatLng(element.lat, element.long),
        // infoWindow: InfoWindow(title: element['name']),
        icon: thirdPartyMarker,
      ));
      }
    });
    allPlotsData.docs.forEach((element){
      var plotData = element.data();
      if(plotData['guests'].length > 50) {
        markerList.add(Marker(
          flat: true,
          onTap: () async {
            FirestorePlotData temp =
            await firestoreFunctions.makePlotObject(plotData['plotCode']);
            goLocation(plotData['lat'], plotData['long']);
            setState(() {
              firestorePlotData = temp;
            });
            showDetails();
          },
          markerId: MarkerId(plotData['plotCode']),
          position: LatLng(plotData['lat'], plotData['long']),
          // infoWindow: InfoWindow(title: element['name']),
          icon: poppinMarker,
        ));
      } else {
        markerList.add(Marker(
          flat: true,
          onTap: () async {
            FirestorePlotData temp =
            await firestoreFunctions.makePlotObject(plotData['plotCode']);
            goLocation(plotData['lat'], plotData['long']);
            setState(() {
              firestorePlotData = temp;
            });
            showDetails();
          },
          markerId: MarkerId(plotData['plotCode']),
          position: LatLng(plotData['lat'], plotData['long']),
          // infoWindow: InfoWindow(title: element['name']),
          icon:regularPlotMarker,
        ));
      }
    });


    if (_permissionGranted.toString() != 'PermissionStatus.granted') {
      return SizedBox.expand(
          child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                minMaxZoomPreference: minMaxZoomPreference,
                zoomGesturesEnabled: true,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                    target: LatLng(34.0522, -118.2437), zoom: 10),
                markers: markerList.toSet(),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              )));
    } else {
      Location location = new Location();
      LocationData _locationData = await location.getLocation();
      return SizedBox.expand(
          child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          minMaxZoomPreference: minMaxZoomPreference,
          zoomGesturesEnabled: true,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
              target: LatLng(_locationData.latitude, _locationData.longitude),
              zoom: 12),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: markerList.toSet(),
        ),
      ));
    }
  }

  showDetails() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
              decoration: BoxDecoration(
                color: Color(0xff1e1e1e),
                borderRadius: BorderRadius.all(
                  Radius.circular(25.0),
                ),
              ),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    firestorePlotData.flyerURL != ''
                        ? GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding: EdgeInsets.all(10),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: InteractiveViewer(
                                            panEnabled: false,
                                            // Set it to false
                                            boundaryMargin: EdgeInsets.all(100),
                                            minScale: 0.5,
                                            maxScale: 2,
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  firestorePlotData.flyerURL,
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(25)),
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  Container(
                                                alignment: Alignment.center,
                                                child: CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                            Color(0xff630094)),
                                                    strokeWidth: 4.0),
                                                height: 50.0,
                                                width: 50.0,
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                        ));
                                  });
                            },
                            child: Stack(
                              children: [
                                Container(
                                    constraints: BoxConstraints(
                                      maxHeight:
                                          MediaQuery.of(context).size.height /
                                                  5 +
                                              25,
                                      minHeight:
                                          MediaQuery.of(context).size.height /
                                                  5 +
                                              25,
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: firestorePlotData.flyerURL,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
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
                                          maxHeight: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  5 +
                                              25,
                                          minHeight: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  5 +
                                              25,
                                        ),
                                        child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation(
                                                Color(0xff630094)),
                                            strokeWidth: 4.0),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    )),
                                Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      child: Container(
                                        width: 100,
                                        height: 5,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25))),
                                      ),
                                      padding: EdgeInsets.all(10),
                                    )),
                              ],
                            ))
                        : Stack(
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height / 5 +
                                          25,
                                  minHeight:
                                      MediaQuery.of(context).size.height / 5 +
                                          25,
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
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    child: Container(
                                      width: 100,
                                      height: 5,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25))),
                                    ),
                                    padding: EdgeInsets.all(10),
                                  )),
                            ],
                          ),
                    Container(
                      padding: EdgeInsets.only(left: 30, top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firestorePlotData.plotName,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 26),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "about event",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            firestorePlotData.description,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Container(
                                child: Icon(
                                  Icons.calendar_today,
                                  size: 50,
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Color(0xff630094),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('dd MMMM, y')
                                        .format(firestorePlotData.startDate)
                                        .toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    DateFormat('EEEE, hh:mm a')
                                        .format(firestorePlotData.startDate)
                                        .toString(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Container(
                                child: Icon(
                                  Icons.attach_money,
                                  size: 50,
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Color(0xff630094),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              firestorePlotData.free
                                  ? Text(
                                      "free",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 20),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${firestorePlotData.ticketLevelsAndPrices.keys.elementAt(0).toString()}: \$${firestorePlotData.ticketLevelsAndPrices.values.elementAt(0).toString()}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 16),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        firestorePlotData.ticketLevelsAndPrices
                                                    .length >
                                                1
                                            ? Text(
                                                "${firestorePlotData.ticketLevelsAndPrices.keys.elementAt(1).toString()}: \$${firestorePlotData.ticketLevelsAndPrices.values.elementAt(1).toString()}",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : Container(),
                                      ],
                                    )
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: NextButton(
                        text: "details",
                        callback: () async {
                          SharedPrefsServices sharedPrefServices =
                              SharedPrefsServices();
                          SharedPrefData sharedPrefData =
                              await sharedPrefServices.makeUserObject();
                          String hostProfilePic = await firestoreFunctions
                              .getProfilePicURLFromAuthID(
                                  firestorePlotData.hostAuthID);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      PlotPreview(
                                        sharedPrefData: sharedPrefData,
                                        plotData: firestorePlotData,
                                        hostProfilePic: hostProfilePic,
                                      )));
                        },
                      ),
                    ),
                    Container(
                        height: 50, width: MediaQuery.of(context).size.width)
                  ]));
        });
  }

  @override
  Widget build(BuildContext myContext) {
    return FutureBuilder<Widget>(
        future: buildMap(context),
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.hasData) {
            return Stack(children: <Widget>[
              snapshot.data,
              _buildBottomButtons(),
              _upperBar(),
            ]);
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Stack(children: <Widget>[
              SizedBox.expand(
                  child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: GoogleMap(
                        minMaxZoomPreference: MinMaxZoomPreference(8, 500),
                        zoomGesturesEnabled: true,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                            target: LatLng(34.0522, -118.2437), zoom: 10),
                        markers: markerList.toSet(),
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                      ))),
              Center(child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff1e1e1e),
                ),
                child:CircularProgressIndicator(color: Color(0xff630094),),)),
              _buildBottomButtons(),
              _upperBar(),
            ]);
          } else if (snapshot.connectionState == ConnectionState.none) {
            return Center(
              child: Text(
                'there are connectivity issues.\nplease retry later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            );
          } else {
            return PlotsError();
          }
        });
  }
}

class SearchPlots extends SearchDelegate<String> {
  final List searchInfo;
  final List closestPlots;

  SearchPlots({
    this.searchInfo,
    this.closestPlots,
  });

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
        icon: Icon(
          Icons.arrow_back,
          color: Colors.black,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestionList = query.isEmpty
        ? closestPlots
        : searchInfo
            .where((p) =>
                p['plotName'].toLowerCase().startsWith(query.toLowerCase()) ||
                p['plotCode'].toLowerCase().startsWith(query.toLowerCase()))
            .toList();
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? closestPlots
        : searchInfo
            .where((p) =>
                p['plotName'].toLowerCase().startsWith(query.toLowerCase()) ||
                p['plotCode'].toLowerCase().startsWith(query.toLowerCase()))
            .toList();
    if (suggestionList.length == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
          ),
          Icon(
            Icons.place,
            size: 50,
            color: Colors.white,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "search plot code or plot name",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ],
      );
    } else {
      return ListView.builder(
          itemCount: suggestionList.length,
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: EdgeInsets.only(bottom: 5, top: 5, right: 10),
              onTap: () async {
                FirestoreFunctions firestoreFunctions = FirestoreFunctions();
                query = '${suggestionList[index]['plotName']}';
                print(query);
                SharedPrefsServices sharedPrefServices = SharedPrefsServices();
                SharedPrefData sharedPrefData =
                    await sharedPrefServices.makeUserObject();
                FirestorePlotData firestorePlotData = await firestoreFunctions
                    .makePlotObject(suggestionList[index]['plotCode']);
                String hostProfilePic = await firestoreFunctions
                    .getProfilePicURLFromAuthID(firestorePlotData.hostAuthID);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => PlotPreview(
                              sharedPrefData: sharedPrefData,
                              plotData: firestorePlotData,
                              hostProfilePic: hostProfilePic,
                            )));
              },
              leading: GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: EdgeInsets.all(10),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: InteractiveViewer(
                                  panEnabled: false,
                                  // Set it to false
                                  boundaryMargin: EdgeInsets.all(100),
                                  minScale: 0.5,
                                  maxScale: 2,
                                  child: CachedNetworkImage(
                                    imageUrl: suggestionList[index]
                                                ['flyerURL'] ==
                                            ''
                                        ? 'https://firebasestorage.googleapis.com/v0/b/plots-6e93e.appspot.com/o/no_plot_image.jpg?alt=media&token=44aaa97a-0c79-42d5-b4b3-61966d051224'
                                        : suggestionList[index]['flyerURL'],
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) => Container(
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(
                                              Color(0xff630094)),
                                          strokeWidth: 4.0),
                                      height: 80.0,
                                      width: 80.0,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              ));
                        });
                  },
                  child: Container(
                      constraints: BoxConstraints(
                          maxHeight: 80,
                          minWidth: 80,
                          maxWidth: 80,
                          minHeight: 80),
                      child: CachedNetworkImage(
                        imageUrl: suggestionList[index]['flyerURL'] == ''
                            ? 'https://firebasestorage.googleapis.com/v0/b/plots-6e93e.appspot.com/o/no_plot_image.jpg?alt=media&token=44aaa97a-0c79-42d5-b4b3-61966d051224'
                            : suggestionList[index]['flyerURL'],
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
                        placeholder: (context, url) => Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.black, shape: BoxShape.circle),
                          constraints: BoxConstraints(
                              maxHeight: 80,
                              minWidth: 80,
                              maxWidth: 80,
                              minHeight: 80),
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ))),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                        text: suggestionList[index]['plotName']
                            .substring(0, query.length),
                        style: TextStyle(
                            color: Colors.purpleAccent,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            style: TextStyle(color: Colors.white, fontSize: 17),
                            text: suggestionList[index]['plotName'].substring(
                                query.length,
                                suggestionList[index]['plotName'].length),
                          )
                        ]),
                  ),
                  Text(
                    DateFormat('dd MMMM, y')
                        .format(suggestionList[index]['startDate'])
                        .toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 14),
                  ),
                ],
              ),
              trailing: Text(
                suggestionList[index]['plotCode'],
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          });
    }
  }
}
