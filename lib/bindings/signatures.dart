import 'dart:ffi';
import 'dart:math';

import 'package:ffi/ffi.dart';

typedef logan_init_native_t = Int32 Function(Pointer<Utf8> cacheDirs, Pointer<Utf8> pathDris,
    Int32 maxFile, Pointer<Utf8> key16, Pointer<Utf8> iv16);

typedef logan_open_native_t = Int32 Function(Pointer<Utf8> pathName);

typedef logan_write_native_t = Int32 Function(Int32 flag, Pointer<Utf8> log, Pointer<Utf8> localTime,
    Pointer<Utf8> threadName, Int64 threadId, Int32 isMain);

typedef logan_flush_native_t = Int32 Function();

typedef logan_debug_native_t = Int32 Function(Int32 debug);