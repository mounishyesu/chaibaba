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
  final BluePrintPos _bluePrintPos = BluePrintPos.instance;
  List<BlueDevice> _blueDevices = <BlueDevice>[];
  BlueDevice? _selectedDevice;
  bool _isLoading = false;
  int _loadingAtIndex = -1;
  final flutterReactiveBle = RB.FlutterReactiveBle();
  RB.DiscoveredDevice? deviceChipseaBle;
  // String mButtonText = "Connect Chipsea-BLE";
  String mUnit = "no";
  String billTime = "";

  @override
  void initState() {
    super.initState();
    print('->>>>${Utilities.orderDataList}');
    print('->>>>${Utilities.finalPrice}');
    billTime = DateTime.now().toString();
    print('->>>>$billTime');
    (WidgetsBinding.instance)?.addPostFrameCallback((_) async {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onScanPressed() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();
      if (statuses[Permission.bluetoothScan] != PermissionStatus.granted ||
          statuses[Permission.bluetoothConnect] != PermissionStatus.granted) {
        return;
      }
    }

    setState(() => _isLoading = true);
    _bluePrintPos.scan().then((List<BlueDevice> devices) {
      if (devices.isNotEmpty) {
        setState(() {
          _blueDevices = devices;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    });
  }

  void _onDisconnectDevice() {
    _bluePrintPos.disconnect().then((ConnectionStatus status) {
      if (status == ConnectionStatus.disconnect) {
        setState(() {
          _selectedDevice = null;
        });
      }
    });
  }

  void _onSelectDevice(int index) {
    setState(() {
      _isLoading = true;
      _loadingAtIndex = index;
    });
    final BlueDevice blueDevice = _blueDevices[index];
    _bluePrintPos.connect(blueDevice).then((ConnectionStatus status) {
      if (status == ConnectionStatus.connected) {
        setState(() => _selectedDevice = blueDevice);
      } else if (status == ConnectionStatus.timeout) {
        _onDisconnectDevice();
      } else {
        if (kDebugMode) {
          print('$runtimeType - something wrong');
        }
      }
      setState(() => _isLoading = false);
    });
  }

  Future<void> _onPrintReceipt() async {
    /// Example for Print Image
    final ByteData logoBytes = await rootBundle.load(
      'assets/images/chaibabalogo.png',
    );

    /// Example for Print Text
    final ReceiptSectionText receiptText = ReceiptSectionText();
    receiptText.addImage(
      base64.encode(Uint8List.view(logoBytes.buffer)),
      width: 300,
    );
    receiptText.addSpacer();

    receiptText.addSpacer(useDashed: true);
    receiptText.addLeftRightText('Time', billTime);
    receiptText.addSpacer(useDashed: true);
    receiptText.addLeftRightText(
      'Apple 4pcs',
      '\$ 10.00',
      leftStyle: ReceiptTextStyleType.normal,
      rightStyle: ReceiptTextStyleType.bold,
    );
    receiptText.addSpacer(useDashed: true);
    receiptText.addLeftRightText(
      'TOTAL',
      '\$ 10.00',
      leftStyle: ReceiptTextStyleType.normal,
      rightStyle: ReceiptTextStyleType.bold,
    );
    receiptText.addSpacer(useDashed: true);
    receiptText.addLeftRightText(
      'Payment',
      'Cash',
      leftStyle: ReceiptTextStyleType.normal,
      rightStyle: ReceiptTextStyleType.normal,
    );
    // receiptText.addSpacer(count: 2);

    await _bluePrintPos.printReceiptText(receiptText);

    /// Example for print QR
    // await _bluePrintPos.printQR('https://www.google.com/', size: 250);

    /// Text after QR
    final ReceiptSectionText receiptSecondText = ReceiptSectionText();
    // receiptSecondText.addText('Powered by Google',
    //     size: ReceiptTextSizeType.small);
    // receiptSecondText.addSpacer();
    await _bluePrintPos.printReceiptText(receiptSecondText, feedCount: 1);
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
                    Utilities.bthAddress = _selectedDevice?.address;
                  });
                  print("utilities address---->${Utilities.bthAddress}");
                  print("selected device---->${_selectedDevice?.address}");
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
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
      body: SafeArea(
        child: _isLoading && _blueDevices.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            : _blueDevices.isNotEmpty
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Container(
                        //   alignment: Alignment.center,
                        //   child: TextButton(
                        //     child: Text(
                        //       mButtonText,
                        //     ),
                        //     onPressed: () {
                        //       setState(() {
                        //         mButtonText = "Connecting...";
                        //       });
                        //
                        //       flutterReactiveBle.scanForDevices(
                        //         withServices: [],
                        //         scanMode: RB.ScanMode.lowLatency,
                        //       ).listen((device) async {
                        //         //code for handling results
                        //         if (deviceChipseaBle == null &&
                        //             device.name == "Chipsea-BLE") {
                        //           deviceChipseaBle = device;
                        //
                        //           flutterReactiveBle
                        //               .connectToDevice(
                        //             id: device.id,
                        //             servicesWithCharacteristicsToDiscover: null,
                        //             connectionTimeout:
                        //             const Duration(seconds: 2),
                        //           )
                        //               .listen((connectionState) {
                        //             // Handle connection state updates
                        //             String _connectionStatus = "---";
                        //             switch (connectionState.connectionState) {
                        //               case RB.DeviceConnectionState.connected:
                        //                 _connectionStatus =
                        //                 "Connected Chipsea-BLE";
                        //                 break;
                        //               case RB.DeviceConnectionState.connecting:
                        //                 _connectionStatus = "Connecting...";
                        //                 break;
                        //               case RB
                        //                   .DeviceConnectionState.disconnected:
                        //                 _connectionStatus = "Disconnected";
                        //                 break;
                        //               case RB
                        //                   .DeviceConnectionState.disconnecting:
                        //                 _connectionStatus = "Disconnecting...";
                        //                 break;
                        //               default:
                        //                 break;
                        //             }
                        //
                        //             setState(() {
                        //               mButtonText = _connectionStatus;
                        //             });
                        //           }, onError: (Object error) {
                        //             // Handle a possible error
                        //           });
                        //
                        //           List<RB.DiscoveredService> services =
                        //           await flutterReactiveBle.discoverServices(
                        //             device.id,
                        //           );
                        //
                        //           final characteristic =
                        //           RB.QualifiedCharacteristic(
                        //             serviceId: RB.Uuid.parse("FFF0"),
                        //             characteristicId: RB.Uuid.parse("fff1"),
                        //             deviceId: device.id,
                        //           );
                        //           flutterReactiveBle
                        //               .subscribeToCharacteristic(characteristic)
                        //               .listen((data) {
                        //             // code to handle incoming data
                        //             if (data.isNotEmpty) {
                        //               List<int> _dataReading =
                        //               data.sublist(0, 6);
                        //               int _dataAttribute = data[6];
                        //               int _dataDecimalPoint =
                        //               _dataAttribute & 0x07;
                        //               int _dataUnit = _dataAttribute & 0x38;
                        //
                        //               String _reading =
                        //               String.fromCharCodes(_dataReading);
                        //               if (_reading.isNotEmpty) {
                        //                 int decimalPointAt =
                        //                     _reading.length - _dataDecimalPoint;
                        //                 String _readingFront = _reading
                        //                     .substring(0, decimalPointAt);
                        //                 String _readingBack =
                        //                 _reading.substring(decimalPointAt);
                        //
                        //                 String _unit = "no";
                        //                 if (_dataUnit == 8) {
                        //                   _unit = "kg";
                        //                 } else if (_dataUnit == 16) {
                        //                   _unit = "lb";
                        //                 } else if (_dataUnit == 24) {
                        //                   _unit = "oz";
                        //                 } else if (_dataUnit == 32) {
                        //                   _unit = "g";
                        //                 }
                        //
                        //                 setState(() {
                        //                   mWeighingReading = _readingFront +
                        //                       "." +
                        //                       _readingBack;
                        //                   mUnit = _unit;
                        //                 });
                        //               }
                        //             }
                        //           }, onError: (dynamic error) {
                        //             // code to handle errors
                        //           });
                        //         }
                        //       }, onError: (err) {
                        //         //code for handling error
                        //       });
                        //     },
                        //   ),
                        // ),
                        Column(
                          children: List<Widget>.generate(_blueDevices.length,
                              (int index) {
                            return Row(
                              children: <Widget>[
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _blueDevices[index].address ==
                                            (_selectedDevice?.address ?? '')
                                        ? _onDisconnectDevice
                                        : () => _onSelectDevice(index),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            _blueDevices[index].name,
                                            style: TextStyle(
                                              color: _selectedDevice?.address ==
                                                      _blueDevices[index]
                                                          .address
                                                  ? Colors.blue
                                                  : Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            _blueDevices[index].address,
                                            style: TextStyle(
                                              color: _selectedDevice?.address ==
                                                      _blueDevices[index]
                                                          .address
                                                  ? Colors.blueGrey
                                                  : Colors.grey,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (_loadingAtIndex == index && _isLoading)
                                  Container(
                                    height: 24.0,
                                    width: 24.0,
                                    margin: const EdgeInsets.only(right: 8.0),
                                    child: const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue,
                                      ),
                                    ),
                                  ),
                                if (!_isLoading &&
                                    _blueDevices[index].address ==
                                        (_selectedDevice?.address ?? ''))
                                  TextButton(
                                    onPressed: /*_onPrintReceipt*/null,
                                    child: Container(
                                      color: _selectedDevice == null
                                          ? Colors.grey
                                          : blackColor,
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
                                        'Connected',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Text(
                          'Scan bluetooth device',
                          style: TextStyle(fontSize: 24, color: blackColor),
                        ),
                        Text(
                          'Press scan button',
                          style: TextStyle(fontSize: 14, color: blackColor),
                        ),
                      ],
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _onScanPressed,
        child: Text("Scan"),
        backgroundColor: _isLoading ? blackColor : blackColor,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
