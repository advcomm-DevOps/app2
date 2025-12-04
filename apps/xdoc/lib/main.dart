import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:url_strategy/url_strategy.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:window_manager/window_manager.dart';
import 'core/deeplinking/deep_link_handler.dart';
import 'core/services/windows_deep_link_service.dart';
import 'core/routing/routing.dart';
import 'core/sdks/setup_database.dart';
import 'core/sdks/sso.dart';
import 'core/services/theme_service.dart';
import 'custom/lang/supported_locales.dart';
import 'custom/constants.dart';

void main() async {
  // Wrap everything in error handling to catch initialization issues
  try {
    print('🚀 Starting XDoc app initialization...');

    setPathUrlStrategy();
    WidgetsFlutterBinding.ensureInitialized();
    print('✅ Flutter bindings initialized');

    // Initialize InAppWebView platform implementation (required for uids_io_sdk_flutter)
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
      print('✅ InAppWebView initialized for mobile');
    }

    // Initialize window manager for desktop platforms only (single instance support)
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      await windowManager.ensureInitialized();

      WindowOptions windowOptions = const WindowOptions(
        center: true,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
      );

      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
      print('✅ Window manager initialized for desktop');
    }

    print('🔧 Setting up database factory...');
    await setupDatabaseFactory();
    print('✅ Database factory setup complete');

    print('🌐 Initializing EasyLocalization...');
    await EasyLocalization.ensureInitialized();
    print('✅ EasyLocalization initialized');

    print('🔐 Initializing SSO SDK...');
    await initializeSsoSdk(authUrl, audDomain);
    print('✅ SSO SDK initialized');

    print('🎨 Initializing theme service...');
    await ThemeService().initializeTheme();
    print('✅ Theme service initialized');

    print('✅ All initialization complete, starting app...');
    runApp(
      EasyLocalization(
        supportedLocales: getSupportedLocales(),
        path: 'lib/custom/lang', // Path to translation files
        fallbackLocale: const Locale('en'),
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    print('❌ FATAL ERROR during app initialization:');
    print('Error: $e');
    print('Stack trace: $stackTrace');
    // Show error in a basic Material app
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 20),
                  Text(
                    'Initialization Error',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '$e',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    // WindowListener only for desktop platforms
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      windowManager.addListener(this);
    }
    DeepLinkHandler.initialize(); // Initialize app_links deep linking
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      WindowsDeepLinkService.initialize(); // Initialize Windows IPC deep linking (desktop only)
    }
  }

  @override
  void dispose() {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  // WindowListener methods - only used on desktop
  @override
  void onWindowFocus() {
    print("Window focused - ready to handle deep link");
  }

  @override
  void onWindowEvent(String eventName) {
    print("Window event: $eventName");
  }

  @override
  void onWindowBlur() {}

  @override
  void onWindowClose() async {}

  @override
  void onWindowDocked() {}

  @override
  void onWindowEnterFullScreen() {}

  @override
  void onWindowLeaveFullScreen() {}

  @override
  void onWindowMaximize() {}

  @override
  void onWindowMinimize() {}

  @override
  void onWindowMove() {}

  @override
  void onWindowMoved() {}

  @override
  void onWindowResize() {}

  @override
  void onWindowResized() {}

  @override
  void onWindowRestore() {}

  @override
  void onWindowUndocked() {}

  @override
  void onWindowUnmaximize() {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'XDoc',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Open Sans'),
        useMaterial3: true,
      ),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      routerConfig: router,
    );
  }
}
