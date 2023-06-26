import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:chai/helpers/utilities.dart';
import 'package:chai/views/utils/toast_util.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as im;
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter_blue/flutter_blue.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../db/print_database.dart';

class PrintUtils {
  List<BluetoothDevice> _devices = [];
  BlueThermalPrinter bluetoothPrint = BlueThermalPrinter.instance;

  printData() async {
    print('order data');
    print(Utilities.orderDataList);
    try {
      await checkBluetooth(connected: () async {
        List<Uint8List> imgList = [];
         List order = Utilities.orderDataList;
         print("order");
         print(order);
         // var order_at = DateTime.now();
        var currentDateTime = DateTime.now().toString().substring(0,16);
        // DateTime onlyDate = DateTime(currentDateTime.day, currentDateTime.month, currentDateTime.year ,currentDateTime.hour,currentDateTime.minute,);
        // print("onlyDate-------->$onlyDate");
         var order_at = DateTime.now();
          var spaceBar = "                                ";
          var largespaceBar = "                      ";
        var printdata = "------------------- CHAIBABA ----------------\n\n";
            printdata += "B.No : ${Utilities.billNumber}      Date : ${currentDateTime}        \n";
        printdata += "---------------------------------------------------------------\n\n";
            printdata += "ITEM (QTY)  (PRICE)                 TOTAL \n";
            printdata += "---------------------------------------------------------------\n";
        for(int i=0;i<order.length;i++){
          print('item_Name');
          var item = jsonDecode(order[i]);
          var itemname = item['item_Name'].toString();
          if(itemname.toString().length < 12){
            printdata += "${itemname}   (${item['item_Qty'].toString()})  (${item['item_Price'].toString()})               ${item['total_cost'].toString()} \n";
          }else{
            printdata += "${itemname}   (${item['item_Qty'].toString()})  (${item['item_Price'].toString()})      ${item['total_cost'].toString()} \n";
          }

        }
        printdata += "---------------------------------------------------------------\n";
        printdata += "Total Amount                              : ${Utilities.finalPrice} \n";
        printdata += "---------------------------------------------------------------\n";
        printdata += "                           * THANK YOU VISIT AGAIN *          \n";
        printdata += "------------------------------------------------------------\n\n";
        Uint8List imageInt = await getBillImage(printdata);
        im.Image? receiptImg = im.decodePng(imageInt);

        for (var i = 0; i <= receiptImg!.height; i += 200) {
          im.Image cropedReceiptImg = im.copyCrop(receiptImg, 0, i, 470, 200);
          Uint8List bytes = im.encodePng(cropedReceiptImg) as Uint8List;
          imgList.add(bytes);
        }

        for (var element in imgList) {
          bluetoothPrint.printImageBytes(element);
        }
      });
    } catch (ex) {
      if (kDebugMode) {
        print("Error = $ex");
      }
    }
  }

  Future<Uint8List> getBillImage(String label,
      {double fontSize = 20, FontWeight fontWeight = FontWeight.w600}) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    /// Background
    final backgroundPaint = Paint()..color = Colors.white;
    const backgroundRect = Rect.fromLTRB(372, 10000, 0, 0);
    final backgroundPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(backgroundRect, const Radius.circular(0)),
      )
      ..close();
    canvas.drawPath(backgroundPath, backgroundPaint);

    //Title
    final ticketNum = TextPainter(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.left,
      text: TextSpan(
          text: label,
          style: TextStyle(
              color: Colors.black, fontSize: fontSize, fontWeight: fontWeight)),
    );
    ticketNum
      ..layout(
        maxWidth: 800,
      )
      ..paint(
        canvas,
        const Offset(0, 0),
      );

    canvas.restore();
    final picture = recorder.endRecording();
    final pngBytes =
        await (await picture.toImage(372.toInt(), ticketNum.height.toInt() + 5))
            .toByteData(format: ImageByteFormat.png);
    return pngBytes!.buffer.asUint8List();
  }

  checkBluetooth({required Function() connected}) async {
    fb.FlutterBlue.instance.state.listen((state) async {
      if (state == fb.BluetoothState.on) {
        showToastError("Bluetooth on");
        await _checkListDeviceAvailable(connected: () {
          connected();
        });
      } else {
        showToastError("Bluetooth off");
        await bluetoothPrint.isConnected.then((value) {
          if (value!) {
            bluetoothPrint.disconnect();
          }
        });
      }
    });
  }

  _checkListDeviceAvailable({required Function() connected}) async {
    await _scanDevices();
    if (_devices.isNotEmpty) {
      String? deviceAddress = await getDeviceAddress();
      if (deviceAddress!.isNotEmpty) {
        for (int i = 0; i < _devices.length; i++) {
          if (deviceAddress == _devices[i].address) {
            try {
              await bluetoothPrint.disconnect();
            } catch (ex) {}
            await bluetoothPrint.connect(_devices[i]);
            connected();
          }
        }
      }
    }
  }

  _scanDevices() async {
    try {
      _devices = await bluetoothPrint.getBondedDevices();
    } on PlatformException {
      if (kDebugMode) {
        print("Error no prepare devices founds.");
      }
    }
  }
}
