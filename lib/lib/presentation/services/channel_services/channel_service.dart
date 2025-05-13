import 'package:dio/dio.dart';
import 'package:signals/signals_flutter.dart';
import '../../../core/network/dio_client.dart';
import '../../models/channel_model.dart';

final channelService = ChannelService();

class ChannelService {
  final Dio _dio = DioClient().dio;
  final Signal<List<Channel>> _channels = signal([]);
  final Signal<bool> _isLoading = signal(false);
  final Signal<String?> _error = signal(null);

  ReadonlySignal<List<Channel>> get channels => _channels;
  ReadonlySignal<bool> get isLoading => _isLoading;
  ReadonlySignal<String?> get error => _error;

  Future<void> addChannel(Channel newChannel) async {
    try {
      _isLoading.value = true;
      _error.value = null;

      // Generate a temporary ID if not provided
      newChannel.id =
          newChannel.id.isEmpty
              ? 'temp-${DateTime.now().millisecondsSinceEpoch}'
              : newChannel.id;

      // Update the local signal immediately for responsive UI
      _channels.value = [..._channels.value, newChannel];

      // Make the API call
      final response = await _dio.post(
        '/channel',
        data: {
          'initialActorID': newChannel.initialActorId,
          'otherActorID': newChannel.otherActorId,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add channel: ${response.statusCode}');
      }

      // Update with the server-generated ID if available
      if (response.data['id'] != null) {
        newChannel.id = response.data['id'];
      }

      // Trigger UI update with the final channel data
      _channels.value = [..._channels.value];
    } catch (e) {
      // Revert the local change on error
      _channels.value =
          _channels.value
              .where((channel) => channel.id != newChannel.id)
              .toList();
      _error.value = e.toString();
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  // Keep your existing fetchChannels implementation
  Future<void> fetchChannels() async {
    try {
      _isLoading.value = true;
      _error.value = null;

      final response = await _dio.get('/channels');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _channels.value = data.map((json) => Channel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load channels: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _error.value = e.response?.data['message'] ?? e.message;
      _channels.value = [];
    } catch (e) {
      _error.value = e.toString();
      _channels.value = [];
    } finally {
      _isLoading.value = false;
    }
  }
}

// import 'package:dio/dio.dart';
// import 'package:signals/signals_flutter.dart';
// import '../../core/network/dio_client.dart';
// import '../models/channel_model.dart';

// final channelService = ChannelService();

// class ChannelService {
//   final Dio _dio = DioClient().dio;
//   final Signal<List<Channel>> channels = signal([]);
//   // late Signal<List<dynamic>> channels = signal<List<dynamic>>([]);
//   final Signal<bool> _isLoading = signal(false);
//   final Signal<String?> _error = signal(null);

//   // ReadonlySignal<List<Channel>> get channels => _channels;
//   ReadonlySignal<bool> get isLoading => _isLoading;
//   ReadonlySignal<String?> get error => _error;

//   Future<void> fetchChannels() async {
//     try {
//       _isLoading.value = true;
//       _error.value = null;

//       final response = await _dio.get('/channels');

//       if (response.statusCode == 200) {
//         final List<dynamic> data = response.data;
//         channels.value = data.map((json) => Channel.fromJson(json)).toList();
//       } else {
//         throw Exception('Failed to load channels: ${response.statusCode}');
//       }
//     } on DioException catch (e) {
//       _error.value = e.response?.data['message'] ?? e.message;
//       channels.value = [];
//     } catch (e) {
//       _error.value = e.toString();
//       channels.value = [];
//     } finally {
//       _isLoading.value = false;
//     }
//   }
// }
