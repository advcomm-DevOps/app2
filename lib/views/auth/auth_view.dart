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



import 'package:flutter/material.dart';
import 'package:uids_io_sdk_flutter/auth_view.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
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
