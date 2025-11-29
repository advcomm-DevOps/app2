import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:xdoc/custom/constants.dart';
import 'package:xdoc/core/services/theme_service.dart';
import 'package:xdoc/custom/services/rsa.dart';
import 'package:xdoc/custom/services/sso.dart';
import 'package:xdoc/core/services/entity_selection_service.dart';
import 'package:xdoc/views/dashboard/dashboard_model.dart';
import 'package:xdoc/views/dashboard/form_resume.dart';
import '../nav/custom_app_bar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'platform_web.dart' if (dart.library.io) 'platform_non_web.dart';
import 'package:liquid_engine/liquid_engine.dart';
import 'dashboard_controller.dart';
import 'dashboard_logs_view.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uids_io_sdk_flutter/auth_logout.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

// Mobile view navigation enum
enum MobileView { channels, documents, chat }

class DashboardView extends StatefulWidget {
  final String? entity;
  final String? section;
  final String? tagid;
  const DashboardView({super.key, this.entity, this.section, this.tagid});
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // Guard to ensure validateSection popup is only shown once per DashboardView instance
  bool _hasShownValidateSectionPopup = false;
  int? selectedChannelIndex;
  int? selectedDocIndex;
  int? selectedTagIndex;
  String subSelectedEntity = '';
  String selectedEntity = '';
  String? secQr = '';
  String? entityQr = '';
  String? newSecQr = '';
  bool showRightSidebar = false;

  final dio = Dio();
  final String apiUrl = 'https://$audDomain';
  //final String apiUrl = 'http://localhost:3000';
  final String qrurl = "https://d.xdoc.app?path=c";
  List<Map<String, dynamic>> channels = [];
  List<Map<String, dynamic>> docs = [];
  // joinedTags removed - middle panel will display documents only
  List<Map<String, dynamic>> tags = [];
  List<Map<String, String>> actionButtons = [];
  DashboardController dashboardController =
      DashboardController(); // Initialize the controller

  bool isDocsLoading = false;
  bool isDocumentLoading = false;
  // isjoinedTagsLoading removed
  bool isTagsLoading = false;
  bool isUploading = false;
  bool isComposeMode = false;
  // Guard to prevent multiple compose dialogs opening at once
  bool _isComposeDialogOpen = false;
  DateTime? _lastComposeDialogOpenAttempt;
  Locale? _currentLocale;
  bool isSidebarCollapsed = false; // Track sidebar collapse state
  bool _isProfileHovered = false; // Track profile hover state

  // Resizable divider state
  bool _isDividerHovered = false;
  bool _isDragging = false;
  double _docsWidth = 250.0; // Default docs panel width
  double _dragStartX = 0.0;
  double _dragStartWidth = 0.0;

  final ThemeService _themeService = ThemeService();

  List<dynamic> publicInterconnects = [];
  String? selectedInterconnectId;
  List<dynamic> respondentActors = [];
  String? selectedActorId;

  // Entity management (similar to custom app bar)
  List<dynamic> entities = [];
  String? selectedEntityForSwitching;

  final TextEditingController messageController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _htmlController = TextEditingController();
  final TextEditingController _channelNameController = TextEditingController();
  final TextEditingController _entityController = TextEditingController();
  final TextEditingController _composeChannelController =
      TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String htmlForm = getResumeForm();
  String htmlTheme = "";
  String updatedJson = "{}";
  String jsonHtmlTheme = "";
  String searchQuery = ""; // Search query for filtering docs and tags
  List<Map<String, dynamic>> allChannelStateNames =
      []; // Store active states with full data
  List<Map<String, dynamic>> expectedStateTransitions =
      []; // Store expected state transitions

  List<Map<String, dynamic>> currentChatMessages = [];

  // Stream subscription for channels
  StreamSubscription<List<Map<String, dynamic>>>? _channelsSubscription;

  // Mobile navigation state
  MobileView _currentMobileView = MobileView.channels;

  bool get isLastFile {
    if (currentChatMessages.isEmpty) return false;
    final lastMessage = currentChatMessages.last;
    return lastMessage["isFile"] == true;
  }

  // Helper method to check if device is mobile
  bool isMobileDevice(BuildContext context) {
    return MediaQuery.of(context).size.width < 900;
  }

  // Helper method to navigate mobile views
  void _navigateToMobileView(MobileView view) {
    if (mounted) {
      setState(() {
        _currentMobileView = view;
      });
    }
  }

