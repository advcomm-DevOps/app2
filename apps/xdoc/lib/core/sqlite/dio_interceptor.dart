import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mtds/index.dart';

import '../../custom/constants.dart';
import 'db_setup.dart';

/// Global MTDS SDK instance (initialized after authentication)
MTDS_SDK? _mtdsSdk;

/// Get the MTDS SDK instance
MTDS_SDK get mtdsSdk {
  if (_mtdsSdk == null) {
    throw StateError('MTDS SDK not initialized. Authenticate first.');
  }
  return _mtdsSdk!;
}

class DioClient {
  static final Dio dio = Dio();

  static void setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) async {
          // Check if the request URL matches the specific endpoint
          if (response.requestOptions.path.contains('$authUrl/aud')) {
            // Perform specific actions for this endpoint
            if (response.statusCode == 200) {
              try {
                // Get tenant from response extras
                final tenant = response.requestOptions.extra['_database_name'];
                if (tenant != null) {
                  final FlutterSecureStorage secureStorage =
                      FlutterSecureStorage();
                  await secureStorage.write(key: "DatabaseName", value: tenant);
                  print('🔹 Initializing database for tenant: $tenant');

                  // Initialize Drift database
                  await DatabaseSetup.initialize();

                  // Initialize MTDS SDK
                  print('🔹 Initializing MTDS SDK...');
                  _mtdsSdk = MTDS_SDK(
                    db: appDatabase,
                    httpClient: dio,
                    serverUrl: 'https://$audDomain',
                  );

                  // Initialize SDK (sets up device ID and services)
                  await _mtdsSdk!.initialize();
                  print('✅ MTDS SDK initialized successfully');

                  // Subscribe to real-time updates via SSE
                  _mtdsSdk!.subscribeToSSE().listen(
                    (event) {
                      print('📡 SSE Event: ${event.table} -> ${event.type}');
                    },
                    onError: (error) {
                      print('❌ SSE Error: $error');
                    },
                    onDone: () {
                      print('⚠️ SSE connection closed');
                    },
                  );

                  // Enable auto-sync
                  await _mtdsSdk!.enableAutoSync(
                    syncInterval: Duration(seconds: 30),
                    debounceDelay: Duration(seconds: 5),
                  );
                  print('✅ Auto-sync enabled');

                  print('✅ Database initialized successfully.');
                }
              } catch (e) {
                print('❌ Error in database initialization: $e');
              }
            } else {
              print('❌ Error response for /aud: ${response.statusCode}');
            }
          }

          handler.next(response); // Continue with the response
        },
        onError: (DioException e, handler) {
          // Handle errors globally or for the specific endpoint
          if (e.requestOptions.path.contains('$authUrl/aud')) {
            print('❌ Error for /aud endpoint: ${e.message}');
            if (e.response != null) {
              print('Error Data: ${e.response?.data}');
            }
          }
          handler.next(e); // Continue with the error
        },
      ),
    );
  }
}
