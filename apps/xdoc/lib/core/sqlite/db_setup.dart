import 'app_database.dart';

/// Global database instance (initialized after authentication)
AppDatabase? _appDatabase;

/// Get or create the database instance
AppDatabase get appDatabase {
  if (_appDatabase == null) {
    throw StateError(
      'Database not initialized. Call DatabaseSetup.initialize() first.',
    );
  }

  return _appDatabase!;
}

class DatabaseSetup {
  /// Initialize the Drift database
  /// Tables are created automatically via Drift migrations
  /// MTDS metadata tables and triggers are set up via SchemaManager
  static Future<void> initialize() async {
    print("🔹 Initializing Drift database setup...");

    // Create database instance (this triggers migrations)
    _appDatabase = AppDatabase();

    // Ensure MTDS columns exist in all tables (migration from old schema)
    await _ensureCriticalColumns(_appDatabase!);

    // Verify application ID (already set in _openConnection)
    print("🔹 Application ID configured");

    print("🔹 Database initialized successfully with Drift");
  }

  /// Ensure all tables have the required MTDS columns
  /// This handles migration from old column names to new MTDS column names
  static Future<void> _ensureCriticalColumns(AppDatabase db) async {
    // Get all user tables (exclude system tables)
    final tablesResult = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'mtds_%';",
          readsFrom: {},
        )
        .get();

    for (final tableRow in tablesResult) {
      final tableName = tableRow.data['name'] as String;

      // Get existing columns using PRAGMA
      final columnsResult = await db
          .customSelect('PRAGMA table_info($tableName)', readsFrom: {})
          .get();

      final existingColumns = columnsResult
          .map((c) => c.data['name'] as String?)
          .whereType<String>()
          .toSet();

      // Migrate old column names to new MTDS column names
      // lastupdatedtxid → mtds_client_ts
      if (existingColumns.contains('lastupdatedtxid') &&
          !existingColumns.contains('mtds_client_ts')) {
        print(
          "⚡ Migrating 'lastupdatedtxid' to 'mtds_client_ts' in $tableName",
        );

        await db.customStatement(
          'ALTER TABLE $tableName ADD COLUMN mtds_client_ts INTEGER NOT NULL DEFAULT 0;',
        );

        // Copy data from old column to new column
        await db.customStatement(
          'UPDATE $tableName SET mtds_client_ts = COALESCE(lastupdatedtxid, 0);',
        );
      } else if (!existingColumns.contains('mtds_client_ts')) {
        print("⚡ Adding missing 'mtds_client_ts' to $tableName");
        await db.customStatement(
          'ALTER TABLE $tableName ADD COLUMN mtds_client_ts INTEGER NOT NULL DEFAULT 0;',
        );
      }

      // lastupdated → mtds_server_ts
      if (existingColumns.contains('lastupdated') &&
          !existingColumns.contains('mtds_server_ts')) {
        print("⚡ Migrating 'lastupdated' to 'mtds_server_ts' in $tableName");

        await db.customStatement(
          'ALTER TABLE $tableName ADD COLUMN mtds_server_ts INTEGER;',
        );

        // Copy data from old column to new column
        await db.customStatement(
          'UPDATE $tableName SET mtds_server_ts = lastupdated;',
        );
      } else if (!existingColumns.contains('mtds_server_ts')) {
        print("⚡ Adding missing 'mtds_server_ts' to $tableName");
        await db.customStatement(
          'ALTER TABLE $tableName ADD COLUMN mtds_server_ts INTEGER;',
        );
      }

      // deletedtxid → mtds_delete_ts
      if (existingColumns.contains('deletedtxid') &&
          !existingColumns.contains('mtds_delete_ts')) {
        print("⚡ Migrating 'deletedtxid' to 'mtds_delete_ts' in $tableName");
        await db.customStatement(
          'ALTER TABLE $tableName ADD COLUMN mtds_delete_ts INTEGER;',
        );

        // Copy data from old column to new column
        await db.customStatement(
          'UPDATE $tableName SET mtds_delete_ts = deletedtxid;',
        );
      } else if (!existingColumns.contains('mtds_delete_ts')) {
        print("⚡ Adding missing 'mtds_delete_ts' to $tableName");
        await db.customStatement(
          'ALTER TABLE $tableName ADD COLUMN mtds_delete_ts INTEGER;',
        );
      }

      // Add mtds_device_id if missing
      if (!existingColumns.contains('mtds_device_id')) {
        print("⚡ Adding missing 'mtds_device_id' to $tableName");

        await db.customStatement(
          'ALTER TABLE $tableName ADD COLUMN mtds_device_id INTEGER NOT NULL DEFAULT 0;',
        );
      }
    }
  }
}
