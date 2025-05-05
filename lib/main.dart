import 'package:flutter/material.dart';


import 'package:url_strategy/url_strategy.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/deeplinking/deep_link_handler.dart';
import 'core/routing/routing.dart';
import 'core/sdks/setup_database.dart';
import 'core/sdks/sso.dart';
import 'custom/lang/supported_locales.dart';
import 'custom/constants.dart';


void main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  setupDatabaseFactory();
  await EasyLocalization.ensureInitialized();
  // await initializeSsoSdk('https://auth1.3u.gg', 'api.3u.gg');
  await initializeSsoSdk(authUrl, audDomain);

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

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    DeepLinkHandler.initialize(); // Moved deep linking here
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Vendor APP',
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
  