import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter_native_logan/config.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_native_logan/logan.dart';
import 'package:flutter_native_logan/result.dart';

class LogIsolateMonitor {

  Isolate logIsolate;
  ReceivePort receivePort = ReceivePort();
  ReceivePort errorPort = ReceivePort();
  ReceivePort exitPort = ReceivePort();

  SendPort sendPort;
  int msgId = 0;
  Map<int, Completer<LoganResult>> responses = {};
  LogConfig config;
  List<LogRequest> cacheRequestList = [];

  bool isStart = false;

  void initResult(bool success){
    if (success) {
      isStart = true;
    } else {
      cacheRequestList.clear();
    }
  }

  Future<LoganResult> init(String aseKey, String aesIv, int maxFileLen, LogConfig config) async {
    if (isStart) return LoganResult(true, 0, '已经初始化了');
    this.config = config;
    logIsolate = await Isolate.spawn(startLogIsolate, receivePort.sendPort, onError: errorPort.sendPort, onExit: exitPort.sendPort);
    await initIsolate();
    Directory directory = await getApplicationDocumentsDirectory();
    LogRequest request = LogRequest(ActionType.INIT, [directory.path, aseKey, aesIv, maxFileLen, this.config, cacheRequestList]);
    cacheRequestList.clear();
    return sendRequest(request, init: true);
  }

  Future<LoganResult> initIsolate(){
    Completer<LoganResult> completer = Completer();
    responses[-1] = completer;
    receivePort.listen(onResponse);
    errorPort.listen(onError);
    return completer.future;
  }

  Future<LoganResult> log(int type, String log) async {
    LogRequest request = LogRequest(ActionType.WRITE, [type, log]);
    return sendRequest(request);
  }

  Future<LoganResult> getUploadPath(String date){
    LogRequest request = LogRequest(ActionType.DATE_PATH, [date]);
    return sendRequest(request);
  }

  Future<LoganResult> upload(String serverUrl, String date, String appId, String unionId, String deviceId) async {
    LoganResult pathResult = await getUploadPath(date);
    if (!pathResult.success) {
      LoganResult result = LoganResult(false, 0, '该日期$date不存在日志文件');
      return result;
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    HttpClientRequest request = await HttpClient().postUrl(Uri.parse(serverUrl));
    request.headers.add("fileDate", date);
    request.headers.add("appId", appId);
    request.headers.add("unionId", unionId);
    request.headers.add("deviceId",  deviceId);
    request.headers.add("buildVersion", packageInfo.buildNumber);
    request.headers.add("appVersion", packageInfo.version);
    request.headers.add("platform", Platform.isAndroid ? '1' : '2');
    File log = File(pathResult.data);
    request.add(await log.readAsBytes());
    HttpClientResponse response = await request.close();
    int code = response.statusCode;
    String content = await response.transform(utf8.decoder).join();
    return LoganResult(code == 200, code, content);
  }

  Future<LoganResult> flush() {
    LogRequest request = LogRequest.noData(ActionType.FLUSH);
    return sendRequest(request);
  }

  Future<LoganResult> cleanAllLogs() {
    LogRequest request = LogRequest.noData(ActionType.CLEAR_ALL_LOG);
    return sendRequest(request);
  }


  Future<LoganResult> sendRequest(LogRequest request, {bool init = false}){
    Completer<LoganResult> completer = Completer();
    request.msgId = msgId;
    responses[msgId] = completer;
    msgId ++;
    if (!isStart && !init) {
      if (cacheRequestList.length > config.cacheRequestLength) {
        completer.complete(LoganResult(false, 0, '还未初始化并且缓存已满'));
        return completer.future;
      } else {
        cacheRequestList.add(request);
      }
    } else {
      sendPort.send(request);
    }
    return completer.future;
  }



  void onError(dynamic message){
    if (message is List) {
      List listError =  message;
      listError.forEach((item)=>print(item));
    }
  }

  void onResponse(dynamic message){
    if (sendPort == null) {
      sendPort = message;
      responses[-1].complete();
      responses.remove(-1);
      return;
    }
    LogResponse response = message;
    if (responses.containsKey(response.msgId)) {
      responses[response.msgId].complete(response.result);
      responses.remove(response.msgId);
    }
  }


}

class LogIsolate {

  SendPort sendPort;

  LogIsolate(this.sendPort);

  Logan logan = Logan();

  void onMainMsgReceive(dynamic message) async {
    LogRequest request = message;
    try {
      LoganResult result;
      List args = request.data;
      switch(request.type) {
        case ActionType.INIT:
          result = await logan.init(args[0], args[1], args[2], args[3], args[4]);
          writeCacheLog(args[5]);
          break;
        case ActionType.WRITE:
          result = logan.log(args[0], args[1]);
          break;
        case ActionType.FLUSH:
          result = logan.flush();
          break;
        case ActionType.DATE_PATH:
          result = await logan.getUploadPath(args[0]);
          break;
        case ActionType.CLEAR_ALL_LOG:
          result = await logan.cleanAllLogs();
          break;
      }

      send(LogResponse(request.msgId, result));
    } on Exception catch (e) {
      send(LogResponse(request.msgId, LoganResult(false, 0, e.toString())));
    }
  }


  void writeCacheLog(List requestList){
    if (requestList != null && requestList.isNotEmpty) {
      requestList.forEach(onMainMsgReceive);
    }
  }

  void send(dynamic message) {
    sendPort.send(message);
  }
}

void startLogIsolate(SendPort port){
  ReceivePort receivePort = ReceivePort();
  port.send(receivePort.sendPort);
  LogIsolate logIsolate = LogIsolate(port);
  receivePort.listen(logIsolate.onMainMsgReceive);
}


enum ActionType {
  INIT,
  WRITE,
  FLUSH,
  DATE_PATH,
  CLEAR_ALL_LOG
}

class LogRequest{
  int msgId;
  ActionType type;
  dynamic data;
  LogRequest(this.type, this.data);
  LogRequest.noData(this.type);
}

class LogResponse{
  LogResponse(this.msgId, this.result);
  int msgId;
  LoganResult result;
}