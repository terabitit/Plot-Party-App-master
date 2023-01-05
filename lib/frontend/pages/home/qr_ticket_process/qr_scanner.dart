import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';
import 'package:plots/frontend/classes/shared_pref_data.dart';
import 'package:plots/frontend/pages/home/home.dart';
import 'package:plots/frontend/pages/home/qr_ticket_process/scanned_guest_info.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/foundation.dart';

// Scanning QR Code
class QRScanner extends StatefulWidget {
  final SharedPrefData sharedPrefData;

  const QRScanner({Key key, this.sharedPrefData}) : super(key: key);

  @override
  _QRScannerState createState() => _QRScannerState();
}


class _QRScannerState extends State<QRScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode result;
  QRViewController controller;
  Color borderColor = Colors.purpleAccent;
  double leftBorderLength = 75;
  double rightBorderLength = 75;

  double borderWidth = 5;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("plots",),
      centerTitle: false,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_outlined),
        onPressed: (){
          Navigator.pushAndRemoveUntil(context, PageTransition(
            type: PageTransitionType.leftToRight,
            child: Home(
              initialTabIndex: 0,
              sharedPrefData: widget.sharedPrefData,
            ),
          ), (route) => false);
        },
      ),),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child:Column(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                      child: result != null ? Text("loading...", style: TextStyle(
                          fontSize: 20
                      ),) : Text("scan a code", style: TextStyle(
                          fontSize: 20
                      ),)
                    // (result != null)
                    //     ? Text(
                    //     'Barcode Type: ${describeEnum(result.format)}   Data: ${result.code}')
                    //     : Text('Scan a code'),
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: Container(
                color: Colors.transparent,
                width: 250,
                height: 250,
                child: Stack(children: [
                  Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                          color: borderColor,
                          width: leftBorderLength,
                          height: borderWidth)),
                  Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                          color: borderColor,
                          width: borderWidth,
                          height: leftBorderLength)),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                          color: borderColor,
                          width: leftBorderLength,
                          height: borderWidth)),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                          color: borderColor,
                          width: borderWidth,
                          height: leftBorderLength)),
                  Positioned(
                      right: 0,
                      child: Container(
                          color: borderColor,
                          width: rightBorderLength,
                          height: borderWidth)),
                  Positioned(
                      right: 0,
                      child: Container(
                          color: borderColor,
                          width: borderWidth,
                          height: rightBorderLength)),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                          color: borderColor,
                          width: rightBorderLength,
                          height: borderWidth)),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                          color: borderColor,
                          width: borderWidth,
                          height: rightBorderLength)),
                ])),),
          )

        ],
      )
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => ScannedGuestInfo(
            qrCode: scanData.code,
            sharedPrefData: widget.sharedPrefData,
          ),
          transitionDuration: Duration(seconds: 0),
        ),
      );
      // setState(() {
      //   result = scanData;
      // });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
