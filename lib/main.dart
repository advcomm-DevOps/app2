import 'package:flutter/material.dart';
import 'dart:io' show Platform;

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
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager for desktop platforms (single instance support)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
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
  }
  
  await setupDatabaseFactory();
  await EasyLocalization.ensureInitialized();
  // await initializeSsoSdk('https://auth1.3u.gg', 'api.3u.gg');
  await initializeSsoSdk(authUrl, audDomain);
  
  // Initialize theme service
  await ThemeService().initializeTheme();
  
  // await FirebaseService.initializeFirebase();
  runApp(
    EasyLocalization(
      supportedLocales: getSupportedLocales(),
      path: 'lib/custom/lang', // Path to translation files
      fallbackLocale: Locale('en'),
      child: const MyApp(),
    ),
  );
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
    windowManager.addListener(this);
    DeepLinkHandler.initialize(); // Initialize app_links deep linking
    WindowsDeepLinkService.initialize(); // Initialize Windows IPC deep linking
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  // When app is already running and receives a protocol activation (deep link)
  @override
  void onWindowFocus() {
    // Window has been brought to focus, deep link handler will process the link
    print("Window focused - ready to handle deep link");
  }

  @override
  void onWindowEvent(String eventName) {
    print("Window event: $eventName");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'XDoc',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Open Sans',
            ),
        useMaterial3: true,
      ),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      routerConfig: router,
    );
  }
}
  