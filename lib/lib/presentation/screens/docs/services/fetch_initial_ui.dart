import 'package:dio/dio.dart';
import 'package:signals/signals_flutter.dart';
import '../../../../core/network/dio_client.dart';

final showContainerSignal = signal<bool>(false);
final intialHtmlSignal = signal<String>('');
final orignatorActorNameSignal = signal<List<String>>(
  [],
); // List to store multiple names
final responderActorNameSignal = signal<List<String>>(
  [],
); // List to store multiple names

Future<void> fetchInitialHTML(String channelName, String docName) async {
  final Dio _dio = DioClient().dio;
  print("Working............ fetchInitialHTML");
  print("channelName: $channelName");
  print("docName: $docName");

  // final dio = Dio();
  final url = '/doc/$channelName';

  try {
    final response = await _dio.post(url, data: {'docName': docName});
    if (response.statusCode == 200) {
      print("Response OK");
      print("Response data: ${response.data}");
      final data = response.data as Map<String, dynamic>;

      intialHtmlSignal.value = data['html'];
      showContainerSignal.value = true;

      print("orignatorActorNameSignal: ${data['result']}");
      // Safely handle the type casting
      final actors =
          data['result'] as List<dynamic>; // Cast to List<dynamic> first

      // Clear previous values (if any)
      orignatorActorNameSignal.value = [];
      responderActorNameSignal.value = [];

      for (var actor in actors) {
        final actorMap =
            actor
                as Map<
                  String,
                  dynamic
                >; // Cast each item to Map<String, dynamic>
        if (actorMap['IsOriginator'] == true) {
          orignatorActorNameSignal.value = [
            ...orignatorActorNameSignal.value,
            actorMap['ActorName'],
          ]; // Add to originator list
        }
        if (actorMap['IsResponder'] == true) {
          responderActorNameSignal.value = [
            ...responderActorNameSignal.value,
            actorMap['ActorName'],
          ]; // Add to responder list
        }
      }

      print("orignatorActorNameSignal: ${orignatorActorNameSignal.value}");
      print("responderActorNameSignal: ${responderActorNameSignal.value}");

      // intialHtmlSignal.value = response.data;
      // showContainerSignal.value = true;

      // Ensure response.data is a Map<String, dynamic>
      // if (response.data is Map<String, dynamic>) {
      //   final data = response.data as Map<String, dynamic>;

      //   // Update signals with the fetched data
      //   formDataSignal.value = data;
      //   showContainerSignal.value = true;

      //   // Process form inputs (if needed)
      //   final Map<String, dynamic> formInputs = {};
      //   data.forEach((key, value) {
      //     if (value is Map<String, dynamic> && value['type'] == 'checkbox') {
      //       formInputs[key] = value['checked'] ?? false;
      //     } else {
      //       formInputs[key] = '';
      //     }
      //   });

      //   formInputsSignal.value = formInputs;
      // } else {
      //   print('Error: Response data is not a Map<String, dynamic>');
      // }
    } else {
      print('Error fetching initial UI: ${response.statusCode}');
    }
  } catch (error) {
    print('Error fetching initial UI: $error');
  }
}
