import 'package:signals/signals.dart';

final channelState = ChannelState();

class ChannelState {
  final selectedChannelId = signal<String?>(null);
  final showChannelNames = signal(true); // Controls name visibility

  void toggleNameVisibility() {
    showChannelNames.value = !showChannelNames.value;
  }

  void selectChannelId(String id) {
    selectedChannelId.value = id;
  }

  void selectChannelName(String id) {
    selectedChannelId.value = id;
  }
}
