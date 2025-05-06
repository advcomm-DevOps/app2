import 'dart:html' as html;
void handleWebMessage() {
  html.window.onMessage.listen((event) {
    print("aaaaaaaaaa${event.data}");
    if (event.data is Map && event.data['type'] == 'ajaxResponse') {
      final data = event.data['data'];
      print("🌐 Web AJAX Response Captured:");
      print("URL: ${data['url']}");
      print("Method: ${data['method']}");
      print("Status: ${data['status']}");
      print("Response: ${data['response']}");
    }
  });
}
