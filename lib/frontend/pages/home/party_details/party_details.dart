import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/home/party_details/guest_view/guest_view.dart';
import 'package:plots/frontend/pages/home/party_details/host_view/host_view.dart';
import 'package:plots/frontend/pages/home/party_details/security_view.dart';
import 'package:plots/frontend/pages/static_pages/loading.dart';
import 'package:plots/frontend/classes/firestore_plot_data.dart';

class PartyDetails extends StatefulWidget {
  // Party Details, 4th page on home screen
  final SharedPrefData sharedPrefData;

  const PartyDetails({Key key, this.sharedPrefData}) : super(key: key);

  @override
  _PartyDetailsState createState() => _PartyDetailsState();
}

class _PartyDetailsState extends State<PartyDetails> {
  FirestoreFunctions firestoreFunctions = FirestoreFunctions();
  Future<List> plotInfo;

  // Future<FirestorePlotData> getInformation() async {
  Future<List> getInformation() async {
    List info = [];
    info.add(await firestoreFunctions.makePlotObject(widget.sharedPrefData.plotCode));
    info.add(await firestoreFunctions.isHost(widget.sharedPrefData.username, widget.sharedPrefData.plotCode));
    info.add(await firestoreFunctions.isSecurity(widget.sharedPrefData.username, widget.sharedPrefData.plotCode));
    info.add(await firestoreFunctions.getUnreadMessagesFromAuthID(widget.sharedPrefData.authID));
    return info;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    plotInfo = getInformation();
  }

  Future<void> _refresh() async {
    setState(() {
      plotInfo = getInformation();
    });
  }



  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
        color: Colors.blue,
        child: FutureBuilder(
          future: plotInfo,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done){
                FirestorePlotData plotData = snapshot.data[0];
                return snapshot.data[1] ?
                HostView(plotData: plotData, sharedPrefData: widget.sharedPrefData)
                    : snapshot.data[2] ?
                SecurityView(
                  plotData: plotData,
                  sharedPrefData: widget.sharedPrefData,
                  unreadMessages: snapshot.data[3],
                ) :  GuestView(
                  unreadMessages: snapshot.data[3],
                  plotData: plotData,
                  startDate: plotData.startDate,
                  sharedPrefData: widget.sharedPrefData,
                );
            } else {
              return Loading();
            }
          }));
  }
}

