// import 'package:flutter/material.dart';
// import 'package:signals/signals_flutter.dart';
// import '../../services/channel_service.dart';
// import '../../services/signal_state/channel_state.dart';
// import '../../widgets/responsive_layout.dart';
// import '../docs/doc_screen.dart';
// import '../work_area/workarea_screen.dart';
// import 'channel_list.dart';

// class DashboardView extends StatefulWidget {
//   const DashboardView({super.key});

//   @override
//   State<DashboardView> createState() => _DashboardViewState();
// }

// class _DashboardViewState extends State<DashboardView> {
//   // Use the public type DocScreenState
//   final GlobalKey<DocScreenState> _docScreenKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     _loadChannels();
//   }

//   Future<void> _loadChannels() async {
//     await channelService.fetchChannels();
//     if (mounted &&
//         channelService.error.value == null &&
//         channelService.channels.value.isNotEmpty) {
//       channelState.selectChannelName(channelService.channels.value.first.name);
//       // channelState.selectChannelId(channelService.channels.value.first.id);
//       _docScreenKey.currentState?.loadDocumentsForChannel();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final showNames = channelState.showChannelNames.watch(context);
//     final isLoading = channelService.isLoading.watch(context);
//     final error = channelService.error.watch(context);
//     final channels = channelService.channels.watch(context);

//     return Scaffold(
//       body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : error != null
//               ? Center(child: Text('Error: $error'))
//               : ResponsiveLayout(
//                 channelColumn: Container(
//                   width: showNames ? 240 : 72,
//                   decoration: BoxDecoration(
//                     border: Border(
//                       right: BorderSide(color: Colors.grey.shade300),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         height: 56,
//                         child: Row(
//                           children: [
//                             if (showNames)
//                               const Padding(
//                                 padding: EdgeInsets.only(left: 16),
//                                 child: Text(
//                                   'Channels',
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                             const Spacer(),
//                             IconButton(
//                               icon: Icon(
//                                 showNames
//                                     ? Icons.keyboard_arrow_left
//                                     : Icons.keyboard_arrow_right,
//                               ),
//                               onPressed: channelState.toggleNameVisibility,
//                               tooltip: showNames ? 'Collapse' : 'Expand',
//                             ),
//                           ],
//                         ),
//                       ),
//                       const Divider(height: 1),
//                       Expanded(
//                         child: ChannelList(
//                           channels: channels,
//                           onChannelSelected: () {
//                             _docScreenKey.currentState
//                                 ?.loadDocumentsForChannel();
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 docColumn: DocScreen(key: _docScreenKey),
//                 workareaColumn: const WorkareaScreen(),
//               ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:signals/signals_flutter.dart';
// import 'package:xdocapp/presentation/screens/user_screen/user_screen.dart';
// import '../../services/channel_service.dart';
// import '../../services/signal_state/channel_state.dart';
// import '../../widgets/responsive_layout.dart';
// import '../docs/doc_screen.dart';
// import '../work_area/workarea_screen.dart';
// import 'channel_list.dart';
// // Import the UserScreen

// class DashboardView extends StatefulWidget {
//   const DashboardView({super.key});

//   @override
//   State<DashboardView> createState() => _DashboardViewState();
// }

// class _DashboardViewState extends State<DashboardView> {
//   final GlobalKey<DocScreenState> _docScreenKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     _loadChannels();
//   }

//   Future<void> _loadChannels() async {
//     await channelService.fetchChannels();
//     if (mounted &&
//         channelService.error.value == null &&
//         channelService.channels.value.isNotEmpty) {
//       channelState.selectChannelName(channelService.channels.value.first.name);
//       _docScreenKey.currentState?.loadDocumentsForChannel();
//     }
//   }

//   void _navigateToUserProfile() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const UserScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final showNames = channelState.showChannelNames.watch(context);
//     final isLoading = channelService.isLoading.watch(context);
//     final error = channelService.error.watch(context);
//     final channels = channelService.channels.watch(context);

