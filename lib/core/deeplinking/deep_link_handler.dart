import 'package:app_links/app_links.dart';
import '../routing/routing.dart';

class DeepLinkHandler {
  static final AppLinks _appLinks = AppLinks();

  static void initialize() async {
    try {
      Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        handleDeepLink(initialUri);
      }

      _appLinks.uriLinkStream.listen(
        (Uri? uri) {
          if (uri != null) {
            handleDeepLink(uri);
          }
        },
        onError: (err) {
          print("Error handling deep link: $err");
        },
      );
    } catch (e) {
      print("Error initializing deep links: $e");
    }
  }

  static void handleDeepLink(Uri uri) {
    print("Deep link received: ${uri.toString()}");
    if (uri.path.isNotEmpty) {
      router.push(uri.path);
    }
  }
}
