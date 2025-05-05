import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uids_io_sdk_flutter/uids_io_sdk_flutter.dart';

import '../routing/routing.dart';

Future<void> initializeSsoSdk(authUrl,audDomain) async {
  await checkAuthentication();
  Configuration.AuthUrl = authUrl;
  Configuration.AudDomain = audDomain;
  await RegisterService.registerDeviceData();
  await initializePK();
  RefreshTokenService();
}

Future<void> initializePK() async {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String? deviceId = await secureStorage.read(key: "DeviceId");
  BigInt externalDeviceId =
      BigInt.from(deviceId == null ? 0 : int.parse(deviceId));
  PK.initialize(externalDeviceId);
}