  // Theme color getters - Use ThemeService
  bool get isDarkMode => _themeService.isDarkMode;
  Color get backgroundColor => _themeService.backgroundColor;
  Color get surfaceColor => _themeService.surfaceColor;
  Color get cardColor => _themeService.cardColor;
  Color get textColor => _themeService.textColor;
  Color get subtitleColor => _themeService.subtitleColor;
  Color get primaryAccent => _themeService.primaryAccent;
  Color get secondaryAccent => _themeService.secondaryAccent;
  Color get borderColor => _themeService.borderColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLocale = EasyLocalization.of(context)!.locale;
    if (_currentLocale != newLocale) {
      setState(() {
        _currentLocale = newLocale;
      });
    }
  }

  // Helper method to create properly encoded QR URL
  String createQrUrl({
    required String entity,
    required String channel,
    String? tagId,
  }) {
    final encodedEntity = Uri.encodeQueryComponent(entity);
    final encodedChannel = Uri.encodeQueryComponent(channel);

    String url = "$qrurl&entity=$encodedEntity&channel=$encodedChannel";

    if (tagId != null && tagId.isNotEmpty) {
      final encodedTagId = Uri.encodeQueryComponent(tagId);
      url += "&id=$encodedTagId";
    }

    return url;
  }

  Future<void> loadSelectedEntity() async {
    final ssoService = SSOService();
    final entity = await ssoService.getSelectedEntity();
    final subEntity = await ssoService.getSubSelectedEntity();
    setState(() {
      selectedEntity = entity ?? '';
      subSelectedEntity = subEntity ?? '';
    });
  }

  // Fetch entities for account switching (similar to custom app bar)
  Future<void> _fetchEntitiesForSwitching() async {
    print("Starting to fetch entities for switching...");
    try {
      final spService = SharedPreferencesService();
      List<dynamic> fetchedEntities = await spService.getEntitiesList();
      print("Fetched entities: $fetchedEntities");
      print("Fetched entities length: ${fetchedEntities.length}");

      final ssoService = SSOService();
      final defaultEntity = await ssoService.getSelectedEntity();
      print("Default entity: $defaultEntity");

      setState(() {
        entities = fetchedEntities;
        selectedEntityForSwitching = defaultEntity;
      });
      print("Updated state - entities length: ${entities.length}");
      print("Updated state - entities content: $entities");

      // Force a rebuild of the UI
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Error fetching entities for switching: $e");
    }
  }

  Future<void> _checkToken() async {
    String token = await dashboardController.getJwt();
    print('JWT Token in Dashboard: $token');
    if (token.trim().isEmpty) {
      print('JWT Token in Dashboard.......: $token');
      Navigator.pushReplacementNamed(context, '/');
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    initSetup();
    _checkToken();
    secQr = widget.section;
    entityQr = widget.entity;
    dashboardController.onboardEntity().then((result) {
      if (result) {
        fetchChannels();
      }
    });
    loadSelectedEntity();
    dashboardController.getPublicInterconnects().then((result) {
      publicInterconnects = result;
    });

    // Fetch entities for account switching
    _fetchEntitiesForSwitching();

    // Initialize theme service and add listener
    _themeService.initializeTheme();
    _themeService.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> initSetup() async {
    final keysStatus = await generateRSAKeyPair();

    // Show import dialog only when keys exist on server but not locally (keysStatus == true)
    if (keysStatus == true && mounted) {
      // Small delay to ensure the UI is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showImportKeyDialogAutomatic();
        }
      });
    }
  }

  Future<void> fetchChannels() async {
    try {
      // Cancel any existing subscription
      await _channelsSubscription?.cancel();

      // Listen to the channels stream for real-time updates
      _channelsSubscription = dashboardController.fetchChannelsStream().listen(
        (data) {
          if (mounted && data.isNotEmpty) {
            setState(() {
              channels = data;
              // Auto-select "Inbox" channel if present and no channel is currently selected
              // if (selectedChannelIndex == null) {
              //   final inboxIndex = channels.indexWhere(
              //     (channel) => channel['channelname']?.toLowerCase() == 'inbox',
              //   );
              //   if (inboxIndex != -1) {
              //     selectedChannelIndex = inboxIndex;
              //     selectedDocIndex = null;
              //     docs = [];
              //     currentChatMessages = [];
              //     fetchDocs(channels[inboxIndex]["channelname"]);
              //   }
              // }
            });
          } else if (mounted) {
            print("No channels found.");
          }
          // Only show validateSection popup once per DashboardView instance
          if (mounted && !_hasShownValidateSectionPopup) {
            validateSection();
          }
        },
        onError: (error) {
          if (mounted) {
            print("Error in channels stream: $error");
          }
        },
      );
    } catch (e) {
      print("Error setting up channels stream: $e");
    }
  }

  void validateSection() async {
    // Only show the popup if it hasn't been shown yet
    if (_hasShownValidateSectionPopup) return;
    // Defensive null checks for required widget fields
    if (widget.section == null || widget.entity == null || widget.tagid == null) {
      _hasShownValidateSectionPopup = true;
      return;
    }
    secQr = widget.section;
    final tagid = widget.tagid;
    String? tagname = '';

    try {
      final details = await dashboardController.getReciprocalChannelDetails(
          otherUserTid: entityQr!, otherChannelName: widget.section!);
      final channelDetails = await dashboardController.getChannelDetailsForJoin(
        entityId: entityQr!,
        channelName: widget.section!,
        tagId: widget.tagid!,
      );
      if (channelDetails != null && channelDetails["channelDetails"] != null) {
        newSecQr = channelDetails["channelDetails"]["newChannelName"];
        tagname = channelDetails["channelDetails"]["tagName"];
      }

      if (details != null &&
          details['channels'] != null &&
          details['channels'] is List &&
          (details['channels'] as List).isNotEmpty) {
        final List channelsList = details['channels'];
        int? selectedExistingChannelIdx;
        bool isJoinNew = false;
        String newChannelName = '';
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                backgroundColor: surfaceColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Channel Options',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                content: SingleChildScrollView(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Toggle buttons styled as in create new channel
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: !isJoinNew
                                      ? Colors.blueAccent
                                      : Colors.grey[700],
                                  foregroundColor: !isJoinNew
                                      ? Colors.white
                                      : Colors.white70,
                                  side: BorderSide(
                                      color: !isJoinNew
                                          ? Colors.blueAccent
                                          : Colors.grey[500]!,
                                      width: 1.2),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  setState(() {
                                    isJoinNew = false;
                                  });
                                },
                                child: Text('Select Existing Channel',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: isJoinNew
                                      ? Colors.blueAccent
                                      : Colors.grey[700],
                                  foregroundColor:
                                      isJoinNew ? Colors.white : Colors.white70,
                                  side: BorderSide(
                                      color: isJoinNew
                                          ? Colors.blueAccent
                                          : Colors.grey[500]!,
                                      width: 1.2),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  setState(() {
                                    isJoinNew = true;
                                  });
                                },
                                child: Text('Join New Channel',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (!isJoinNew) ...[
                          Text('You already have similar channels:',
                              style: TextStyle(
                                  color: subtitleColor, fontSize: 15)),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children:
                                List.generate(channelsList.length, (index) {
                              final channel = channelsList[index];
                              final isSelected =
                                  selectedExistingChannelIdx == index;
                              return ChoiceChip(
                                label: Text(
                                  channel['channelName']?.toString() ??
                                      'Unnamed Channel',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                ),
                                selected: isSelected,
                                selectedColor: Colors.green,
                                backgroundColor: Colors.grey[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    selectedExistingChannelIdx = index;
                                    newSecQr =
                                        channel['channelName']?.toString() ??
                                            'Unnamed Channel';
                                  });
                                },
                              );
                            }),
                          ),
                        ] else ...[
                          Text('New Channel',
                              style: TextStyle(
                                  color: subtitleColor, fontSize: 15)),
                          const SizedBox(height: 16),
                          TextField(
                            controller:
                                TextEditingController(text: newSecQr ?? ''),
                            decoration: InputDecoration(
                              labelText: 'Channel Name',
                              labelStyle: TextStyle(color: subtitleColor),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            style: TextStyle(color: textColor),
                            onChanged: (val) {
                              setState(() {
                                newChannelName = val;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                actionsPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: subtitleColor),
                    ),
                  ),
                  if (!isJoinNew)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedExistingChannelIdx != null
                            ? Colors.blue
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                      ),
                      onPressed: selectedExistingChannelIdx != null
                          ? () async {
                              // Just select the channel, open document popup, and prefill entityQr and search
                              final existsinlocal = channels.any((channel) =>
                                  channel['channelname'] == newSecQr);
                              if (existsinlocal) {
                                final indexlocal = channels.indexWhere(
                                    (channel) =>
                                        channel['channelname'] == newSecQr);
                                setState(() {
                                  selectedChannelIndex = indexlocal;
                                  selectedDocIndex = null;
                                  docs = [];
                                  currentChatMessages = [];
                                });
                await fetchDocs(
                  channels[indexlocal]["channelname"]);
                                Navigator.of(context).pop();
                                // Open document creation popup and prefill entityQr and search
                                Future.microtask(() {
                                  if (!mounted) return;

                                  // Prevent rapid auto-open loops: allow attempts only if enough time
                                  // has passed since the last attempt.
                                  final now = DateTime.now();
                                  const cooldown = Duration(milliseconds: 800);
                                  if (_lastComposeDialogOpenAttempt != null &&
                                      now.difference(_lastComposeDialogOpenAttempt!) < cooldown) {
                                    return;
                                  }
                                  _lastComposeDialogOpenAttempt = now;

                                  _entityController.text = entityQr ?? '';
                                  _searchController.text = entityQr ?? '';
                                  if (!_isComposeDialogOpen) {
                                    _showComposeDialog(context, autoSearch: true);
                                  }
                                });
                              }
                            }
                          : null,
                      child: Text('Submit',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  if (isJoinNew)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: newChannelName.trim().isNotEmpty
                            ? Colors.blue
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                      ),
                      onPressed: newChannelName.trim().isNotEmpty
                          ? () {
                              // TODO: Add your join new channel logic here
                              joinNewChannel(
                                  entityQr!, secQr!, tagid, tagname, newSecQr);
                              Navigator.of(context).pop();
                            }
                          : null,
                      child: Text('Join',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            );
          },
        ).whenComplete(() {
          // Mark as shown after dialog closes, regardless of how it was closed
          _hasShownValidateSectionPopup = true;
        });
      } else {
        // No details found (no similar channels) - show join new channel UI directly
        String newChannelName = newSecQr ?? '';
        bool isJoinNew = true;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                backgroundColor: surfaceColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Channel Options',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                content: SingleChildScrollView(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Toggle buttons styled as in create new channel
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: !isJoinNew
                                      ? Colors.blueAccent
                                      : Colors.grey[700],
                                  foregroundColor: !isJoinNew
                                      ? Colors.white
                                      : Colors.white70,
                                  side: BorderSide(
                                      color: !isJoinNew
                                          ? Colors.blueAccent
                                          : Colors.grey[500]!,
                                      width: 1.2),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  setState(() {
                                    isJoinNew = false;
                                  });
                                },
                                child: Text('Select Existing Channel',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: isJoinNew
                                      ? Colors.blueAccent
                                      : Colors.grey[700],
                                  foregroundColor:
                                      isJoinNew ? Colors.white : Colors.white70,
                                  side: BorderSide(
                                      color: isJoinNew
                                          ? Colors.blueAccent
                                          : Colors.grey[500]!,
                                      width: 1.2),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  setState(() {
                                    isJoinNew = true;
                                  });
                                },
                                child: Text('Join New Channel',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (isJoinNew) ...[
                          Text('New Channel',
                              style: TextStyle(
                                  color: subtitleColor, fontSize: 15)),
                          const SizedBox(height: 16),
                          TextField(
                            controller:
                                TextEditingController(text: newChannelName),
                            decoration: InputDecoration(
                              labelText: 'Channel Name',
                              labelStyle: TextStyle(color: subtitleColor),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            style: TextStyle(color: textColor),
                            onChanged: (val) {
                              setState(() {
                                newChannelName = val;
                              });
                            },
                          ),
                        ] else ...[
                          Text('No similar channels found.',
                              style: TextStyle(
                                  color: subtitleColor, fontSize: 15)),
                          const SizedBox(height: 16),
                          Text('You can only join a new channel at this time.',
                              style: TextStyle(color: subtitleColor)),
                        ],
                      ],
                    ),
                  ),
                ),
                actionsPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: subtitleColor),
                    ),
                  ),
                  if (isJoinNew)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: newChannelName.trim().isNotEmpty
                            ? Colors.blue
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                      ),
                      onPressed: newChannelName.trim().isNotEmpty
                          ? () {
                              joinNewChannel(entityQr!, secQr!, tagid, tagname,
                                  newChannelName);
                              Navigator.of(context).pop();
                            }
                          : null,
                      child: Text('Join',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            );
          },
        ).whenComplete(() {
          // Mark as shown after dialog closes, regardless of how it was closed
          _hasShownValidateSectionPopup = true;
        });
      }
    } catch (e) {
      print("Error in validateSection: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching channel details: $e')),
      );
      // Mark as shown even if error occurs, to prevent repeated popups
      _hasShownValidateSectionPopup = true;
    }
  }

  // void validateSection() async {
  //   secQr = widget.section;
  //   final tagid = widget.tagid;
  //   String? tagname = '';

  //   // Guard: prevent running if already validating or already validated
  //   if (secQr == null || _isValidatingSection || _hasValidatedSection) return;

  //   // Set guard flags
  //   _isValidatingSection = true;

  //   try {
  //     final details = await dashboardController.getChannelDetailsForJoin(
  //       entityId: entityQr!,
  //       channelName: widget.section!,
  //       tagId: widget.tagid!,
  //     );
  //     if (details != null && details["channelDetails"] != null) {
  //       newSecQr = details["channelDetails"]["newChannelName"];
  //       tagname = details["channelDetails"]["tagName"];
  //     }

  //     final exists =
  //         channels.any((channel) => channel['channelname'] == newSecQr);
  //     final index =
  //         channels.indexWhere((channel) => channel['channelname'] == newSecQr);

  //     if (!exists) {
  //       showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           backgroundColor: Colors.grey[900],
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(16),
  //           ),
  //           title: const Text(
  //             'Channel Not Found',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           content: Text(
  //             'Channel "$newSecQr" does not exist in the available channels. Do you want to add it?',
  //             style: const TextStyle(
  //               color: Colors.white70,
  //               fontSize: 14,
  //             ),
  //           ),
  //           actionsPadding:
  //               const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  //           actionsAlignment: MainAxisAlignment.spaceBetween,
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //                 _hasValidatedSection = true; // Mark as validated (user declined)
  //               },
  //               child: const Text(
  //                 'No',
  //                 style: TextStyle(color: Colors.white70),
  //               ),
  //             ),
  //             ElevatedButton(
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.blue,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //                 padding:
  //                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //               ),
  //               onPressed: () {
  //                 joinNewChannel(entityQr!, secQr!, tagid, tagname, newSecQr!);
  //                 Navigator.of(context).pop();
  //                 _hasValidatedSection = true; // Mark as validated after joining
  //               },
  //               child: const Text(
  //                 'Yes',
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ).whenComplete(() {
  //         // Reset guard when dialog closes
  //         _isValidatingSection = false;
  //       });
  //     } else {
  //       // Channel exists
  //       addTagIfNotExist(
  //           oldEntityId: entityQr!,
  //           tagId: tagid!,
  //           oldChannelName: secQr!,
  //           newChannelName: newSecQr!,
  //           tagName: tagname!);
  //       setState(() {
  //         selectedChannelIndex = index;
  //         selectedDocIndex = null;
  //         docs = [];
  //         currentChatMessages = [];
  //       });
  //       fetchDocs(channels[index]["channelname"]);
  //       fetchJoinedTags(channels[index]["channelname"]);
  //       _hasValidatedSection = true; // Mark as validated
  //     }
  //   } finally {
  //     // Always reset the validating flag
  //     _isValidatingSection = false;
  //   }
  // }

  // void addTagIfNotExist(
  //     {required String oldEntityId,
  //     required String tagId,
  //     required String oldChannelName,
  //     required String newChannelName,
  //     required String tagName}) {
  //   dashboardController.addTagIfNotExists(
  //     oldEntityId: oldEntityId,
  //     tagId: tagId,
  //     oldChannelName: oldChannelName,
  //     newChannelName: newChannelName,
  //     tagName: tagName,
  //   );
  // }

  void joinNewChannel(String entityName, String sectionName, String? tagid,
      String? tagname, String? newSecQr) {
    dashboardController
        .joinChannel(entityName, sectionName, tagid, tagname, newSecQr)
        .then((joined) {
      if (joined) {
        // Don't call fetchChannels() here - it will trigger validateSection again
        // Instead, just refresh the channels list without triggering validation
        setState(() {
          secQr = null;
        });

        // Manually fetch channels without triggering stream listener
        dashboardController.fetchChannelsStream().first.then((data) {
          if (mounted) {
            setState(() {
              channels = data;
              // Select the newly joined channel
              final index =
                  channels.indexWhere((c) => c['channelname'] == newSecQr);
                if (index != -1) {
                selectedChannelIndex = index;
                fetchDocs(channels[index]["channelname"]);
              }
            });
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Section "$sectionName" added to channels.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Channel joining failed')),
        );
      }
    });
  }

  // void createTemporaryDocument(Map<String, String> formData) async {
  //   print('Creating temporary document with data: $formData');
  //   String? tagname = '';
  //   final details = await dashboardController.getChannelDetailsForJoin(
  //     entityId: formData['entity']!,
  //     channelName: formData['channel']!,
  //     tagId: formData['tagId']!,
  //   );
  //   if (details != null && details["channelDetails"] != null) {
  //     newSecQr = details["channelDetails"]["newChannelName"];
  //     tagname = details["channelDetails"]["tagName"];
  //   addTagIfNotExist(
  //         oldEntityId: formData['entity']!,
  //         tagId: formData['tagId']!,
  //         oldChannelName: formData['channel']!,
  //         newChannelName: channels[selectedChannelIndex!]["channelname"],
  //         tagName: tagname!);
  //   fetchDocs(channels[selectedChannelIndex!]["channelname"]);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Document created successfully!'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   }
  // }

  void createEncryptedDocument(
    String entityName,
    String channelName,
    String? tagid,
    String submittedData,
  ) async {
    bool joined = await dashboardController.createEncryptedDocument(
      entityName: entityName,
      fromChannelName: channels[selectedChannelIndex!]["channelname"],
      channelName: channelName,
      tagId: tagid,
      submittedData: submittedData,
    );

    if (joined) {
      if (tagid != null) {
        await dashboardController.removeTagById(
          channelName: channels[selectedChannelIndex!]["channelname"],
          tagId: tagid,
        );
      }
  fetchDocs(channels[selectedChannelIndex!]["channelname"]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submitted.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failed')),
      );
    }
  }

  void updateEncryptedEvent(
    String action,
    String docid,
    String submittedData,
    dynamic docRelativeIndex,
  ) async {
    bool isUpdated = await dashboardController.updateEncryptedEvent(
      actionName: action,
      docid: docid,
      submittedData: submittedData,
    );

    if (isUpdated) {
      getDocumentDetails(docid, docRelativeIndex);
      // fetchDocs(channels[selectedChannelIndex!]["channelname"]);
      // fetchJoinedTags(channels[selectedChannelIndex!]["channelname"]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submitted.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failed')),
      );
    }
  }

  void _showCreateChannelDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Create New Channel',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Interconnects section
                    if (publicInterconnects.isNotEmpty) ...[
                      const Text(
                        'Select Interconnect',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            publicInterconnects.map<Widget>((interconnect) {
                          return ChoiceChip(
                            label: Text(
                              interconnect['interconnectname'],
                              style: const TextStyle(fontSize: 13),
                            ),
                            labelStyle: TextStyle(
                              color: selectedInterconnectId ==
                                      interconnect['interconnectid']
                                  ? Colors.white
                                  : Colors.white70,
                            ),
                            selected: selectedInterconnectId ==
                                interconnect['interconnectid'],
                            selectedColor: Colors.blueAccent,
                            backgroundColor: Colors.grey[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (bool selected) async {
                              setState(() {
                                selectedInterconnectId = selected
                                    ? interconnect['interconnectid']
                                    : null;
                                respondentActors = [];
                                selectedActorId = null;
                              });

                              if (selected) {
                                respondentActors = await dashboardController
                                    .getRespondentActors(
                                        selectedInterconnectId!);
                                setState(() {});
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Respondent actors section
                    if (respondentActors.isNotEmpty) ...[
                      const Text(
                        'Select Respondent Actor',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: respondentActors.map<Widget>((actor) {
                          return ChoiceChip(
                            label: Text(
                              actor['actorname'] ?? 'Unnamed',
                              style: const TextStyle(fontSize: 13),
                            ),
                            labelStyle: TextStyle(
                              color:
                                  selectedActorId == actor['actorid'].toString()
                                      ? Colors.white
                                      : Colors.white70,
                            ),
                            selected:
                                selectedActorId == actor['actorid'].toString(),
                            selectedColor: Colors.green,
                            backgroundColor: Colors.grey[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (bool selected) {
                              setState(() {
                                selectedActorId = selected
                                    ? actor['actorid'].toString()
                                    : null;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Channel name input
                    if (selectedActorId != null)
                      TextField(
                        controller: _channelNameController,
                        decoration: InputDecoration(
                          labelText: 'Channel Name',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintText: 'Enter channel name',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.grey[800],
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                  ],
                ),
              ),
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    if (_channelNameController.text.isNotEmpty &&
                        selectedInterconnectId != null &&
                        selectedActorId != null) {
                      dashboardController
                          .createChannel(
                        _channelNameController.text.trim(),
                        selectedActorId!,
                      )
                          .then((created) {
                        if (created) {
                          fetchChannels();
                          Navigator.pop(context);
                        } else {
                          print("Channel creation failed.");
                        }
                      });
                    }
                  },
                  child: const Text(
                    'Create',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateTagDialog(BuildContext context, int index) {
    final TextEditingController tagController = TextEditingController();
    final TextEditingController tagDescriptionController =
        TextEditingController();
    final TextEditingController expireAtController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create New Tag',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: subtitleColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: tagController,
                        decoration: InputDecoration(
                          labelText: 'Tag *',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintText: 'Enter tag (e.g. example-tag)',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.grey[800],
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: tagDescriptionController,
                        decoration: InputDecoration(
                          labelText: 'Tag Description *',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintText: 'Enter tag description',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.grey[800],
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.multiline,
                        minLines: 3,
                        maxLines: null,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: expireAtController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Expire At (Optional)',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintText: 'Select expiration date and time',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.grey[800],
                          suffixIcon: const Icon(Icons.calendar_today,
                              color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              final DateTime combined = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                time.hour,
                                time.minute,
                              );
                              expireAtController.text =
                                  combined.toUtc().toIso8601String();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showChannelOptionsBottomSheet(context, index);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    if (tagController.text.isEmpty ||
                        tagDescriptionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all required fields.'),
                        ),
                      );
                      return;
                    }
                    dashboardController
                        .createTag(
                            tagController.text.trim(),
                            tagDescriptionController.text.trim(),
                            expireAtController.text.trim(),
                            channels[selectedChannelIndex!]["channelname"])
                        .then((created) {
                      if (created) {
                        setState(() {
                          tags.add({
                            "tag": tagController.text.trim(),
                            "description": tagDescriptionController.text.trim(),
                            "expireAt": expireAtController.text.trim(),
                          });
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tag created successfully')),
                        );
                        Navigator.pop(context);
                        _showChannelOptionsBottomSheet(context, index);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('failed')),
                        );
                      }
                    });
                  },
                  child: const Text(
                    'Create',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> fetchDocs(String channelName) async {
    try {
      setState(() {
        isDocsLoading = true;
        docs = [];
        selectedDocIndex = null;
        currentChatMessages = [];
      });

      final docsList = await dashboardController.getDocs(channelName);
      // print('Fetched docs........................................: $docsList');
      setState(() {
        docs = List<Map<String, dynamic>>.from(docsList);
        isDocsLoading = false;
      });
    } catch (e) {
      setState(() {
        isDocsLoading = false;
      });
      print("Error fetching docs: $e");
    }
  }

  // fetchJoinedTags removed - joined tags listing removed from UI

  Future<void> fetchTags(int channelId) async {
    try {
      setState(() {
        isTagsLoading = true;
        tags = [];
        selectedTagIndex = null;
      });
      final tagsList = await dashboardController.getTags(channelId);
      setState(() {
        tags = List<Map<String, dynamic>>.from(tagsList);
        isTagsLoading = false;
      });
    } catch (e) {
      setState(() {
        isTagsLoading = false;
      });
      print("Error fetching Tags: $e");
    }
  }

  Future<void> uploadFile() async {
    // Check if we have valid indices and data before proceeding
    if (selectedChannelIndex == null ||
        selectedDocIndex == null ||
        selectedDocIndex! < 0 ||
        selectedDocIndex! >= docs.length ||
        docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid document first')),
      );
      return;
    }

    String token = await dashboardController.getJwt();
    try {
      // Pick a file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'png',
          'jpg',
          'jpeg',
          'zip'
        ],
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        setState(() {
          isUploading = true;
        });

        // Create form data
        FormData formData = FormData.fromMap({
          "file": await MultipartFile.fromFile(file.path!, filename: file.name),
          "channelName": channels[selectedChannelIndex!]["channelname"],
          "description": docs[selectedDocIndex!]["docname"],
        });
        print(
            "Uploading file: ${file.name} (${(file.size / 1024).toStringAsFixed(1)} KB)");
        print("Form data: $formData");
        // Set headers
        dio.options.headers["Authorization"] = "Bearer $token";
        dio.options.headers["Content-Type"] = "multipart/form-data";

        // Upload file
        final response = await dio.post(
          '$apiUrl/upload',
          data: formData,
          onSendProgress: (int sent, int total) {
            print(
                "Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%");
          },
        );

        if (response.statusCode == 200) {
          // Add a message about the uploaded file
          setState(() {
            currentChatMessages.add({
              "sender": "You",
              "isFile": true,
              "message":
                  "Uploaded file: ${file.name} (${(file.size / 1024).toStringAsFixed(1)} KB)"
            });
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print("Error uploading file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      currentChatMessages.add({"sender": "You", "message": text});
      messageController.clear();
    });
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 30),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
    );
  }

  String appendScriptWithHtml(String html,
      {bool isSubmitButtonNeeded = false}) {
    const messageChannelScript = '''
      // Enhanced form handling with submit trigger support and HTML5 validation
      window.triggerFormSubmit = function() {
        console.log('🚀 Form submit triggered from Flutter');
        
        // Find the form first
        const form = document.querySelector('form');
        if (form) {
          console.log('✅ Found form, checking HTML5 validation...');
          
          // Check HTML5 form validity first
          if (!form.checkValidity()) {
            console.log('❌ Form validation failed, showing validation messages');
            
            // Find the first invalid field and focus it
            const firstInvalidField = form.querySelector(':invalid');
            if (firstInvalidField) {
              firstInvalidField.focus();
              firstInvalidField.reportValidity();
            }
            
            // Report validity for all fields to show validation messages
            form.reportValidity();
            return; // Don't submit if validation fails
          }
          
          console.log('✅ Form validation passed, processing submission...');
          
          // Use the existing processFormData function from formHandlingJS
          if (typeof processFormData === 'function') {
            const nestedData = processFormData(form);
            const quillData = window.quill ? window.quill.root.innerHTML : '';
            if (quillData.trim() !== '') {
              nestedData.quillData = quillData;
            }
            const jsonString = JSON.stringify(nestedData, null, 2);
            console.log('📝 Form data processed:', jsonString);
            
            // Send to Flutter using the existing handler
            if (window.flutter_inappwebview) {
              window.flutter_inappwebview.callHandler('onFormSubmit', jsonString);
            } else {
              window.parent.postMessage({ type: 'onFormSubmit', payload: jsonString }, '*');
            }
          } else {
            // Fallback: trigger form submit event (this will also trigger HTML5 validation)
            console.log('⚠️ processFormData not found, using fallback...');
            const submitEvent = new Event('submit', { bubbles: true, cancelable: true });
            form.dispatchEvent(submitEvent);
          }
        } else {
          console.log('❌ No form found to submit');
          alert('No form found to submit');
        }
      };
      
      // Add CSS for validation states
      const style = document.createElement('style');
      style.textContent = `
        /* HTML5 validation styles */
        input:invalid, textarea:invalid, select:invalid {
          border-color: #dc3545 !important;
          box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.25) !important;
        }
        
        input:valid, textarea:valid, select:valid {
          border-color: #28a745 !important;
        }
        
        /* Custom validation message styles */
        .validation-message {
          color: #dc3545;
          font-size: 0.875rem;
          margin-top: 0.25rem;
          display: block;
        }
        
        /* Highlight required fields */
        input[required]:not(:focus):invalid, 
        textarea[required]:not(:focus):invalid, 
        select[required]:not(:focus):invalid {
          background-color: #fff5f5;
        }
      `;
      document.head.appendChild(style);
      
      // Set up ready signal
      console.log('🔧 Submit trigger function ready');
      if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler('setupMessageChannel', 'ready');
      } else {
        window.parent.postMessage({ type: 'setupMessageChannel', payload: 'ready' }, '*');
      }
    ''';

    if (isSubmitButtonNeeded) {
      return "$html<script>${dashboardController.formHandlingJS}</script><script>$messageChannelScript</script>";
    } else {
      return "$html<script>${dashboardController.formHandlingJS}</script>";
    }
  }

  void _handleAction(String action, String fileName, String html) {
    InAppWebViewController? webViewController; // Store the webview controller
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            action,
            style: TextStyle(color: textColor),
          ),
          backgroundColor: surfaceColor,
          content: SizedBox(
            width: 400,
            height: 100,
            child: InAppWebView(
              initialData: InAppWebViewInitialData(
                  data: appendScriptWithHtml(html, isSubmitButtonNeeded: true)),
              onWebViewCreated: (controller) {
                webViewController = controller; // Store controller reference
                if (!kIsWeb) {
                  controller.addJavaScriptHandler(
                    handlerName: 'setupMessageChannel',
                    callback: (args) {
                      print('✅ Submit trigger setup complete: ${args[0]}');
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'onFormChange',
                    callback: (args) async {
                      String jsonString = args[0];
                      print('Form changed: $jsonString');
                      // Handle the form change - update preview, validate, etc.
                    },
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'onFormSubmit',
                    //aaaaaaaaaaaaaaaaa
                    callback: (args) {
                      String jsonString = args[0];
                      print('Received JSON string: $jsonString');
                      // Add bounds checking before accessing docs array
                      if (selectedDocIndex != null &&
                          selectedDocIndex! >= 0 &&
                          selectedDocIndex! < docs.length) {
                        updateEncryptedEvent(
                            action,
                            docs[selectedDocIndex!]["docid"],
                            jsonString,
                            selectedDocIndex);
                      } else {
                        print(
                            'Error: Invalid selectedDocIndex when handling form submit');
                      }
                    },
                  );
                } else {
                  handleWebMessage();
                }
              },
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Trigger form submission using the global function
                if (webViewController != null) {
                  try {
                    await webViewController!.evaluateJavascript(source: '''
                        console.log('🎯 Submit button clicked from Flutter');
                        if (typeof window.triggerFormSubmit === 'function') {
                          window.triggerFormSubmit();
                        } else {
                          console.log('⚠️ triggerFormSubmit function not ready, using fallback...');
                          // Fallback to direct form submission
                          var form = document.querySelector('form');
                          if (form) {
                            console.log('📋 Found form, dispatching submit event...');
                            var submitEvent = new Event('submit', { bubbles: true, cancelable: true });
                            form.dispatchEvent(submitEvent);
                          } else {
                            console.log('❌ No form found');
                            alert('No form found to submit');
                          }
                        }
                      ''');

                    // Show user feedback
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(
                    //     content: Text('Form submission triggered'),
                    //     backgroundColor: Colors.blue,
                    //   ),
                    // );
                  } catch (e) {
                    print('Error triggering form submission: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error triggering form submission: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('WebView not ready. Please wait and try again.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void showQrDialog(BuildContext context, String qrData, int index) {
    print('QR Data..................: $qrData index: $index');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: surfaceColor,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  qrData,
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  height: 300,
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: qrData));
                Navigator.of(context).pop();
                _showChannelOptionsBottomSheet(context, index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('URL copied: $qrData'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text('Copy', style: TextStyle(color: primaryAccent)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showChannelOptionsBottomSheet(context, index);
              },
              child: Text('Close', style: TextStyle(color: subtitleColor)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showComposeDialog(BuildContext context, {bool autoSearch = false}) async {
    // Persistent dialog state
    List<dynamic> pubChannels = [];
    bool isSearching = false;
    bool hasSearched = false;
    int? selectedChannelIndexLocal;
    List<dynamic> pubTags = [];
    int? selectedTagIndexLocal;
    bool showWebView = false;
    Map<String, dynamic>? selectedTagData;
    bool isLoadingTags = false;
    bool isViewDocumentOpen = false; // Track if View Document dialog is open
    ScrollController scrollController =
        ScrollController(); // Add scroll controller
    InAppWebViewController?
        webViewController; // Add WebView controller reference
    InAppWebViewController?
        previewWebViewController; // Add WebView controller for preview
    String lastRenderedJson =
        ""; // Track last rendered JSON to avoid unnecessary reloads
  // Guard to ensure autoSearch runs only once while this compose dialog is open
  bool hasTriggeredAutoSearch = false;

    // mark dialog as open
    if (mounted) {
      setState(() {
        _isComposeDialogOpen = true;
      });
    }

    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing on outside click
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Future<void> fetchChannelTags(int channelIdx, {String? autoSelectTagId}) async {
              setState(() {
                pubTags = [];
                selectedTagIndexLocal = null;
                isLoadingTags = true;
              });
              final channel = pubChannels[channelIdx];
              final channelName = channel['channelname'] ?? channel.toString();
              final entity = _entityController.text.trim();
              try {
                final tags = await dashboardController.getPubChannelTags(
                    entity, channelName);
                setState(() {
                  pubTags = tags;
                  isLoadingTags = false;
                });

                // If an auto-select tag id was provided, try to select it
                if (autoSelectTagId != null && autoSelectTagId.isNotEmpty) {
                  try {
                    final matchedIdx = pubTags.indexWhere((t) {
                      final tid = (t['tagid'] ?? t['tagId'] ?? t['id'] ?? '').toString();
                      return tid == autoSelectTagId.toString();
                    });
                    if (matchedIdx != -1) {
                      final tag = pubTags[matchedIdx];
                      final tagId = tag['tagid'] ?? tag['tagId'] ?? 'Unknown TagID';
                      final channelNameLocal = channelName;
                      final entityName = _entityController.text.trim();
                      // Fetch context data asynchronously
                      final contextData = await dashboardController.getContextAndPublicKey(
                          entityName, channelNameLocal, tagId);
                      if (contextData != null && contextData["contextform"] != null) {
                        htmlForm = contextData["contextform"];
                        htmlTheme = contextData['contexttemplate'] ?? '';
                      }
                      if (mounted) {
                        setState(() {
                          selectedTagIndexLocal = matchedIdx;
                          showWebView = true;
                          selectedTagData = tag;
                        });
                      }
                    }
                  } catch (_) {
                    // ignore auto-select tag errors
                  }
                }
              } catch (e) {
                setState(() {
                  isLoadingTags = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error fetching tags: $e')),
                );
              }
            }

            Future<void> searchPubChannels({bool triggeredByAuto = false}) async {
              final entity = _entityController.text.trim();
              if (entity.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter an entity name.')),
                );
                return;
              }
              final int actorId =
                  channels[selectedChannelIndex!]["initialactorid"];
              setState(() {
                isSearching = true;
                hasSearched = false;
                pubTags = [];
                selectedTagIndexLocal = null;
                selectedChannelIndexLocal = null;
              });
              try {
                final result =
                    await dashboardController.getPubChannels(entity, actorId);

                // Prepare local copies and derived values so we can update state
                final List<dynamic> foundChannels = result;
                // Update UI state synchronously
                setState(() {
                  pubChannels = foundChannels;
                  isSearching = false;
                  hasSearched = true;
                  selectedTagIndexLocal = null;
                  selectedChannelIndexLocal = (foundChannels.length == 1) ? 0 : null;
                });

                // If this search was triggered by auto-open, try to auto-select the channel
                // only when the outer `secQr` value exists in the returned public channels.
                if (triggeredByAuto && secQr != null && secQr!.isNotEmpty) {
                  try {
                    final String target = secQr!.toString();
                    final pubIdx = foundChannels.indexWhere((c) => ((c['channelname'] ?? c.toString()) .toString()) == target);
                      if (pubIdx != -1) {
                      // Select in compose dialog
                      if (mounted) {
                        setState(() {
                          selectedChannelIndexLocal = pubIdx;
                          _composeChannelController.text = target;
                        });
                      }

                      // If that public channel maps to a local channel, select it and fetch docs/tags
                      final localIdx = channels.indexWhere((c) => ((c['channelname'] ?? '').toString()) == target);
                      if (localIdx != -1) {
                        if (mounted) {
                          setState(() {
                            selectedChannelIndex = localIdx;
                            selectedDocIndex = null;
                            docs = [];
                            currentChatMessages = [];
                          });
                        }
                          try {
                          await fetchDocs(channels[localIdx]["channelname"]);
                        } catch (_) {
                          // ignore fetch errors
                        }
                      }

                      // Fetch tags for the selected pub channel, and if widget.tagid is present try to auto-select that tag
                      try {
                        await fetchChannelTags(pubIdx, autoSelectTagId: widget.tagid);
                      } catch (_) {}
                    }
                  } catch (_) {
                    // ignore auto-select errors
                  }
                } else {
                  // Not an auto-invocation or secQr not present: if exactly one channel found,
                  // prefill compose controller but don't auto-change parent selection.
                  if (foundChannels.length == 1) {
                    final autoChannelName = foundChannels[0]['channelname'] ?? foundChannels[0].toString();
                    if (mounted) {
                      setState(() {
                        _composeChannelController.text = autoChannelName;
                        selectedChannelIndexLocal = 0;
                      });
                    }
                    try {
                      await fetchChannelTags(0);
                    } catch (_) {}
                  }
                }
              } catch (e) {
                setState(() {
                  isSearching = false;
                  hasSearched = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error fetching channels: $e')),
                );
              }
            }

            // If dialog was opened with autoSearch request, trigger search after build
            if (autoSearch && !hasTriggeredAutoSearch) {
              hasTriggeredAutoSearch = true; // ensure it runs only once
              // Defer to next microtask so controllers are ready in the dialog
              Future.microtask(() {
                // Only trigger if there's an entity present
                if (_entityController.text.trim().isNotEmpty) {
                  searchPubChannels(triggeredByAuto: true);
                } else {
                  // If entity is empty but _searchController has value, copy it
                  if (_searchController.text.trim().isNotEmpty) {
                    _entityController.text = _searchController.text.trim();
                    searchPubChannels(triggeredByAuto: true);
                  }
                }
              });
            }

            // Responsive layout calculations
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final isMobile = screenWidth < 900; // Mobile breakpoint
            // Responsive width: use 95% on mobile, scale between 780-95% on desktop based on screen size
            final dialogWidth = isMobile
                ? screenWidth * 0.95
                : (screenWidth > 1400 ? 780.0 : screenWidth * 0.56)
                    .clamp(600.0, 780.0);

            // Desktop: side by side, Mobile: full screen scrollable
            final createDocTop = isMobile ? 20.0 : 50.0;
            final createDocLeft = isMobile
                ? (screenWidth - dialogWidth) / 2
                : (isViewDocumentOpen ? 20.0 : (screenWidth - dialogWidth) / 2);

            final previewTop = isMobile
                ? screenHeight + 40 // Below viewport - need to scroll to see
                : 50.0; // Same top position as Create New Document on desktop
            final previewRight =
                isMobile ? null : 20.0; // Match the right margin
            final previewLeft = isMobile
                ? (screenWidth - dialogWidth) / 2 // Centered on mobile
                : (screenWidth -
                    dialogWidth -
                    20.0); // Positioned on right with margin on desktop

            final stackContent = Stack(
              children: [
                Positioned(
                  top: createDocTop,
                  left: createDocLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: dialogWidth,
                      constraints: BoxConstraints(
                        maxHeight: isMobile
                            ? screenHeight - 100 // Full height on mobile
                            : screenHeight - 100,
                      ),
                      child: AlertDialog(
                        backgroundColor: surfaceColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          'Create New Document',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 800,
                            maxHeight: showWebView ? 1200 : 500,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Entity field with search button
                                SizedBox(
                                  width: 700,
                                  child: TextField(
                                    controller: _entityController,
                                    decoration: InputDecoration(
                                      labelText: 'Entity *',
                                      labelStyle: const TextStyle(
                                          color: Colors.white70),
                                      hintText: 'Enter entity name',
                                      hintStyle: const TextStyle(
                                          color: Colors.white54),
                                      filled: true,
                                      fillColor: Colors.grey[800],
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.blue),
                                      ),
                                      suffixIcon: isSearching
                                          ? const Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white),
                                              ),
                                            )
                                          : Container(
                                              margin: const EdgeInsets.all(8.0),
                                              child: Material(
                                                color:
                                                    (isSearching || hasSearched)
                                                        ? Colors.grey[600]
                                                        : Colors.blueAccent,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  onTap: (isSearching ||
                                                          hasSearched)
                                                      ? null
                                                      : searchPubChannels,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: const Icon(
                                                      Icons.search,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                    enabled: !isSearching && !hasSearched,
                                    onSubmitted: (_) {
                                      if (!isSearching && !hasSearched)
                                        searchPubChannels();
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // After search, show channels or no match
                                if (hasSearched)
                                  pubChannels.isEmpty
                                      ? const Text('No matching channel found',
                                          style: TextStyle(
                                              color: Colors.redAccent))
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                pubChannels.length == 1
                                                    ? 'Channel Auto-Selected:'
                                                    : 'Select Channel:',
                                                style: TextStyle(
                                                    color:
                                                        pubChannels.length == 1
                                                            ? Colors.green
                                                            : Colors.white70,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(height: 12),
                                            Wrap(
                                              spacing: 10,
                                              runSpacing: 10,
                                              children: pubChannels
                                                  .asMap()
                                                  .entries
                                                  .map((entry) {
                                                final idx = entry.key;
                                                final channel = entry.value;
                                                final channelName =
                                                    channel['channelname'] ??
                                                        channel.toString();
                                                final isSelected =
                                                    selectedChannelIndexLocal ==
                                                        idx;
                                                final description = channel[
                                                        'channeldescription'] ??
                                                    '';
                                                return Tooltip(
                                                  message:
                                                      description.isNotEmpty
                                                          ? description
                                                          : channelName,
                                                  child: ChoiceChip(
                                                    label: Text(channelName,
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color: isSelected
                                                                ? Colors.white
                                                                : Colors
                                                                    .white70)),
                                                    labelStyle: TextStyle(
                                                      color: isSelected
                                                          ? Colors.white
                                                          : Colors.white70,
                                                    ),
                                                    selected: isSelected,
                                                    selectedColor:
                                                        Colors.blueAccent,
                                                    backgroundColor:
                                                        Colors.grey[700],
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    onSelected:
                                                        (bool selected) {
                                                      setState(() {
                                                        if (selected) {
                                                          selectedChannelIndexLocal =
                                                              idx;
                                                          _composeChannelController
                                                                  .text =
                                                              channelName;
                                                          fetchChannelTags(idx);
                                                          // Hide InAppWebView when channel changes
                                                          showWebView = false;
                                                          selectedTagIndexLocal =
                                                              null;
                                                          selectedTagData =
                                                              null; // Clear selected tag data
                                                        } else {
                                                          selectedChannelIndexLocal =
                                                              null;
                                                          pubTags = [];
                                                          selectedTagIndexLocal =
                                                              null;
                                                          selectedTagData =
                                                              null; // Clear selected tag data
                                                          // Hide InAppWebView when channel deselected
                                                          showWebView = false;
                                                        }
                                                      });
                                                    },
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                        ),

                                // Tag selection chips and Create button only after channel selected
                                if (hasSearched &&
                                    pubChannels.isNotEmpty &&
                                    selectedChannelIndexLocal != null) ...[
                                  Row(
                                    children: [
                                      const Text('Select Tag:',
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontWeight: FontWeight.bold)),
                                      if (isLoadingTags)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8.0),
                                          child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white70),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (pubTags.isEmpty && !isLoadingTags)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                            'No tags found for this channel',
                                            style: TextStyle(
                                                color: Colors.redAccent)),
                                        const SizedBox(height: 8),
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            // Get context data without tag
                                            final entityName =
                                                _entityController.text.trim();
                                            final channelName =
                                                selectedChannelIndexLocal !=
                                                        null
                                                    ? pubChannels[
                                                                selectedChannelIndexLocal!]
                                                            ['channelname'] ??
                                                        'Unknown Channel'
                                                    : 'Unknown Channel';

                                            print(
                                                'Sending without tag for channel: $channelName');
                                            print('Entity Name: $entityName');

                                            // Fetch context data without tagId
                                            final contextData =
                                                await dashboardController
                                                    .getContextAndPublicKey(
                                                        entityName,
                                                        channelName,
                                                        null);

                                            if (contextData != null) {
                                              if (contextData["contextform"] !=
                                                  null) {
                                                htmlForm =
                                                    contextData["contextform"];
                                                print(
                                                    "Context form found, rendering without tag...");
                                                setState(() {
                                                  showWebView = true;
                                                  selectedTagData =
                                                      null; // No tag selected
                                                });
                                              } else {
                                                print(
                                                    "No context template found for this channel.");
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'No form template available for this channel')),
                                                );
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Failed to fetch channel data')),
                                              );
                                            }
                                          },
                                          icon:
                                              const Icon(Icons.send, size: 16),
                                          label: const Text('Send without tag'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (isLoadingTags)
                                    const Text(
                                        'Loading tags for auto-selected channel...',
                                        style:
                                            TextStyle(color: Colors.white54)),
                                  if (pubTags.isNotEmpty)
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children:
                                          pubTags.asMap().entries.map((entry) {
                                        final idx = entry.key;
                                        final tag = entry.value;
                                        final tagName = tag['tag'] ??
                                            tag['tagName'] ??
                                            tag['tagid']?.toString() ??
                                            'Tag';
                                        final tagDescription =
                                            tag['tagdescription'] ??
                                                tag['tagDescription'] ??
                                                '';
                                        final isSelected =
                                            selectedTagIndexLocal == idx;
                                        return Tooltip(
                                          message: tagDescription.isNotEmpty
                                              ? tagDescription
                                              : tagName,
                                          child: ChoiceChip(
                                            label: Text(tagName,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Colors.white70)),
                                            labelStyle: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.white70,
                                            ),
                                            selected: isSelected,
                                            selectedColor: Colors.green,
                                            backgroundColor: Colors.grey[700],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            onSelected: (bool selected) async {
                                              if (selected) {
                                                final tagId = tag['tagid'] ??
                                                    tag['tagId'] ??
                                                    'Unknown TagID';
                                                final channelName =
                                                    selectedChannelIndexLocal !=
                                                            null
                                                        ? pubChannels[
                                                                    selectedChannelIndexLocal!]
                                                                [
                                                                'channelname'] ??
                                                            'Unknown Channel'
                                                        : 'Unknown Channel';
                                                final entityName =
                                                    _entityController.text
                                                        .trim();
                                                print('Selected tag: $tagName');
                                                print('Tag ID: $tagId');
                                                print(
                                                    'Channel Name: $channelName');
                                                print(
                                                    'Entity Name: $entityName');

                                                // Fetch context data asynchronously
                                                final contextData =
                                                    await dashboardController
                                                        .getContextAndPublicKey(
                                                            entityName,
                                                            channelName,
                                                            tagId);
                                                // print("Context Data: $contextData");
                                                if (contextData != null) {
                                                  if (contextData[
                                                          "contextform"] !=
                                                      null) {
                                                    htmlForm = contextData[
                                                        "contextform"];
                                                    htmlTheme = contextData[
                                                        'contexttemplate'];
                                                    print(
                                                        "Context form found, rendering...");
                                                  } else {
                                                    print(
                                                        "No context template found for this tag.");
                                                  }
                                                }
                                                setState(() {
                                                  selectedTagIndexLocal = idx;
                                                  showWebView = true;
                                                  selectedTagData =
                                                      tag; // Store the selected tag data
                                                });
                                              } else {
                                                setState(() {
                                                  selectedTagIndexLocal = null;
                                                  showWebView = false;
                                                  selectedTagData =
                                                      null; // Clear selected tag data
                                                });
                                                print('Tag deselected');
                                              }
                                            },
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  const SizedBox(height: 16),
                                ],

                                // Show InAppWebView below tag selection when a tag is selected
                                if (showWebView) ...[
                                  Container(
                                    height: 530,
                                    margin: const EdgeInsets.only(
                                        top: 16, right: 20),
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.grey[600]!),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: InAppWebView(
                                            initialData:
                                                InAppWebViewInitialData(
                                              data: appendScriptWithHtml(
                                                  htmlForm,
                                                  isSubmitButtonNeeded: true),
                                            ),
                                            onWebViewCreated: (controller) {
                                              webViewController =
                                                  controller; // Store controller reference
                                              print(
                                                  '🔧 WebView controller stored successfully');
                                              if (!kIsWeb) {
                                                // Add handler for MessageChannel setup
                                                controller.addJavaScriptHandler(
                                                  handlerName:
                                                      'setupMessageChannel',
                                                  callback: (args) {
                                                    print(
                                                        '✅ Submit trigger setup complete: ${args[0]}');
                                                  },
                                                );
                                                controller.addJavaScriptHandler(
                                                  handlerName: 'onFormChange',
                                                  callback: (args) async {
                                                    String jsonString = args[0];
                                                    setState(() {
                                                      updatedJson = jsonString;
                                                    });
                                                    // Update preview WebView smoothly without rebuild
                                                    if (previewWebViewController !=
                                                            null &&
                                                        htmlTheme.isNotEmpty &&
                                                        jsonString.isNotEmpty &&
                                                        jsonString != "{}" &&
                                                        jsonString !=
                                                            lastRenderedJson) {
                                                      try {
                                                        final rendered =
                                                            await renderResume(
                                                                jsonString);
                                                        await previewWebViewController!
                                                            .loadData(
                                                          data: rendered,
                                                          baseUrl: WebUri(
                                                              'about:blank'),
                                                        );
                                                        lastRenderedJson =
                                                            jsonString;
                                                      } catch (e) {
                                                        print(
                                                            'Error updating preview on form change: $e');
                                                      }
                                                    }
                                                    // print('Form changed: $jsonString');
                                                    // Handle the form change - update preview, validate, etc.
                                                  },
                                                );
                                                controller.addJavaScriptHandler(
                                                  handlerName: 'onFormSubmit',
                                                  callback: (args) {
                                                    String jsonString = args[0];
                                                    print(
                                                        'Received JSON string: $jsonString');
                                                    // Add bounds checking before accessing joinedTags array
                                                    if (jsonString.isNotEmpty) {
                                                      final entityName =
                                                          _entityController.text
                                                              .trim();
                                                      final channelName =
                                                          selectedChannelIndexLocal !=
                                                                  null
                                                              ? pubChannels[
                                                                          selectedChannelIndexLocal!]
                                                                      [
                                                                      'channelname'] ??
                                                                  'Unknown Channel'
                                                              : 'Unknown Channel';
                                                      final tagId = selectedTagData !=
                                                              null
                                                          ? (selectedTagData![
                                                                      'tagid'] ??
                                                                  selectedTagData![
                                                                      'tagId'] ??
                                                                  'Unknown TagID')
                                                              .toString()
                                                          : null; // Pass null when no tag selected
                                                      print(
                                                          'Entity Name: $entityName');
                                                      print(
                                                          'Channel Name: $channelName');
                                                      print('Tag ID: $tagId');
                                                      createEncryptedDocument(
                                                          entityName,
                                                          channelName,
                                                          tagId,
                                                          jsonString);
                                                    } else {
                                                      print(
                                                          'Error: Invalid selectedjoinedTagIndex when handling form submit');
                                                    }
                                                  },
                                                );
                                              } else {
                                                handleWebMessage();
                                              }
                                            },
                                          ),
                                        ),
                                        // Floating close button
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: FloatingActionButton(
                                            mini: true,
                                            backgroundColor:
                                                Colors.red.withOpacity(0.8),
                                            onPressed: () {
                                              setState(() {
                                                showWebView = false;
                                                selectedTagIndexLocal = null;
                                                selectedTagData =
                                                    null; // Clear selected tag data
                                              });
                                            },
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                        // Floating View Document button
                                        Positioned(
                                          top: 8,
                                          right:
                                              60, // Position to the left of close button
                                          child: FloatingActionButton(
                                            mini: true,
                                            backgroundColor:
                                                Colors.blue.withOpacity(0.8),
                                            onPressed: () {
                                              setState(() {
                                                isViewDocumentOpen =
                                                    !isViewDocumentOpen;
                                              });
                                            },
                                            child: const Icon(
                                              Icons.visibility,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ],
                            ),
                          ), // ConstrainedBox child
                        ), // ConstrainedBox
                        actionsPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        actionsAlignment: MainAxisAlignment.spaceBetween,
                        actions: [
                          // Cancel button - always on the left
                          TextButton(
                            onPressed: () {
                              // Reset updatedJson when closing the dialog (using main setState)
                              this.setState(() {
                                updatedJson = "{}";
                              });
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          // Right side buttons wrapped in Row
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Reset button - only show if search has been performed
                              if (hasSearched)
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      // Reset all local state for a new search
                                      isSearching = false;
                                      hasSearched = false;
                                      pubChannels = [];
                                      selectedChannelIndexLocal = null;
                                      pubTags = [];
                                      selectedTagIndexLocal = null;
                                      selectedTagData =
                                          null; // Clear selected tag data
                                      _entityController.clear();
                                      _composeChannelController.clear();
                                      // Hide InAppWebView when reset is clicked
                                      showWebView = false;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                  child: const Text(
                                    'Reset',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              // Add spacing between Reset and Submit buttons
                              if (hasSearched && showWebView)
                                const SizedBox(width: 12),
                              // Submit button - only show when WebView is visible
                              if (showWebView)
                                ElevatedButton(
                                  onPressed: () async {
                                    // Trigger form submission using the global function
                                    if (webViewController != null) {
                                      try {
                                        await webViewController!
                                            .evaluateJavascript(source: '''
                                  console.log('🎯 Submit button clicked from Flutter');
                                  if (typeof window.triggerFormSubmit === 'function') {
                                    window.triggerFormSubmit();
                                  } else {
                                    console.log('⚠️ triggerFormSubmit function not ready, using fallback...');
                                    // Fallback to direct form submission
                                    var form = document.querySelector('form');
                                    if (form) {
                                      console.log('📋 Found form, dispatching submit event...');
                                      var submitEvent = new Event('submit', { bubbles: true, cancelable: true });
                                      form.dispatchEvent(submitEvent);
                                    } else {
                                      console.log('❌ No form found');
                                      alert('No form found to submit');
                                    }
                                  }
                                ''');

                                        // Show user feedback
                                        // ScaffoldMessenger.of(context).showSnackBar(
                                        //   const SnackBar(
                                        //     content: Text('Form submission triggered'),
                                        //     backgroundColor: Colors.blue,
                                        //   ),
                                        // );
                                      } catch (e) {
                                        print(
                                            'Error triggering form submission: $e');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Error triggering form submission: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'WebView not ready. Please wait and try again.'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                  child: const Text(
                                    'Submit',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ), // AlertDialog
                    ),
                  ),
                ),
                // View Document Dialog - shown conditionally
                if (isViewDocumentOpen)
                  Positioned(
                    top: previewTop,
                    right: previewRight,
                    left: previewLeft,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width:
                            dialogWidth, // Same width as Create New Document dialog
                        constraints: BoxConstraints(
                          maxHeight: isMobile
                              ? screenHeight - 100 // Full height on mobile
                              : screenHeight -
                                  100, // Same height as Create New Document dialog
                        ),
                        child: AlertDialog(
                          backgroundColor: surfaceColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            'Document Preview',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: htmlTheme.isNotEmpty
                              ? SizedBox(
                                  width:
                                      800, // Match the width constraint from Create New Document
                                  height: isMobile
                                      ? screenHeight *
                                          0.75 // 75% height on mobile for good viewing
                                      : 1200, // Match the height from Create New Document when showWebView is true
                                  child: InAppWebView(
                                    key: ValueKey(
                                        'preview_webview'), // Stable key to prevent recreation
                                    initialData: InAppWebViewInitialData(
                                      data:
                                          '', // Start with empty, will update via controller
                                    ),
                                    onWebViewCreated: (controller) async {
                                      previewWebViewController = controller;
                                      // Load initial content if available
                                      if (updatedJson.isNotEmpty &&
                                          updatedJson != "{}") {
                                        try {
                                          final rendered =
                                              await renderResume(updatedJson);
                                          await controller.loadData(
                                            data: rendered,
                                            baseUrl: WebUri('about:blank'),
                                          );
                                          lastRenderedJson = updatedJson;
                                        } catch (e) {
                                          print(
                                              'Error rendering initial preview: $e');
                                        }
                                      }
                                    },
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    'No form data available yet. Please fill in the form.',
                                    style: TextStyle(color: subtitleColor),
                                  ),
                                ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isViewDocumentOpen = false;
                                });
                              },
                              child: const Text(
                                'Close',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ); // Stack

            // Wrap in SingleChildScrollView for mobile to allow scrolling between dialogs
            return isMobile
                ? SingleChildScrollView(
                    controller: scrollController,
                    child: SizedBox(
                      height: isViewDocumentOpen
                          ? screenHeight * 2 +
                              100 // Double height when both dialogs shown
                          : screenHeight,
                      child: stackContent,
                    ),
                  )
                : stackContent; // Desktop: just return the Stack
          },
        );
      },
    ).whenComplete(() {
      // reset open flag when dialog closes
      if (mounted) {
        setState(() {
          _isComposeDialogOpen = false;
        });
      }
    });
  }

  // Fallback renderer that creates a simple HTML table from JSON
  String _createFallbackHtml(Map<String, dynamic> jsonData) {
    final buffer = StringBuffer();
    buffer.write('''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            max-width: 900px;
            margin: 20px auto;
            padding: 20px;
            background: #f9f9f9;
          }
          .document-container {
            background: white;
            border-radius: 8px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
          }
          h1 { color: #333; margin-top: 0; }
          h2 { color: #555; border-bottom: 2px solid #e0e0e0; padding-bottom: 8px; }
          .section { margin: 20px 0; }
          .field { margin: 10px 0; padding: 8px; background: #f5f5f5; border-radius: 4px; }
          .field-label { font-weight: bold; color: #666; }
          .field-value { color: #333; margin-left: 10px; }
          .array-item { border-left: 3px solid #2196f3; padding-left: 15px; margin: 10px 0; }
          .warning {
            background: #fff3cd;
            border: 1px solid #ffc107;
            padding: 12px;
            border-radius: 4px;
            margin-bottom: 20px;
          }
        </style>
      </head>
      <body>
        <div class="document-container">
     
    ''');

    void renderValue(String key, dynamic value, int depth) {
      if (value == null) return;

      if (value is Map) {
        buffer.write('<div class="section">');
        buffer.write(
            '<h${(depth + 2).clamp(2, 6)}>${key.replaceAll('_', ' ').toUpperCase()}</h${(depth + 2).clamp(2, 6)}>');
        value.forEach((k, v) => renderValue(k.toString(), v, depth + 1));
        buffer.write('</div>');
      } else if (value is List) {
        buffer.write('<div class="section">');
        buffer.write(
            '<h${(depth + 2).clamp(2, 6)}>${key.replaceAll('_', ' ').toUpperCase()}</h${(depth + 2).clamp(2, 6)}>');
        for (var i = 0; i < value.length; i++) {
          buffer.write('<div class="array-item">');
          renderValue('Item ${i + 1}', value[i], depth + 1);
          buffer.write('</div>');
        }
        buffer.write('</div>');
      } else {
        buffer.write('<div class="field">');
        buffer.write(
            '<span class="field-label">${key.replaceAll('_', ' ')}:</span>');
        buffer.write('<span class="field-value">${value.toString()}</span>');
        buffer.write('</div>');
      }
    }

    jsonData.forEach((key, value) => renderValue(key, value, 0));

    buffer.write('''
        </div>
      </body>
      </html>
    ''');

    return buffer.toString();
  }

  Future<String> renderResume(String jsonContent) async {
    print('🔄 Starting renderResume with Liquid...');

    try {
      final raw = htmlTheme;

      // Validate inputs
      if (raw.isEmpty) {
        print('❌ HTML theme is empty - using fallback');
        final jsonData = jsonDecode(jsonContent);
        return _createFallbackHtml(jsonData);
      }

      if (jsonContent.isEmpty || jsonContent == "{}") {
        print('❌ JSON content is empty - using fallback');
        return _createFallbackHtml({});
      }

      print(
          '📋 JSON length: ${jsonContent.length}, Template length: ${raw.length}');

      // Parse JSON safely
      final Map<String, dynamic> jsonData = jsonDecode(jsonContent);
      print('✅ JSON parsed successfully');

      // Try rendering with timeout protection
      print('🎨 Creating Liquid template context...');
      try {
        final context = Context.create();
        context.variables = jsonData;

        print('🚀 Parsing and rendering template...');
        final template = Template.parse(context, Source.fromString(raw));
        final result = await template.render(context).timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            print('⏱️ Rendering timed out');
            throw TimeoutException('Template rendering timeout');
          },
        );

        print('✅ Template rendered successfully (${result.length} chars)');
        return result;
      } on StackOverflowError catch (e) {
        print('❌ Stack Overflow detected: $e');
        print('🔧 Template too complex - using fallback renderer');
        return _createFallbackHtml(jsonData);
      } on TimeoutException catch (e) {
        print('⏱️ Timeout: $e');
        print('🔧 Using fallback renderer');
        return _createFallbackHtml(jsonData);
      } catch (e) {
        print('❌ Rendering error: $e');
        print('🔧 Using fallback renderer');
        return _createFallbackHtml(jsonData);
      }
    } on FormatException catch (e) {
      print('❌ JSON parsing error: $e');
      return '<html><body style="font-family: sans-serif; padding: 40px;"><h1 style="color: #d32f2f;">Error: Invalid JSON format</h1><p>$e</p></body></html>';
    } catch (e) {
      print('❌ Unexpected error: $e');
      try {
        final jsonData = jsonDecode(jsonContent);
        return _createFallbackHtml(jsonData);
      } catch (_) {
        return '''
          <html>
          <body style="font-family: sans-serif; padding: 40px; max-width: 800px; margin: 0 auto;">
            <h1 style="color: #d32f2f;">⚠️ Error rendering document</h1>
            <p><strong>Error:</strong> $e</p>
            <hr>
            <h3>Solution:</h3>
            <p><strong>Your template is too complex for the Liquid engine in release mode.</strong></p>
            <p>Please simplify your template or break it into smaller sections.</p>
            <p>Template size: ${htmlTheme.length} characters (recommended: < 30,000)</p>
          </body>
          </html>
        ''';
      }
    }
  }

  void showHtmlPopup(BuildContext context, String jsonContent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          backgroundColor: surfaceColor,
          child: SizedBox(
            width: double.infinity,
            height: 800,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: primaryAccent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Document Preview",
                          style: TextStyle(color: Colors.white)),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<String>(
                    future: renderResume(jsonContent), // ✅ call async function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 48, color: Colors.red),
                                const SizedBox(height: 16),
                                Text(
                                  'Error rendering document',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${snapshot.error}',
                                  style: TextStyle(color: subtitleColor),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    // Print debug info
                                    print('JSON Content: $jsonContent');
                                    print(
                                        'HTML Theme length: ${htmlTheme.length}');
                                  },
                                  child: const Text('Show Debug Info'),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return InAppWebView(
                          initialData: InAppWebViewInitialData(
                            data: snapshot.data!,
                          ),
                        );
                      }
                    },
                  ),
                ),
                // Expanded(
                //   child: InAppWebView(
                //     initialData: InAppWebViewInitialData(
                //       data: renderResume(jsonContent,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChannelOptionsBottomSheet(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // if (selectedChannelIndex != null &&
            //     channels[selectedChannelIndex!]["actorsequence"] == 1)
            //   ListTile(
            //     leading: Icon(Icons.qr_code, color: textColor),
            //     title: Text(
            //       'Show QR Code for ${channels[index]["channelname"]}',
            //       style: TextStyle(color: textColor),
            //     ),
            //     onTap: () {
            //       Navigator.pop(context);
            //       String qrData = createQrUrl(
            //         entity: selectedEntity,
            //         channel: channels[index]["channelname"],
            //       );
            //       showQrDialog(context, qrData, index);
            //     },
            //   ),
            // const SizedBox(height: 10),

            // Create Tag Button
            if (selectedChannelIndex != null &&
                channels[selectedChannelIndex!]["actorsequence"] == 1)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Create Tag',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _showCreateTagDialog(context, index);
                },
              ),

            // Tags List
            if (tags.isNotEmpty)
              ...tags.asMap().entries.map((entry) {
                var tag = entry.value;
                return ListTile(
                  leading: Icon(Icons.label, color: subtitleColor),
                  title: Text(
                    tag["tag"],
                    style: TextStyle(color: subtitleColor),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    String qrData = createQrUrl(
                      entity: selectedEntity,
                      channel: channels[index]["channelname"],
                      tagId: tag["channeltagid"]?.toString(),
                    );
                    showQrDialog(context, qrData, index);
                  },
                );
              })
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "No Tags Available",
                  style: TextStyle(color: subtitleColor),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showDeleteChannelDialog(BuildContext context, int index) {
    final channelName = channels[index]["channelname"];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Channel',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete channel "$channelName"? This action cannot be undone.',
            style: TextStyle(color: subtitleColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: subtitleColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _deleteChannel(index);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteChannel(int index) async {
    final channelName = channels[index]["channelname"];
    final channelId = channels[index]["channelid"]?.toString() ??
        channels[index]["id"]?.toString();

    if (channelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to delete: Channel ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading state
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleting channel "$channelName"...'),
          backgroundColor: Colors.blue,
        ),
      );

      // Call the delete channel API
      bool success = await dashboardController.deleteChannel(channelId);

      if (success) {
        // Clear selection if deleted channel was selected
        if (selectedChannelIndex == index) {
          setState(() {
            selectedChannelIndex = null;
            selectedDocIndex = null;
            selectedTagIndex = null;
            docs = [];
            currentChatMessages = [];
          });
        } else if (selectedChannelIndex != null &&
            selectedChannelIndex! > index) {
          // Adjust selected index if it's after the deleted channel
          setState(() {
            selectedChannelIndex = selectedChannelIndex! - 1;
          });
        }

        // Refresh the channels list
        fetchChannels();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Channel "$channelName" deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete channel "$channelName"'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error deleting channel: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting channel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void getContextAndPublicKey(
      oldEntityId, oldChannelName, tagId, isChannelOwner, index) async {
    print('Fetching tags detail for tagId: $tagId');
    if (isChannelOwner) {
      setState(() {
        currentChatMessages = [];
        selectedDocIndex = index;
        // currentChatMessages = dashboardController.documentChats[item["docname"]] ?? [];
      });
    } else {
      final contextData = await dashboardController.getContextAndPublicKey(
          oldEntityId, oldChannelName, tagId);

      // print("Context Data: $contextData");
      if (contextData != null) {
        if (contextData["contextform"] != null) {
          setState(() {
            currentChatMessages = [];
            // indicate a tag-based selection by setting selectedDocIndex to -1
            selectedDocIndex = -1;
            htmlForm = contextData["contextform"];
            currentChatMessages =
                dashboardController.documentChats[tagId] ?? [];

            currentChatMessages.add({
              "sender": "Pending Form",
              "message":
                  "Click to open form", // Or whatever text you want to show
              "isFile": false,
              "hasActionButtons": false,
            });
          });
        } else {
          print("No context template found for this tag.");
          setState(() {
            currentChatMessages = [];
            selectedDocIndex = -1;
            currentChatMessages.add({
              "sender": "Unknown",
              "message":
                  "${contextData["message"]}", // Or whatever text you want to show
              "isFile": false,
            });
          });
        }
      }
    }
  }

  void getDocumentDetails(docId, index) async {
    setState(() {
      currentChatMessages = [];
      selectedDocIndex = index;
      isDocumentLoading = true;
    });
    print('Fetching document details for docId: $docId');
    Map<String, dynamic>? docDetails;
    try {
      docDetails = await dashboardController.getDocumentDetails(docId);
    } catch (e) {
      print('Error fetching document details: $e');
      docDetails = null;
    } finally {
      // ensure we clear loading flag after data is processed (below may also set state)
      if (mounted) {
        setState(() {
          isDocumentLoading = false;
        });
      }
    }
    if (docDetails != null) {
      final dd = docDetails;
      // print("......................................${docDetails['jsonData']}");
      // print("......................................${docDetails['htmlTheme']}");
    final availableEvents = dd['data']['documentDetails']
          ['available_events'] as List<dynamic>;
      // ...existing code...
    final activeStates = dd['current_user_active_states']; // Changed to correct path
      List<Map<String, dynamic>> currentActiveStates = [];
      if (activeStates != null &&
          activeStates is List &&
          activeStates.isNotEmpty) {
        print("=== All Channel State Names ===");
        for (var state in activeStates) {
          print("Channel State Name: ${state['channel_state_name']}");
        }

        // Store the list of active states with full data
        currentActiveStates = activeStates.cast<Map<String, dynamic>>();
        print("All Channel States: $currentActiveStates");
      } else {
        print("No active states found");
      }

      // Extract expected state transitions
  final stateTransitions = dd['expected_state_transitions'];
      List<Map<String, dynamic>> currentExpectedTransitions = [];
      if (stateTransitions != null &&
          stateTransitions is List &&
          stateTransitions.isNotEmpty) {
        print("=== Expected State Transitions ===");
        for (var transition in stateTransitions) {
          print(
              "Triggered by channel state: ${transition['triggered_by_channel_state_name']}");
        }

        // Store the list of expected transitions with full data
        currentExpectedTransitions =
            stateTransitions.cast<Map<String, dynamic>>();
        // print("All Expected Transitions: $currentExpectedTransitions");
      } else {
        print("No expected state transitions found");
      }
      // ...existing code...
      if (dd["jsonData"] != null) {
        setState(() {
          // currentChatMessages = [];
          selectedDocIndex = index;
          htmlTheme = dd['htmlTheme'];
          jsonHtmlTheme = dd['jsonData'];
          allChannelStateNames = currentActiveStates; // Store in state variable
          expectedStateTransitions =
              currentExpectedTransitions; // Store expected transitions

          currentChatMessages = dashboardController.documentChats[docId] ?? [];
          actionButtons = [];
          actionButtons.addAll(
            availableEvents.map<Map<String, String>>((event) {
              final eventName = event['event_name']?.toString() ?? "Unknown";
              // return {
              //   "label": eventName,
              //   "html": "<button>$eventName</button>",
              // };
              return {
                "label": eventName,
                "html":
                    "<form class='m-2'><input type='text' class='form-control' required name='${eventName}' placeholder='Enter text...' /></form>",
              };
            }).toList(),
          );

          currentChatMessages.add({
            "sender": "Received Document",
            "message": "Click to view doc", // Or whatever text you want to show
            "isFile": false,
            "hasActionButtons": true,
          });
        });
      } else {
        print("No context template found for this tag.");
        setState(() {
          currentChatMessages = [];
          selectedDocIndex = -1;
          allChannelStateNames = []; // Clear active states
          expectedStateTransitions = []; // Clear expected transitions
          currentChatMessages.add({
            "sender": "Unknown",
            "message":
                "Error while loading data", // Or whatever text you want to show
            "isFile": false,
          });
          isDocumentLoading = false;
        });
      }
    }
  }

  Widget buildDocsListOrTagsList() {
    final bool isLoading = isDocsLoading;
    final List<Map<String, dynamic>> docsList =
        List<Map<String, dynamic>>.from(docs);

    if (isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Map<String, dynamic>> filteredList = searchQuery.isEmpty
        ? docsList
        : docsList.where((item) {
            final itemName = (item["docname"] ?? "")?.toLowerCase() ?? "";
            return itemName.contains(searchQuery.toLowerCase());
          }).toList();

    if (filteredList.isEmpty) {
      final message = searchQuery.isEmpty
          ? "No document found"
          : "No results found for '$searchQuery'";
      return Expanded(
        child: Center(
          child: Text(
            message,
            style: TextStyle(color: subtitleColor),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: filteredList.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final item = filteredList[index];
          final isSelected = selectedDocIndex == index;
          final displayName = item["docname"] ?? "Doc $index";

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDocIndex = index;
              });
              getDocumentDetails(item["docid"], index);
              if (isMobileDevice(context)) {
                _navigateToMobileView(MobileView.chat);
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDarkMode
                        ? Colors.blueGrey[700]
                        : secondaryAccent.withOpacity(0.2))
                    : (isDarkMode ? Colors.grey[800] : surfaceColor),
                borderRadius: BorderRadius.circular(12),
                border: !isDarkMode
                    ? Border.all(
                        color: isSelected ? secondaryAccent : borderColor,
                        width: isSelected ? 2 : 1,
                      )
                    : null,
                boxShadow: [
                  if (isSelected || !isDarkMode)
                    BoxShadow(
                      color: isSelected
                          ? (isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : secondaryAccent.withOpacity(0.2))
                          : Colors.grey.withOpacity(0.1),
                      blurRadius: isSelected ? 8 : 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Tooltip(
                message: _docsWidth < 120 ? displayName : '',
                child: _docsWidth < 120
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDarkMode
                                      ? Colors.white.withOpacity(0.2)
                                      : primaryAccent.withOpacity(0.15))
                                  : (isDarkMode
                                      ? Colors.grey[700]
                                      : borderColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.description_outlined,
                              color: isSelected
                                  ? (isDarkMode ? Colors.white : primaryAccent)
                                  : subtitleColor,
                              size: 20,
                            ),
                          ),
                        ),
                      )
                    : ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDarkMode
                                    ? Colors.white.withOpacity(0.2)
                                    : primaryAccent.withOpacity(0.15))
                                : (isDarkMode ? Colors.grey[700] : borderColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.description_outlined,
                            color: isSelected
                                ? (isDarkMode ? Colors.white : primaryAccent)
                                : subtitleColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          displayName,
                          style: TextStyle(
                            color: isSelected
                                ? (isDarkMode ? Colors.white : primaryAccent)
                                : textColor,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildChatColumn() {
    // final isActorSequenceOne = selectedChannelIndex != null &&
    //     channels[selectedChannelIndex!]["actorsequence"] == "1";
    // final chatTitle = isActorSequenceOne
    //     ? tr("Chat in") + " ${docs[selectedDocIndex!]["docname"]}"
    //     : tr("Chat in") + " ${joinedTags[selectedjoinedTagIndex!]["tagId"]}";

    // Determine the title based on what's selected
    String chatTitle = "Please select a document";
    if (selectedChannelIndex != null) {
      final isChannelOwner =
          channels[selectedChannelIndex!]["actorsequence"] == 1;
      if (isChannelOwner &&
          selectedDocIndex != null &&
          docs.isNotEmpty &&
          selectedDocIndex! >= 0 &&
          selectedDocIndex! < docs.length) {
        chatTitle =
            "Document: ${docs[selectedDocIndex!]["docname"] ?? "Unknown"}";
      } else if (isChannelOwner) {
        chatTitle = "Select a document to chat";
      } else {
        chatTitle = "Select a job to chat";
      }
    }

    return Column(
      children: [
        // Header with consistent styling like compose view
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border(bottom: BorderSide(color: borderColor, width: 1)),
            boxShadow: !isDarkMode
                ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  chatTitle,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
              // No action buttons needed in header
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              // Chat messages including the System message with InAppWebView
              ...currentChatMessages.map((msg) {
                final isUser = msg["sender"] == "You";
                // final isSystem = msg["sender"] == "System";
                final isPendingForm = msg["sender"] == "Pending Form";
                final isReceivedDoc = msg["sender"] == "Received Document";
                final isFile = msg["isFile"] == true;
                final isLastFile = isFile && msg == currentChatMessages.last;
                final hasActionButtons = msg["hasActionButtons"] == true;
                if (isPendingForm) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          InAppWebViewController? webViewController;
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(msg["message"] ?? "Form"),
                              content: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                child: InAppWebView(
                                  initialData: InAppWebViewInitialData(
                                    data: appendScriptWithHtml(htmlForm,
                                        isSubmitButtonNeeded: true),
                                  ),
                                  onWebViewCreated: (controller) {
                                    webViewController =
                                        controller; // Store controller reference
                                    if (!kIsWeb) {
                                      controller.addJavaScriptHandler(
                                        handlerName: 'setupMessageChannel',
                                        callback: (args) {
                                          print(
                                              '✅ Submit trigger setup complete: ${args[0]}');
                                        },
                                      );
                                      controller.addJavaScriptHandler(
                                        handlerName: 'onFormChange',
                                        callback: (args) async {
                                          String jsonString = args[0];
                                          print('Form changed: $jsonString');
                                          // Handle the form change - update preview, validate, etc.
                                        },
                                      );
                                        controller.addJavaScriptHandler(
                                        handlerName: 'onFormSubmit',
                                        callback: (args) {
                                          String jsonString = args[0];
                                          print(
                                              'Received JSON string: $jsonString');
                                          // If a document is selected, submit relative to that doc
                                          if (selectedDocIndex != null &&
                                              selectedDocIndex! >= 0 &&
                                              selectedDocIndex! < docs.length) {
                                            final doc = docs[selectedDocIndex!];
                                            createEncryptedDocument(
                                                doc["entity"] ?? selectedEntity,
                                                doc["channelname"] ?? channels[selectedChannelIndex!]["channelname"],
                                                null,
                                                jsonString);
                                          } else if (selectedChannelIndex != null) {
                                            // Fallback: submit to the selected channel without tag
                                            createEncryptedDocument(
                                              selectedEntity,
                                              channels[selectedChannelIndex!]["channelname"],
                                              null,
                                              jsonString,
                                            );
                                          } else {
                                            print('Error: No valid selection for form submit');
                                          }
                                        },
                                      );
                                    } else {
                                      handleWebMessage();
                                    }
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(tr('Close')),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    // Trigger form submission using the global function
                                    if (webViewController != null) {
                                      try {
                                        await webViewController!
                                            .evaluateJavascript(source: '''
                                              console.log('🎯 Submit button clicked from Flutter');
                                              if (typeof window.triggerFormSubmit === 'function') {
                                                window.triggerFormSubmit();
                                              } else {
                                                console.log('⚠️ triggerFormSubmit function not ready, using fallback...');
                                                // Fallback to direct form submission
                                                var form = document.querySelector('form');
                                                if (form) {
                                                  console.log('📋 Found form, dispatching submit event...');
                                                  var submitEvent = new Event('submit', { bubbles: true, cancelable: true });
                                                  form.dispatchEvent(submitEvent);
                                                } else {
                                                  console.log('❌ No form found');
                                                  alert('No form found to submit');
                                                }
                                              }
                                            ''');

                                        // Show user feedback
                                        // ScaffoldMessenger.of(context).showSnackBar(
                                        //   const SnackBar(
                                        //     content: Text('Form submission triggered'),
                                        //     backgroundColor: Colors.blue,
                                        //   ),
                                        // );
                                      } catch (e) {
                                        print(
                                            'Error triggering form submission: $e');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Error triggering form submission: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'WebView not ready. Please wait and try again.'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                  child: const Text(
                                    'Submit',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(maxWidth: 300),
                          decoration: BoxDecoration(
                            color: Colors.green[800],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg["sender"]!,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    msg["message"]!,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.open_in_new,
                                      size: 16, color: Colors.white70),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (hasActionButtons && actionButtons.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: actionButtons.map((button) {
                              return Row(
                                children: [
                                  _buildActionButton(
                                    button["label"]!,
                                    () => _handleAction(button["label"]!,
                                        msg["message"]!, button["html"]!),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  );
                }
                if (isReceivedDoc) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          showHtmlPopup(context, jsonHtmlTheme);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(maxWidth: 300),
                          decoration: BoxDecoration(
                            color: Colors.green[800],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg["sender"]!,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    msg["message"]!,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.open_in_new,
                                      size: 16, color: Colors.white70),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (hasActionButtons && actionButtons.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 8),
                          child: Row(
                            mainAxisAlignment: isUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: actionButtons.map((button) {
                              return Row(
                                children: [
                                  _buildActionButton(
                                    button["label"]!,
                                    () => _handleAction(button["label"]!,
                                        msg["message"]!, button["html"]!),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        constraints: const BoxConstraints(maxWidth: 300),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blueAccent : Colors.grey[700],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg["sender"]!,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white70),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg["message"]!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if ((isLastFile || hasActionButtons) &&
                        actionButtons.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 8),
                        child: Row(
                          mainAxisAlignment: isUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: actionButtons.map((button) {
                            return Row(
                              children: [
                                _buildActionButton(
                                  button["label"]!,
                                  () => _handleAction(button["label"]!,
                                      msg["message"]!, button["html"]!),
                                ),
                                const SizedBox(width: 4),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
        //   child: Row(
        //     children: [
        //       Expanded(
        //         child: TextField(
        //           controller: messageController,
        //           style: const TextStyle(color: Colors.white),
        //           decoration: const InputDecoration(
        //             hintText: 'Type a message...',
        //             hintStyle: TextStyle(color: Colors.white54),
        //             filled: true,
        //             fillColor: Colors.black26,
        //             border: OutlineInputBorder(
        //               borderRadius: BorderRadius.all(Radius.circular(8)),
        //               borderSide: BorderSide.none,
        //             ),
        //           ),
        //           enabled: !(currentChatMessages.isNotEmpty &&
        //               currentChatMessages.last["isFile"] == true),
        //         ),
        //       ),
        //       const SizedBox(width: 8),
        //       IconButton(
        //         icon: const Icon(Icons.upload_file, color: Colors.white),
        //         tooltip: 'Upload form',
        //         onPressed: (currentChatMessages.isNotEmpty &&
        //                 currentChatMessages.last["isFile"] == true)
        //             ? null
        //             : () => _showUploadMethodDialog(context),
        //       ),
        //       IconButton(
        //         icon: const Icon(Icons.attach_file, color: Colors.white),
        //         tooltip: 'Attach a file',
        //         onPressed: (currentChatMessages.isNotEmpty &&
        //                 currentChatMessages.last["isFile"] == true)
        //             ? null
        //             : uploadFile,
        //       ),
        //       IconButton(
        //         icon: const Icon(Icons.send, color: Colors.white),
        //         onPressed: (currentChatMessages.isNotEmpty &&
        //                 currentChatMessages.last["isFile"] == true)
        //             ? null
        //             : sendMessage,
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  StatusNode parseStatusNode(Map<String, dynamic> json) {
    return StatusNode(
      label: json['label'],
      value: json['value'],
      children: (json['children'] != null)
          ? (json['children'] as List)
              .map((child) => parseStatusNode(child))
              .toList()
          : [],
    );
  }

  List<StatusNode> parseStatusTree(List<Map<String, dynamic>> jsonList) {
    return jsonList.map((e) => parseStatusNode(e)).toList();
  }

  Widget buildDocStatusTree({required String? currentDocStatus}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active States Section
        if (allChannelStateNames.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              "Active States",
              style: TextStyle(
                  fontSize: 20, color: textColor, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: allChannelStateNames.map<Widget>((state) {
                // Check if this state is final
                bool isFinal = state['is_final'] == true;
                String stateName = state['channel_state_name'] ?? 'Unknown';

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isFinal
                        ? Colors.blue.withOpacity(0.2) // Blue for final states
                        : Colors.orange
                            .withOpacity(0.2), // Orange for non-final states
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isFinal
                          ? Colors.blue.withOpacity(0.5)
                          : Colors.orange.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              isFinal ? Colors.blue[700] : Colors.orange[700],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          stateName,
                          style: TextStyle(
                            color:
                                isFinal ? Colors.blue[700] : Colors.orange[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isFinal)
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        // Expected State Transitions Section
        if (expectedStateTransitions.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              "Expected State Transitions",
              style: TextStyle(
                  fontSize: 20, color: textColor, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: expectedStateTransitions.map<Widget>((transition) {
                // Extract transition data
                String transitionDesc =
                    transition['transition_description'] ?? 'Unknown';
                String triggeredByStateName =
                    transition['triggered_by_channel_state_name'] ?? 'Unknown';
                String resultsInStateName =
                    transition['results_in_actor_state_name'] ?? 'Unknown';
                bool otherActorInTriggerState =
                    transition['other_actor_currently_in_trigger_state'] ==
                        true;

                // Determine colors based on transition type and current state
                Color containerColor;
                Color borderColor;
                Color textColor;
                IconData? iconData;

                if (transitionDesc == 'immediate_transition' &&
                    otherActorInTriggerState) {
                  // Active transition - red/urgent
                  containerColor = Colors.red.withOpacity(0.2);
                  borderColor = Colors.red.withOpacity(0.5);
                  textColor = Colors.red[700]!;
                  iconData = Icons.warning;
                } else if (transitionDesc == 'potential_transition') {
                  // Potential transition - yellow/pending
                  containerColor = Colors.amber.withOpacity(0.2);
                  borderColor = Colors.amber.withOpacity(0.5);
                  textColor = Colors.amber[700]!;
                  iconData = Icons.schedule;
                } else {
                  // Default - purple
                  containerColor = Colors.purple.withOpacity(0.2);
                  borderColor = Colors.purple.withOpacity(0.5);
                  textColor = Colors.purple[700]!;
                  iconData = Icons.arrow_forward;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row with icon and transition type
                      Row(
                        children: [
                          Icon(
                            iconData,
                            size: 18,
                            color: textColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              triggeredByStateName,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (otherActorInTriggerState)
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.red[600],
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Transition arrow and result
                      Row(
                        children: [
                          const SizedBox(width: 26), // Align with icon above
                          Icon(
                            Icons.arrow_downward,
                            size: 16,
                            color: textColor.withOpacity(0.7),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Results in: $resultsInStateName",
                              style: TextStyle(
                                color: textColor.withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChannelItem(int index) {
    bool isSelected = selectedChannelIndex == index;
    final isMobile = isMobileDevice(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 8.0 : 6.0),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selectedChannelIndex = index;
                selectedDocIndex = null;
                docs = [];
                currentChatMessages = [];
              });
              fetchDocs(channels[index]["channelname"]);

              // Navigate to documents view on mobile
              if (isMobileDevice(context)) {
                _navigateToMobileView(MobileView.documents);
              }
            },
            child: Tooltip(
              message: channels[index]["channelname"],
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? primaryAccent : cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: !isSelected && !isDarkMode
                      ? Border.all(color: borderColor, width: 1)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryAccent.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                margin: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 10),
                width: isMobile
                    ? MediaQuery.of(context).size.width - 24
                    : (isSidebarCollapsed
                            ? 75.0
                            : (MediaQuery.of(context).size.width > 1200
                                ? 160.0
                                : 140.0)) -
                        20,
                height: isMobile ? 64 : 50,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                    horizontal: isSidebarCollapsed && !isMobile ? 4 : 12),
                child: Text(
                  isSidebarCollapsed && !isMobile
                      ? channels[index]["channelname"].length >= 2
                          ? channels[index]["channelname"]
                              .substring(0, 2)
                              .toUpperCase()
                          : channels[index]["channelname"].toUpperCase()
                      : channels[index]["channelname"],
                  style: TextStyle(
                    color: isSelected ? Colors.white : textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 16 : (isSidebarCollapsed ? 12 : 14),
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: isMobile ? 2 : (isSidebarCollapsed ? 1 : 2),
                ),
              ),
            ),
          ),
          // Three dots menu button (always visible)
          Positioned(
            top: 2,
            right: isSidebarCollapsed ? 4 : 12,
            child: PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              color: surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'channel_tags',
                  child: Row(
                    children: [
                      Icon(Icons.label, color: textColor, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Channel Tags',
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete_channel',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Delete Channel',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (String value) async {
                switch (value) {
                  case 'channel_tags':
                    // Set the channel as selected if not already
                    if (selectedChannelIndex != index) {
                      setState(() {
                        selectedChannelIndex = index;
                        selectedDocIndex = null;
                        docs = [];
                        currentChatMessages = [];
                      });
                    }
                    await fetchTags(channels[index]["channelid"]);
                    _showChannelOptionsBottomSheet(context, index);
                    break;
                  case 'delete_channel':
                    _showDeleteChannelDialog(context, index);
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Discord-like settings area for left sidebar
  Widget _buildLeftSidebarSettingsArea(double sidebarWidth) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isProfileHovered = true),
      onExit: (_) => setState(() => _isProfileHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 60,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: _isProfileHovered
              ? surfaceColor.withOpacity(0.9)
              : surfaceColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isProfileHovered
                ? borderColor.withOpacity(0.6)
                : borderColor.withOpacity(0.3),
            width: _isProfileHovered ? 1.5 : 1,
          ),
          boxShadow: _isProfileHovered
              ? [
                  BoxShadow(
                    color: primaryAccent.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: GestureDetector(
          onTap: () => _showDiscordStyleProfile(context),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                // User avatar with hover effect
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _isProfileHovered
                        ? primaryAccent.withOpacity(0.9)
                        : primaryAccent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _isProfileHovered
                        ? [
                            BoxShadow(
                              color: primaryAccent.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                if (!isSidebarCollapsed) ...[
                  const SizedBox(width: 12),
                  // User info (only show when not collapsed)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          selectedEntityForSwitching ??
                              (selectedEntity.isNotEmpty
                                  ? selectedEntity
                                  : 'No Entity'),
                          style: TextStyle(
                            color: _isProfileHovered
                                ? textColor.withOpacity(0.95)
                                : textColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Online',
                          style: TextStyle(
                            color: _isProfileHovered
                                ? subtitleColor.withOpacity(0.9)
                                : subtitleColor,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build resizable divider between docs and right panel
  Widget _buildResizableDivider() {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _isDividerHovered = true),
      onExit: (_) => setState(() => _isDividerHovered = false),
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
            _dragStartX = details.globalPosition.dx;
            _dragStartWidth = _docsWidth;
          });
        },
        onPanUpdate: (details) {
          if (_isDragging) {
            final deltaX = details.globalPosition.dx - _dragStartX;
            final newWidth = _dragStartWidth + deltaX;

            // Apply constraints - allow dragging left until only logo shows
            const minWidth = 80.0; // Increased slightly for better usability
            const maxWidth = 400.0;

            setState(() {
              _docsWidth = newWidth.clamp(minWidth, maxWidth);
            });
          }
        },
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
          });
        },
        child: Container(
          width: 1,
          decoration: BoxDecoration(
            color: _isDividerHovered || _isDragging
                ? primaryAccent.withOpacity(0.8)
                : borderColor,
          ),
        ),
      ),
    );
  }

  // Show Discord-style profile popup
  void _showDiscordStyleProfile(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Transparent barrier to close popup when clicking outside
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(color: Colors.transparent),
              ),
            ),
            // Discord-style profile popup
            Positioned(
              bottom: 80, // Position above the settings area
              left: 20,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent,
                child: Container(
                  width: 320,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Profile Header with gradient banner and user info
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryAccent,
                                primaryAccent.withOpacity(0.8)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Avatar with online status
                                Stack(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.3),
                                            width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    // Online status indicator
                                    Positioned(
                                      bottom: 2,
                                      right: 2,
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: primaryAccent, width: 2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                // User info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedEntityForSwitching ??
                                            (selectedEntity.isNotEmpty
                                                ? selectedEntity
                                                : 'No Entity'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (subSelectedEntity.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          subSelectedEntity,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Online',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Menu Options
                        _buildSimpleProfileMenuItem(
                            Icons.swap_horiz, 'Switch Account'),
                        _buildSimpleProfileMenuItem(
                            Icons.language, 'Select Language'),
                        _buildSimpleProfileMenuItem(
                            Icons.list_alt, 'View Logs'),
                        _buildSimpleProfileMenuItem(
                            Icons.key, 'Import/Export Keys'),

                        // Divider
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          height: 1,
                          color: borderColor.withOpacity(0.3),
                        ),

                        // Logout option (in red)
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            // Use a slight delay to ensure the profile popup is fully closed
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              _showLogoutDialog();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            child: Row(
                              children: [
                                Icon(Icons.logout, color: Colors.red, size: 18),
                                const SizedBox(width: 12),
                                Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to build simple profile menu items
  Widget _buildSimpleProfileMenuItem(IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        _handleSimpleProfileMenuAction(title);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 18),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(color: textColor, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // Handle simple profile menu actions
  void _handleSimpleProfileMenuAction(String action) {
    switch (action) {
      case 'Switch Account':
        _showSwitchAccountPage();
        break;
      case 'Select Language':
        _showLanguageDialog();
        break;
      case 'View Logs':
        DashboardLogsView.showLogsDialog(context, dashboardController);
        break;
      case 'Import/Export Keys':
        _showRSAKeysDialog();
        break;
    }
  }

  // Show switch account dialog
  void _showSwitchAccountPage() async {
    await secureStorage.delete(key: "JWT_Token");
    context.goNamed('/');
  }

  // Show language selection dialog
  void _showLanguageDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient and icon
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryAccent, primaryAccent.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.language,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Select Language',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Language options
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: context.supportedLocales.map((locale) {
                      final isCurrentLanguage =
                          _currentLocale?.languageCode == locale.languageCode;
                      final languageName = _getLanguageName(locale);

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: isCurrentLanguage
                              ? primaryAccent.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isCurrentLanguage
                              ? Border.all(
                                  color: primaryAccent.withOpacity(0.3))
                              : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              setState(() {
                                _currentLocale = locale;
                              });
                              context.setLocale(locale);
                              Navigator.of(context).pop();

                              // Show elegant success notification
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: Colors.white, size: 20),
                                      const SizedBox(width: 12),
                                      Text('Language changed to $languageName'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  // Language flag/icon placeholder
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isCurrentLanguage
                                          ? primaryAccent
                                          : subtitleColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.translate,
                                      color: isCurrentLanguage
                                          ? Colors.white
                                          : subtitleColor,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Language name
                                  Expanded(
                                    child: Text(
                                      languageName,
                                      style: TextStyle(
                                        color: isCurrentLanguage
                                            ? primaryAccent
                                            : textColor,
                                        fontWeight: isCurrentLanguage
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),

                                  // Check icon for selected language
                                  if (isCurrentLanguage)
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: primaryAccent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Cancel button
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: borderColor.withOpacity(0.3)),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to get language display name
  String _getLanguageName(Locale locale) {
    Map<String, String> languageNames = {
      'en': 'English',
      'ar': 'العربية',
      'de': 'Deutsch',
    };
    return languageNames[locale.languageCode] ??
        locale.languageCode.toUpperCase();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 24),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout? You will be redirected to the login screen.',
          style: TextStyle(color: subtitleColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: subtitleColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Perform actual logout using AuthLogout
              AuthLogout.logout(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRSAKeysDialog() async {
    // Show loading dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Fetch RSA keys
      final keys = await dashboardController.getSelectedEntityRSAKeys();

      // Close loading dialog
      Navigator.pop(context);

      if (keys == null) {
        // Show error if no keys found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No RSA keys found for this entity'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final publicKey = keys['publicKey'] ?? 'Not available';
      final privateKey = keys['privateKey'] ?? 'Not available';

      // Show key management dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.vpn_key, color: primaryAccent, size: 24),
              const SizedBox(width: 12),
              Text(
                'Key Management',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage your RSA keys',
                  style: TextStyle(color: subtitleColor, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Export Keys Card
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _showExportKeysDialog(publicKey, privateKey);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child:
                              Icon(Icons.upload, color: Colors.blue, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Export Keys',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Encrypt and export your public & private keys',
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            color: subtitleColor, size: 16),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Import Key Card
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _showImportKeyDialog();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.download,
                              color: Colors.green, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Import Private Key',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Decrypt and import an encrypted key',
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            color: subtitleColor, size: 16),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Warning message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Keep your private key secure and never share it with anyone.',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: subtitleColor)),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog if still open
      Navigator.pop(context);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading RSA keys: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showExportKeysDialog(String publicKey, String privateKey) {
    final TextEditingController passwordController = TextEditingController();
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.lock, color: Colors.blue, size: 24),
              const SizedBox(width: 12),
              Text(
                'Export Keys',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter a password to encrypt your RSA keys:',
                style: TextStyle(color: subtitleColor, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: subtitleColor),
                  hintText: 'Enter a strong password',
                  hintStyle: TextStyle(color: subtitleColor.withOpacity(0.5)),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryAccent),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: subtitleColor,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Remember this password! You\'ll need it to import the key.',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: subtitleColor)),
            ),
            ElevatedButton(
              onPressed: () async {
                final password = passwordController.text.trim();
                if (password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a password'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (password.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password must be at least 6 characters'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  // Encrypt both keys with password
                  final encryptedKeys =
                      await _encryptKeys(publicKey, privateKey, password);

                  Navigator.pop(context);

                  // Show encrypted keys for copying
                  _showEncryptedKeyDialog(encryptedKeys);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error encrypting keys: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Export'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEncryptedKeyDialog(String encryptedKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            const SizedBox(width: 12),
            Text(
              'Encrypted Keys',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Container(
          width: 600,
          constraints: BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your encrypted keys (public & private):',
                style: TextStyle(color: subtitleColor, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                constraints: BoxConstraints(maxHeight: 250),
                child: SingleChildScrollView(
                  child: SelectableText(
                    encryptedKey,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Key successfully encrypted! Copy and store it securely.',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: subtitleColor)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: encryptedKey));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Encrypted keys copied to clipboard'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(Icons.copy, size: 18),
            label: Text('Copy'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showImportKeyDialog() {
    final TextEditingController encryptedKeyController =
        TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.upload, color: Colors.green, size: 24),
              const SizedBox(width: 12),
              Text(
                'Import Private Key',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paste your encrypted keys:',
                  style: TextStyle(color: subtitleColor, fontSize: 14),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: encryptedKeyController,
                  maxLines: 5,
                  style: TextStyle(
                      color: textColor, fontSize: 12, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    hintText: 'Paste encrypted keys here...',
                    hintStyle: TextStyle(color: subtitleColor.withOpacity(0.5)),
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter the password used to encrypt:',
                  style: TextStyle(color: subtitleColor, fontSize: 14),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: subtitleColor),
                    hintText: 'Enter decryption password',
                    hintStyle: TextStyle(color: subtitleColor.withOpacity(0.5)),
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryAccent),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: subtitleColor,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: subtitleColor)),
            ),
            ElevatedButton(
              onPressed: () async {
                final encryptedKey = encryptedKeyController.text.trim();
                final password = passwordController.text.trim();

                if (encryptedKey.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  // Decrypt both keys
                  final decryptedKeys =
                      await _decryptKeys(encryptedKey, password);

                  // Save the keys
                  final entityName =
                      await dashboardController.getSelectedEntity();
                  await dashboardController.addOrUpdateEntityKeys(
                    entityName,
                    decryptedKeys['publicKey']!,
                    decryptedKeys['privateKey']!,
                  );

                  Navigator.pop(context);

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Keys imported successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Decryption failed: Invalid password or corrupted keys'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('Import'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImportKeyDialogAutomatic() {
    final TextEditingController encryptedKeyController =
        TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      barrierDismissible: false, // User must import keys or close manually
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Import Required',
                  style:
                      TextStyle(color: textColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'No keys found. Please import your encrypted keys from another device.',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Paste your encrypted keys:',
                  style: TextStyle(color: subtitleColor, fontSize: 14),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: encryptedKeyController,
                  maxLines: 5,
                  style: TextStyle(
                      color: textColor, fontSize: 12, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    hintText: 'Paste encrypted keys here...',
                    hintStyle: TextStyle(color: subtitleColor.withOpacity(0.5)),
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter the password used to encrypt:',
                  style: TextStyle(color: subtitleColor, fontSize: 14),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: subtitleColor),
                    hintText: 'Enter decryption password',
                    hintStyle: TextStyle(color: subtitleColor.withOpacity(0.5)),
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryAccent),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: subtitleColor,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  Text('Skip for Now', style: TextStyle(color: subtitleColor)),
            ),
            ElevatedButton(
              onPressed: () async {
                final encryptedKey = encryptedKeyController.text.trim();
                final password = passwordController.text.trim();

                if (encryptedKey.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  // Decrypt both keys
                  final decryptedKeys =
                      await _decryptKeys(encryptedKey, password);

                  // Save the keys
                  final entityName =
                      await dashboardController.getSelectedEntity();
                  await dashboardController.addOrUpdateEntityKeys(
                    entityName,
                    decryptedKeys['publicKey']!,
                    decryptedKeys['privateKey']!,
                  );

                  Navigator.pop(context);

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Keys imported successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Decryption failed: Invalid password or corrupted keys'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('Import Keys'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _encryptKeys(
      String publicKey, String privateKey, String password) async {
    try {
      // Combine both keys with a separator
      final combinedKeys = '$publicKey|||KEYSEPARATOR|||$privateKey';

      // Use AES encryption with the password
      final key =
          encrypt.Key.fromUtf8(password.padRight(32, '0').substring(0, 32));
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final encrypted = encrypter.encrypt(combinedKeys, iv: iv);

      // Combine IV and encrypted data for storage
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  Future<Map<String, String>> _decryptKeys(
      String encryptedData, String password) async {
    try {
      // Split IV and encrypted data
      final parts = encryptedData.split(':');
      if (parts.length != 2) {
        throw Exception('Invalid encrypted data format');
      }

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encryptedText = encrypt.Encrypted.fromBase64(parts[1]);

      // Use the same key derivation as encryption
      final key =
          encrypt.Key.fromUtf8(password.padRight(32, '0').substring(0, 32));
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final decrypted = encrypter.decrypt(encryptedText, iv: iv);

      // Split the combined keys
      final keyParts = decrypted.split('|||KEYSEPARATOR|||');
      if (keyParts.length != 2) {
        throw Exception('Invalid key data format');
      }

      return {
        'publicKey': keyParts[0],
        'privateKey': keyParts[1],
      };
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  // Mobile back button widget
  Widget _buildMobileBackButton(String label, MobileView targetView) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: primaryAccent),
            onPressed: () => _navigateToMobileView(targetView),
          ),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasChannels = channels.isNotEmpty;

    return Scaffold(
      appBar: CustomAppBar(
        title: "dashboard.dashboard",
        context: context,
      ),
      body: Column(
        children: [
          // Horizontal divider between AppBar and content
          Container(
            width: double.infinity,
            height: 1,
            color: borderColor,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _buildMainLayout(hasChannels, constraints);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainLayout(bool hasChannels, BoxConstraints constraints) {
    // Check if mobile
    final isMobile = isMobileDevice(context);

    // Dynamic sidebar width based on screen size and collapse state
    final normalSidebarWidth = constraints.maxWidth > 1200 ? 160.0 : 140.0;
    final collapsedSidebarWidth = 75.0; // Width when collapsed
    final sidebarWidth =
        isSidebarCollapsed ? collapsedSidebarWidth : normalSidebarWidth;

    // Initialize docs width if not set, make it responsive
    if (_docsWidth == 250.0) {
      _docsWidth = constraints.maxWidth > 1200 ? 280.0 : 220.0;
    }

    // On mobile, make panels full width
    final mobileSidebarWidth = isMobile ? constraints.maxWidth : sidebarWidth;

    return Stack(
      children: [
        Row(
          children: [
            // Left Sidebar (Channels) - Show on desktop OR mobile channels view
            if (!isMobile || _currentMobileView == MobileView.channels)
              Container(
                width: mobileSidebarWidth,
                color: backgroundColor,
                child: Column(
                  children: [
                    // Logo Section (always visible)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 8.0),
                      child: CircleAvatar(
                        radius: isSidebarCollapsed
                            ? 18
                            : (constraints.maxWidth > 1200 ? 24 : 20),
                        backgroundColor: Colors.transparent,
                        child: SvgPicture.asset(
                          'assets/images/xdoc_logo.svg',
                          width: isSidebarCollapsed
                              ? 28
                              : (constraints.maxWidth > 1200 ? 40 : 32),
                          height: isSidebarCollapsed
                              ? 28
                              : (constraints.maxWidth > 1200 ? 40 : 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Channels List
                    Expanded(
                      child: hasChannels
                          ? Builder(
                              builder: (context) {
                                // Separate channels by actorsequence
                                final channelsSeq0 = <int>[];
                                final channelsSeq1 = <int>[];

                                for (int i = 0; i < channels.length; i++) {
                                  final actorSequence =
                                      channels[i]["actorsequence"];
                                  if (actorSequence == 0) {
                                    channelsSeq0.add(i);
                                  } else if (actorSequence == 1) {
                                    channelsSeq1.add(i);
                                  }
                                }

                                return ListView(
                                  children: [
                                    // Heading for actorsequence 0 (Sent Items)
                                    if (channelsSeq0.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: Text(
                                          "Sent Items",
                                          style: TextStyle(
                                            color: subtitleColor,
                                            fontSize:
                                                isSidebarCollapsed ? 10 : 12,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),

                                    // Channels with actorsequence 0
                                    ...channelsSeq0.map(
                                        (index) => _buildChannelItem(index)),

                                    // Separator (only show if both groups have channels)
                                    // if (channelsSeq0.isNotEmpty && channelsSeq1.isNotEmpty)
                                    //   Padding(
                                    //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    //     child: Container(
                                    //       height: 1,
                                    //       color: borderColor,
                                    //     ),
                                    //   ),

                                    // Heading for actorsequence 1 (Inboxes)
                                    if (channelsSeq1.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: Text(
                                          "Inboxes",
                                          style: TextStyle(
                                            color: subtitleColor,
                                            fontSize:
                                                isSidebarCollapsed ? 10 : 12,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),

                                    // Channels with actorsequence 1
                                    ...channelsSeq1.map(
                                        (index) => _buildChannelItem(index)),
                                  ],
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                "No Channels",
                                style: TextStyle(
                                    color: subtitleColor, fontSize: 12),
                              ),
                            ),
                    ),
                    // Add Channel Button (bottom)
                    Padding(
                      padding: EdgeInsets.all(isMobile ? 12.0 : 8.0),
                      child: GestureDetector(
                        onTap: () => _showCreateChannelDialog(context),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          width: mobileSidebarWidth - (isMobile ? 24 : 20),
                          height: isMobile ? 60 : 50,
                          child: isSidebarCollapsed && !isMobile
                              ? const Icon(Icons.add,
                                  color: Colors.white, size: 20)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add,
                                        color: Colors.white,
                                        size: isMobile ? 24 : 20),
                                    SizedBox(width: isMobile ? 12 : 8),
                                    Text(
                                      'Add Channel',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isMobile ? 16 : 12,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    // Discord-like settings area for left sidebar
                    _buildLeftSidebarSettingsArea(mobileSidebarWidth),
                  ],
                ),
              ),
            // Vertical divider between Left Sidebar and Middle Panel
            if (!isMobile)
              Container(
                width: 1,
                color: borderColor,
              ),
            // Middle Panel (Docs) - Show on desktop OR mobile documents view
            if (!isMobile || _currentMobileView == MobileView.documents)
              Container(
                width: isMobile ? constraints.maxWidth : _docsWidth,
                color: surfaceColor,
                child: Column(
                  children: [
                    // Mobile back button for documents view
                    if (isMobile && _currentMobileView == MobileView.documents)
                      _buildMobileBackButton(
                          'Back to Channels', MobileView.channels),
                    // Show compose button if "Sent" channel is selected
                    // if (selectedChannelIndex != null &&
                    //     channels[selectedChannelIndex!]["channelname"] == "Sent")
                    if (selectedChannelIndex != null &&
                        channels[selectedChannelIndex!]["actorsequence"] == 0)
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        child: _docsWidth > 150
                            ? ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[600],
                                  minimumSize: const Size(double.infinity, 45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon:
                                    const Icon(Icons.add, color: Colors.white),
                                label: const Text(
                                  'Document',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                                onPressed: () {
                                  // Show compose dialog instead of toggling mode
                                  _showComposeDialog(context);
                                },
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[600],
                                  minimumSize: const Size(double.infinity, 45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () {
                                  // Show compose dialog instead of toggling mode
                                  _showComposeDialog(context);
                                },
                                child: const Center(
                                  child: Icon(Icons.add,
                                      color: Colors.white, size: 24),
                                ),
                              ),
                      ),
                    buildDocsListOrTagsList(),
                    // Search input at bottom of middle panel
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        border: Border(
                          top: BorderSide(color: borderColor, width: 1),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search documents and tags...',
                          hintStyle:
                              TextStyle(color: subtitleColor, fontSize: 14),
                          prefixIcon: Icon(Icons.search,
                              color: subtitleColor, size: 20),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear,
                                      color: subtitleColor, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      searchQuery = '';
                                      _searchController.clear();
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: primaryAccent, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            // Resizable divider between Middle Panel and Right Panel
            if (!isMobile) _buildResizableDivider(),
            // Right Panel (Chat Panel) - Show on desktop OR mobile chat view
            if (!isMobile || _currentMobileView == MobileView.chat)
              Expanded(
                child: Stack(
                  children: [
                    // Mobile back button for chat view
                    if (isMobile && _currentMobileView == MobileView.chat)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: _buildMobileBackButton(
                            'Back to Documents', MobileView.documents),
                      ),
                    // Chat content
                    Container(
                      margin: isMobile && _currentMobileView == MobileView.chat
                          ? EdgeInsets.only(
                              top: 56) // Add margin for back button
                          : EdgeInsets.zero,
                      color: cardColor,
                      child: (selectedChannelIndex == null)
                          ? Center(
                              child: Text(
                                "Please select a channel",
                                style: TextStyle(color: textColor),
                              ),
                            )
                          : (isDocumentLoading)
                              ? const Center(child: CircularProgressIndicator())
                              : (isDocsLoading)
                                  ? const Center(child: CircularProgressIndicator())
                                  : (selectedDocIndex == null)
                                  ? Center(
                                      child: Text(
                                        "Please select a doc",
                                        style: TextStyle(color: textColor),
                                      ),
                                    )
                                  : buildChatColumn(),
                    ),
                    // Top-Right Button (Menu button for right sidebar)
          if (selectedChannelIndex != null && selectedDocIndex != null)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          icon: Icon(Icons.menu_open, color: textColor),
                          onPressed: () {
                            setState(() {
                              showRightSidebar = true;
                            });
                          },
                          tooltip: 'Document Status',
                        ),
                      ),
                    // Right Sidebar Overlay
                    if (showRightSidebar)
                      Positioned(
                        top: 0,
                        right: 0,
                        bottom: 0,
                        width: constraints.maxWidth > 1200 ? 350 : 300,
                        child: Container(
                          decoration: BoxDecoration(
                            color: surfaceColor,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.close, color: textColor),
                                onPressed: () {
                                  setState(() {
                                    showRightSidebar = false;
                                  });
                                },
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: buildDocStatusTree(
                                        currentDocStatus: "underprocess"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
        // Small button positioned at the divider line in front of logo (hide on mobile)
        if (!isMobile)
          Positioned(
            left: sidebarWidth - 12, // Position at the edge of sidebar
            top: 24, // Align with logo area
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: primaryAccent.withOpacity(0.9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: backgroundColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      isSidebarCollapsed = !isSidebarCollapsed;
                    });
                  },
                  child: Icon(
                    isSidebarCollapsed
                        ? Icons.chevron_right
                        : Icons.chevron_left,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        if (isUploading)
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Uploading file...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    // Cancel the channels stream subscription
    _channelsSubscription?.cancel();

    // Remove theme service listener
    _themeService.removeListener(_onThemeChanged);

    // Dispose other controllers and resources
    messageController.dispose();
    _urlController.dispose();
    _htmlController.dispose();
    _channelNameController.dispose();

    super.dispose();
  }
}
