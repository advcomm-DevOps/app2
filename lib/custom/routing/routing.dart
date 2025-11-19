import 'package:xdoc/views/dashboard/dashboard_view.dart';
import 'package:xdoc/views/landingpage/interconnects_view.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/routing.dart';
import 'package:xdoc/views/about/about_view.dart';
import 'package:xdoc/views/profile/profile_view.dart';

import 'route_names.dart';

final List<GoRoute> customRoutes = [
  GoRoute(
    name: aboutRoute,
    path: aboutRoute,
    pageBuilder: (context, state) =>
        buildPageWithTransition(context, state, AboutView()),
    redirect: (context, state) async {
      await checkAuthentication();
      if (!isAuthenticated) {
        redirectPath = state.uri.toString();
      }
      return handleRedirect();
    },
  ),
  GoRoute(
    name: profileRoute,
    path: profileRoute,
    pageBuilder: (context, state) =>
        buildPageWithTransition(context, state, ProfileView()),
    redirect: (context, state) async {
      await checkAuthentication();
      if (!isAuthenticated) {
        redirectPath = state.uri.toString();
      }
      return handleRedirect();
    },
  ),
  GoRoute(
    name: landingpageRoute,
    path: landingpageRoute,
    pageBuilder: (context, state) =>
        buildPageWithTransition(context, state, InterconnectsView()),
    redirect: (context, state) async {
      await checkAuthentication();
      if (!isAuthenticated) {
        redirectPath = state.uri.toString();
      }
      return handleRedirect();
    },
  ),
  GoRoute(
    name: "c",
    path: '/c/:entity/:section/:tagid',
    pageBuilder: (context, state) {
      final entity = state.pathParameters['entity']!;
      final section = state.pathParameters['section']!;
      final tagid = state.pathParameters['tagid'];
      return buildPageWithTransition(
        context,
        state,
        DashboardView(entity: entity, section: section, tagid: tagid),
      );
    },
    redirect: (context, state) async {
      await checkAuthentication();
      if (!isAuthenticated) {
        redirectPath = state.uri.toString();
        print("Storing redirect path for /c route: $redirectPath");
      }
      return handleRedirect();
    },
  ),
];
