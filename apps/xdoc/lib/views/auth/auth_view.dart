// import 'package:flutter/material.dart';
// import 'package:uids_io_sdk_flutter/gmail_sso.dart';

// class AuthView extends StatelessWidget {
//    AuthView({super.key});
//   final GmailSSO _gmailSSO = GmailSSO();

//   void _signIn(BuildContext context) async {
//     await _gmailSSO.signInWithGoogle(context);
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: SingleChildScrollView(
//           child: Container(
//             width: 400, // Constrain the width for web view
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               children: [
//                 const Text(
//                   'Login',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(
//                     height: 16), // Space between text and AuthButtons
//                      const SizedBox(height: 16), // Space between AuthButtons and new button
//                 ElevatedButton(
//                   onPressed: () {
//                     _signIn(context);
//                   },
//                   child: const Text("Api Button"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uids_io_sdk_flutter/auth_view.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    // On Linux desktop, InAppWebView is not supported by flutter_inappwebview
    // Show a message instead of crashing
    if (!kIsWeb && Platform.isLinux) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.info_outline, size: 64, color: Colors.orange),
                SizedBox(height: 20),
                Text(
                  'Authentication Not Available',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Linux desktop authentication is not yet supported.\n\n'
                  'Please use Windows, macOS, Android, or iOS to sign in.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 20),
                Text(
                  'Technical: flutter_inappwebview does not support Linux',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // On supported platforms, use the full AuthScreen with InAppWebView
    return AuthScreen(key: globalKey);
  }
}

// import 'package:flutter/material.dart';
// import 'package:uids_io_sdk_flutter/auth_buttons.dart';

// class AuthView extends StatelessWidget {
//   const AuthView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: SingleChildScrollView(
//           child: Container(
//             width: 400, // Constrain the width for web view
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               children: [
//                 const Text(
//                   'Login',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(
//                     height: 16), // Space between text and AuthButtons
//                 AuthButtons(), // Your authentication buttons widget
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
