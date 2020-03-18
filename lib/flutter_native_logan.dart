

import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:flutter_native_logan/config.dart';
import 'package:flutter_native_logan/logan.dart';
import 'package:flutter_native_logan/result.dart';

import 'log_isolate.dart';

class FlutterNativeLogan {

  static LogIsolateMonitor logan = LogIsolateMonitor();

  static Future<LoganResult> init(
      String aseKey, String aesIv, int maxFileLen, {LogConfig config}) async {
    config ??= LogConfig();
    LoganResult result = await logan.init(aseKey, aesIv, maxFileLen, config);
    logan.initResult(result.success);
    return result;

  }

  static Future<LoganResult> log(int type, String log) async {
    return await logan.log(type, log);
  }

  static Future<LoganResult> getUploadPath(String date) async {
    return await logan.getUploadPath(date);
  }

  static Future<LoganResult> upload(String serverUrl, String date, String appId, String unionId, String deviceId) async {
    LoganResult result = await logan.upload(serverUrl, date, appId, unionId, deviceId);
    log(1, result.message);
    return result;
  }

  static Future<LoganResult> flush() async {
    return await logan.flush();
  }

  static Future<void> cleanAllLogs() async {
    return await logan.cleanAllLogs();
  }
}

