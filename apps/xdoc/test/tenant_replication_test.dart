import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter/services.dart';
import 'package:xdoc/core/sqlite/db_setup.dart';
import 'package:xdoc/core/sqlite/app_database.dart';
import 'package:xdoc/core/sqlite/dio_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtds/index.dart';
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
          return 'mtds_test_db';
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

  test('MTDS SDK initialization and database setup', () async {
    print('\n🧪 Testing MTDS SDK initialization...');

    // Initialize the database
    await DatabaseSetup.initialize();
    print('✅ Database initialized');

    // Verify database is accessible
    final db = appDatabase;
    expect(db, isNotNull);
    print('✅ Database instance accessible');

    // Query tables
    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name;",
          readsFrom: {},
        )
        .get();

    final tableNames = tables.map((t) => t.data['name'] as String).toList();
    print('📊 Created tables: ${tableNames.join(', ')}');

    // Verify expected tables exist
    expect(tableNames.contains('channels'), true);
    expect(tableNames.contains('channel_tags'), true);
    expect(tableNames.contains('x_doc_actors'), true);
    expect(tableNames.contains('x_doc_events'), true);
    expect(tableNames.contains('x_doc_state_transitions'), true);
    expect(tableNames.contains('x_docs'), true);
    expect(tableNames.contains('mtds_change_log'), true);
    expect(tableNames.contains('mtds_metadata'), true);
    expect(tableNames.contains('mtds_state'), true);

    print('✅ All expected tables created');
    print('✅ Test completed successfully');
  });

  test('MTDS SDK CRUD operations', () async {
    print('\n🧪 Testing MTDS SDK CRUD operations...');

    // Initialize database
    await DatabaseSetup.initialize();
    final db = appDatabase;

    // Test: Insert a channel
    print('📝 Testing insert operation...');
    final channelData = ChannelsCompanion.insert(
      channelId: Value(1),
      channelName: 'test-channel',
      channelDescription: 'Test Channel',
      actorSequence: BigInt.from(1),
    );

    await db.into(db.channels).insert(channelData);
    print('✅ Channel inserted');

    // Test: Query the channel
    print('📖 Testing query operation...');
    final channels = await db.select(db.channels).get();
    expect(channels.length, 1);
    expect(channels.first.channelName, 'test-channel');
    print('✅ Channel queried successfully');

    // Verify MTDS columns exist
    expect(channels.first.mtdsClientTs, isNotNull);
    expect(channels.first.mtdsDeviceId, isNotNull);
    print('✅ MTDS columns present');

    // Test: Update the channel
    print('🔄 Testing update operation...');
    await (db.update(db.channels)..where((c) => c.channelId.equals(1))).write(
      ChannelsCompanion(channelDescription: Value('Updated Description')),
    );

    final updated = await (db.select(
      db.channels,
    )..where((c) => c.channelId.equals(1))).getSingle();
    expect(updated.channelDescription, 'Updated Description');
    print('✅ Channel updated successfully');

    // Test: Delete the channel
    print('🗑️  Testing delete operation...');
    final deleted = await (db.delete(
      db.channels,
    )..where((c) => c.channelId.equals(1))).go();
    expect(deleted, 1);
    print('✅ Channel deleted successfully');

    print('✅ All CRUD operations passed');
  });
}
