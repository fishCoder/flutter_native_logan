import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'signatures.dart';
class _LoganBindings {
  DynamicLibrary loganLib;
  int Function(Pointer<Utf8>, Pointer<Utf8>, int, Pointer<Utf8>, Pointer<Utf8>) init;
  int Function(Pointer<Utf8>) open;
  int Function(int, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, int, int) write;
  int Function() flush;
  int Function(int) debug;
  _LoganBindings(){
    loganLib = Platform.isAndroid
        ? DynamicLibrary.open("liblogan.so")
        : DynamicLibrary.process();

    init = loganLib.lookup<NativeFunction<logan_init_native_t>>('clogan_init').asFunction();
    open = loganLib.lookup<NativeFunction<logan_open_native_t>>('clogan_open').asFunction();
    write = loganLib.lookup<NativeFunction<logan_write_native_t>>('clogan_write').asFunction();
    flush = loganLib.lookup<NativeFunction<logan_flush_native_t>>('clogan_flush').asFunction();
    debug = loganLib.lookup<NativeFunction<logan_debug_native_t>>('clogan_debug').asFunction();
  }

}

_LoganBindings _cachedBindings;
_LoganBindings get bindings =>  _cachedBindings ??= _LoganBindings();