import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:xdoc/core/routing/route_names.dart';
import 'package:xdoc/core/services/entity_selection_service.dart';
import 'package:xdoc/core/services/theme_service.dart';
import 'package:xdoc/custom/services/sso.dart';
import 'package:xdoc/views/dashboard/dashboard_controller.dart';
import 'package:xdoc/config/environment.dart';
import 'package:go_router/go_router.dart';
import 'package:uids_io_sdk_flutter/auth_logout.dart';
// import 'package:uids_io_sdk_flutter/services/pk_service.dart';

// import '../../custom/routing/route_names.dart';

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
  final ThemeService _themeService = ThemeService();
  List<dynamic> entities = [];
  String? selectedEntity;

  @override
  void initState() {
    super.initState();
    _fetchEntities();
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
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
      backgroundColor: _themeService.surfaceColor,
      foregroundColor: _themeService.textColor,
      title: Text(
        widget.title.tr(),
        style: TextStyle(
          color: _themeService.textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: _themeService.isDarkMode ? 0 : 1,
      shadowColor: _themeService.isDarkMode ? null : Colors.grey.withOpacity(0.2),
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
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
        //   child: TextButton(
        //     onPressed: () => context.push(aboutRoute),
        //     child: Text(
        //       "about.about".tr(),
        //       style: TextStyle(
        //         color: Colors.blue,
        //         decoration: TextDecoration.underline,
        //       ),
        //     ),
        //   ),
        // ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
        //   child: TextButton(
        //     onPressed: () => context.pushReplacement(dashboardRoute),
        //     child: Text(
        //       "dashboard.dashboard".tr(),
        //       style: TextStyle(
        //         color: Colors.blue,
        //         decoration: TextDecoration.underline,
        //       ),
        //     ),
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: IconButton(
            icon: Icon(Icons.refresh),
            color: _themeService.primaryAccent,
            tooltip: "Refresh",
            onPressed: () => context.pushReplacement(dashboardRoute),
          ),
        ),

        // Theme Toggle Button
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: _themeService.isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: _themeService.isDarkMode
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: _themeService.isDarkMode
                  ? null
                  : Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => _themeService.toggleTheme(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _themeService.isDarkMode
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          key: ValueKey(_themeService.isDarkMode),
                          color: _themeService.isDarkMode
                              ? Colors.amber[400]
                              : const Color(0xFF4A5568),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _themeService.isDarkMode ? 'Light' : 'Dark',
                        style: TextStyle(
                          color: _themeService.isDarkMode
                              ? Colors.white
                              : const Color(0xFF2D3748),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Language selection
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: PopupMenuButton<Locale>(
            icon: Icon(Icons.language, color: _themeService.textColor),
            color: _themeService.surfaceColor,
            onSelected: (Locale locale) {
              context.setLocale(locale);
            },
            itemBuilder: (BuildContext context) {
              return context.supportedLocales.map((locale) {
                return PopupMenuItem(
                  value: locale,
                  child: Text(
                    _getLanguageName(locale),
                    style: TextStyle(color: _themeService.textColor),
                  ),
                );
              }).toList();
            },
          ),
        ),
        if (entities.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.account_tree, color: _themeService.subtitleColor),
              color: _themeService.surfaceColor,
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
                      color: isSelected ? _themeService.primaryAccent.withOpacity(0.1) : null,
                      child: ListTile(
                        leading: Icon(Icons.business, color: _themeService.primaryAccent),
                        title: Text(
                          entity['tenant'] ?? 'Unknown Tenant',
                          style: TextStyle(color: _themeService.textColor),
                        ),
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
