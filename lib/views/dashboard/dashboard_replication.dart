import 'dart:async';
import 'package:tenant_replication/tenant_replication.dart';

class DashboardReplication {
  static Future<List<Map<String, dynamic>>> getChannels() async {
    final db = await DBHelper.db;
    return db.query("tblchannels");
  }
  static Future<List<Map<String, dynamic>>> getChannelTags(int channelid) async {
    final db = await DBHelper.db;
    return db.query("tblchanneltags", where: "channelid = ?", whereArgs: [channelid]);
  }

  /// Get single channel by ID (example of one-time fetch)
  static Future<Map<String, dynamic>?> getChannelById(int channelId) async {
    final db = await DBHelper.db;
    final result = await db.query(
      "tblchannels",
      where: "channelid = ?",
      whereArgs: [channelId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }
}
