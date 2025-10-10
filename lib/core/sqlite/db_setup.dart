import 'package:tenant_replication/tenant_replication.dart';

import '../../custom/sqlite_tables.dart';

class DatabaseSetup {
  static Future<void> initialize() async {
    print("🔹 Initializing database setup...");
    final db = await DBHelper.db;
    
    // Create tblcategories table
     await db.transaction((txn) async {
      for (String query in createTableQueries) {
        await txn.execute(query);
      }
    });
     await _ensureCriticalColumns(db);
    // Add sync triggers
    await TriggerManager.setupTriggers();
    var result = await db.rawQuery("PRAGMA application_id;");
    print("🔹 Application ID set to: ${result.first.values.first}");
  }

  static Future<void> _ensureCriticalColumns(db) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name != 'tbldmlog';"
    );

    for (final tableRow in tables) {
      final tableName = tableRow['name'] as String;
      
      final columns = await db.rawQuery("PRAGMA table_info($tableName);");
      final existingColumns = columns.map((c) => c['name']).toSet();

      if (!existingColumns.contains('lastupdatedtxid')) {
        print("⚡ Adding missing 'lastupdatedtxid' to $tableName");
        await db.execute('ALTER TABLE $tableName ADD COLUMN lastupdatedtxid INTEGER;');
      }
      if (!existingColumns.contains('lastupdated')) {
        print("⚡ Adding missing 'lastupdated' to $tableName");
        await db.execute('ALTER TABLE $tableName ADD COLUMN lastupdated BIGINT;');
      }
      if (!existingColumns.contains('deletedtxid')) {
        print("⚡ Adding missing 'deletedtxid' to $tableName");
        await db.execute('ALTER TABLE $tableName ADD COLUMN deletedtxid INTEGER;');
      }
    }
  }
}

