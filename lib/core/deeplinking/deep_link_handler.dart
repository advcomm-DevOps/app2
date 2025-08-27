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

    String routePath;

    // For web URLs (http/https), use only the path part
    // For custom schemes, use the host as part of the path
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      routePath = uri.path;
    } else if (uri.host.isNotEmpty) {
      routePath = '/' + uri.host + uri.path;
    } else {
      routePath = uri.path;
    }

    // Default to dashboard route if path is empty or just "/"
    if (routePath.isEmpty || routePath == '/') {
      routePath = '/';
    }

    print("Navigating to: $routePath");

    if (routePath.isNotEmpty) {
      router.push(routePath);
    }
  }

  // static void handleDeepLink(Uri uri) {
  //   print("Deep link received: ${uri.toString()}");
  //   if (uri.path.isNotEmpty) {
  //     router.push(uri.path);
  //   }
  // }
}
