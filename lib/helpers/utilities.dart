import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// ConnectivityResult connectivityResult;

class Utilities {
  static int selectedmenuIndex = 0;
  static String? title;
  static String? companyLogo;
  static int filledQues = 0;
  static int countFilled = 0;
  static bool isPermission = false;
  static String dataState = "";
  static String? stationCode;
  static int finalPrice = 0;
  static var bthAddress;
  static List orderDataList= [];
  static var billNumber = 0;
  static bool isConnected = false;


  static void Snackbar(BuildContext context, String text) {
    final snackBar = SnackBar(
      margin: EdgeInsets.only(bottom: 70, left: 15, right: 15),
      duration: Duration(seconds: 3),
      content: Text(text.toString(),
          textAlign: TextAlign.start,
          style: TextStyle(color: Colors.white),
          textHeightBehavior:
          TextHeightBehavior(applyHeightToFirstAscent: true)),
      backgroundColor: (Colors.black45),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'OK',
        textColor: Colors.white,
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  static Future<bool> CheckUserConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  static void showAlert(BuildContext context,
      String text,) {
    var alert = AlertDialog(
      content: Row(
        children: <Widget>[
          Flexible(
              fit: FlexFit.loose,
              child: Text(
                text,
                overflow: TextOverflow.visible,
              ))
        ],
      ),
      actions: <Widget>[
        // ignore: deprecated_member_use
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: TextStyle(color: Colors.black),
            ))
      ],
    );
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return alert;
        });
  }

  ///////requestprmission/////////////
  static void requestPermission() async {
    print("calling.........................");
    Map<Permission, PermissionStatus> statuses = await [
      Permission.locationAlways,
      Permission.storage,
      Permission.camera,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      //add more permission to request here.
    ].request();
    print("-----------------------");
    print(statuses);
    print("-----------------------");
    // if (statuses[Permission.storage]!.isDenied) {
    //   isPermission = true;
    //   print("storage permission is denied.");
    // } else if (statuses[Permission.storage]!.isPermanentlyDenied) {
    //   isPermission = true;
    //   print("Permission is permanently denied");
    // }
    // if (statuses[Permission.location]!.isDenied) {
    //   //check each permission status after.
    //   print("Camera permission is denied.");
    // }
    // if (statuses[Permission.camera]!.isDenied) {
    //   //check each permission status after.
    //   print("stroage permission is denied.");
    // }
  }
}