//     return Scaffold(
//       body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : error != null
//               ? Center(child: Text('Error: $error'))
//               : ResponsiveLayout(
//                 channelColumn: Container(
//                   width: showNames ? 240 : 72,
//                   decoration: BoxDecoration(
//                     border: Border(
//                       right: BorderSide(color: Colors.grey.shade300),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         height: 56,
//                         child: Row(
//                           children: [
//                             // Add CircleAvatar here
//                             Padding(
//                               padding: const EdgeInsets.only(left: 8),
//                               child: GestureDetector(
//                                 onTap: _navigateToUserProfile,
//                                 child: const CircleAvatar(
//                                   radius: 20,
//                                   child: Text(
//                                     'UN',
//                                     style: TextStyle(fontSize: 16),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             if (showNames)
//                               const Padding(
//                                 padding: EdgeInsets.only(left: 8),
//                                 child: Text(
//                                   'Channels',
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                             const Spacer(),
//                             IconButton(
//                               icon: Icon(
//                                 showNames
//                                     ? Icons.keyboard_arrow_left
//                                     : Icons.keyboard_arrow_right,
//                               ),
//                               onPressed: channelState.toggleNameVisibility,
//                               tooltip: showNames ? 'Collapse' : 'Expand',
//                             ),
//                           ],
//                         ),
//                       ),
//                       const Divider(height: 1),
//                       Expanded(
//                         child: ChannelList(
//                           channels: channels,
//                           onChannelSelected: () {
//                             _docScreenKey.currentState
//                                 ?.loadDocumentsForChannel();
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 docColumn: DocScreen(key: _docScreenKey),
//                 workareaColumn: const WorkareaScreen(),
//               ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:signals/signals_flutter.dart';
// import 'package:xdocapp/presentation/screens/user_screen/user_screen.dart';
// import '../../services/channel_service.dart';
// import '../../services/signal_state/channel_state.dart';
// import '../../widgets/responsive_layout.dart';
// import '../docs/doc_screen.dart';
// import '../work_area/workarea_screen.dart';
// import 'channel_list.dart';
// // import 'user_screen.dart';

// class DashboardView extends StatefulWidget {
//   const DashboardView({super.key});

//   @override
//   State<DashboardView> createState() => _DashboardViewState();
// }

// class _DashboardViewState extends State<DashboardView> {
//   final GlobalKey<DocScreenState> _docScreenKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     _loadChannels();
//   }

//   Future<void> _loadChannels() async {
//     await channelService.fetchChannels();
//     if (mounted &&
//         channelService.error.value == null &&
//         channelService.channels.value.isNotEmpty) {
//       channelState.selectChannelName(channelService.channels.value.first.name);
//       _docScreenKey.currentState?.loadDocumentsForChannel();
//     }
//   }

//   void _navigateToUserProfile() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const UserScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final showNames = channelState.showChannelNames.watch(context);
//     final isLoading = channelService.isLoading.watch(context);
//     final error = channelService.error.watch(context);
//     final channels = channelService.channels.watch(context);

//     return Scaffold(
//       body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : error != null
//               ? Center(child: Text('Error: $error'))
//               : ResponsiveLayout(
//                 channelColumn: Container(
//                   width: showNames ? 240 : 72,
//                   decoration: BoxDecoration(
//                     border: Border(
//                       right: BorderSide(color: Colors.grey.shade300),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         height: 56,
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             // User avatar with name
//                             Padding(
//                               padding: const EdgeInsets.only(left: 8),
//                               child: Row(
//                                 children: [
//                                   GestureDetector(
//                                     onTap: _navigateToUserProfile,
//                                     child: const CircleAvatar(
//                                       radius: 16,
//                                       child: Text(
//                                         'UN',
//                                         style: TextStyle(fontSize: 12),
//                                       ),
//                                     ),
//                                   ),
//                                   if (showNames)
//                                     const Padding(
//                                       padding: EdgeInsets.only(left: 8),
//                                       child: Text(
//                                         'John Doe',
//                                         style: TextStyle(fontSize: 14),
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ),
//                             const Spacer(),
//                           ],
//                         ),
//                       ),
//                       // Channels header with collapse/expand button
//                       SizedBox(
//                         height: 40,
//                         child: Row(
//                           children: [
//                             if (showNames)
//                               const Padding(
//                                 padding: EdgeInsets.only(left: 16),
//                                 child: Text(
//                                   'Channels',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ),
//                             const Spacer(),
//                             IconButton(
//                               icon: Icon(
//                                 showNames
//                                     ? Icons.keyboard_arrow_left
//                                     : Icons.keyboard_arrow_right,
//                                 size: 20,
//                               ),
//                               onPressed: channelState.toggleNameVisibility,
//                               tooltip: showNames ? 'Collapse' : 'Expand',
//                               padding: EdgeInsets.zero,
//                               constraints: const BoxConstraints(),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const Divider(height: 1),
//                       Expanded(
//                         child: ChannelList(
//                           channels: channels,
//                           onChannelSelected: () {
//                             _docScreenKey.currentState
//                                 ?.loadDocumentsForChannel();
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 docColumn: DocScreen(key: _docScreenKey),
//                 workareaColumn: const WorkareaScreen(),
//               ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:signals/signals_flutter.dart';
// import 'package:xdocapp/presentation/screens/user_screen/user_screen.dart';
// import '../../services/channel_service.dart';
// import '../../services/signal_state/channel_state.dart';
// import '../../widgets/responsive_layout.dart';
// import '../docs/doc_screen.dart';
// import '../work_area/workarea_screen.dart';
// import 'channel_list.dart';
// // import 'user_screen.dart';

