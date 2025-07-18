import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_starter/views/dashboard/dashboard_controller.dart';

final secureStorage = FlutterSecureStorage();

Future<void> generateX25519KeyPair() async {
  DashboardController dashboardController = DashboardController();

  Map<String, String>? keys =
      await dashboardController.getSelectedEntityX25519Keys();

  if (keys != null) {
    print("Keys already exist:");

    Uint8List publicKeyBytes = base64Decode(keys['publicKey']!);
    Uint8List privateKeyBytes = base64Decode(keys['privateKey']!);
    print("Public Key decoded bytes: $publicKeyBytes");
    print("Private Key decoded bytes: $privateKeyBytes");

  } else {
    print("No keys found, generating new keys.");

    final algorithm = X25519();
    final keyPair = await algorithm.newKeyPair();

    final publicKeyObj = await keyPair.extractPublicKey();
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();

    // Convert to Base64 for storage
    final publicKeyBase64 = base64Encode(publicKeyObj.bytes);
    final privateKeyBase64 = base64Encode(privateKeyBytes);

    // Save keys to secure storage and upload
    bool isUploaded = await dashboardController.uploadPublicKey(
        publicKeyBase64, privateKeyBase64);

    if (isUploaded) {
      print('Generated and saved new keys');
    } else {
      print("Failed to upload public key.");
    }
  }
}

Uint8List generate32BytesRandom() {
  final random = Random.secure();
  final bytes = Uint8List(32);
  for (int i = 0; i < bytes.length; i++) {
    bytes[i] = random.nextInt(256);
  }
  return bytes;
}
