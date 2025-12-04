import 'dart:async';
import '../../core/sqlite/db_setup.dart';
import '../../core/sqlite/app_database.dart';

class DashboardReplication {
  /// Get all channels as list of maps (for backward compatibility)
  static Future<List<Map<String, dynamic>>> getChannels() async {
    final db = appDatabase;
    final channels = await db.select(db.channels).get();
    return channels.map((c) => _channelToMap(c)).toList();
  }

  /// Watch channels for real-time updates using Drift's watch()
  static Stream<List<Map<String, dynamic>>> watchChannels() {
    final db = appDatabase;
    return db
        .select(db.channels)
        .watch()
        .map((channels) => channels.map((c) => _channelToMap(c)).toList());
  }

  /// Get channel tags for a specific channel
  static Future<List<Map<String, dynamic>>> getChannelTags(
    int channelid,
  ) async {
    final db = appDatabase;
    final tags = await (db.select(
      db.channelTags,
    )..where((t) => t.channelId.equals(BigInt.from(channelid)))).get();
    return tags.map((t) => _channelTagToMap(t)).toList();
  }

  /// Get single channel by ID
  static Future<Map<String, dynamic>?> getChannelById(int channelId) async {
    final db = appDatabase;
    final channel =
        await (db.select(db.channels)
              ..where((c) => c.channelId.equals(channelId))
              ..limit(1))
            .getSingleOrNull();
    return channel != null ? _channelToMap(channel) : null;
  }

  /// Delete channel from local database (soft delete using MTDS SDK)
  static Future<bool> deleteChannel(String channelId) async {
    try {
      final db = appDatabase;
      final numericId = int.tryParse(channelId);
      if (numericId == null) {
        print("❌ Invalid channel ID: $channelId");
        return false;
      }

      // Use Drift delete
      final deletedRows = await (db.delete(
        db.channels,
      )..where((c) => c.channelId.equals(numericId))).go();

      print("✅ Deleted $deletedRows channel(s)");
      return deletedRows > 0;
    } catch (e) {
      print("❌ Error deleting channel from database: $e");
      return false;
    }
  }

  // ========================================================================
  // Helper methods to convert Drift data classes to maps
  // ========================================================================

  static Map<String, dynamic> _channelToMap(Channel channel) {
    return {
      'channelid': channel.channelId,
      'channelname': channel.channelName,
      'channeldescription': channel.channelDescription,
      'entityroles': channel.entityRoles,
      'actorsequence': channel.actorSequence.toInt(),
      'initialactorid': channel.initialActorId?.toInt(),
      'otheractorid': channel.otherActorId?.toInt(),
      'contexttemplate': channel.contextTemplate,
      'istagrequired': channel.isTagRequired ? 1 : 0,
      'mtds_client_ts': channel.mtdsClientTs.toInt(),
      'mtds_server_ts': channel.mtdsServerTs?.toInt(),
      'mtds_device_id': channel.mtdsDeviceId.toInt(),
      'mtds_delete_ts': channel.mtdsDeleteTs?.toInt(),
    };
  }

  static Map<String, dynamic> _channelTagToMap(ChannelTag tag) {
    return {
      'channeltagid': tag.channelTagId.toInt(),
      'channelid': tag.channelId.toInt(),
      'tag': tag.tag,
      'tagdescription': tag.tagDescription,
      'expireat': tag.expireAt?.toIso8601String(),
      'mtds_client_ts': tag.mtdsClientTs.toInt(),
      'mtds_server_ts': tag.mtdsServerTs?.toInt(),
      'mtds_device_id': tag.mtdsDeviceId.toInt(),
      'mtds_delete_ts': tag.mtdsDeleteTs?.toInt(),
    };
  }
}