// class DashboardView extends StatefulWidget {
//   const DashboardView({super.key});

//   @override
//   State<DashboardView> createState() => _DashboardViewState();
// }

// class _DashboardViewState extends State<DashboardView> {
//   final GlobalKey<DocScreenState> _docScreenKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     _loadChannels();
//   }

//   Future<void> _loadChannels() async {
//     await channelService.fetchChannels();
//     if (mounted &&
//         channelService.error.value == null &&
//         channelService.channels.value.isNotEmpty) {
//       channelState.selectChannelName(channelService.channels.value.first.name);
//       _docScreenKey.currentState?.loadDocumentsForChannel();
//     }
//   }

//   void _navigateToUserProfile() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const UserScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final showNames = channelState.showChannelNames.watch(context);
//     final isLoading = channelService.isLoading.watch(context);
//     final error = channelService.error.watch(context);
//     final channels = channelService.channels.watch(context);

//     return Scaffold(
//       body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : error != null
//               ? Center(child: Text('Error: $error'))
//               : ResponsiveLayout(
//                 channelColumn: Container(
//                   width: showNames ? 240 : 72,
//                   decoration: BoxDecoration(
//                     border: Border(
//                       right: BorderSide(color: Colors.grey.shade300),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       // Top section with user avatar and name
//                       SizedBox(
//                         height: 56,
//                         child: Row(
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(left: 12),
//                               child: GestureDetector(
//                                 onTap: _navigateToUserProfile,
//                                 child: const CircleAvatar(
//                                   radius: 16,
//                                   child: Text(
//                                     'UN',
//                                     style: TextStyle(fontSize: 12),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             if (showNames)
//                               const Padding(
//                                 padding: EdgeInsets.only(left: 8),
//                                 child: Text('John Doe'),
//                               ),
//                             const Spacer(),
//                           ],
//                         ),
//                       ),
//                       // Channels header with arrow first, then text
//                       SizedBox(
//                         height: 40,
//                         child: Row(
//                           children: [
//                             IconButton(
//                               icon: Icon(
//                                 showNames
//                                     ? Icons.keyboard_arrow_left
//                                     : Icons.keyboard_arrow_right,
//                                 size: 20,
//                               ),
//                               onPressed: channelState.toggleNameVisibility,
//                               padding: EdgeInsets.zero,
//                               constraints: const BoxConstraints(),
//                             ),
//                             if (showNames)
//                               const Text(
//                                 'Channels',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                       const Divider(height: 1),
//                       Expanded(
//                         child: ChannelList(
//                           channels: channels,
//                           onChannelSelected: () {
//                             _docScreenKey.currentState
//                                 ?.loadDocumentsForChannel();
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 docColumn: DocScreen(key: _docScreenKey),
//                 workareaColumn: const WorkareaScreen(),
//               ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:signals/signals_flutter.dart';
// import 'package:xdocapp/presentation/screens/user_screen/user_screen.dart';
// import '../../services/channel_service.dart';
// import '../../services/signal_state/channel_state.dart';
// import '../../widgets/responsive_layout.dart';
// import '../docs/doc_screen.dart';
// import '../work_area/workarea_screen.dart';
// import 'channel_list.dart';
// // import 'user_screen.dart';

