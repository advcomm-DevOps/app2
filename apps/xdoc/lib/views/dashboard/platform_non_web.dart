// void handleWebMessage() {
//   // Empty implementation for non-web platforms
//   // The actual handling is done via InAppWebView's JavaScript handler
// }
import 'dart:async';

Stream<String> handleWebMessage() {
  // Create a broadcast stream controller to allow multiple listeners
  final controller = StreamController<String>.broadcast();
  return controller.stream;
}
