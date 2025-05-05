import 'package:go_router/go_router.dart';
import '../../core/routing/routing.dart';
import 'package:flutter_starter/views/about/about_view.dart';
import 'package:flutter_starter/views/profile/profile_view.dart';

import 'route_names.dart';

final List<GoRoute> customRoutes = [
  GoRoute(
    name: aboutRoute,
    path: aboutRoute,
    pageBuilder:
        (context, state) =>
            buildPageWithTransition(context, state, AboutView()),
    redirect: (context, state) async {
      await checkAuthentication();
      return handleRedirect();
    },
  ),

  GoRoute(
    name: profileRoute,
    path: profileRoute,
    pageBuilder:
        (context, state) =>
            buildPageWithTransition(context, state, ProfileView()),
    redirect: (context, state) async {
      await checkAuthentication();
      return handleRedirect();
    },
  ),
];
