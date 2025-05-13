import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals/signals.dart';

final Signal<String> selectedChannel = Signal('');
final entityName = Signal<String>('');

class UserState extends ChangeNotifier {
  final jwtTokenSignal = Signal<String>("");
  // final isAuthenticated = Signal<bool>(false);
  final userName = Signal<String>("");
  final email = Signal<String>("");
  final channelsName = Signal<List<String>>([]);
  final userUID = Signal<int>(0);
  final channelName = Signal<String>('');

  UserState() {
    loadUserState();
    print("slectedChannel.value: ${selectedChannel.value}");
  }

  void loadUserState() async {
    print(' 123..................................loadUserState');
    final FlutterSecureStorage secureStorage = FlutterSecureStorage();
    final String? jwtToken = await secureStorage.read(key: "JWT_Token");
    final prefs = await SharedPreferences.getInstance();
    jwtTokenSignal.value = jwtToken ?? '';
    print("jwtTokenSignal.value: ${jwtTokenSignal.value}");
    userName.value = prefs.getString('myUserName') ?? '';
    print("userName.value: ${userName.value}");
    // channelsName.value = prefs.getStringList('channelsName') ?? [];
    print("channelsName.value: ${channelsName.value}");
    userUID.value = prefs.getInt('userUID') ?? 0;
    print("userUID.value: ${userUID.value}");
    // final prefs = await SharedPreferences.getInstance();
    // isAuthenticated.value = prefs.getBool('isAuthenticated') ?? false;
  }

  void userInfo(String name, List<String> channels, int uid) async {
    // print('authenticateUser ' + name);

    userName.value = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('myUserName', name);
    channelsName.value = channels;
    await prefs.setStringList('channelsName', channels);
    // print("channelsName.value: ${channelsName.value}");
    userUID.value = uid;
    await prefs.setInt('userUID', uid);
    print("Name: $name, Channels: $channels, UID: $uid");

    // notifyListeners(); // Notify GoRouter of changes
  }

  void setSelectedChannel(String channel) {
    selectedChannel.value = channel;
    print("selectedChannel.value: ${selectedChannel.value}");
    // notifyListeners();
  }

  void setChannelName(String name) {
    channelName.value = name;
    print("channelName.value: ${channelName.value}");
    // notifyListeners();
  }
}

final userState = UserState();
