import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter/core/routing/route_names.dart';
import 'package:flutter_starter/core/services/entity_selection_service.dart';
import 'package:go_router/go_router.dart';
import 'package:uids_io_sdk_flutter/auth_logout.dart';
import 'package:uids_io_sdk_flutter/services/pk_service.dart';

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

  Future<void> _fetchEntities() async {
    print("Generated PK: ");
    print(PK.getPK());
    List<dynamic> fetchedEntities = await _spService.getEntitiesList();
    setState(() {
      entities = fetchedEntities;
      if (entities.isNotEmpty) {
        selectedEntity = entities[0]['tenant']; // Default selection
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

        // Entity selection
        if (entities.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.account_tree, color: Colors.grey),
              onSelected: (String newValue) {
                setState(() {
                  selectedEntity = newValue;
                });
              },
              itemBuilder: (BuildContext context) {
                return entities.map<PopupMenuEntry<String>>((entity) {
                  return PopupMenuItem<String>(
                    value: entity['tenant'],
                    child: ListTile(
                      leading: Icon(Icons.business, color: Colors.blue),
                      title: Text(entity['tenant'] ?? 'Unknown Tenant'),
                    ),
                  );
                }).toList();
              },
            ),
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
