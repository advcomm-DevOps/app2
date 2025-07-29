import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:flutter_starter/views/dashboard/dashboard_controller.dart';

final secureStorage = FlutterSecureStorage();

Future<void> generateX25519KeyPair() async {
  testDocEncryption();
  DashboardController dashboardController = DashboardController();

  Map<String, String>? keys =
      await dashboardController.getSelectedEntityX25519Keys();
  if (keys != null) {
    print("Keys already exist:");

    // Uint8List publicKeyBytes = base64Decode(keys['publicKey']!);
    // Uint8List privateKeyBytes = base64Decode(keys['privateKey']!);
    // print("Public Key decoded bytes: $publicKeyBytes");
    // print("Private Key decoded bytes: $privateKeyBytes");
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
  final senderPrivateKeyBytes = base64Decode(senderKeys["privateKey"]!);
  final senderPublicKeyBytes = base64Decode(senderKeys["publicKey"]!);

  // 📥 Load recipient keys
  final recipientKeys =
      await dashboardController.getSelectedEntityX25519Keys("info@advcomm.net");
  if (recipientKeys == null) {
    print("❌ Recipient keys not found.");
    return;
  }
  final recipientPrivateKeyBytes = base64Decode(recipientKeys["privateKey"]!);
  final recipientPublicKeyBytes = base64Decode(recipientKeys["publicKey"]!);

  // 🔐 Encrypt using sender + recipient public key
  final encrypted = await encryptTextForRecipient(
    plainText: symmetrickey.toString(),
    senderPrivateKeyBytes: senderPrivateKeyBytes,
    senderPublicKeyBytes: senderPublicKeyBytes,
    recipientPublicKeyBytes: recipientPublicKeyBytes,
  );

  print("Encrypted Symmetric key: ${encrypted['cipherText']}");

  // 🔓 Decrypt using recipient private key + sender public key
  final decrypted = await decryptTextFromSender(
    cipherText: encrypted['cipherText']!,
    nonce: encrypted['nonce']!,
    mac: encrypted['mac']!,
    senderPublicKeyBytes: senderPublicKeyBytes,
    recipientPrivateKeyBytes: recipientPrivateKeyBytes,
  );

  print("Decrypted Symmetric key: $decrypted");
  rsaEncryption();
}

Future<Map<String, String>> encryptTextForRecipient({
  required String plainText,
  required Uint8List senderPrivateKeyBytes,
  required Uint8List senderPublicKeyBytes,
  required Uint8List recipientPublicKeyBytes,
}) async {
  final aesGcm = AesGcm.with256bits();
  final x25519 = X25519();
  // 1. Import sender keypair
  final senderKeyPair = await x25519.newKeyPairFromSeed(senderPrivateKeyBytes);

  // 2. Recipient public key
  final recipientPublicKey = SimplePublicKey(
    recipientPublicKeyBytes,
    type: KeyPairType.x25519,
  );

  // 3. Shared secret
  final sharedSecret = await x25519.sharedSecretKey(
    keyPair: senderKeyPair,
    remotePublicKey: recipientPublicKey,
  );

  final derivedKey = await sharedSecret.extractBytes();
  final aesKey = derivedKey.sublist(0, 32);

  // 4. Encrypt
  final nonce = aesGcm.newNonce();
  final encrypted = await aesGcm.encrypt(
    utf8.encode(plainText),
    secretKey: SecretKey(aesKey),
    nonce: nonce,
  );

  return {
    'cipherText': base64Encode(encrypted.cipherText),
    'nonce': base64Encode(encrypted.nonce),
    'mac': base64Encode(encrypted.mac.bytes),
    'ephemeralPublicKey':
        base64Encode(senderPublicKeyBytes), // Not ephemeral anymore
  };
}

Future<String> decryptTextFromSender({
  required String cipherText,
  required String nonce,
  required String mac,
  required Uint8List senderPublicKeyBytes,
  required Uint8List recipientPrivateKeyBytes,
}) async {
  final aesGcm = AesGcm.with256bits();
  final x25519 = X25519();
  // 1. Import recipient keypair
  final recipientKeyPair =
      await x25519.newKeyPairFromSeed(recipientPrivateKeyBytes);

  // 2. Sender's public key
  final senderPublicKey = SimplePublicKey(
    senderPublicKeyBytes,
    type: KeyPairType.x25519,
  );

  // 3. Derive shared secret
  final sharedSecret = await x25519.sharedSecretKey(
    keyPair: recipientKeyPair,
    remotePublicKey: senderPublicKey,
  );

  final derivedKey = await sharedSecret.extractBytes();
  final aesKey = derivedKey.sublist(0, 32);

  // 4. Decrypt
  final secretBox = SecretBox(
    base64Decode(cipherText),
    nonce: base64Decode(nonce),
    mac: Mac(base64Decode(mac)),
  );

  final decryptedBytes = await aesGcm.decrypt(
    secretBox,
    secretKey: SecretKey(aesKey),
  );

  return utf8.decode(decryptedBytes);
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

void rsaEncryption() {
  final publicKeyPem = '''-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCDOAG1g9DP/cnRchIT6Pst9No5
clTS5GBdrVBuqno65jmrsYUjNhX28hZDO/X4vr5nYTdyj+xBqIsUvyOyAxXhTxNu
vi8+pR/UWgC8F8ZV70nBST5555ZyzwuiZTj9s58o0uzCAaqA7KBWFKBmLHFLBI8s
cbUl/y8N9kFnCLuh8wIDAQAB
-----END PUBLIC KEY-----''';

  final privateKeyPem = '''-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQCDOAG1g9DP/cnRchIT6Pst9No5clTS5GBdrVBuqno65jmrsYUj
NhX28hZDO/X4vr5nYTdyj+xBqIsUvyOyAxXhTxNuvi8+pR/UWgC8F8ZV70nBST55
55ZyzwuiZTj9s58o0uzCAaqA7KBWFKBmLHFLBI8scbUl/y8N9kFnCLuh8wIDAQAB
AoGAU2DEHT2L8o2VrsNn30TcTgBWpcgTRAoffYbCI/+pOUHPBV0AdzZH0KlVIhW4
nv086V2pqN7wxWu+LEmj+dniDWTca5unJUIZ2FoHt13fc01OsdXYZIKoYQiXVrKR
93JIIYPQzzrbgWCeMuoxUv9ZE3IsOzvilXj6NAI7hIZ9HlkCQQDO1ek740tVQau6
rwGyWkYU3bS3RcxcGdyGuxLK9xtTTleKigiKnwrFDIS9CHABzVcBtEOvw/hdZYNP
Rb7zHGBdAkEAomjClXdQvXPN5f8dnPKH9U+r4Q626D2exCXBEm47cId7dTxZ/xvc
kjCYDSCn8qkywDyaRypfUAPspyVR0qQmjwJBAIbpyOSjcfP+jgGLPdQURjo+Ey6o
fJBm3g2T4MI7RLumEjvvpXqmGuRFMiALbOQACIy4BJ6VeV+SY4BFwjPZgpECQEP/
+Pj77CJmyl7yYkPEiIh9w0mID61Nn5wg8qX04Y5MK7T6f/QAhmnvTrqwYaGIlmdG
+JGzfBTUj9GsHoZDlKECQCg8dacSMF8yHDu8Z+DQcf56a+jx9G8mrepmnxI0opq2
vthGnf3m1yPHPXH91Egm5twqXFsahyYh1KubXUbMRzs=
-----END RSA PRIVATE KEY-----''';

  final publicKey = RSAKeyParser().parse(publicKeyPem) as RSAPublicKey;
  final privateKey = RSAKeyParser().parse(privateKeyPem) as RSAPrivateKey;

  final encrypter = Encrypter(RSA(publicKey: publicKey));
  final encrypted = encrypter.encrypt("Hello Flutter RSA!");
  print("🔐 Encrypted RSA: ${encrypted.base64}");

  final decrypter = Encrypter(RSA(privateKey: privateKey));
  final decrypted = decrypter.decrypt(encrypted);
  print("🔓 Decrypted RSA: $decrypted");
}
