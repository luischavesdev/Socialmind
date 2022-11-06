import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDataProvider with ChangeNotifier {
  String _username = "";
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo? _deviceID = null;

  String get username => _username;

  String? get deviceID => _deviceID?.id;

  void setUsername(String name) {
    _username = name;
    notifyListeners();
  }

  void setID() async {
    _deviceID = await deviceInfo.androidInfo;
    notifyListeners();
  }
}
