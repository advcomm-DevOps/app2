import 'package:tenant_replication/tenant_replication.dart';

import '../../custom/constants.dart';

class SyncService {
  static Future<void> sync() async {
    await SyncManager.syncWithServer("http://$audDomain");
  }
}
