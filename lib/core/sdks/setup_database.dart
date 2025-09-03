import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:uids_io_sdk_flutter/uids_io_sdk_flutter.dart';

import '../sqlite/dio_interceptor.dart';

Future<void> setupDatabaseFactory() async {
  sqfliteFfiInit();
  
  if (!kIsWeb) {
    // Change to the executable directory so database files are created there
    String executablePath = Platform.resolvedExecutable;
    String executableDir = executablePath.substring(0, executablePath.lastIndexOf(Platform.pathSeparator));
    Directory.current = executableDir;
    
    databaseFactory = databaseFactoryFfi;
  } else {
    databaseFactory = databaseFactoryFfiWeb;
  }
  
  DioClient.setupInterceptors();
  GmailSSO.dio2 = DioClient.dio;
}