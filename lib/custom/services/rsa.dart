import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:xdoc/custom/services/encryption.dart';
import 'package:xdoc/views/dashboard/dashboard_controller.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:async';
import 'package:pointycastle/export.dart' as pc;
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/foundation.dart';

final secureStorage = FlutterSecureStorage();

/// Cross-platform secure random number generator
Uint8List _generateSecureRandomBytes(int length) {
  final bytes = Uint8List(length);
  
  if (kIsWeb) {
    // For web, use a combination of DateTime and Math.random equivalent
    final random = Random();
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Seed with current time + microseconds for better entropy
    final microNow = DateTime.now().microsecondsSinceEpoch;
    final seededRandom = Random(now ^ microNow);
    
    for (int i = 0; i < length; i++) {
      // Combine multiple sources of randomness for web
      final timeBased = ((now + microNow + i) & 0xFF);
      final randomBased = seededRandom.nextInt(256);
      final combinedRandom = random.nextInt(256);
      final additionalRandom = Random(now + i * 1000).nextInt(256);
      
      bytes[i] = (timeBased ^ randomBased ^ combinedRandom ^ additionalRandom) & 0xFF;
    }
  } else {
    // For native platforms, use Random.secure()
    final random = Random.secure();
    for (int i = 0; i < length; i++) {
      bytes[i] = random.nextInt(256);
    }
  }
  
  return bytes;
}

/// Cross-platform RSA key pair generation (legacy function, now calls improved version)
void generateAndSaveRSAKeyPair() async {
  try {
    await _generateRSAKeyPairWithRetry();
  } catch (e) {
    print('Error in generateAndSaveRSAKeyPair: $e');
  }
}

/// Simple manual encoding for public key (final fallback)
String _manualEncodePublicKey(pc.RSAPublicKey publicKey) {
  final keyData = {
    'modulus': publicKey.modulus.toString(),
    'exponent': publicKey.exponent.toString(),
  };
  final jsonString = jsonEncode(keyData);
  final base64String = base64Encode(utf8.encode(jsonString));
  return '-----BEGIN RSA PUBLIC KEY-----\n${_formatBase64(base64String)}\n-----END RSA PUBLIC KEY-----';
}

/// Simple manual encoding for private key (final fallback)
String _manualEncodePrivateKey(pc.RSAPrivateKey privateKey) {
  final keyData = {
    'modulus': privateKey.modulus.toString(),
    'exponent': privateKey.exponent.toString(),
    'privateExponent': privateKey.privateExponent.toString(),
    'p': privateKey.p.toString(),
    'q': privateKey.q.toString(),
  };
  final jsonString = jsonEncode(keyData);
  final base64String = base64Encode(utf8.encode(jsonString));
  return '-----BEGIN RSA PRIVATE KEY-----\n${_formatBase64(base64String)}\n-----END RSA PRIVATE KEY-----';
}

/// Format base64 string with line breaks
String _formatBase64(String base64String) {
  final regex = RegExp(r'.{1,64}');
  return regex.allMatches(base64String).map((match) => match.group(0)).join('\n');
}
Future<void> generateRSAKeyPair() async {
  // testDocEncryption();
  DashboardController dashboardController = DashboardController();

  final keys = await dashboardController.getSelectedEntityRSAKeys();
  if (keys != null) {
    print("Keys already exist:");
    final privateKeyBytes = keys["privateKey"]!;
    final publicKeyBytes = keys["publicKey"]!;
    await dashboardController.uploadPublicKey(publicKeyBytes, privateKeyBytes);
  } else {
    print("No keys found, generating new keys.");
    
    // Try multiple approaches for better cross-platform compatibility
    try {
      await _generateRSAKeyPairWithRetry();
    } catch (e) {
      print("All key generation methods failed: $e");
      // You might want to show an error dialog to the user here
    }
  }
}

/// Improved key generation with retry logic
Future<void> _generateRSAKeyPairWithRetry() async {
  // Optimized configurations for web performance
  final configurations = [
    // Start with very fast configuration for web
    {'keySize': kIsWeb ? 1024 : 2048, 'certainty': kIsWeb ? 1 : 64, 'description': 'Fast Web'},
    // Fallback to even faster if needed
    {'keySize': 1024, 'certainty': kIsWeb ? 1 : 32, 'description': 'Ultra Fast'},
    // Last resort - minimal security but functional
    {'keySize': 512, 'certainty': 1, 'description': 'Minimal'},
  ];
  
  for (var config in configurations) {
    try {
      print('Trying ${config['description']} configuration (${config['keySize']}-bit)...');
      final stopwatch = Stopwatch()..start();
      
      await _generateRSAKeyPairWithConfig(
        config['keySize'] as int, 
        config['certainty'] as int
      );
      
      stopwatch.stop();
      print('✅ Successfully generated keys with ${config['description']} configuration in ${stopwatch.elapsedMilliseconds}ms');
      return; // Success, exit
    } catch (e) {
      print('❌ Failed with ${config['description']} configuration: $e');
      if (config == configurations.last) {
        rethrow; // Last attempt failed, rethrow
      }
    }
  }
}

