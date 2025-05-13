import 'package:go_router/go_router.dart';
import '../screens/channels/channel_screen.dart';
import '../screens/user_screen/user_screen.dart';
import 'router_constants.dart';

final router = GoRouter(
  initialLocation: RouteConstants.home,
  routes: [
    GoRoute(
      path: RouteConstants.home,
      builder: (context, state) => const DashboardView(),
    ),
    GoRoute(
      path: RouteConstants.user,
      builder: (context, state) => const UserScreen(),
    ),
  ],
);
