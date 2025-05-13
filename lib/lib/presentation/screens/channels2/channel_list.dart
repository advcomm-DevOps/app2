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
