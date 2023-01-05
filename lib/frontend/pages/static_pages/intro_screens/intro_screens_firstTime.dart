import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:location/location.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/home/home.dart';


class IntroScreensFirstTime extends StatefulWidget {
  final SharedPrefData sharedPrefData;

  const IntroScreensFirstTime({Key key, this.sharedPrefData}) : super(key: key);
  @override
  _IntroScreensFirstTimeState createState() => _IntroScreensFirstTimeState();
}

class _IntroScreensFirstTimeState extends State<IntroScreensFirstTime> {
  final introKeyFirstTime = GlobalKey<IntroductionScreenState>();
  bool _serviceEnabled;
  Location location = new Location();
  PermissionStatus _permissionGranted;

  void _onIntroEnd(context) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (BuildContext context) => Home(initialTabIndex: 0, sharedPrefData: widget.sharedPrefData,)
    ), (route) => false);
  }


  Widget _buildImage(String assetName) {
    return Image.asset('assets/images/$assetName', width: 350,);
  }


  void checkPermissions(int page) async {
    if(page == 1){
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled)  {
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
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Color(0xff1e1e1e),
      imagePadding: EdgeInsets.zero,
    );

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 20),
        child: IntroductionScreen(
          key: introKeyFirstTime,
          onChange: (int page) => checkPermissions(page),
          globalBackgroundColor: Color(0xff1e1e1e),
          pages: [
            PageViewModel(
              title: "what's plots?",
              body: "join or create your own parties.",
              image: _buildImage('ft1.jpg'),
              decoration: pageDecoration.copyWith(
          bodyFlex: 2,
          imageFlex: 4,
          bodyAlignment: Alignment.topCenter,
          imageAlignment: Alignment.bottomCenter,
        ),
            ),
            PageViewModel(
              title: "discover parties",
              body: "tap on party icons on the plotmap to pull up details and attend.",
              decoration: pageDecoration.copyWith(
                bodyFlex: 2,
                imageFlex: 4,
                bodyAlignment: Alignment.bottomCenter,
                imageAlignment: Alignment.topCenter,
              ),
              image: _buildImage('ft2.jpg'),
              reverse: true,
            ),
          ],
          onDone: () => _onIntroEnd(context),
          onSkip: () => _onIntroEnd(context) ,
          showSkipButton: true,
          skip: const Text('Skip', style: TextStyle(color: Colors.white),),
          skipFlex: 0,
          nextFlex: 0,
          next: const Icon(Icons.arrow_forward, color: Colors.white,),
          done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
          curve: Curves.easeIn,
          controlsMargin: const EdgeInsets.all(16),
          controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
          dotsDecorator: const DotsDecorator(
            size: Size(10.0, 10.0),
            color: Color(0xFFBDBDBD),
            activeColor: Color(0xff630094),
            activeSize: Size(22.0, 10.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
          ),
          dotsContainerDecorator: const ShapeDecoration(
            color: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
        ),
      ),
    );
  }
}
