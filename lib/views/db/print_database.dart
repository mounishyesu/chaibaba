
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/utilities.dart';

const String deviceName = "deviceName";
const String deviceAddress = "deviceAddress";

Future setDeviceData(name, address) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(deviceName, name);
  prefs.setString(deviceAddress, address);
}

Future<String?> getDeviceName() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(deviceName) ?? "";
}

Future<String?> getDeviceAddress() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print("deviceAddress------------");
  print(deviceAddress);
  return prefs.getString(deviceAddress) ?? Utilities.bthAddress;
}

Future clearDevice() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(deviceName, "");
  prefs.setString(deviceAddress, "");
}