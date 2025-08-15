import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:flutter_starter/views/dashboard/dashboard_controller.dart';

Uint8List generate32BytesRandom() {
  final random = Random.secure();
  final bytes = Uint8List(32);
  for (int i = 0; i < bytes.length; i++) {
    bytes[i] = random.nextInt(256);
  }
  return bytes;
}

void testDocEncryption() async {
  final symmetrickey = generate32BytesRandom();
  print("Symmetric Key: ${symmetrickey}");
  final message = "Confidential Message";

  // 🔐 Encrypt using sender + recipient public key
  final encrypted = await encryptWithSymmetrickey(
    symmetrickey: symmetrickey,
    plainText: message,
  );

  print("Encrypted Doc: ${encrypted['cipherText']}");

  // 🔓 Decrypt using recipient private key + sender public key
  final decrypted = await decryptWithSymmetrickey(
    symmetrickey: symmetrickey,
    cipherText: encrypted['cipherText']!,
    nonce: encrypted['nonce']!,
    mac: encrypted['mac']!,
  );

  print("Decrypted Doc: $decrypted");
  testKeyEncryption(symmetrickey);
}

void testKeyEncryption(symmetrickey) async {
  final dashboardController = DashboardController();

  // 📥 Load sender keys
  final senderKeys = await dashboardController.getSelectedEntityX25519Keys();
  if (senderKeys == null) {
    print("❌ Sender keys not found.");
    return;
  }
  // final senderPrivateKeyBytes = senderKeys["privateKey"]!;
  // final senderPublicKeyBytes = senderKeys["publicKey"]!;

  // 📥 Load recipient keys
  final recipientKeys =
      await dashboardController.getSelectedEntityX25519Keys("basit.munir89@gmail.com");
  if (recipientKeys == null) {
    print("❌ Recipient keys not found.");
    return;
  }
  final recipientPrivateKeyBytes = recipientKeys["privateKey"]!;
  final recipientPublicKeyBytes = recipientKeys["publicKey"]!;
  String encryptedData =await rsaEncryption(
    "${symmetrickey.toString()}",
    recipientPublicKeyBytes,
  );
  rsaDecryption(
    encryptedData,
    recipientPrivateKeyBytes,
  );

  // 🔐 Encrypt using sender + recipient public key
  // final encrypted = await encryptTextForRecipient(
  //   plainText: symmetrickey.toString(),
  //   senderPrivateKeyBytes: senderPrivateKeyBytes,
  //   senderPublicKeyBytes: senderPublicKeyBytes,
  //   recipientPublicKeyBytes: recipientPublicKeyBytes,
  // );

  // print("Encrypted Symmetric key: ${encrypted['cipherText']}");
  // print(senderPublicKeyBytes);
  // // 🔓 Decrypt using recipient private key + sender public key
  // final decrypted = await decryptTextFromSender(
  //   cipherText: encrypted['cipherText']!,
  //   nonce: encrypted['nonce']!,
  //   mac: encrypted['mac']!,
  //   senderPublicKeyBytes: senderPublicKeyBytes,
  //   recipientPrivateKeyBytes: recipientPrivateKeyBytes,
  // );

  // print("Decrypted Symmetric key: $decrypted");
}

Future<Map<String, String>> encryptWithSymmetrickey({
  required List<int> symmetrickey,
  required String plainText,
}) async {
  final aesGcm = AesGcm.with256bits();
  final nonce = aesGcm.newNonce();
  final encrypted = await aesGcm.encrypt(
    utf8.encode(plainText),
    secretKey: SecretKey(symmetrickey),
    nonce: nonce,
  );

  return {
    'cipherText': base64Encode(encrypted.cipherText),
    'nonce': base64Encode(encrypted.nonce),
    'mac': base64Encode(encrypted.mac.bytes),
  };
}

Future<String> decryptWithSymmetrickey({
  required List<int> symmetrickey,
  required String cipherText,
  required String nonce,
  required String mac,
}) async {
  final aesGcm = AesGcm.with256bits();
  final secretBox = SecretBox(
    base64Decode(cipherText),
    nonce: base64Decode(nonce),
    mac: Mac(base64Decode(mac)),
  );

  final decryptedBytes = await aesGcm.decrypt(
    secretBox,
    secretKey: SecretKey(symmetrickey),
  );

  return utf8.decode(decryptedBytes);
}

Future<String> rsaEncryption(String data, String publicKeyPem) async {
  final publicKey = RSAKeyParser().parse(publicKeyPem) as RSAPublicKey;

  final encrypter = Encrypter(RSA(publicKey: publicKey));
  final encrypted = encrypter.encrypt(data);
  return encrypted.base64;
}

Future<String> rsaDecryption(String encryptedBase64, String privateKeyPem) async {
  final privateKey = RSAKeyParser().parse(privateKeyPem) as RSAPrivateKey;

  final decrypter = Encrypter(RSA(privateKey: privateKey));
  final decrypted = decrypter.decrypt(Encrypted.fromBase64(encryptedBase64));
  return decrypted;
}