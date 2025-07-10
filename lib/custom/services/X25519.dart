import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorage = FlutterSecureStorage();

Future<void> generateX25519KeyPair() async {
  final String? publicKey = await secureStorage.read(key: "publicKey");
  final String? privateKey = await secureStorage.read(key: "privateKey");
  if (publicKey == null  && privateKey == null) {
    final algorithm = X25519();
    final keyPair = await algorithm.newKeyPair();

    final publicKeyObj = await keyPair.extractPublicKey();
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();

    // Convert to Base64 for storage
    final publicKeyBase64 = base64Encode(publicKeyObj.bytes);
    final privateKeyBase64 = base64Encode(privateKeyBytes);
    // Save keys to secure storage
    await secureStorage.write(key: "publicKey", value: publicKeyBase64);
    await secureStorage.write(key: "privateKey", value: privateKeyBase64);
    print('Generated and saved new keys');
  } else {
    print('Public key already exists in secure storage');
    final decodedPubKey = base64Decode(publicKey!);
    final decodedPirKey = base64Decode(privateKey!);
    print('Public Key: $decodedPubKey');
    print('Private Key: $decodedPirKey');
  }
}