// class DashboardView extends StatefulWidget {
//   const DashboardView({super.key});

//   @override
//   State<DashboardView> createState() => _DashboardViewState();
// }

// class _DashboardViewState extends State<DashboardView> {
//   final GlobalKey<DocScreenState> _docScreenKey = GlobalKey();
//   final TextEditingController _channelNameController = TextEditingController();
//   String userName = "John Doe"; // Replace with actual username

//   @override
//   void initState() {
//     super.initState();
//     _loadChannels();
//   }

//   @override
//   void dispose() {
//     _channelNameController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadChannels() async {
//     await channelService.fetchChannels();
//     if (mounted &&
//         channelService.error.value == null &&
//         channelService.channels.value.isNotEmpty) {
//       channelState.selectChannelName(channelService.channels.value.first.name);
//       _docScreenKey.currentState?.loadDocumentsForChannel();
//     }
//   }

//   void _navigateToUserProfile() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const UserScreen()),
//     );
//   }

//   void _showCreateChannelDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Create New Channel'),
//         content: TextField(
//           controller: _channelNameController,
//           decoration: const InputDecoration(
//             hintText: 'Enter channel name',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               if (_channelNameController.text.trim().isNotEmpty) {
//                 await channelService.createChannel(
//                   _channelNameController.text.trim(),
//                 );
//                 if (mounted) {
//                   Navigator.pop(context);
//                   _channelNameController.clear();
//                   await _loadChannels();
//                 }
//               }
//             },
//             child: const Text('Create'),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getUserInitials(String name) {
//     if (name.isEmpty) return 'US';
//     final parts = name.split(' ');
//     if (parts.length == 1) return parts[0].substring(0, 2).toUpperCase();
//     return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final showNames = channelState.showChannelNames.watch(context);
//     final isLoading = channelService.isLoading.watch(context);
//     final error = channelService.error.watch(context);
//     final channels = channelService.channels.watch(context);