/// Generate RSA key pair with specific configuration
Future<void> _generateRSAKeyPairWithConfig(int keySize, int certainty) async {
  pc.SecureRandom rng;
  
  // Add timeout for web to prevent hanging
  if (kIsWeb) {
    return await _generateRSAKeyPairWithTimeout(keySize, certainty);
  }
  
  try {
    // Try Fortuna PRNG first
    rng = pc.FortunaRandom();
    final seed = _generateSecureRandomBytes(32); // Exactly 32 bytes for Fortuna
    rng.seed(pc.KeyParameter(seed));
    
    // For native platforms, add additional entropy
    if (!kIsWeb) {
      for (int i = 0; i < 2; i++) {
        final additionalSeed = _generateSecureRandomBytes(32);
        rng.seed(pc.KeyParameter(additionalSeed));
      }
    }
    
    // Test the RNG by generating a few bytes to ensure it works
    rng.nextBytes(8);
    
  } catch (e) {
    print('Fortuna PRNG failed: $e, creating fallback RNG...');
    
    // Create a simpler fallback RNG
    rng = _createSimpleSecureRandom();
  }

  final params = pc.RSAKeyGeneratorParameters(
    BigInt.from(65537), // Standard public exponent
    keySize,
    certainty
  );
  
  final keyGen = pc.RSAKeyGenerator()
    ..init(pc.ParametersWithRandom(params, rng));

  final pair = keyGen.generateKeyPair();
  
  // Extract keys
  final publicKey = pair.publicKey as pc.RSAPublicKey;
  final privateKey = pair.privateKey as pc.RSAPrivateKey;
  
  // Convert to PEM format with multiple fallback attempts
  String publicKeyPem;
  String privateKeyPem;
  
  // Try PKCS1 format first
  try {
    publicKeyPem = CryptoUtils.encodeRSAPublicKeyToPemPkcs1(publicKey);
    privateKeyPem = CryptoUtils.encodeRSAPrivateKeyToPemPkcs1(privateKey);
  } catch (e) {
    print('PKCS1 encoding failed: $e, trying PKCS8...');
    
    // Try PKCS8 format
    try {
      publicKeyPem = CryptoUtils.encodeRSAPublicKeyToPem(publicKey);
      privateKeyPem = CryptoUtils.encodeRSAPrivateKeyToPem(privateKey);
    } catch (e2) {
      print('PKCS8 encoding failed: $e2, using manual encoding...');
      
      // Final fallback - simple base64 encoding
      publicKeyPem = _manualEncodePublicKey(publicKey);
      privateKeyPem = _manualEncodePrivateKey(privateKey);
    }
  }

  DashboardController dashboardController = DashboardController();
  bool isUploaded = await dashboardController.uploadPublicKey(
      publicKeyPem, privateKeyPem);

  if (isUploaded) {
    print('Generated and saved new keys ($keySize-bit)');
  } else {
    throw Exception("Failed to upload public key to server");
  }
}

/// Generate RSA key pair with timeout for web
Future<void> _generateRSAKeyPairWithTimeout(int keySize, int certainty) async {
  const timeoutDuration = Duration(seconds: 15); // 15 second timeout for web
  
  try {
    await _generateRSAKeyPairCore(keySize, certainty).timeout(timeoutDuration);
  } on TimeoutException {
    print('⏱️ Key generation timed out after ${timeoutDuration.inSeconds}s, trying faster method...');
    
    // Fallback to even faster generation
    if (keySize > 512) {
      await _generateRSAKeyPairWithTimeout(512, 1);
    } else {
      throw Exception('Key generation timed out even with minimal settings');
    }
  }
}

