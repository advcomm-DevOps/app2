
import 'dart:html' as html;

void handleWebMessage() {
  html.window.onMessage.listen((event) {
    final data = event.data;
    if (data is Map && data['type'] == 'onFormSubmit') {
      final jsonString = data['payload'];
      print('📩 Received form submission data: $jsonString');
    }
  });
}

