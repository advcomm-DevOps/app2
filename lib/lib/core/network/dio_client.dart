// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import '../../presentation/state/user_state.dart';

class DioClient {
  final Dio _dio = Dio();
  // final jwtTokenComputed = computed(() => userState.jwtTokenSignal.value);

  DioClient() {
    _dio.options.baseUrl = 'http://localhost:3000';
    // _dio.interceptors.add(
    //   InterceptorsWrapper(
    //     onRequest: (options, handler) async {
    //       // final prefs = await SharedPreferences.getInstance();
    //       // final token = prefs.getString('jwt_token');
    //       print(jwtTokenComputed);
    //       // if (jwtTokenComputed != null) {
    //       options.headers['Authorization'] = 'Bearer $jwtTokenComputed';
    //       // }
    //       return handler.next(options);
    //     },
    //   ),
    // );
  }

  Dio get dio => _dio;
}

class DioClientPub {
  final Dio _dio = Dio();
  final jwtTokenComputed = computed(() => userState.jwtTokenSignal.value);

  DioClientPub() {
    _dio.options.baseUrl = 'http://localhost:3002';
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // final prefs = await SharedPreferences.getInstance();
          // final token = prefs.getString('jwt_token');
          print(jwtTokenComputed);
          // if (jwtTokenComputed != null) {
          options.headers['Authorization'] = 'Bearer $jwtTokenComputed';
          // }
          return handler.next(options);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
