import 'package:flutter_starter/views/dashboard/dashboard_view.dart';
import 'package:flutter_starter/views/landingpage/interconnects_view.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/routing.dart';
import 'package:flutter_starter/views/about/about_view.dart';
import 'package:flutter_starter/views/profile/profile_view.dart';

import 'route_names.dart';

final List<GoRoute> customRoutes = [
  GoRoute(
    name: aboutRoute,
    path: aboutRoute,
    pageBuilder: (context, state) =>
        buildPageWithTransition(context, state, AboutView()),
    redirect: (context, state) async {
      await checkAuthentication();
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
      return handleRedirect();
    },
  ),
  GoRoute(
    name: "c",
    path: '/c/:entity/:section/:tagid',
    pageBuilder: (context, state) {
       print('Full URI,,,: ${state.uri}');
      final entity = state.pathParameters['entity']!;
      final section = state.pathParameters['section']!;
      final tagid = state.pathParameters['tagid'];
      print('tagid.................................: $tagid');
      return buildPageWithTransition(
        context,
        state,
        DashboardView(entity: entity, section: section, tagid: tagid),
      );
    },
    redirect: (context, state) async {
      await checkAuthentication();
      return handleRedirect();
    },
  ),
];
