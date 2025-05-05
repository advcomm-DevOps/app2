import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:uids_io_sdk_flutter/uids_io_sdk_flutter.dart';

import '../sqlite/dio_interceptor.dart';

void setupDatabaseFactory() {
  sqfliteFfiInit();
  databaseFactory = kIsWeb ? databaseFactoryFfiWeb : databaseFactoryFfi;
  DioClient.setupInterceptors();
  GmailSSO.dio2 = DioClient.dio;
}