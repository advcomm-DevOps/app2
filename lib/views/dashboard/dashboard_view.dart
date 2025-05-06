import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_starter/views/nav/custom_app_bar.dart';

import 'platform_web.dart' if (dart.library.io) 'platform_non_web.dart';// Import for web and mobile


class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  Locale? _currentLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLocale = EasyLocalization.of(context)!.locale;
    if (_currentLocale != newLocale) {
      setState(() {
        _currentLocale = newLocale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "dashboard.dashboard",
        context: context,
      ),
      body: Column(
        children: [
          // Row before WebView
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "dashboard.welcome".tr(), // Localized welcome text
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // WebView
          Expanded(
            child: InAppWebView(
              initialFile: "lib/html/form.html",
              onWebViewCreated: (controller) {
                if (!kIsWeb) {
                  controller.addJavaScriptHandler(
                    handlerName: 'ajaxResponse',
                    callback: (args) {
                      final data = args.first;
                      print("🚀 AJAX Response Captured:");
                      print("URL: ${data['url']}");
                      print("Method: ${data['method']}");
                      print("Status: ${data['status']}");
                      print("Response: ${data['response']}");
                    },
                  );
                } else {
                  handleWebMessage();
                  // html.window.onMessage.listen((event) {
                  //          print("aaaaaaaaaa${event.data}");
                  //   if (event.data is Map &&
                  //       event.data['type'] == 'ajaxResponse') {
                  //     final data = event.data['data'];
                  //     print("🌐 Web AJAX Response Captured:");
                  //     print("URL: ${data['url']}");
                  //     print("Method: ${data['method']}");
                  //     print("Status: ${data['status']}");
                  //     print("Response: ${data['response']}");
                  //   }
                  // });
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
