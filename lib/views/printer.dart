import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:blue_print_pos/blue_print_pos.dart';
import 'package:blue_print_pos/models/blue_device.dart';
import 'package:blue_print_pos/models/connection_status.dart';
import 'package:blue_print_pos/receipt/receipt_section_text.dart';
import 'package:blue_print_pos/receipt/receipt_text_size_type.dart';
import 'package:blue_print_pos/receipt/receipt_text_style_type.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart' as RB;

import '../helpers/utilities.dart';
import '../widgets/constraints.dart';
import 'home/home.dart';

class PrintOrder extends StatefulWidget {
  const PrintOrder({Key? key}) : super(key: key);

  @override
  State<PrintOrder> createState() => _PrintOrderState();
}

class _PrintOrderState extends State<PrintOrder> {
  bool connected = false;
  List availableBluetoothDevices = [];
  String isCheck = "";
  String isMac = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getBluetooth() async {
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");
    setState(() {
      availableBluetoothDevices = bluetooths!;
    });
  }

  Future<void> setConnect(String mac) async {
    final String? result = await BluetoothThermalPrinter.connect(mac);
    print("state conneected $result");
    print(Utilities.isConnected);
    if (result == "true") {
      setState(() {
        connected = true;
        Utilities.isConnected = true;
        isCheck = mac;
        printDialogue(context);

      });
    }
  }
  printDialogue(context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (stfContext, stfSetState) {
          return Dialog(
            // The background color
            backgroundColor: bordertextcolor,
            child: SingleChildScrollView(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Text(
                            "Bluetooth",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: yellowColor,
                                fontSize: headerSize),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            color: yellowColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      child: Text("Printer Connected Successfully",style: TextStyle(color: whiteColor,fontSize: textSize),),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Utilities.isConnected == true
                        ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 90,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: yellowColor,
                                // shape: RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.circular(15),
                                // ),
                              ),
                              onPressed: () {
                                ///*********** Below code is to print the order ***************//
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => HomePage()),
                                );
                              },
                              child: Text(
                                "Next",
                                style: TextStyle(color: blackColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        : Container(
                      child: Text(
                        "Please connect to printer",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: headerSize),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: yellowColor,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Printer Connection",
              style: TextStyle(color: blackColor),
            ),
            GestureDetector(
                onTap: () {
                  setState(() {
                    print(connected);
                    print(Utilities.isConnected);
                  });
                  if (Utilities.isConnected == true) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  } else {
                    Utilities.showAlert(context, 'No Device Connected');
                  }
                },
                child: Text(
                  "Next",
                  style: TextStyle(color: blackColor),
                )),
          ],
        ),
        centerTitle: true,
        backgroundColor: yellowColor,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              child: ListView.builder(
                itemCount: availableBluetoothDevices.length > 0
                    ? availableBluetoothDevices.length
                    : 0,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      // String name = list[0];
                      String select = availableBluetoothDevices[index];
                      print(select);
                      List list = select.split("#");
                      String mac = list[1];
                      setState(() {
                        isMac = mac;
                      });

                      print(mac);
                      print(isMac);
                      setConnect(mac);
                    },
                    title: Text('${availableBluetoothDevices[index]}',style: TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text( "Click to connect",style: TextStyle(fontWeight: FontWeight.bold,)),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getBluetooth();
        },
        child: Text("Scan"),
        backgroundColor: blackColor,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
