import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:xdoc/core/routing/route_names.dart';
import 'package:xdoc/core/services/entity_selection_service.dart';
import 'package:xdoc/custom/services/sso.dart';
import 'package:xdoc/views/dashboard/dashboard_controller.dart';
import 'package:xdoc/config/environment.dart';
import 'package:go_router/go_router.dart';
import 'package:uids_io_sdk_flutter/auth_logout.dart';
// import 'package:uids_io_sdk_flutter/services/pk_service.dart';

import '../../custom/routing/route_names.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final BuildContext context;
  final List<Widget>? actions;

  CustomAppBar({
    required this.title,
    required this.context,
    this.actions,
  });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final SharedPreferencesService _spService = SharedPreferencesService();
  List<dynamic> entities = [];
  String? selectedEntity;

  @override
  void initState() {
    super.initState();
    _fetchEntities();
  }
  Future<String> getSelectedEntity() async {
    final ssoService = SSOService();
    final String? entity = await ssoService.getSelectedEntity();
    return entity ?? '';
  }

  Future<void> _fetchEntities() async {
    // print("Generated PK: ");
    // print(PK.getPK());
    List<dynamic> fetchedEntities = await _spService.getEntitiesList();
    final defaultEntity = await getSelectedEntity();
    setState(() {
      entities = fetchedEntities;
      if (entities.isNotEmpty) {
        selectedEntity = defaultEntity; // Default selection
      }
    });
  }

  String _getLanguageName(Locale locale) {
    Map<String, String> languageNames = {
      'en': 'English',
      'ar': 'العربية',
      'de': 'Deutsch',
    };
    return languageNames[locale.languageCode] ??
        locale.languageCode.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title.tr()),
      actions: [
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
        //   child: TextButton(
        //     onPressed: () => context.push(landingpageRoute),
        //     child: Text(
        //       "InterConnects",
        //       style: TextStyle(
        //         color: Colors.blue,
        //         decoration: TextDecoration.underline,
        //       ),
        //     ),
        //   ),
        // ),
        // About button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextButton(
            onPressed: () => context.push(aboutRoute),
            child: Text(
              "about.about".tr(),
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextButton(
            onPressed: () => context.push(dashboardRoute),
            child: Text(
              "dashboard.dashboard".tr(),
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),

        // Language selection
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: PopupMenuButton<Locale>(
            icon: Icon(Icons.language, color: Colors.black),
            onSelected: (Locale locale) {
              context.setLocale(locale);
            },
            itemBuilder: (BuildContext context) {
              return context.supportedLocales.map((locale) {
                return PopupMenuItem(
                  value: locale,
                  child: Text(_getLanguageName(locale)),
                );
              }).toList();
            },
          ),
        ),
        if (entities.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.account_tree, color: Colors.grey),
              onSelected: (String newValue) {
                print("Selected Entity: $newValue");
                setState(() {
                  selectedEntity = newValue;
                });
              },
              itemBuilder: (BuildContext context) {
                return entities.map<PopupMenuEntry<String>>((entity) {
                  final isSelected = entity['tenant'] == selectedEntity;

                  return PopupMenuItem<String>(
                    value: entity['tenant'],
                    child: Container(
                      color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                      child: ListTile(
                        leading: Icon(Icons.business, color: Colors.blue),
                        title: Text(entity['tenant'] ?? 'Unknown Tenant'),
                      ),
                    ),
                  );
                }).toList();
              },
            ),
          ),
        // Delete Tags button - only show in development
        if (Environment.isDevelopment)
          IconButton(
            icon: Icon(Icons.delete),
            color: Colors.red,
            tooltip: "Delete Tags",
            onPressed: () {
              DashboardController dashboardController = DashboardController();
              dashboardController.deleteTagsList();
            },
          ),
        // Logout button
        IconButton(
          icon: Icon(Icons.logout),
          color: Colors.red,
          onPressed: () => AuthLogout.logout(context),
        ),

        // Additional custom actions
        if (widget.actions != null) ...widget.actions!,
      ],
    );
  }
}
