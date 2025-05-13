import 'package:dio/dio.dart';
import 'package:signals/signals_flutter.dart';
import '../../../core/network/dio_client.dart';
import '../../models/doc_model.dart';

final docService = DocService();

class DocService {
  final Dio _dio = DioClient().dio;
  final Signal<List<Document>> _documents = signal([]);
  final Signal<bool> _isLoading = signal(false);
  final Signal<String?> _error = signal(null);

  ReadonlySignal<List<Document>> get documents => _documents;
  ReadonlySignal<bool> get isLoading => _isLoading;
  ReadonlySignal<String?> get error => _error;

  Future<void> fetchDocuments(String channelName) async {
    print('fetchDocuments: .........     $channelName');
    try {
      _isLoading.value = true;
      _error.value = null;
      _documents.value = []; // Clear previous documents

      final response = await _dio.get('/docs/$channelName');

      if (response.statusCode == 200) {
        // Ensure response.data is a List
        if (response.data is List) {
          final List<dynamic> data = response.data;
          _documents.value =
              data.map((json) {
                try {
                  return Document.fromJson(json)..channelId = channelName;
                } catch (e) {
                  throw FormatException('Failed to parse document: $e');
                }
              }).toList();
        } else {
          throw FormatException(
            'Expected List but got ${response.data.runtimeType}',
          );
        }
      } else {
        throw Exception('Failed to load documents: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _error.value =
          e.response?.data is Map
              ? e.response?.data['message'] ?? e.message
              : e.message;
      _documents.value = [];
    } catch (e) {
      _error.value = e.toString();
      _documents.value = [];
    } finally {
      _isLoading.value = false;
    }
  }
}
