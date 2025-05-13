import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../core/network/dio_client.dart';
import '../../../models/channel_model.dart';
import '../../../services/channel_services/channel_service.dart';

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
      // setState(() {
      //   channelsNameList = [...channelsNameList, newChannel];
      // });
      channelsNameList = [...channelsNameList, newChannel];
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
                      children:
                          _channels.value.map((channel) {
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
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:signals/signals_flutter.dart';
// import '../../../../core/network/dio_client.dart';
// import '../../../models/channel_model.dart';
// import '../../../services/channel_service.dart';

// void addChannelPopup(BuildContext context) {
//   final TextEditingController _entityController = TextEditingController();
//   final _channels = signal<List<Map<String, dynamic>>>([]);
//   final Dio _dioPub = DioClientPub().dio;
//   final _error = signal<String?>(null);

//   Future<void> _addChannel(int otherActorID) async {
//     try {
//       // Create a new channel with empty ID (will be set in service)
//       final newChannel = Channel(
//         id: '', // Will be set by service
//         name: 'New Channel', // Temporary name
//         description: "Newly added channel",
//         entityRoles: "all",
//         initialActorId: 4,
//         otherActorId: otherActorID,
//         createdAt: DateTime.now(),
//       );

//       await channelService.addChannel(newChannel);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Channel added successfully')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to add channel: ${e.toString()}')),
//       );
//     }
//   }

//   void _showAddChannelPopup(BuildContext context, int otherActorID) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Add Channel'),
//           content: const Text('Do you want to add it?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 Navigator.pop(context);
//                 await _addChannel(otherActorID);
//               },
//               child: const Text('Add'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ... rest of your existing code for _fetchChannelDetails and showDialog ...
//   Future<void> _fetchChannelDetails(
//     String entityName,
//     String channelName,
//   ) async {
//     try {
//       final response = await _dioPub.get('/Channel/$entityName/$channelName');
//       final data = response.data;
//       final otherActorID = data['v_OtherActorID'];
//       // final initialActorID = data['v_InitialActorID'];

//       if (otherActorID != 5) {
//         _showAddChannelPopup(context, otherActorID);
//       } else {
//         // Handle the case where the IDs match
//         print("Channel details: $data");
//       }
//     } catch (e) {
//       _error.value = e.toString();
//     }
//   }

//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('Search Entity Name'),
//         content: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxHeight: MediaQuery.of(context).size.height * 0.6,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: _entityController,
//                 decoration: const InputDecoration(
//                   hintText: 'Enter entity name',
//                 ),
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 child: SingleChildScrollView(
//                   child: Watch((context) {
//                     if (_channels.value.isEmpty) {
//                       return Container();
//                     }
//                     return Column(
//                       children:
//                           _channels.value.map((channel) {
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 vertical: 4.0,
//                               ),
//                               child: InkWell(
//                                 borderRadius: BorderRadius.circular(6),
//                                 splashColor: Colors.white,
//                                 hoverColor: Colors.grey,
//                                 onTap: () async {
//                                   Navigator.pop(context);
//                                   final entityName = _entityController.text;
//                                   final channelName = channel['ChannelName'];
//                                   await _fetchChannelDetails(
//                                     entityName,
//                                     channelName,
//                                   );
//                                 },
//                                 child: ListTile(
//                                   title: Text(channel['ChannelName']),
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                     );
//                   }),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               final entityName = _entityController.text;
//               if (entityName.isNotEmpty) {
//                 try {
//                   final response = await _dioPub.get('/Channels/$entityName');
//                   _channels.value = List<Map<String, dynamic>>.from(
//                     response.data,
//                   );
//                 } catch (e) {
//                   _error.value = e.toString();
//                 }
//               }
//             },
//             child: const Text('Submit'),
//           ),
//         ],
//       );
//     },
//   );
// }
