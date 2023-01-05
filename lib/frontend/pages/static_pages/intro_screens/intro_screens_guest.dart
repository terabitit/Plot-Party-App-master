import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/home/home.dart';
import 'package:plots/frontend/services/shared_pref_service.dart';

class IntroScreensGuest extends StatefulWidget {
  final SharedPrefData sharedPrefData;

  const IntroScreensGuest({Key key, this.sharedPrefData}) : super(key: key);
  @override
  _IntroScreensGuestState createState() => _IntroScreensGuestState();
}

class _IntroScreensGuestState extends State<IntroScreensGuest> {
  final introKeyGuest = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (BuildContext context) => Home(initialTabIndex: 0, sharedPrefData: widget.sharedPrefData,)
    ), (route) => false);
  }

  Widget _buildFullscrenImage() {
    return Image.asset(
      'assets/images/fullscreen.jpg',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
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
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Color(0xff1e1e1e),
      imagePadding: EdgeInsets.zero,
    );

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 20),
        child: IntroductionScreen(
          key: introKeyGuest,
          globalBackgroundColor: Color(0xff1e1e1e),
          pages: [
            PageViewModel(
              title: "you have been approved.",
              body: "go party!",
              image: _buildImage('gft1.jpg'),
              decoration: pageDecoration.copyWith(
                bodyFlex: 2,
                imageFlex: 4,
                bodyAlignment: Alignment.topCenter,
                imageAlignment: Alignment.bottomCenter,
              ),
            ),
            PageViewModel(
              title: "chat with other guests",
              bodyWidget: Container(),
              decoration: pageDecoration.copyWith(
                bodyFlex: 1,
                imageFlex: 6,
                bodyAlignment: Alignment.bottomCenter,
                imageAlignment: Alignment.topCenter,
              ),
              image: _buildImage('gft2.jpg'),
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
