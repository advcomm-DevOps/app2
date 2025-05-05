import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SharedPreferencesService {
  Future<List<dynamic>> getEntitiesList() async {
    final FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String? jsonString = await secureStorage.read(key: "Entities_List");
    if (jsonString != null) {
      Map<String, dynamic> data = jsonDecode(jsonString);
      return data['Entities'] ?? []; // Ensure it's a list
    }
    return [];
  }

  Future<Map<String, dynamic>?> getSelectEntityConfigurations() async {
    final FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String? jsonString = await secureStorage.read(key: "Entities_List");
    if (jsonString != null) {
      final decodedData = jsonDecode(jsonString);
      List<Map<String, dynamic>> entities =
          List<Map<String, dynamic>>.from(decodedData['Entities'] ?? []);
      String username = decodedData['Username'] ?? '';

      List<String> tenants = entities
          .map((e) => e['tenant'] as String? ?? '')
          .where((tenant) => tenant.isNotEmpty)
          .toList();

      List<String> refreshTokens = entities
          .map((e) => e['refreshtoken'] as String? ?? '')
          .where((token) => token.isNotEmpty)
          .toList();

      if (tenants.length != refreshTokens.length) {
        print(
            "Mismatch in data: tenants list length ${tenants.length}, refreshTokens list length ${refreshTokens.length}");
      }

      return {
        'tenants': tenants,
        'username': username,
        'refreshTokens': refreshTokens,
      };
    }
    return null;
  }
}
