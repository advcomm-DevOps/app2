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
String? redirectPath; // Store the intended path for redirect after login

Future<void> checkAuthentication() async {
  // isAuthenticated = true;
  // isEntitySelected = true;
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final String? entities = await secureStorage.read(key: "Entities_List");
  final String? jwtToken = await secureStorage.read(key: "JWT_Token");
  print('JWT Token: ${jwtToken != null ? 'Present' : 'Not found'}');
  print(
    'Entities: ${entities != null && entities.isNotEmpty ? 'Present' : 'Not found'}',
  );
  isAuthenticated = entities != null && entities.isNotEmpty;
  isEntitySelected = jwtToken != null && jwtToken.isNotEmpty;
  print(
    'isAuthenticated: $isAuthenticated, isEntitySelected: $isEntitySelected',
  );
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
      pageBuilder: (context, state) =>
          buildPageWithTransition(context, state, AuthView()),
      redirect: (context, state) async {
        print("Auth route redirect called");
        print("Current redirectPath: ${redirectPath ?? 'null'}");
        await checkAuthentication();
        print(
          "After checkAuth - isAuthenticated: $isAuthenticated, isEntitySelected: $isEntitySelected",
        );
        if (isAuthenticated && isEntitySelected) {
          // If there's a stored redirect path, redirect to it
          // Don't clear it here - let the destination route clear it
          final String? storedPath = redirectPath;
          if (storedPath != null && storedPath != authRoute) {
            print(
              "Auth: User authenticated, will redirect to stored path: $storedPath",
            );
            // Don't clear yet - dashboard might need it
            return storedPath;
          } else {
            print("Auth: No stored path, going to dashboard");
            return dashboardRoute;
          }
        } else if (isAuthenticated && !isEntitySelected) {
          print("Auth: User authenticated but no entity selected");
          return selectEntityRoute;
        }
        print("Auth: Staying on auth page");
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
      pageBuilder: (context, state) =>
          buildPageWithTransition(context, state, DashboardView()),
      redirect: (context, state) async {
        print("Dashboard route redirect called");
        print("Current redirectPath: ${redirectPath ?? 'null'}");
        await checkAuthentication();
        if (!isAuthenticated) {
          // Store the current path for redirect after login
          redirectPath = state.uri.toString();
          print("Storing redirect path for dashboard: $redirectPath");
          return authRoute;
        } else if (isAuthenticated && !isEntitySelected) {
          return selectEntityRoute;
        }

        // Check if there's a stored redirect path after successful login
        // dashboardRoute is '/' so we just need to check it's not the dashboard
        if (redirectPath != null && redirectPath != dashboardRoute) {
          final String storedPath = redirectPath!;
          redirectPath = null; // Clear it
          print("Dashboard: Redirecting to stored path: $storedPath");
          return storedPath;
        }

        return null;
      },
    ),
    ...customRoutes,
  ],
);

Page<void> buildPageWithTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

String? handleRedirect() {
  if (!isAuthenticated) {
    return authRoute;
  }
  // Don't check for redirectPath here - let the auth route handle it
  return null;
}
