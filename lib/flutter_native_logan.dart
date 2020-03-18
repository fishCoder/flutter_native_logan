

import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:flutter_native_logan/logan.dart';
import 'package:flutter_native_logan/result.dart';

import 'log_isolate.dart';

class FlutterNativeLogan {

  static LogIsolateMonitor logan = LogIsolateMonitor();

  static Future<LoganResult> init(
      String aseKey, String aesIv, int maxFileLen) async {
    return await logan.init(aseKey, aesIv, maxFileLen);

  }

  static Future<LoganResult> log(int type, String log) async {
    return await logan.log(type, log);
  }

  static Future<LoganResult> getUploadPath(String date) async {
    return await logan.getUploadPath(date);
  }

  static Future<LoganResult> upload(String serverUrl, String date, String appId, String unionId, String deviceId) async {
    
    return await logan.upload(serverUrl, date, appId, unionId, deviceId);
  }

  static Future<LoganResult> flush() async {
    return await logan.flush();
  }

  static Future<void> cleanAllLogs() async {
    return await logan.cleanAllLogs();
  }
}

