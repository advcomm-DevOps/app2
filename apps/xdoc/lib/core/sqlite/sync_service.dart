import 'package:mtds/index.dart';
import 'dio_interceptor.dart';

class SyncService {
  /// Manually trigger sync to server
  /// Returns SyncResult with sync statistics
  static Future<SyncResult> sync() async {
    final sdk = mtdsSdk;
    final result = await sdk.syncToServer();

    print('🔄 Sync completed:');
    print('  - Total: ${result.total}');
    print('  - Processed: ${result.processed}');
    print('  - Errors: ${result.errors}');
    print('  - Success: ${result.success}');

    return result;
  }

  /// Load data from server for specific tables
  static Future<void> loadData({required List<String> tableNames}) async {
    final sdk = mtdsSdk;
    await sdk.loadFromServer(tableNames: tableNames);

    print('📥 Data loaded for tables: ${tableNames.join(', ')}');
  }
}
