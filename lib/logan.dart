import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter_native_logan/config.dart';
import 'package:flutter_native_logan/result.dart';
import 'package:intl/intl.dart';
import 'bindings/bindings.dart' show bindings;
import 'bindings/constants.dart';

class Logan {
  Directory _loganFileDir;
  int currentDay = 0;
  int lastTime = 0;
  
  LogConfig config;

  static const int LONG = 24  * 60 * 60 * 1000;
  static const DATE_FORMAT = 'yyyy-MM-dd';
  static const MINUTE = 1000 * 60;

  bool hasInit = false;

  Future<LoganResult> init(String dir, String aseKey, String aesIv, int maxFileLen, LogConfig config) async {
    if (hasInit) {
      return LoganResult(true, 0, 'Logan已经初始化了');
    }
    this.config = config;
    Directory directory = Directory(dir);
    final cachePath = Utf8.toUtf8(directory.path);
    final String loganFilePath = '${directory.path}/logan_v1';
    _loganFileDir = Directory(loganFilePath);
    if (!await _loganFileDir.exists()) {
    await _loganFileDir.create();
    }
    final path = Utf8.toUtf8(_loganFileDir.path);
    final cKey = Utf8.toUtf8(aseKey);
    final cIv = Utf8.toUtf8(aesIv);
    int nativeCode = bindings.init(cachePath, path, maxFileLen, cKey,  cIv);
    /// native堆释放内存
    free(cachePath);
    free(path);
    free(cKey);
    free(cIv);

    hasInit = nativeCode == CLOGAN_INIT_SUCCESS_MMAP || nativeCode == CLOGAN_INIT_SUCCESS_MEMORY;

    return LoganResult.fromNative(
      hasInit,
      nativeCode
    );
  }


  bool isToday(){
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    return currentDay < currentTime && currentDay + LONG > currentTime;
  }

  void preWriteProcess(){
    if (!isToday()){
      ///删除过期日志文件

      int todayStartTime = dateTimeToStartTime(DateTime.now().millisecondsSinceEpoch);
      currentDay = todayStartTime;
      int deleteTime = todayStartTime - config.expiredTime;
      deleteExpiredFile(deleteTime);

      ///创建新日志文件
      open(todayStartTime.toString());
    }
  }

  /// 求当天00:00:00的毫秒数
  int dateTimeToStartTime(int dateTime){
    DateFormat df = DateFormat(DATE_FORMAT);
    String dateStr = df.format(DateTime.fromMillisecondsSinceEpoch(dateTime));
    return df.parse(dateStr).millisecondsSinceEpoch;
  }

  /// 求当天00:00:00的毫秒数
  int dateToStartTime(String dateStr){
    DateFormat df = DateFormat(DATE_FORMAT);
    int dateTime = df.parse(dateStr).millisecondsSinceEpoch;
    return dateTimeToStartTime(dateTime);
  }

  bool open(String fileName){
    var cFileName = Utf8.toUtf8(fileName);
    int nativeCode = bindings.open(cFileName);
    free(cFileName);
    if (config.debug) {
      print('${DateTime.now().toUtc()} ${NativeCodeMessage[nativeCode]}');
    }
    return nativeCode == CLOGAN_OPEN_SUCCESS;
  }


  LoganResult log(int type, String log){

    preWriteProcess();

    int threadId = 0;
    int isMain = 0;
    int nativeCode = bindings.write(
        type,
        Utf8.toUtf8(log),
        Utf8.toUtf8(DateTime.now().millisecondsSinceEpoch.toString()),
        Utf8.toUtf8('main'),
        threadId,
        isMain
    );

    if(config.debug){
      print('${DateTime.now().toUtc()} ${NativeCodeMessage[nativeCode]} -> $log');
    }

    return LoganResult.fromNative(
      nativeCode == CLOGAN_WRITE_SUCCESS,
      nativeCode
    );
  }

  /// 删除过期文件
  Future<void> deleteExpiredFile(int deleteTime) {
    var completer = new Completer<void>();
    if (_loganFileDir == null) {
      completer.complete();
      return completer.future;
    }

    _loganFileDir.list().listen(
      (file){
        String path = file.path;
        int index = path.lastIndexOf('/');
        String fileName = path.substring(index + 1);
        int logTime = int.parse(fileName);
        if (deleteTime > logTime) {
          file.deleteSync();
        }
      },
      onDone: (){
        completer.complete();
      }
    );
    return completer.future;
  }

  LoganResult flush(){
    int nativeCode = bindings.flush();
    return LoganResult.fromNative(nativeCode == CLOGAN_FLUSH_SUCCESS, nativeCode);
  }

  ///清空所以日志
  Future<LoganResult> cleanAllLogs(){
    var completer = new Completer<LoganResult>();
    _loganFileDir.list().listen(
        (file) {
          if(config.debug) {
            print('删除日志: $file');
          }
          file.deleteSync();
        },
        onDone: (){
          completer.complete(LoganResult.simple(true));
        }
    );
    return completer.future;
  }

  ///获取日期的日志文件路径
  Future<LoganResult> getUploadPath(String date) {
    var completer = new Completer<LoganResult>();
    _loganFileDir.list().listen(
            (file) {
          if(file.path.contains(dateToStartTime(date).toString())){
            completer.complete(LoganResult.data(file.path));
          }
        },
        onDone: (){
          if(!completer.isCompleted){
            completer.complete(LoganResult(false, 0, '该日期下没有日志文件'));
          }
        }
    );
    return completer.future;
  }

}