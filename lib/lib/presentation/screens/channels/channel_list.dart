import 'package:flutter/material.dart';
import '../../models/channel_model.dart';
import 'channel_item.dart';

class ChannelList extends StatelessWidget {
  final List<Channel> channels;
  final VoidCallback onChannelSelected;

  const ChannelList({
    super.key,
    required this.channels,
    required this.onChannelSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: channels.length,
      itemBuilder: (context, index) {
        return ChannelItem(
          channel: channels[index],
          onChannelSelected: onChannelSelected,
        );
      },
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:xdocapp/presentation/models/channel_model.dart';
// import '../../services/signal_state/channel_state.dart';
// // import '../models/channel_model.dart';

// class ChannelList extends StatelessWidget {
//   final List<Channel> channels;
//   final VoidCallback onChannelSelected;

//   const ChannelList({
//     super.key,
//     required this.channels,
//     required this.onChannelSelected, required bool showNames,
//   });

//   List<Channel> get _sortedChannels {
//     // Put 'ack' and 'misc' first, then sort others alphabetically
//     final specialChannels =
//         channels
//             .where(
//               (c) =>
//                   c.name.toLowerCase() == 'ack' ||
//                   c.name.toLowerCase() == 'misc',
//             )
//             .toList();
//     final otherChannels =
//         channels
//             .where(
//               (c) =>
//                   c.name.toLowerCase() != 'ack' &&
//                   c.name.toLowerCase() != 'misc',
//             )
//             .toList()
//           ..sort((a, b) => a.name.compareTo(b.name));

//     return [...specialChannels, ...otherChannels];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: _sortedChannels.length,
//       itemBuilder: (context, index) {
//         final channel = _sortedChannels[index];
//         return ListTile(
//           leading: CircleAvatar(child: Text(channel.avatarText)),
//           title: Text(channel.name),
//           onTap: () {
//             channelState.selectChannelName(channel.name);
//             onChannelSelected();
//           },
//         );
//       },
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:xdocapp/presentation/models/channel_model.dart';
// import '../../services/signal_state/channel_state.dart';
// // import '../models/channel_model.dart';

// class ChannelList extends StatelessWidget {
//   final List<Channel> channels;
//   final bool showNames;
//   final VoidCallback onChannelSelected;

//   const ChannelList({
//     super.key,
//     required this.channels,
//     required this.showNames,
//     required this.onChannelSelected,
//   });

//   List<Channel> get _sortedChannels {
//     final specialChannels =
//         channels
//             .where(
//               (c) =>
//                   c.name.toLowerCase() == 'ack' ||
//                   c.name.toLowerCase() == 'misc',
//             )
//             .toList();
//     final otherChannels =
//         channels
//             .where(
//               (c) =>
//                   c.name.toLowerCase() != 'ack' &&
//                   c.name.toLowerCase() != 'misc',
//             )
//             .toList()
//           ..sort((a, b) => a.name.compareTo(b.name));

//     return [...specialChannels, ...otherChannels];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: _sortedChannels.length,
//       itemBuilder: (context, index) {
//         final channel = _sortedChannels[index];
//         return ListTile(
//           leading: CircleAvatar(child: Text(channel.avatarText)),
//           title: showNames ? Text(channel.name) : null,
//           onTap: () {
//             channelState.selectChannelName(channel.name);
//             onChannelSelected();
//           },
//         );
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:signals/signals_flutter.dart';
// import 'package:xdoc/presentation/models/channel_model.dart';
// import '../../services/channel_service.dart';
// import '../../services/signal_state/channel_state.dart';
// // import '../models/channel_model.dart';

// class ChannelList extends StatelessWidget {
//   // final List<Channel> channels;
//   final bool showNames;
//   final VoidCallback onChannelSelected;

//   const ChannelList({
//     super.key,
//     // required this.channels,
//     required this.showNames,
//     required this.onChannelSelected,
//   });

//   List<Channel> _sortChannels(List<Channel> channels) {
//     final specialChannels =
//         channels
//             .where(
//               (c) =>
//                   c.name.toLowerCase() == 'ack' ||
//                   c.name.toLowerCase() == 'misc',
//             )
//             .toList();
//     final otherChannels =
//         channels
//             .where(
//               (c) =>
//                   c.name.toLowerCase() != 'ack' &&
//                   c.name.toLowerCase() != 'misc',
//             )
//             .toList()
//           ..sort((a, b) => a.name.compareTo(b.name));

//     return [...specialChannels, ...otherChannels];
//   }

//   @override
//   Widget build(BuildContext context) {
//     final channels = channelService.channels.watch(context);
//     print("channels: $channels");
//     final sortedChannels = _sortChannels(channels);
//     return Watch(
//       (context) => ListView.builder(
//         itemCount: sortedChannels.length,
//         itemBuilder: (context, index) {
//           print("sortedChannels: $sortedChannels");
//           final channel = sortedChannels[index];
//           return ListTile(
//             leading: CircleAvatar(child: Text(channel.avatarText)),
//             title: showNames ? Text(channel.name) : null,
//             onTap: () {
//               channelState.selectChannelName(channel.name);
//               onChannelSelected();
//             },
//           );
//         },
//       ),
//     );
//   }
// }
