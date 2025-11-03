import 'dart:async';
import 'package:tenant_replication/tenant_replication.dart';

class DashboardReplication {
  static Future<List<Map<String, dynamic>>> getChannels() async {
    final db = await DBHelper.db;
    return db.query("tblchannels");
  }

  /// Watch channels for real-time updates
  static Stream<List<Map<String, dynamic>>> watchChannels() async* {
    final db = await DBHelper.db;
    
    // Emit initial data
    yield await db.query("tblchannels");
    
    // Create a stream controller for database changes
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
    Timer? periodicTimer;
    List<Map<String, dynamic>> lastData = await db.query("tblchannels");
    
    // Use a more efficient polling approach with comparison
    periodicTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final currentData = await db.query("tblchannels");
        
        // Compare with last data to avoid unnecessary updates
        if (!_areListsEqual(lastData, currentData)) {
          lastData = List.from(currentData);
          if (!controller.isClosed) {
            controller.add(currentData);
          }
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    });
    
    // Clean up when stream is cancelled
    controller.onCancel = () {
      periodicTimer?.cancel();
    };
    
    yield* controller.stream;
  }
  
  /// Helper method to compare two lists of maps for equality
  static bool _areListsEqual(List<Map<String, dynamic>> list1, List<Map<String, dynamic>> list2) {
    if (list1.length != list2.length) return false;
    
    for (int i = 0; i < list1.length; i++) {
      if (!_areMapsEqual(list1[i], list2[i])) {
        return false;
      }
    }
    return true;
  }
  
  /// Helper method to compare two maps for equality
  static bool _areMapsEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    
    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) {
        return false;
      }
    }
    return true;
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

  /// Delete channel from local SQLite database
  static Future<bool> deleteChannel(String channelId) async {
    try {
      final db = await DBHelper.db;
      final int deletedRows = await db.delete(
        "tblchannels",
        where: "channelid = ?",
        whereArgs: [channelId],
      );
      return deletedRows > 0;
    } catch (e) {
      print("Error deleting channel from SQLite: $e");
      return false;
    }
  }
}