//     return Scaffold(
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : error != null
//               ? Center(child: Text('Error: $error'))
//               : ResponsiveLayout(
//                   channelColumn: Container(
//                     width: showNames ? 240 : 72,
//                     decoration: BoxDecoration(
//                       border: Border(
//                         right: BorderSide(color: Colors.grey.shade300),
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         // Top section with user avatar and name
//                         SizedBox(
//                           height: 56,
//                           child: Row(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 12),
//                                 child: GestureDetector(
//                                   onTap: _navigateToUserProfile,
//                                   child: CircleAvatar(
//                                     radius: 16,
//                                     child: Text(
//                                       _getUserInitials(userName),
//                                       style: const TextStyle(fontSize: 12),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               if (showNames)
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 8),
//                                   child: Text(userName),
//                                 ),
//                               const Spacer(),
//                             ],
//                           ),
//                         ),
//                         // Channels header with arrow first, then text
//                         SizedBox(
//                           height: 40,
//                           child: Row(
//                             children: [
//                               IconButton(
//                                 icon: Icon(
//                                   showNames
//                                       ? Icons.keyboard_arrow_left
//                                       : Icons.keyboard_arrow_right,
//                                   size: 20,
//                                 ),
//                                 onPressed: channelState.toggleNameVisibility,
//                                 padding: EdgeInsets.zero,
//                                 constraints: const BoxConstraints(),
//                               ),
//                               if (showNames)
//                                 const Text(
//                                   'Channels',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                         const Divider(height: 1),
//                         Expanded(
//                           child: ChannelList(
//                             channels: channels,
//                             onChannelSelected: () {
//                               _docScreenKey.currentState
//                                   ?.loadDocumentsForChannel();
//                             },
//                           ),
//                         ),
//                         // Bottom section with add channel button
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: IconButton(
//                               icon: const CircleAvatar(
//                                 radius: 16,
//                                 backgroundColor: Colors.blue,
//                                 child: Icon(
//                                   Icons.add,
//                                   size: 16,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               onPressed: _showCreateChannelDialog,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   docColumn: DocScreen(key: _docScreenKey),
//                   workareaColumn: const WorkareaScreen(),
//                 ),
//     );
//   }
// }
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../user_screen/user_screen.dart';
import '../../../core/network/dio_client.dart';
import '../../models/channel_model.dart';
import '../../services/channel_services/channel_service.dart';
import '../../services/signal_state/channel_state.dart';
import '../../widgets/responsive_layout.dart';
import '../docs/doc_screen.dart';
import '../work_area/workarea_screen.dart';
import 'channel_list.dart';
// import 'services/add_channel.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final GlobalKey<DocScreenState> _docScreenKey = GlobalKey();
  final TextEditingController _channelNameController = TextEditingController();
  final String userName = "John Doe";
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  @override
  void dispose() {
    _channelNameController.dispose();
    super.dispose();
  }

  Future<void> _loadChannels() async {
    await channelService.fetchChannels();
    if (mounted &&
        channelService.error.value == null &&
        channelService.channels.value.isNotEmpty) {
      channelState.selectChannelName(channelService.channels.value.first.name);
      _docScreenKey.currentState?.loadDocumentsForChannel();
    }
  }

  void _navigateToUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserScreen()),
    );
  }

  // void _showCreateChannelDialog() {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: const Text('Create New Channel'),
  //           content: TextField(
  //             controller: _channelNameController,
  //             decoration: const InputDecoration(
  //               hintText: 'Enter channel name',
  //               border: OutlineInputBorder(),
  //             ),
  //             autofocus: true,
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text('Close'),
  //             ),
  //             ElevatedButton(
  //               onPressed: () async {
  //                 final channelName = _channelNameController.text.trim();
  //                 if (channelName.isEmpty) {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(
  //                       content: Text('Please enter a channel name'),
  //                     ),
  //                   );
  //                   return;
  //                 }

  //                 try {
  //                   await channelService.createChannel(channelName);
  //                   if (mounted) {
  //                     Navigator.pop(context);
  //                     _channelNameController.clear();
  //                     await _loadChannels();
  //                     final newChannel = channelService.channels.value.last;
  //                     channelState.selectChannelName(newChannel.name);
  //                     _docScreenKey.currentState?.loadDocumentsForChannel();
  //                   }
  //                 } catch (e) {
  //                   if (mounted) {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(content: Text('Failed to create channel: $e')),
  //                     );
  //                   }
  //                 }
  //               },
  //               child: const Text('Create'),
  //             ),
  //           ],
  //         ),
  //   );
  // }
  void addChannelPopup(BuildContext context) {
    final TextEditingController _entityController = TextEditingController();
    final _channels = signal<List<Map<String, dynamic>>>([]);
    final Dio _dioPub = DioClientPub().dio;
    final Dio _dio = DioClient().dio;
    final _error = signal<String?>(null);
    var channelsNameList = channelService.channels.watch(context);

    // void addChannel(Channel channel) {
    //   setState(() {
    //     channels.add(channel);
    //   });
    // }
    Future<void> _addChannel(int otherActorID) async {
      try {
        final response = await _dio.post(
          '/channel',
          data: {'initialActorID': otherActorID},
        );
        print("channelsNameList.value  9999999999999: $channelsNameList");
        if (response.data['outParams'] == null) {
          print("response.data['outParams'] == null");
          // Sidebar();
          return;
        }
        print("response.data['outParams']: ${response.data['outParams']}");
        // Extract the new channel name from the response
        final newChannelName = response.data['outParams']['v_ChannelName'];

        // Create a new channel object
        // final newChannel = {
        //   "ChannelName": newChannelName,
        //   "ChannelDescription": "Newly added channel", // You can customize this
        //   "EntityRoles": "all", // Default value
        //   "InitialActorID": 4, // Default value
        //   "OtherActorID": 3, // Default value
        // };
        final newChannel = Channel(
          name: newChannelName,
          description: "Newly added channel",
          entityRoles: "all",
          initialActorId: 4,
          otherActorId: 3,
          id: '',
          createdAt: DateTime.now(),
        );

        // Update the channelsNameList signal with the new channel
        setState(() {
          channelsNameList.add(newChannel);
          // channelsNameList = [...channelsNameList, newChannel];
        });
        // channelsNameList = [...channelsNameList, newChannel];
        // final newChannelName = response.data['outParams'].v_ChannelName;
        print("newChannelName: $newChannelName");
        // Sidebar();
        // AppSignal().appChannels.value = [newChannelName];
        // _channels.value = [
        //   ..._channels.value,
        //   {'ChannelName': newChannelName},
        // ];
      } catch (e) {
        _error.value = e.toString();
      }
    }

    void _showAddChannelPopup(BuildContext context, int otherActorID) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Channel'),
            content: const Text(' Do you want to add it?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await _addChannel(otherActorID);
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    }

    Future<void> _fetchChannelDetails(
      String entityName,
      String channelName,
    ) async {
      try {
        final response = await _dioPub.get('/Channel/$entityName/$channelName');
        final data = response.data;
        final otherActorID = data['v_OtherActorID'];
        // final initialActorID = data['v_InitialActorID'];

        if (otherActorID != 5) {
          _showAddChannelPopup(context, otherActorID);
        } else {
          // Handle the case where the IDs match
          print("Channel details: $data");
        }
      } catch (e) {
        _error.value = e.toString();
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Entity Name'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _entityController,
                  decoration: const InputDecoration(
                    hintText: 'Enter entity name',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  child: SingleChildScrollView(
                    child: Watch((context) {
                      if (_channels.value.isEmpty) {
                        return Container();
                      }
                      return Column(
                        children: _channels.value.map((channel) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(6),
                              splashColor: Colors.white,
                              hoverColor: Colors.grey,
                              onTap: () async {
                                Navigator.pop(context);
                                final entityName = _entityController.text;
                                final channelName = channel['ChannelName'];
                                await _fetchChannelDetails(
                                  entityName,
                                  channelName,
                                );
                              },
                              child: ListTile(
                                title: Text(channel['ChannelName']),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final entityName = _entityController.text;
                if (entityName.isNotEmpty) {
                  try {
                    final response = await _dioPub.get('/Channels/$entityName');
                    _channels.value = List<Map<String, dynamic>>.from(
                      response.data,
                    );
                  } catch (e) {
                    _error.value = e.toString();
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  String _getUserInitials(String name) {
    if (name.isEmpty) return 'US';
    final parts = name.split(' ');
    if (parts.length == 1) return parts[0].substring(0, 2).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final showNames = channelState.showChannelNames.watch(context);
    final isLoading = channelService.isLoading.watch(context);
    final error = channelService.error.watch(context);
    final channels = channelService.channels.watch(context);

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : ResponsiveLayout(
                  channelColumn: Container(
                    width: showNames ? 240 : 72,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 56,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: GestureDetector(
                                  onTap: _navigateToUserProfile,
                                  child: CircleAvatar(
                                    radius: 16,
                                    child: Text(
                                      _getUserInitials(userName),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),
                              if (showNames)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(userName),
                                ),
                              const Spacer(),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          child: MouseRegion(
                            onEnter: (_) => setState(() => _isHovering = true),
                            onExit: (_) => setState(() => _isHovering = false),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    showNames
                                        ? Icons.keyboard_arrow_left
                                        : Icons.keyboard_arrow_right,
                                    size: 20,
                                  ),
                                  onPressed: channelState.toggleNameVisibility,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  tooltip: _isHovering
                                      ? (showNames ? 'Collapse' : 'Expand')
                                      : null,
                                ),
                                if (showNames)
                                  const Text(
                                    'Channels',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ChannelList(
                            channels: channels,
                            // showNames: showNames,
                            onChannelSelected: () {
                              _docScreenKey.currentState
                                  ?.loadDocumentsForChannel();
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Tooltip(
                              message: 'Create new channel',
                              child: IconButton(
                                icon: const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.blue,
                                  child: Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () => addChannelPopup(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  docColumn: DocScreen(key: _docScreenKey),
                  workareaColumn: const WorkareaScreen(),
                ),
    );
  }
}
