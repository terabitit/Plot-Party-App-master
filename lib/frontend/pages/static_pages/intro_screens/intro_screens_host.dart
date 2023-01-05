import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/home/home.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';

class IntroScreensHost extends StatefulWidget {
  final SharedPrefData sharedPrefData;

  const IntroScreensHost({Key key, this.sharedPrefData}) : super(key: key);
  @override
  _IntroScreensHostState createState() => _IntroScreensHostState();
}

class _IntroScreensHostState extends State<IntroScreensHost> {
  final introKeyHost = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (BuildContext context) => Home(initialTabIndex: 0, sharedPrefData: widget.sharedPrefData,)
    ), (route) => false);
  }

  Widget _buildImage(String assetName) {
    return Image.asset('assets/images/$assetName', width: 350,);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 20.0);

    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      pageColor: Color(0xff1e1e1e),
      imagePadding: EdgeInsets.zero,
    );

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 20),
        child: IntroductionScreen(
          key: introKeyHost,
          globalBackgroundColor: Color(0xff1e1e1e),
          pages: [
            PageViewModel(
              title: "host view",
              body: "you have new powers as a host",
              image: _buildImage('hft1.jpg'),
              decoration: pageDecoration.copyWith(
                bodyFlex: 2,
                imageFlex: 4,
                bodyAlignment: Alignment.topCenter,
                imageAlignment: Alignment.bottomCenter,
              ),
            ),
            PageViewModel(
              title:"1. manage guest list\n2. manage security\n3. accept/decline attend requests\n4. edit payment info",
              bodyWidget: Container(),
              decoration: pageDecoration.copyWith(
                bodyFlex: 3,
                imageFlex: 5,
                bodyAlignment: Alignment.bottomCenter,
                imageAlignment: Alignment.topCenter,
              ),
              image: _buildImage('hft2.jpg'),
              reverse: true,
            ),
          ],
          onDone: () => _onIntroEnd(context),
          onSkip: () => _onIntroEnd(context), // You can override onSkip callback
          showSkipButton: true,
          skipFlex: 0,
          nextFlex: 0,
          //rtl: true, // Display as right-to-left
          skip: const Text('Skip', style: TextStyle(color: Colors.white),),
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
