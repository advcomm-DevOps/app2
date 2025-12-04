import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import '../deeplinking/deep_link_handler.dart';

class WindowsDeepLinkService {
  static const MethodChannel _channel = MethodChannel('xdoc.app/deep_link');
  static bool _initialized = false;

  static void initialize() {
    if (_initialized || !Platform.isWindows) return;

    _initialized = true;

    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'handleDeepLink') {
        final String? url = call.arguments['url'];
        print('Windows IPC raw received: "$url"');
        print('Windows IPC raw bytes: ${url?.codeUnits}');

        if (url != null && url.isNotEmpty) {
          // Clean up any null characters or whitespace
          final String cleanUrl = url
              .replaceAll(RegExp(r'[\x00\s]+$'), '')
              .trim();
          print('Windows IPC cleaned: "$cleanUrl"');

          // Extract the deep link URL from command line
          // Format: "xdoc://c/entity/section/tagid"
          final RegExp deepLinkRegex = RegExp(r'xdoc://[^\s\x00]+');
          final Match? match = deepLinkRegex.firstMatch(cleanUrl);

          if (match != null) {
            final String deepLinkUrl = match.group(0)!;
            print('Processing deep link from IPC: $deepLinkUrl');

            // Parse to Uri and use DeepLinkHandler
            try {
              final Uri uri = Uri.parse(deepLinkUrl);
              DeepLinkHandler.handleDeepLink(uri);
            } catch (e) {
              print('Error parsing deep link URL: $e');
            }
          } else {
            print('No deep link pattern found in: $cleanUrl');
          }
        }
      }
    });

    print('Windows deep link service initialized');
  }
}
