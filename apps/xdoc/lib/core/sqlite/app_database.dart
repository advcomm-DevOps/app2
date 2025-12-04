import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mtds/index.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'app_database.g.dart';

// ============================================================================
// Table Definitions with MtdsColumns Mixin
// ============================================================================

/// Channels table - stores communication channels between entities
class Channels extends Table with MtdsColumns {
  IntColumn get channelId => integer()();
  TextColumn get channelName => text().withLength(min: 1, max: 63)();
  TextColumn get channelDescription => text().withLength(min: 1, max: 63)();
  TextColumn get entityRoles =>
      text().withLength(min: 1, max: 63).withDefault(const Constant('all'))();
  Int64Column get actorSequence => int64()();
  Int64Column get initialActorId => int64().nullable()();
  Int64Column get otherActorId => int64().nullable()();
  TextColumn get contextTemplate => text().nullable()();
  BoolColumn get isTagRequired =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {channelId};
}

/// Channel tags table - stores tags associated with channels
class ChannelTags extends Table with MtdsColumns {
  Int64Column get channelTagId => int64().autoIncrement()();
  Int64Column get channelId => int64()();
  TextColumn get tag => text().withLength(min: 1, max: 63)();
  TextColumn get tagDescription => text().withLength(max: 255).nullable()();
  DateTimeColumn get expireAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {channelId, tag},
  ];
}

/// XDoc actors table - stores document actors (participants)
class XDocActors extends Table with MtdsColumns {
  Int64Column get xDocActorId => int64().autoIncrement()();
  Int64Column get xDocId => int64()();
  Int64Column get actorId => int64()();
  Int64Column get channelId => int64()();
  BlobColumn get encryptedSymmetricKey => blob().nullable()();
  Int64Column get interconnectId => int64().nullable()();
  TextColumn get docName => text().withLength(min: 1, max: 63)();
  TextColumn get contextData => text()(); // JSONB stored as TEXT
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get completionTime => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {xDocId, actorId},
  ];
}

/// XDoc events table - stores events related to documents
class XDocEvents extends Table with MtdsColumns {
  Int64Column get xDocEventId => int64().autoIncrement()();
  Int64Column get xDocActorId => int64()();
  Int64Column get xDocId => int64().nullable()(); // Denormalized
  Int64Column get actorId => int64().nullable()(); // Denormalized
  TextColumn get eventPayload => text()();
  TextColumn get contextData => text().withDefault(const Constant('{}'))();
  TextColumn get entityRoles => text().withLength(min: 1, max: 63)();
}

/// XDoc state transitions table - tracks document state changes
class XDocStateTransitions extends Table with MtdsColumns {
  Int64Column get xDocStateTransitionId => int64().autoIncrement()();
  TextColumn get channelStateName => text().withLength(min: 1, max: 63)();
  Int64Column get xDocActorId => int64()();
  Int64Column get channelStateId => int64().nullable()();
  DateTimeColumn get entryTime => dateTime()();
  DateTimeColumn get exitTime => dateTime().nullable()();
}

/// XDocs table - main documents table
class XDocs extends Table with MtdsColumns {
  IntColumn get xDocId => integer()();
  IntColumn get interconnectId => integer().nullable()();
  TextColumn get docName => text().withLength(max: 63).nullable()();
  TextColumn get contextData => text().nullable()();
  TextColumn get startTime => text().nullable()();
  TextColumn get completionTime => text().nullable()();
  IntColumn get insertTime => integer().nullable()();
  IntColumn get deletedTime => integer().nullable()();
  IntColumn get isNotDeleted => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {xDocId};
}

// ============================================================================
// Database Class
// ============================================================================

@DriftDatabase(
  tables: [
    Channels,
    ChannelTags,
    XDocActors,
    XDocEvents,
    XDocStateTransitions,
    XDocs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Testing constructor for in-memory database
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // Setup MTDS metadata tables
      await SchemaManager.ensureMetadataTable(this);
      await SchemaManager.ensureChangeLogTable(this);
      await SchemaManager.ensureStateTable(this);
    },
    beforeOpen: (details) async {
      if (details.wasCreated || details.hadUpgrade) {
        // Prepare database with MTDS triggers and state
        await SchemaManager.prepareDatabase(this);
      }
    },
  );
}

/// Opens a database connection using the same path logic as the existing setup
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Get database name from secure storage (set during authentication)
    final secureStorage = FlutterSecureStorage();
    final databaseName = await secureStorage.read(key: "DatabaseName");

    if (databaseName == null || databaseName.isEmpty) {
      throw Exception(
        'Database name not found in secure storage. Please authenticate first.',
      );
    }

    // Determine database path based on platform
    String dbPath;

    if (kIsWeb) {
      throw UnsupportedError(
        'Web platform not yet supported for Drift database',
      );
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Mobile: Use application documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      dbPath = p.join(appDocDir.path, '$databaseName.db');
    } else {
      // Desktop: Use the current directory (set by setupDatabaseFactory)
      final currentDir = Directory.current.path;
      dbPath = p.join(currentDir, '$databaseName.db');
    }

    // Ensure directory exists
    final dbFile = File(dbPath);
    if (!dbFile.parent.existsSync()) {
      dbFile.parent.createSync(recursive: true);
    }

    print('📁 Database file path: $dbPath');

    // Use native SQLite3 for better performance
    if (!kIsWeb) {
      // Load sqlite3 library
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }
    }

    return NativeDatabase.createInBackground(
      File(dbPath),
      setup: (database) {
        // Set application ID (same as old setup)
        database.execute(
          'PRAGMA application_id = 0x58444F43;',
        ); // 'XDOC' in hex
      },
    );
  });
}
