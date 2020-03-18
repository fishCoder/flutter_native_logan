import 'package:flutter_native_logan/bindings/constants.dart';

class LoganResult{
  LoganResult(this.success, this.code, this.message);
  LoganResult.fromNative(this.success, this.code){
    message = NativeCodeMessage[code];
  }
  LoganResult.simple(this.success);
  LoganResult.data(this.data){
    this.success = true;
  }
  bool success;
  int code;
  String message;
  dynamic data;
}