import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plots/backend/firestore_functions.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/home/map_page/help_pages/frequently_asked_questions.dart';
import 'package:plots/frontend/pages/home/map_page/help_pages/note_from_host.dart';
import 'package:plots/frontend/pages/home/map_page/help_pages/submit_bug_report.dart';
import 'package:plots/frontend/pages/static_pages/intro_screens/intro_screens_firstTime.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class HelpBottomModal extends StatefulWidget {
  final bool locationEnabled;

  const HelpBottomModal({Key key, this.locationEnabled}) : super(key: key);

  @override
  _HelpBottomModalState createState() => _HelpBottomModalState();
}

class _HelpBottomModalState extends State<HelpBottomModal> {
  Future<int> litness;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    litness = getLitness();
  }

  Future<int> getLitness() async {
    FirestoreFunctions firestoreFunctions = FirestoreFunctions();
    int litness = await firestoreFunctions.getLitness();
    return litness;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xff1e1e1e),
          borderRadius: BorderRadius.all(
            Radius.circular(25.0),
          ),
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
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
              Text("map key", style: TextStyle(color: Colors.grey, fontSize: 16),),
              Container(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: 50,
                              minWidth: 50,
                              maxWidth: 50,
                              minHeight: 50,
                            ),
                            child:
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/tpp-marker.png',
                                  ),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )),
                          Text("third party plot\n(not created through plots app)",textAlign: TextAlign.center, style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12
                          ),)
                        ],
                      ),),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: 50,
                              minWidth: 50,
                              maxWidth: 50,
                              minHeight: 50,
                            ),
                            child:
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/poppin.png',
                                  ),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )),
                          Text('poppin party\n(+50 people)',textAlign: TextAlign.center, style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12
                          ),)
                        ],
                      ),),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: 50,
                              minWidth: 50,
                              maxWidth: 50,
                              minHeight: 50,
                            ),
                            child:
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/regular-plot-marker.png',
                                  ),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )),
                          Text("regular plot",textAlign: TextAlign.center, style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12
                          ),)
                        ],
                      ),),
                ],),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: [Colors.blue, Color(0xffB53D3D)])),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.transparent,
                            padding: EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(25)),
                            )),
                        child: Column(
                          children: [
                            Icon(
                              Icons.help,
                              size: 50,
                            ),
                            Text(
                              "frequently\nasked\nquestions",
                              textAlign: TextAlign.center,
                              style:
                              TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      FrequentlyAskedQuestions()));
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xffB53D3D), Color(0xff630094)])),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.transparent,
                            padding: EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(25)),
                            )),
                        child: Column(
                          children: [
                            Icon(
                              Icons.rule_sharp,
                              size: 50,
                            ),
                            Text(
                              "\nintro\nscreens",
                              textAlign: TextAlign.center,
                              style:
                              TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          SharedPrefsServices sharedPrefServices =
                          SharedPrefsServices();
                          SharedPrefData sharedPrefData =
                          await sharedPrefServices.makeUserObject();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      IntroScreensFirstTime(
                                        sharedPrefData: sharedPrefData,
                                      )));
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          gradient: LinearGradient(
                              begin: Alignment.bottomRight,
                              end: Alignment.topLeft,
                              colors: [Colors.green, Colors.blue])),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.transparent,
                            padding: EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(25)),
                            )),
                        child: Column(
                          children: [
                            Icon(
                              Icons.bug_report,
                              size: 50,
                            ),
                            Text(
                              "help\nimprove\nplots",
                              textAlign: TextAlign.center,
                              style:
                              TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      SubmitBugReport()));
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [Color(0xff630094), Colors.green])),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.transparent,
                            padding: EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(25)),
                            )),
                        child: Column(
                          children: [
                            Icon(
                              Icons.person,
                              size: 50,
                            ),
                            Text(
                              "about\nthe\ndeveloper",
                              textAlign: TextAlign.center,
                              style:
                              TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      NoteFromHost()));
                        },
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 5,),
              widget.locationEnabled ? FutureBuilder(
                  future: litness,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done){
                      return Column(children: [
                          Text("litness meter",style: TextStyle(
                              color: Colors.white,
                              fontSize: 22
                          ),),
                          Text("the litness meter measures how many parties there are around your area." ,style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16
                          ),
                            textAlign: TextAlign.center,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "dry",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width - 100,
                                padding: EdgeInsets.all(16),
                                child: StepProgressIndicator(
                                  totalSteps: 10,
                                  currentStep: snapshot.data,
                                  size: 8,
                                  padding: 0,
                                  selectedColor: Colors.yellow,
                                  unselectedColor: Colors.cyan,
                                  roundedEdges: Radius.circular(10),
                                  selectedGradientColor: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Colors.yellowAccent, Colors.deepOrange],
                                  ),
                                  unselectedGradientColor: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Colors.black, Colors.blue],
                                  ),
                                ),
                              ),
                              Text(
                                "lit",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],);
                    } else {
                      return SizedBox(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Color(0xff630094)),
                            strokeWidth: 4.0
                        ),
                      );
                    }
                  })
        :  Container(),
              SizedBox(height: 30,),
            ]));
  }
}
