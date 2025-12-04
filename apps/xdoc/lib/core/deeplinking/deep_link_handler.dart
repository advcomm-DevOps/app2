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

  static void handleDeepLink(Uri uri) async {
    print("Deep link received: ${uri.toString()}");

    String routePath;

    // For web URLs (http/https), use only the path part
    // For custom schemes (like xdoc://), combine host and path
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      routePath = uri.path;
    } else if (uri.host.isNotEmpty) {
      // For custom scheme like xdoc://c/entity/section/tagid
      // host is 'c' and path is '/entity/section/tagid'
      // We need to combine them: /c/entity/section/tagid
      routePath = '/${uri.host}${uri.path}';
    } else {
      routePath = uri.path;
    }

    // Default to dashboard route if path is empty or just "/"
    if (routePath.isEmpty || routePath == '/') {
      routePath = '/';
    }

    print("Final route path to navigate: $routePath");

    if (routePath.isNotEmpty) {
      // Store the path for potential redirect after login
      redirectPath = routePath;
      print("Storing redirect path: $routePath");

      // Check authentication status
      await checkAuthentication();

      if (!isAuthenticated) {
        print(
          "User not authenticated, navigating to target (will auto-redirect to auth)",
        );
        // Navigate to the target route - it will redirect to auth if not authenticated
        router.go(routePath);
      } else {
        // User is authenticated, navigate directly
        print("User authenticated, navigating directly to: $routePath");
        router.go(routePath);
      }
    } else {
      print("Route path is empty, cannot navigate");
    }
  }

  // static void handleDeepLink(Uri uri) {
  //   print("Deep link received: ${uri.toString()}");
  //   if (uri.path.isNotEmpty) {
  //     router.push(uri.path);
  //   }
  // }
}
