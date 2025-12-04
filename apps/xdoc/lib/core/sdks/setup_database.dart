import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:uids_io_sdk_flutter/uids_io_sdk_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../sqlite/dio_interceptor.dart';

Future<void> setupDatabaseFactory() async {
  if (!kIsWeb) {
    // Only initialize sqfliteFfi for desktop platforms (not mobile)
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      String databasePath;

      if (Platform.isWindows) {
        // Check if we're running in an MSIX package
        bool isMsixPackage = _isRunningInMsixPackage();

        if (isMsixPackage) {
          // For MSIX packages, use ApplicationData/Local folder
          String? localAppData = Platform.environment['LOCALAPPDATA'];
          if (localAppData != null) {
            databasePath = '$localAppData\\XDoc';
          } else {
            // Ultimate fallback for MSIX
            String? userProfile = Platform.environment['USERPROFILE'];
            databasePath = '$userProfile\\AppData\\Local\\XDoc';
          }
        } else {
          // For regular executables (debug/release), use executable directory
          String executablePath = Platform.resolvedExecutable;
          databasePath = executablePath.substring(
            0,
            executablePath.lastIndexOf(Platform.pathSeparator),
          );
        }
      } else {
        // For Linux/MacOS desktop, use executable directory
        String executablePath = Platform.resolvedExecutable;
        databasePath = executablePath.substring(
          0,
          executablePath.lastIndexOf(Platform.pathSeparator),
        );
      }

      // Create directory if it doesn't exist
      try {
        Directory(databasePath).createSync(recursive: true);
        Directory.current = databasePath;
        print('Database path: $databasePath');
      } catch (e) {
        print('Error setting up database directory: $e');
        print('Using current directory: ${Directory.current.path}');
      }
    } else if (Platform.isAndroid || Platform.isIOS) {
      // For mobile platforms (Android/iOS), use the app's documents directory
      // Do NOT set Directory.current on mobile - it's not allowed
      final appDocDir = await getApplicationDocumentsDirectory();
      print('Mobile database path: ${appDocDir.path}');
      // Note: We don't set Directory.current here - Drift will handle the path
    }
  } else {
    databaseFactory = databaseFactoryFfiWeb;
  }

  DioClient.setupInterceptors();
  GmailSSO.dio2 = DioClient.dio;
}

bool _isRunningInMsixPackage() {
  // Check multiple indicators that we're running in an MSIX package
  return Platform.environment['LOCALAPPDATA']?.contains('\\Packages\\') ==
          true ||
      Platform.environment['MSIX_PACKAGE_FAMILY_NAME'] != null ||
      Platform.environment['ApplicationUserModelId'] != null ||
      Platform.resolvedExecutable.contains('WindowsApps');
}
