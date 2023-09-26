// import 'dart:convert';
// import 'dart:ui';
//
// import 'package:blue_thermal_printer/blue_thermal_printer.dart';
// import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
// import 'package:chai/helpers/utilities.dart';
// import 'package:chai/views/utils/toast_util.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// // import 'package:flutter_blue/flutter_blue.dart' as fb;
// import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
// import 'package:image/image.dart' as im;
//
// import '../db/print_database.dart';
//
// class PrintUtils {
//   List<BluetoothDevice> _devices = [];
//   BlueThermalPrinter bluetoothPrint = BlueThermalPrinter.instance;
//
//   Future<void> printTicket() async {
//     String? isConnected = Utilities.isConnected.toString();
//     if (isConnected == "true") {
//       List<int> bytes = await getTicket();
//       final result = await BluetoothThermalPrinter.writeBytes(bytes);
//       print("Print $result");
//     } else {
//       //Hadnle Not Connected Senario
//     }
//   }
//
//   Future<List<int>> getTicket() async {
//     List<int> bytes = [];
//     CapabilityProfile profile = await CapabilityProfile.load();
//     final generator = Generator(PaperSize.mm80, profile);
//     var currentDateTime = DateTime.now().toString().substring(0, 16);
//     bytes += generator.text("DFC SHOP",
//         styles: PosStyles(
//           align: PosAlign.center,
//           height: PosTextSize.size2,
//           width: PosTextSize.size5,
//           bold: true,
//         ),
//         linesAfter: 1);
//
//     bytes += generator.text("KAKINADA, AP, INDIA",
//         styles: PosStyles(align: PosAlign.center));
//     bytes += generator.text('Bill No. : #000${Utilities.billNumber.toString()}',
//         styles: PosStyles(align: PosAlign.center));
//
//     bytes += generator.hr();
//     bytes += generator.row([
//       PosColumn(
//           text: 'No',
//           width: 1,
//           styles: PosStyles(align: PosAlign.left, bold: true)),
//       PosColumn(
//         text: 'Item',
//         width: 7,
//         styles: PosStyles(
//           align: PosAlign.left,
//           bold: true,
//         ),
//       ),
//       PosColumn(
//           text: 'Price Qty Amt',
//           width: 4,
//           styles: PosStyles(align: PosAlign.right, bold: true)),
//       // PosColumn(
//       //     text: 'Qty',
//       //     width: 2,
//       //     styles: PosStyles(align: PosAlign.center, bold: true)),
//       // PosColumn(
//       //     text: 'Amount',
//       //     width: 2,
//       //     styles: PosStyles(align: PosAlign.right, bold: true)),
//     ]);
//
//     print(Utilities.orderDataList);
//
//     // [{"item_ID":"4","category_Id":"9","item_Name":"DUM TEA","item_Qty":4,"item_Price":10,"total_cost":40}, {"item_ID":"7","category_Id":"9","item_Name":"JAGGERY TEA","item_Qty":3,"item_Price":15,"total_cost":45}]
//     List orderDataListData = Utilities.orderDataList;
//     for (int i = 0; i < orderDataListData.length; i++) {
//       var orderDataListDataObj = jsonDecode(orderDataListData[i]);
//
//       bytes += generator.row([
//         PosColumn(text: "${i + 1}", width: 1),
//         PosColumn(
//             text: 'karam onion masala capsicum cheese\ndosa',
//             width: 7,
//             styles: PosStyles(
//               align: PosAlign.left,
//             )),
//         PosColumn(
//             text:
//                 '${orderDataListDataObj['item_Price']} * ${orderDataListDataObj['item_Qty']} = 1200',
//             width: 4,
//             styles: PosStyles(
//               align: PosAlign.right,
//             )),
//       ]);
//     }
//
//     bytes += generator.hr();
//
//     bytes += generator.row([
//       PosColumn(
//           text: 'TOTAL',
//           width: 4,
//           styles: PosStyles(
//             align: PosAlign.left,
//             height: PosTextSize.size2,
//             width: PosTextSize.size2,
//           )),
//       PosColumn(
//           text: "${Utilities.finalPrice.toString()}",
//           width: 8,
//           styles: PosStyles(
//             align: PosAlign.right,
//             height: PosTextSize.size2,
//             width: PosTextSize.size2,
//           )),
//     ]);
//
//     bytes += generator.hr(ch: '=', linesAfter: 1);
//
//     // ticket.feed(2);
//     bytes += generator.text('THANK YOU! VISIT US AGAIN',
//         styles: PosStyles(align: PosAlign.center, bold: true));
//
//     bytes += generator.text("$currentDateTime",
//         styles: PosStyles(align: PosAlign.center), linesAfter: 1);
//
//     // bytes += generator.text(
//     //     'Note: Goods once sold will not be taken back or exchanged.',
//     //     styles: PosStyles(align: PosAlign.center, bold: false));
//     bytes += generator.cut();
//     return bytes;
//   }
//
//   printData() async {
//     print('order data');
//     print(Utilities.orderDataList);
//     try {
//       await checkBluetooth(connected: () async {
//         List<Uint8List> imgList = [];
//         List order = Utilities.orderDataList;
//         print("order");
//         print(order);
//         // var order_at = DateTime.now();
//         var currentDateTime = DateTime.now().toString().substring(0, 16);
//         // DateTime onlyDate = DateTime(currentDateTime.day, currentDateTime.month, currentDateTime.year ,currentDateTime.hour,currentDateTime.minute,);
//         // print("onlyDate-------->$onlyDate");
//         var order_at = DateTime.now();
//         var spaceBar = "                                ";
//         var largespaceBar = "                      ";
//         var printdata = "------------------- DFC DOSA ----------------\n\n";
//         printdata +=
//             "B.No : ${Utilities.billNumber}      Date : ${currentDateTime}        \n";
//         printdata +=
//             "---------------------------------------------------------------\n\n";
//         printdata += "ITEM (QTY)  (PRICE)                 TOTAL \n";
//         printdata +=
//             "---------------------------------------------------------------\n";
//         for (int i = 0; i < order.length; i++) {
//           print('item_Name');
//           var item = jsonDecode(order[i]);
//           var itemname = item['item_Name'].toString();
//           if (itemname.toString().length < 12) {
//             printdata +=
//                 "${itemname}   (${item['item_Qty'].toString()})  (${item['item_Price'].toString()})               ${item['total_cost'].toString()} \n";
//           } else {
//             printdata +=
//                 "${itemname}   (${item['item_Qty'].toString()})  (${item['item_Price'].toString()})      ${item['total_cost'].toString()} \n";
//           }
//         }
//         printdata +=
//             "---------------------------------------------------------------\n";
//         printdata +=
//             "Total Amount                              : ${Utilities.finalPrice} \n";
//         printdata +=
//             "---------------------------------------------------------------\n";
//         printdata +=
//             "                           * THANK YOU VISIT AGAIN *          \n";
//         printdata +=
//             "------------------------------------------------------------\n\n";
//         Uint8List imageInt = await getBillImage(printdata);
//         im.Image? receiptImg = im.decodePng(imageInt);
//
//         for (var i = 0; i <= receiptImg!.height; i += 300) {
//           im.Image cropedReceiptImg = im.copyCrop(receiptImg, 0, i, 470, 200);
//           Uint8List bytes = im.encodePng(cropedReceiptImg) as Uint8List;
//           imgList.add(bytes);
//         }
//
//         for (var element in imgList) {
//           bluetoothPrint.printImageBytes(element);
//         }
//       });
//     } catch (ex) {
//       if (kDebugMode) {
//         print("Error = $ex");
//       }
//     }
//   }
//
//   Future<Uint8List> getBillImage(String label,
//       {double fontSize = 20, FontWeight fontWeight = FontWeight.w600}) async {
//     final recorder = PictureRecorder();
//     final canvas = Canvas(recorder);
//
//     /// Background
//     final backgroundPaint = Paint()..color = Colors.white;
//     const backgroundRect = Rect.fromLTRB(372, 10000, 0, 0);
//     final backgroundPath = Path()
//       ..addRRect(
//         RRect.fromRectAndRadius(backgroundRect, const Radius.circular(0)),
//       )
//       ..close();
//     canvas.drawPath(backgroundPath, backgroundPaint);
//
//     //Title
//     final ticketNum = TextPainter(
//       textDirection: TextDirection.rtl,
//       textAlign: TextAlign.left,
//       text: TextSpan(
//           text: label,
//           style: TextStyle(
//               color: Colors.black, fontSize: fontSize, fontWeight: fontWeight)),
//     );
//     ticketNum
//       ..layout(
//         maxWidth: 800,
//       )
//       ..paint(
//         canvas,
//         const Offset(0, 0),
//       );
//
//     canvas.restore();
//     final picture = recorder.endRecording();
//     final pngBytes =
//         await (await picture.toImage(372.toInt(), ticketNum.height.toInt() + 5))
//             .toByteData(format: ImageByteFormat.png);
//     return pngBytes!.buffer.asUint8List();
//   }
//
//   checkBluetooth({required Function() connected}) async {
//     fb.FlutterBlue.instance.state.listen((state) async {
//       if (state == fb.BluetoothState.on) {
//         showToastError("Bluetooth on");
//         await _checkListDeviceAvailable(connected: () {
//           connected();
//         });
//       } else {
//         showToastError("Bluetooth off");
//         await bluetoothPrint.isConnected.then((value) {
//           if (value!) {
//             bluetoothPrint.disconnect();
//           }
//         });
//       }
//     });
//   }
//
//   _checkListDeviceAvailable({required Function() connected}) async {
//     await _scanDevices();
//     if (_devices.isNotEmpty) {
//       String? deviceAddress = await getDeviceAddress();
//       if (deviceAddress!.isNotEmpty) {
//         for (int i = 0; i < _devices.length; i++) {
//           if (deviceAddress == _devices[i].address) {
//             try {
//               await bluetoothPrint.disconnect();
//             } catch (ex) {}
//             await bluetoothPrint.connect(_devices[i]);
//             connected();
//           }
//         }
//       }
//     }
//   }
//
//   _scanDevices() async {
//     try {
//       _devices = await bluetoothPrint.getBondedDevices();
//     } on PlatformException {
//       if (kDebugMode) {
//         print("Error no prepare devices founds.");
//       }
//     }
//   }
// }