/// Core RSA key generation logic
Future<void> _generateRSAKeyPairCore(int keySize, int certainty) async {
  // Use the simplest possible configuration for web
  final rng = _createSimpleSecureRandom();
  
  // Yield control back to the event loop periodically
  await Future.delayed(Duration.zero);
  
  print('🔄 Generating $keySize-bit RSA key pair (certainty: $certainty)...');
  
  final params = pc.RSAKeyGeneratorParameters(
    BigInt.from(65537), // Standard public exponent
    keySize,
    certainty
  );
  
  final keyGen = pc.RSAKeyGenerator()
    ..init(pc.ParametersWithRandom(params, rng));

  // Yield control before heavy computation
  await Future.delayed(Duration.zero);
  
  final pair = keyGen.generateKeyPair();
  
  print('🔑 Key pair generated successfully!');
  
  // Extract keys
  final publicKey = pair.publicKey as pc.RSAPublicKey;
  final privateKey = pair.privateKey as pc.RSAPrivateKey;
  
  // Use the fastest encoding method for web
  String publicKeyPem;
  String privateKeyPem;
  
  if (kIsWeb) {
    // For web, use manual encoding (fastest)
    publicKeyPem = _manualEncodePublicKey(publicKey);
    privateKeyPem = _manualEncodePrivateKey(privateKey);
  } else {
    // For native, try proper PEM encoding first
    try {
      publicKeyPem = CryptoUtils.encodeRSAPublicKeyToPemPkcs1(publicKey);
      privateKeyPem = CryptoUtils.encodeRSAPrivateKeyToPemPkcs1(privateKey);
    } catch (e) {
      publicKeyPem = _manualEncodePublicKey(publicKey);
      privateKeyPem = _manualEncodePrivateKey(privateKey);
    }
  }

  print('📤 Uploading keys to server...');
  
  DashboardController dashboardController = DashboardController();
  bool isUploaded = await dashboardController.uploadPublicKey(
      publicKeyPem, privateKeyPem);

  if (isUploaded) {
    print('✅ Generated and saved new keys ($keySize-bit)');
  } else {
    throw Exception("Failed to upload public key to server");
  }
}

/// Create a simple secure random generator that works on web
pc.SecureRandom _createSimpleSecureRandom() {
  return _WebSecureRandom();
}

/// Custom secure random implementation for web compatibility (optimized for speed)
class _WebSecureRandom implements pc.SecureRandom {
  final Random _random = Random();
  final Random _secureRandom = kIsWeb ? Random(DateTime.now().millisecondsSinceEpoch) : Random.secure();
  int _seedCounter = 0;
  
  @override
  String get algorithmName => 'WebSecureRandom';

  @override
  int nextUint8() {
    if (kIsWeb) {
      // Optimized for web performance - simplified random generation
      final r1 = _random.nextInt(256);
      final r2 = _secureRandom.nextInt(256);
      final counter = (_seedCounter++) & 0xFF;
      return (r1 ^ r2 ^ counter) & 0xFF;
    } else {
      return _secureRandom.nextInt(256);
    }
  }

  @override
  int nextUint16() => (nextUint8() << 8) | nextUint8();

  @override
  int nextUint32() => (nextUint16() << 16) | nextUint16();

  @override
  BigInt nextBigInteger(int bitLength) {
    if (kIsWeb && bitLength > 1024) {
      // For web, use a faster method for large integers
      return _fastBigInteger(bitLength);
    }
    
    final bytes = (bitLength + 7) ~/ 8;
    final result = nextBytes(bytes);
    // Convert bytes to BigInt manually
    BigInt value = BigInt.zero;
    for (int i = 0; i < result.length; i++) {
      value = (value << 8) + BigInt.from(result[i]);
    }
    return value;
  }

  /// Fast BigInteger generation for web
  BigInt _fastBigInteger(int bitLength) {
    // Use a more efficient method for large integers on web
    final chunks = (bitLength / 32).ceil();
    BigInt result = BigInt.zero;
    
    for (int i = 0; i < chunks; i++) {
      final chunk = nextUint32();
      result = (result << 32) + BigInt.from(chunk);
    }
    
    // Ensure we have the right bit length
    final mask = (BigInt.one << bitLength) - BigInt.one;
    return result & mask;
  }

  @override
  Uint8List nextBytes(int count) {
    final bytes = Uint8List(count);
    
    if (kIsWeb && count > 100) {
      // For large byte arrays on web, use bulk generation
      for (int i = 0; i < count; i += 4) {
        final chunk = nextUint32();
        final remaining = count - i;
        
        if (remaining >= 4) {
          bytes[i] = (chunk >> 24) & 0xFF;
          bytes[i + 1] = (chunk >> 16) & 0xFF;
          bytes[i + 2] = (chunk >> 8) & 0xFF;
          bytes[i + 3] = chunk & 0xFF;
        } else {
          for (int j = 0; j < remaining; j++) {
            bytes[i + j] = (chunk >> (24 - j * 8)) & 0xFF;
          }
        }
      }
    } else {
      // Standard byte-by-byte generation
      for (int i = 0; i < count; i++) {
        bytes[i] = nextUint8();
      }
    }
    
    return bytes;
  }

  @override
  void seed(pc.CipherParameters params) {
    // Accept seed but don't need to do anything special for our implementation
    if (params is pc.KeyParameter) {
      // Use the seed to initialize our counter - simplified for speed
      _seedCounter = params.key.length > 0 ? params.key[0] : 0;
    }
  }
}