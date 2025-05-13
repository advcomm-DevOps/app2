import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../../services/channel_services/channel_service.dart';
import '../../services/signal_state/channel_state.dart';
import '../../widgets/responsive_layout.dart';
import '../docs/doc_screen.dart';
import '../work_area/workarea_screen.dart';
import 'channel_list.dart';

class ChannelScreen extends StatefulWidget {
  const ChannelScreen({super.key});

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  // Use the public type DocScreenState
  final GlobalKey<DocScreenState> _docScreenKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    await channelService.fetchChannels();
    if (mounted &&
        channelService.error.value == null &&
        channelService.channels.value.isNotEmpty) {
      channelState.selectChannelName(channelService.channels.value.first.name);
      // channelState.selectChannelId(channelService.channels.value.first.id);
      _docScreenKey.currentState?.loadDocumentsForChannel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showNames = channelState.showChannelNames.watch(context);
    final isLoading = channelService.isLoading.watch(context);
    final error = channelService.error.watch(context);
    final channels = channelService.channels.watch(context);

    return Scaffold(
      body:
          isLoading
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
                            if (showNames)
                              const Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Text(
                                  'Channels',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(
                                showNames
                                    ? Icons.keyboard_arrow_left
                                    : Icons.keyboard_arrow_right,
                              ),
                              onPressed: channelState.toggleNameVisibility,
                              tooltip: showNames ? 'Collapse' : 'Expand',
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ChannelList(
                          channels: channels,
                          onChannelSelected: () {
                            _docScreenKey.currentState
                                ?.loadDocumentsForChannel();
                          },
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
