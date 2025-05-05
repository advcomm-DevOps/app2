import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tenant_replication/tenant_replication.dart';

import '../../custom/constants.dart';
import 'db_setup.dart';

class DioClient {
  static final Dio dio = Dio();

  static void setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) async {
          // Check if the request URL matches the specific endpoint
          if (response.requestOptions.path.contains(
            '$authUrl/aud',
          )) {

            // Perform specific actions for this endpoint
            if (response.statusCode == 200) {
              try {
                // Get tenant from response extras
                final tenant =
                    response.requestOptions.extra['_database_name'];
                if (tenant != null) {
                  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
                  await secureStorage.write(key: "DatabaseName", value: tenant);
                  print('Initializing database for tenant: $tenant');
                  await DatabaseSetup.initialize();
                  // await SSEManager.initializeSSE('http://192.168.0.87:3000');
                  await SSEManager.initializeSSE('http://$audDomain');
                  print('Database initialized successfully.');
                }
              } catch (e) {
                print('Error in database initialization: $e');
              }
            } else {
              print('Error response for /aud: ${response.statusCode}');
            }
          }

          handler.next(response); // Continue with the response
        },
        onError: (DioError e, handler) {
          // Handle errors globally or for the specific endpoint
          if (e.requestOptions.path.contains('$authUrl/aud')) {
            print('Error for /aud endpoint: ${e.message}');
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
