import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../../models/channel_model.dart';
import '../../services/signal_state/channel_state.dart';
import '../../widgets/avatar_widget.dart';

class ChannelItem extends StatelessWidget {
  final Channel channel;
  final VoidCallback? onChannelSelected;

  const ChannelItem({super.key, required this.channel, this.onChannelSelected});

  @override
  Widget build(BuildContext context) {
    final isSelected =
        channelState.selectedChannelId.watch(context) == channel.name;
    print('isSelected: ....: .... $isSelected');
    final showNames = channelState.showChannelNames.watch(context);

    return Material(
      type: MaterialType.transparency,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: AvatarWidget(name: channel.name, size: 36),
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child:
                showNames
                    ? Tooltip(
                      message: channel.name,
                      child: Text(
                        _truncateName(channel.name, 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        key: Key('name-${channel.name}'),
                      ),
                    )
                    : const SizedBox.shrink(key: Key('no-name')),
          ),
          minLeadingWidth: 0,
          horizontalTitleGap: 8,
          onTap: () {
            channelState.selectChannelName(channel.name);
            // channelState.selectChannelId(channel.id);
            onChannelSelected?.call();
          },
        ),
      ),
    );
  }

  String _truncateName(String name, int maxWords) {
    final words = name.split(' ');
    if (words.length <= maxWords) return name;
    final truncated = words.take(maxWords).join(' ');
    return '$truncated...';
  }
}
