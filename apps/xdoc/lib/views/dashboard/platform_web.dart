import 'dart:async';
import 'dart:html' as html;

// void handleWebMessage() {
//   html.window.onMessage.listen((event) {
//     final data = event.data;
//     if (data is Map && data['type'] == 'onFormSubmit') {
//       final jsonString = data['payload'];
//       print('📩 Received form submission data: $jsonString');
//     }
//   });
// }
Stream<String> handleWebMessage() {
  // Create a broadcast stream controller to allow multiple listeners
  final controller = StreamController<String>.broadcast();

  html.window.onMessage.listen((event) {
    final data = event.data;
    if (data is Map && data['type'] == 'onFormSubmit') {
      final jsonString = data['payload'];
      print('📩 Received form submission data: $jsonString');
      controller.add(jsonString); // Add the data to the stream
    }
  });

  return controller.stream;
}
