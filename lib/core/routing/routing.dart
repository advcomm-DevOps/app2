import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../custom/routing/routing.dart';
import '../../views/auth/auth_view.dart';
import '../../views/dashboard/dashboard_view.dart';
import '../views/select_entity_view.dart';
import 'route_names.dart';

bool isAuthenticated = false;
bool isEntitySelected = false;

Future<void> checkAuthentication() async {
  // isAuthenticated = true;
  // isEntitySelected = true;
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final String? entities = await secureStorage.read(key: "Entities_List");
  final String? jwtToken = await secureStorage.read(key: "JWT_Token");
  isAuthenticated = entities != null && entities.isNotEmpty;
  isEntitySelected = jwtToken != null && jwtToken.isNotEmpty;
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: authRoute, // Default to authRoute
  debugLogDiagnostics: true,
  routes: <RouteBase>[
    GoRoute(
      name: authRoute,
      path: authRoute,
      pageBuilder: (context, state) => buildPageWithTransition(
        context,
        state,
        AuthView(),
      ),
      redirect: (context, state) async {
        await checkAuthentication();
        if (isAuthenticated && isEntitySelected) {
          return dashboardRoute;
        } else if (isAuthenticated && !isEntitySelected) {
          return selectEntityRoute;
        }
        return null; // Stay on authRoute
      },
    ),
    GoRoute(
      name: selectEntityRoute,
      path: selectEntityRoute,
      pageBuilder: (context, state) => buildPageWithTransition(
        context,
        state,
        SelectEntityView(), // New view to select entity
      ),
      redirect: (context, state) async {
        await checkAuthentication();
        if (!isAuthenticated) {
          return authRoute;
        } else if (isAuthenticated && isEntitySelected) {
          return dashboardRoute;
        }
        return null;
      },
    ),
    GoRoute(
      name: dashboardRoute,
      path: dashboardRoute,
      pageBuilder: (context, state) => buildPageWithTransition(
        context,
        state,
        DashboardView(),
      ),
      redirect: (context, state) async {
        await checkAuthentication();
        if (!isAuthenticated) {
          return authRoute;
        } else if (isAuthenticated && !isEntitySelected) {
          return selectEntityRoute;
        }
        return null;
      },
    ),
     ...customRoutes,
  ],
);

Page<void> buildPageWithTransition(
    BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}
String? handleRedirect() {
  if (!isAuthenticated) return authRoute;
  return null;
}