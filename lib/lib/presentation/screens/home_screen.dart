// // lib/presentation/screens/home_screen.dart
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:xdoc/presentation/screens/channels/channel_screen.dart';
// import 'package:xdoc/presentation/screens/docs/doc_screen.dart';
// import 'package:xdoc/presentation/screens/work_area/workarea_screen.dart';
// import '../widgets/responsive_layout.dart';

// class HomeScreen extends StatefulWidget {
//   final String? initialChannel;
//   final String? initialUser;

//   const HomeScreen({Key? key, this.initialChannel, this.initialUser})
//     : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   String? _selectedChannel;
//   String? _selectedUser;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize state with the saved values
//     _selectedChannel = widget.initialChannel;
//     _selectedUser = widget.initialUser;
//   }

//   // Callback when a channel is selected
//   // void _onChannelSelected(String channel) async {
//   //   await AppState.saveSelectedChannel(channel); // Save selected channel
//   //   setState(() {
//   //     _selectedChannel = channel;
//   //     _selectedUser = null; // Reset selected user
//   //   });
//   // }

//   // Callback when a user is selected
//   // void _onUserSelected(String user) async {
//   //   await AppState.saveSelectedUser(user); // Save selected user
//   //   setState(() {
//   //     _selectedUser = user;
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ResponsiveLayout(
//         // mobile: _buildMobileLayout(context),
//         // tablet: _buildDesktopLayout(context),
//         // desktop: _buildDesktopLayout(context),
//       ),
//     );
//   }

//   Widget _buildMobileLayout(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: Row(
//             children: [
//               // Sidebar(),
//               Expanded(
//                 child: Container(
//                   color: Colors.grey[700], // Set background color to grey[700]
//                   child:
//                   //  _selectedUser != null
//                   //     ?
//                   WorkareaScreen(
//                     // receiverId: '2',
//                     // onBackPressed: () {
//                     //   setState(() {
//                     //     _selectedUser = null; // Go back to user list
//                     //   });
//                     // },
//                   ),
//                   // : _selectedChannel != null
//                   //     ? DocExchange(
//                   //         onUserSelected: _onUserSelected,
//                   //         onBackPressed: () {
//                   //           setState(() {
//                   //             _selectedChannel =
//                   //                 null; // Go back to channel list
//                   //           });
//                   //         },
//                   //       )
//                   //     : ChannelList(
//                   //         onChannelSelected: _onChannelSelected,
//                   //       ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDesktopLayout(BuildContext context) {
//     return Row(
//       children: [
//         ChannelScreen(),
//         // ChannelList(
//         //   onChannelSelected: _onChannelSelected,
//         // ),
//         // if (_selectedChannel != null)
//         DocScreen(
//           // onUserSelected: _onUserSelected,
//           // onBackPressed: () {
//           //   setState(() {
//           //     _selectedChannel = null; // Go back to channel list
//           //   });
//           // },
//         ),
//         // if (_selectedUser != null)
//         Expanded(
//           child: Container(
//             color: Colors.grey[700], // Set background color to grey[700]
//             child: WorkareaScreen(
//               // receiverId: '2',
//               // onBackPressed: () {
//               //   setState(() {
//               //     _selectedUser = null; // Go back to user list
//               //   });
//               // },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
