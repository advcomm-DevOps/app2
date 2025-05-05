import 'package:flutter/services.dart';
import 'package:flutter_starter/core/sqlite/db_setup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenant_replication/tenant_replication.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() {
  // Must be first
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = kIsWeb ? databaseFactoryFfiWeb : databaseFactoryFfi;

  const MethodChannel channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

setUp(() {
  // Mock the secure storage plugin methods
  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'read') {
      final String? key = methodCall.arguments['key'];
      if (key == 'DeviceId') {
        return '00000000';
      } else if (key == 'DatabaseName') {
        return 'testing';
      }
      return null;
    }
    switch (methodCall.method) {
      case 'write':
      case 'delete':
      case 'deleteAll':
        return null;
      default:
        return null;
    }
  });
});

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('testing code..........', () async {
    await DatabaseSetup.initialize();
    await SSEManager.initializeSSE('http://192.168.0.87:3000');
    expect(true, true);
  });
}
