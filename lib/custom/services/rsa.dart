import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter_starter/custom/services/encryption.dart';
import 'package:flutter_starter/views/dashboard/dashboard_controller.dart';
import 'dart:math';
import 'package:pointycastle/export.dart' as pc;
import 'package:basic_utils/basic_utils.dart';

final secureStorage = FlutterSecureStorage();

/// Check if we're running on a web platform
bool get isWebPlatform => kIsWeb;

/// Check if we're running on a desktop platform
bool get isDesktopPlatform => !kIsWeb;

/// Get optimal RSA parameters based on platform
pc.RSAKeyGeneratorParameters _getOptimalRSAParams() {
  return pc.RSAKeyGeneratorParameters(
    BigInt.from(65537), // Standard public exponent (F4)
    2048, // Key size - good balance of security and performance
    isWebPlatform ? 32 : 64 // Lower certainty on web for better performance
  );
}

/// Generate a cryptographically secure random seed
/// Works consistently across web and desktop platforms
Uint8List _generateSecureRandomSeed(int length) {
  final random = Random.secure();
  final seed = Uint8List(length);
  
  if (kIsWeb) {
    // For web, use multiple iterations to ensure good entropy
    for (int i = 0; i < length; i++) {
      seed[i] = random.nextInt(256);
    }
    // Add additional entropy mixing for web
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    for (int i = 0; i < length; i++) {
      seed[i] ^= ((timestamp >> (i % 8)) & 0xFF);
    }
  } else {
    // For desktop platforms, Random.secure() is more reliable
    for (int i = 0; i < length; i++) {
      seed[i] = random.nextInt(256);
    }
  }
  
  return seed;
}

/// Initialize FortunaRandom with platform-appropriate seeding
pc.FortunaRandom _initializeSecureRandom() {
  final rng = pc.FortunaRandom();
  
  // Use a larger seed for better entropy
  final seed = _generateSecureRandomSeed(64);
  rng.seed(pc.KeyParameter(seed));
  
  // Additional entropy for web platform
  if (kIsWeb) {
    // Add more entropy sources for web
    final additionalSeed = _generateSecureRandomSeed(32);
    rng.seed(pc.KeyParameter(additionalSeed));
  }
  
  return rng;
}

Future<void> generateAndSaveRSAKeyPair() async {
  try {
    final rng = _initializeSecureRandom();

    // Use optimal RSA parameters for the current platform
    final params = _getOptimalRSAParams();
    
    final keyGen = pc.RSAKeyGenerator()
      ..init(pc.ParametersWithRandom(params, rng));

    final pair = keyGen.generateKeyPair();
    
    // Use try-catch for key encoding as it might fail on some platforms
    String publicKeyPem;
    String privateKeyPem;
    
    try {
      publicKeyPem = CryptoUtils.encodeRSAPublicKeyToPemPkcs1(
          pair.publicKey as pc.RSAPublicKey);
      privateKeyPem = CryptoUtils.encodeRSAPrivateKeyToPemPkcs1(
          pair.privateKey as pc.RSAPrivateKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error encoding keys with PKCS1, trying alternative encoding: $e');
      }
      // Fallback to different encoding if PKCS1 fails
      publicKeyPem = CryptoUtils.encodeRSAPublicKeyToPem(
          pair.publicKey as pc.RSAPublicKey);
      privateKeyPem = CryptoUtils.encodeRSAPrivateKeyToPem(
          pair.privateKey as pc.RSAPrivateKey);
    }

    DashboardController dashboardController = DashboardController();
    bool isUploaded = await dashboardController.uploadPublicKey(
        publicKeyPem, privateKeyPem);

    if (isUploaded) {
      if (kDebugMode) {
        print('Generated and saved new RSA keys successfully');
      }
    } else {
      if (kDebugMode) {
        print("Failed to upload public key.");
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error generating RSA key pair: $e');
    }
    rethrow;
  }
}
Future<void> generateRSAKeyPair() async {
  try {
    // testDocEncryption();
    DashboardController dashboardController = DashboardController();

    final keys = await dashboardController.getSelectedEntityX25519Keys();
    if (keys != null) {
      if (kDebugMode) {
        print("Keys already exist:");
      }
      final privateKeyBytes = keys["privateKey"]!;
      final publicKeyBytes = keys["publicKey"]!;
      await dashboardController.uploadPublicKey(publicKeyBytes, privateKeyBytes);
    } else {
      if (kDebugMode) {
        print("No keys found, generating new RSA keys.");
      }
      await generateAndSaveRSAKeyPair();
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error in generateRSAKeyPair: $e');
    }
    rethrow;
  }
}

/// Test function to verify RSA key generation works on current platform
/// This can be called from UI for testing purposes
Future<bool> testRSAKeyGeneration() async {
  try {
    if (kDebugMode) {
      print('Testing RSA key generation on ${isWebPlatform ? 'Web' : 'Desktop'} platform...');
    }
    
    final rng = _initializeSecureRandom();
    final params = _getOptimalRSAParams();
    final keyGen = pc.RSAKeyGenerator()
      ..init(pc.ParametersWithRandom(params, rng));

    final pair = keyGen.generateKeyPair();
    
    // Test key encoding
    final publicKeyPem = CryptoUtils.encodeRSAPublicKeyToPemPkcs1(
        pair.publicKey as pc.RSAPublicKey);
    final privateKeyPem = CryptoUtils.encodeRSAPrivateKeyToPemPkcs1(
        pair.privateKey as pc.RSAPrivateKey);
    
    if (kDebugMode) {
      print('✅ RSA key generation test successful!');
      print('Public key length: ${publicKeyPem.length}');
      print('Private key length: ${privateKeyPem.length}');
    }
    
    return true;
  } catch (e) {
    if (kDebugMode) {
      print('❌ RSA key generation test failed: $e');
    }
    return false;
  }
}
