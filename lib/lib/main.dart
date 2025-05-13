import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import 'presentation/router/app_router.dart';
import 'presentation/screens/channels2/channel_screen.dart';
import 'presentation/screens/user_screen/user_screen.dart';
import 'presentation/services/signal_state/channel_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();
  channelState.selectedChannelId.value = prefs.getString('selected_channel');

  // React to channel selection changes
  effect(() {
    if (channelState.selectedChannelId.value != null) {
      prefs.setString(
        'selected_channel',
        channelState.selectedChannelId.value!,
      );
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Channel App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// final _router = GoRouter(
//   routes: [
//     GoRoute(path: '/', builder: (context, state) => const ChannelScreen()),
//     GoRoute(path: '/user', builder: (context, state) => const UserScreen()),
//   ],
// );
