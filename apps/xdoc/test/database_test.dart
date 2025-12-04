import 'dart:io';
import 'package:flutter/services.dart';
import 'package:xdoc/core/sqlite/db_setup.dart';
import 'package:flutter_test/flutter_test.dart';
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
          return 'xdoc_test_db';
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

  test('Database initialization and table creation', () async {
    print('\n🔹 Starting database initialization test...');

    // Initialize the database
    await DatabaseSetup.initialize();

    print('✅ Database initialized successfully');

    // Access the database instance
    final db = appDatabase;

    // Query to check all created tables
    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name;",
          readsFrom: {},
        )
        .get();

    print('\n📊 Created tables:');
    for (final table in tables) {
      final tableName = table.data['name'];
      print('  - $tableName');

      // Get column info for each table
      final columns = await db
          .customSelect('PRAGMA table_info($tableName)', readsFrom: {})
          .get();

      print('    Columns:');
      for (final col in columns) {
        final colName = col.data['name'];
        final colType = col.data['type'];
        print('      • $colName ($colType)');
      }
    }

    print('\n✅ Test completed successfully');
    print(
      '📁 Database file location: ${Directory.current.path}/xdoc_test_db.db',
    );

    // Verify expected tables exist
    final tableNames = tables.map((t) => t.data['name'] as String).toSet();
    expect(
      tableNames.contains('channels'),
      true,
      reason: 'channels table should exist',
    );
    expect(
      tableNames.contains('channel_tags'),
      true,
      reason: 'channel_tags table should exist',
    );
    expect(
      tableNames.contains('x_doc_actors'),
      true,
      reason: 'x_doc_actors table should exist',
    );
    expect(
      tableNames.contains('x_doc_events'),
      true,
      reason: 'x_doc_events table should exist',
    );
    expect(
      tableNames.contains('x_doc_state_transitions'),
      true,
      reason: 'x_doc_state_transitions table should exist',
    );
    expect(
      tableNames.contains('x_docs'),
      true,
      reason: 'x_docs table should exist',
    );
    expect(
      tableNames.contains('mtds_change_log'),
      true,
      reason: 'mtds_change_log table should exist',
    );
    expect(
      tableNames.contains('mtds_metadata'),
      true,
      reason: 'mtds_metadata table should exist',
    );
    expect(
      tableNames.contains('mtds_state'),
      true,
      reason: 'mtds_state table should exist',
    );
  });
}
