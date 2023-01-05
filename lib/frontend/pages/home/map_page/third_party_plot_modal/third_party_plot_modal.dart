import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/classes/third_party_plot_data.dart';
import 'package:plots/frontend/pages/enter_or_create_plot/create/user_agreement_to_host.dart';
import 'package:plots/frontend/pages/home/map_page/third_party_plot_modal/third_party_plot_list_widget.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';


class ThirdPartyPlotModal extends StatefulWidget {
  final List<ThirdPartyPlotData> thirdPartyPlots;

  const ThirdPartyPlotModal({Key key, this.thirdPartyPlots}) : super(key: key);

  @override
  _ThirdPartyPlotModalState createState() => _ThirdPartyPlotModalState();
}

class _ThirdPartyPlotModalState extends State<ThirdPartyPlotModal> {
  Future<int> litness;
  ScrollController scrollController = ScrollController();



  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 200,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xff1e1e1e),
          borderRadius: BorderRadius.all(
            Radius.circular(25.0),
          ),
        ),
      child: Column(
        children: [
          Container(
            child: Container(
              width: 100,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                      Radius.circular(25))),
            ),
            padding: EdgeInsets.only(top: 1,bottom: 1),
          ),
    SizedBox(height: 10,),
    Row(children: [
      Expanded(flex: 1,child: Container(),),
      Expanded(flex: 5, child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("more parties near you...", style: TextStyle(
              color: Colors.white, fontSize: 16
          ),),
          Text("tap on a plot for details", style: TextStyle(
              color: Colors.grey, fontSize: 12
          )),
      ],),),
      Expanded(flex: 1, child: FirebaseAuth.instance.currentUser.uid == 'ab9p7hF2ULZE0fBuokxuNRDr9pC3' ? IconButton(
        icon: Icon(Icons.add,  color: Colors.white,),
        onPressed: ()async{
          SharedPrefsServices sharedPrefServices = SharedPrefsServices();
          SharedPrefData sharedPrefData = await sharedPrefServices.makeUserObject();
          Navigator.push(context,
              MaterialPageRoute(
                  builder: (BuildContext context) => UserAgreementToHost(
                    createActual: false,
                    sharedPrefData: sharedPrefData,
                  )
              ));
        },
      ) : Container(),),

    ],),
          Divider(thickness: 2, color: Colors.grey,),
    widget.thirdPartyPlots.length == 0 ? Column(
      children: [
        SizedBox(height: 100,),
        Icon(Icons.mood_bad, size: 80, color: Colors.grey,),
        Text("there are no parties right now.", style: TextStyle(
          color: Colors.grey,
        ),),
      ],
    ):
    Expanded(
    child: RawScrollbar(
    controller: scrollController,
    thickness: 4,
    thumbColor: Colors.white,
    child: ListView.builder(
    shrinkWrap: true,
    itemCount: widget.thirdPartyPlots.length,
    itemBuilder: (BuildContext context, int index) {
      return ThirdPartyPlotListWidget(thirdPartyPlotData: widget.thirdPartyPlots[index],);
    }
    ) ) )       ],
      ),
    );
  }
}
