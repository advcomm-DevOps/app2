import 'package:dio/dio.dart';
import 'package:signals/signals_flutter.dart';
import '../../../core/network/dio_client.dart';
import '../../models/doc_log_model.dart';

final docLogService = DocLogService();

class DocLogService {
  final Dio _dio = DioClient().dio;
  final Signal<List<DocLog>> _logs = signal([]);
  final Signal<bool> _isLoading = signal(false);
  final Signal<String?> _error = signal(null);

  ReadonlySignal<List<DocLog>> get logs => _logs;
  ReadonlySignal<bool> get isLoading => _isLoading;
  ReadonlySignal<String?> get error => _error;

  Future<void> fetchDocLogs(String channelName, String docName) async {
    try {
      _isLoading.value = true;
      _error.value = null;

      final response = await _dio.get('/doclogs/$channelName/$docName');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _logs.value = data.map((json) => DocLog.fromJson(json)).toList();
        print("_logs.value: ${_logs.value}");
      } else {
        throw Exception('Failed to load document logs: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _error.value = e.response?.data['message'] ?? e.message;
      _logs.value = [];
    } catch (e) {
      _error.value = e.toString();
      _logs.value = [];
    } finally {
      _isLoading.value = false;
    }
  }
}
