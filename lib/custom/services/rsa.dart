import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_starter/custom/services/encryption.dart';
import 'package:flutter_starter/views/dashboard/dashboard_controller.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart' as pc;
import 'package:basic_utils/basic_utils.dart';

final secureStorage = FlutterSecureStorage();
void generateAndSaveRSAKeyPair() async {
    final rng = pc.FortunaRandom();
    final seed = Uint8List(32);
    final random = Random.secure();
    for (int i = 0; i < seed.length; i++) {
      seed[i] = random.nextInt(256);
    }
    rng.seed(pc.KeyParameter(seed));

    final params = pc.RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64);
    final keyGen = pc.RSAKeyGenerator()
      ..init(pc.ParametersWithRandom(params, rng));

    final pair = keyGen.generateKeyPair();
    final publicKeyPem = CryptoUtils.encodeRSAPublicKeyToPemPkcs1(
        pair.publicKey as pc.RSAPublicKey);
    final privateKeyPem = CryptoUtils.encodeRSAPrivateKeyToPemPkcs1(
        pair.privateKey as pc.RSAPrivateKey);

    DashboardController dashboardController = DashboardController();
    bool isUploaded = await dashboardController.uploadPublicKey(
        publicKeyPem, privateKeyPem);

    if (isUploaded) {
      print('Generated and saved new keys');
    } else {
      print("Failed to upload public key.");
    }
  }
Future<void> generateRSAKeyPair() async {
  // testDocEncryption();
  DashboardController dashboardController = DashboardController();

  final keys = await dashboardController.getSelectedEntityX25519Keys();
  if (keys != null) {
    print("Keys already exist:");
    final privateKeyBytes = keys["privateKey"]!;
    final publicKeyBytes = keys["publicKey"]!;
    await dashboardController.uploadPublicKey(publicKeyBytes, privateKeyBytes);
  } else {
    print("No keys found, generating new keys.");
    generateAndSaveRSAKeyPair();
  }

}