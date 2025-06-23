import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SSOService {
  final secureStorage = const FlutterSecureStorage();

  Future<String?> getSelectedEntity() async {
    try {
      final String? jwtToken = await secureStorage.read(key: "JWT_Token");
      if (jwtToken == null || jwtToken.isEmpty) {
        return null;
      }

      // Decode the JWT token
      Map<String, dynamic> decodedToken = JwtDecoder.decode(jwtToken);

      // Extract the selected entity from the token
      String? selectedEntity = decodedToken['tid'];

      return selectedEntity;
    } catch (e) {
      // Handle errors (e.g., token decoding issues)
      return null;
    }
  }
}