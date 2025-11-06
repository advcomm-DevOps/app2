import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
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

class DashboardView extends StatefulWidget {
  final String? entity;
  final String? section;
  final String? tagid;
  const DashboardView({super.key, this.entity, this.section, this.tagid});
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int? selectedChannelIndex;
  int? selectedDocIndex;
  int? selectedjoinedTagIndex;
  int? selectedTagIndex;
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
  List<Map<String, dynamic>> joinedTags = [];
  List<Map<String, dynamic>> tags = [];
  List<Map<String, String>> actionButtons = [];
  DashboardController dashboardController =
      DashboardController(); // Initialize the controller

  bool isDocsLoading = false;
  bool isjoinedTagsLoading = false;
  bool isTagsLoading = false;
  bool isUploading = false;
  bool isComposeMode = false;
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

  String htmlForm = getResumeForm();
  String htmlResume = "";
  String jsonHtmlTheme = "";

  List<Map<String, dynamic>> currentChatMessages = [];

  // Stream subscription for channels
  StreamSubscription<List<Map<String, dynamic>>>? _channelsSubscription;

  bool get isLastFile {
    if (currentChatMessages.isEmpty) return false;
    final lastMessage = currentChatMessages.last;
    return lastMessage["isFile"] == true;
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
    setState(() {
      selectedEntity = entity ?? '';
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
    await generateRSAKeyPair();
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
              if (selectedChannelIndex == null) {
                final inboxIndex = channels.indexWhere(
                  (channel) => channel['channelname']?.toLowerCase() == 'inbox',
                );
                if (inboxIndex != -1) {
                  selectedChannelIndex = inboxIndex;
                  selectedDocIndex = null;
                  docs = [];
                  currentChatMessages = [];
                  fetchDocs(channels[inboxIndex]["channelname"]);
                  fetchJoinedTags(channels[inboxIndex]["channelname"]);
                }
              }
            });
          } else if (mounted) {
            print("No channels found.");
          }
          if (mounted) {
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
    secQr = widget.section;
    final tagid = widget.tagid;
    String? tagname = '';
    if (secQr == null) return;

    final details = await dashboardController.getChannelDetailsForJoin(
      entityId: entityQr!,
      channelName: widget.section!,
      tagId: widget.tagid!,
    );
    if (details != null && details["channelDetails"] != null) {
      newSecQr = details["channelDetails"]["newChannelName"];
      tagname = details["channelDetails"]["tagName"];
    }

    final exists =
        channels.any((channel) => channel['channelname'] == newSecQr);
    final index =
        channels.indexWhere((channel) => channel['channelname'] == newSecQr);
    if (!exists) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Channel Not Found',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Channel "$newSecQr" does not exist in the available channels. Do you want to add it?',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // User chose not to add
              },
              child: const Text(
                'No',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                joinNewChannel(entityQr!, secQr!, tagid, tagname, newSecQr!);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      addTagIfNotExist(
          oldEntityId: entityQr!,
          tagId: tagid!,
          oldChannelName: secQr!,
          newChannelName: newSecQr!,
          tagName: tagname!);
      setState(() {
        selectedChannelIndex = index;
        selectedDocIndex = null;
        docs = [];
        currentChatMessages = [];
      });
      fetchDocs(channels[index]["channelname"]);
      fetchJoinedTags(channels[index]["channelname"]);
    }
  }

  void addTagIfNotExist(
      {required String oldEntityId,
      required String tagId,
      required String oldChannelName,
      required String newChannelName,
      required String tagName}) {
    dashboardController.addTagIfNotExists(
      oldEntityId: oldEntityId,
      tagId: tagId,
      oldChannelName: oldChannelName,
      newChannelName: newChannelName,
      tagName: tagName,
    );
  }

  void joinNewChannel(String entityName, String sectionName, String? tagid,
      String? tagname, String? newSecQr) {
    dashboardController
        .joinChannel(entityName, sectionName, tagid, tagname, newSecQr)
        .then((joined) {
      if (joined) {
        fetchChannels();
        fetchDocs(sectionName);
        setState(() {
          secQr = null; // set to null after joining
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

  void createTemporaryDocument(Map<String, String> formData) async {
    print('Creating temporary document with data: $formData');
    String? tagname = '';
    final details = await dashboardController.getChannelDetailsForJoin(
      entityId: formData['entity']!,
      channelName: formData['channel']!,
      tagId: formData['tagId']!,
    );
    if (details != null && details["channelDetails"] != null) {
      newSecQr = details["channelDetails"]["newChannelName"];
      tagname = details["channelDetails"]["tagName"];
      addTagIfNotExist(
          oldEntityId: formData['entity']!,
          tagId: formData['tagId']!,
          oldChannelName: formData['channel']!,
          newChannelName: channels[selectedChannelIndex!]["channelname"],
          tagName: tagname!);
      fetchJoinedTags(channels[selectedChannelIndex!]["channelname"]);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void createEncryptedDocument(
    String entityName,
    String channelName,
    String tagid,
    String submittedData,
  ) async {
    bool joined = await dashboardController.createEncryptedDocument(
      entityName: entityName,
      channelName: channelName,
      tagId: tagid,
      submittedData: submittedData,
    );

    if (joined) {
      await dashboardController.removeTagById(
        channelName: channels[selectedChannelIndex!]["channelname"],
        tagId: tagid,
      );
      fetchDocs(channels[selectedChannelIndex!]["channelname"]);
      fetchJoinedTags(channels[selectedChannelIndex!]["channelname"]);
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
  ) async {
    bool isUpdated = await dashboardController.updateEncryptedEvent(
      actionName: action,
      docid: docid,
      submittedData: submittedData,
    );

    if (isUpdated) {
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

  Future<void> fetchJoinedTags(String channelName) async {
    try {
      setState(() {
        isjoinedTagsLoading = true;
        joinedTags = [];
        selectedjoinedTagIndex = null;
        currentChatMessages = [];
      });
      final joinTagsList =
          await dashboardController.getTagList(channelName: channelName);
      setState(() {
        joinedTags = List<Map<String, dynamic>>.from(joinTagsList);
        isjoinedTagsLoading = false;
      });
    } catch (e) {
      setState(() {
        isjoinedTagsLoading = false;
      });
      print("Error fetching joined tags: $e");
    }
  }

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

  String appendScriptWithHtml(String html) {
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
    
    return "$html<script>${dashboardController.formHandlingJS}</script><script>$messageChannelScript</script>";
  }

  void _handleAction(String action, String fileName, String html) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Form Actions',
            style: TextStyle(color: textColor),
          ),
          backgroundColor: surfaceColor,
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            child: InAppWebView(
              initialData:
                  InAppWebViewInitialData(data: appendScriptWithHtml(html)),
              onWebViewCreated: (controller) {
                if (!kIsWeb) {
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
                        updateEncryptedEvent(action,
                            docs[selectedDocIndex!]["docid"], jsonString);
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
          // actions: [
          //   ElevatedButton(
          //     style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          //     onPressed: () {
          //       setState(() {
          //         currentChatMessages.add({
          //           "sender": "System",
          //           "message":
          //               "You $action the file: ${fileName.split(':').last.trim()}",
          //         });
          //       });
          //       Navigator.pop(context);
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         SnackBar(
          //           content: const Text('File Submitted successfully'),
          //           backgroundColor: Colors.green,
          //         ),
          //       );
          //     },
          //     child:
          //         const Text('Submit', style: TextStyle(color: Colors.white)),
          //   ),
          // ],
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

  void _showUploadMethodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload Form', style: TextStyle(color: textColor)),
          backgroundColor: surfaceColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select how you want to upload the form:',
                  style: TextStyle(color: subtitleColor)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showUrlInputDialog(context);
                    },
                    child: const Text('By URL',
                        style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showHtmlInputDialog(context);
                    },
                    child: const Text('By HTML',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUrlInputDialog(BuildContext context) {
    _urlController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Form URL', style: TextStyle(color: textColor)),
          backgroundColor: surfaceColor,
          content: TextField(
            controller: _urlController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'https://example.com/form',
              hintStyle: TextStyle(color: subtitleColor),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: subtitleColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                if (_urlController.text.isNotEmpty) {
                  Navigator.pop(context);
                  _showPreviewDialog(context, _urlController.text, isUrl: true);
                }
              },
              child:
                  const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showHtmlInputDialog(BuildContext context) {
    _htmlController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter HTML Form', style: TextStyle(color: textColor)),
          backgroundColor: surfaceColor,
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              controller: _htmlController,
              maxLines: 10,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: '<form>...</form>',
                hintStyle: TextStyle(color: subtitleColor),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: subtitleColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                if (_htmlController.text.isNotEmpty) {
                  Navigator.pop(context);
                  _showPreviewDialog(context, _htmlController.text,
                      isUrl: false);
                }
              },
              child:
                  const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showPreviewDialog(BuildContext context, String content,
      {required bool isUrl}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isUrl ? 'URL Form Preview' : 'HTML Form Preview',
            style: TextStyle(color: textColor),
          ),
          backgroundColor: surfaceColor,
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            child: InAppWebView(
              initialUrlRequest:
                  isUrl ? URLRequest(url: WebUri(content)) : null,
              initialData:
                  !isUrl ? InAppWebViewInitialData(data: content) : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: subtitleColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isUrl ? 'URL form submitted' : 'HTML form submitted',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Confirm Upload',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showComposeDialog(BuildContext context) {
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
  InAppWebViewController? webViewController; // Add WebView controller reference

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Future<void> fetchChannelTags(int channelIdx) async {
              setState(() {
                pubTags = [];
                selectedTagIndexLocal = null;
                isLoadingTags = true;
              });
              final channel = pubChannels[channelIdx];
              final channelName = channel['channelname'] ?? channel.toString();
              final entity = _entityController.text.trim();
              try {
                final tags = await dashboardController.getPubChannelTags(entity, channelName);
                setState(() {
                  pubTags = tags;
                  isLoadingTags = false;
                });
              } catch (e) {
                setState(() {
                  isLoadingTags = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error fetching tags: $e')),
                );
              }
            }

            Future<void> searchPubChannels() async {
              final entity = _entityController.text.trim();
              if (entity.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter an entity name.')),
                );
                return;
              }
              final int actorId = channels[selectedChannelIndex!]["initialactorid"];
              setState(() {
                isSearching = true;
                hasSearched = false;
                pubTags = [];
                selectedTagIndexLocal = null;
                selectedChannelIndexLocal = null;
              });
              try {
                final result = await dashboardController.getPubChannels(entity, actorId);
                bool shouldAutoFetch = false;
                setState(() {
                  pubChannels = result;
                  isSearching = false;
                  hasSearched = true;
                  
                  // Auto-select channel if only one channel is found
                  if (pubChannels.length == 1) {
                    selectedChannelIndexLocal = 0;
                    final channelName = pubChannels[0]['channelname'] ?? pubChannels[0].toString();
                    _composeChannelController.text = channelName;
                    shouldAutoFetch = true;
                  }
                });
                
                // Auto-fetch tags if only one channel is found
                if (shouldAutoFetch) {
                  await fetchChannelTags(0);
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

            return AlertDialog(
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
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintText: 'Enter entity name',
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
                          suffixIcon: isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  ),
                                )
                              : Container(
                                  margin: const EdgeInsets.all(8.0),
                                  child: Material(
                                    color: (isSearching || hasSearched) 
                                        ? Colors.grey[600] 
                                        : Colors.blueAccent,
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: (isSearching || hasSearched)
                                          ? null
                                          : searchPubChannels,
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
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
                          if (!isSearching && !hasSearched) searchPubChannels();
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // After search, show channels or no match
                    if (hasSearched)
                      pubChannels.isEmpty
                          ? const Text('No matching channel found', style: TextStyle(color: Colors.redAccent))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pubChannels.length == 1 
                                    ? 'Channel Auto-Selected:' 
                                    : 'Select Channel:', 
                                  style: TextStyle(
                                    color: pubChannels.length == 1 ? Colors.green : Colors.white70, 
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: pubChannels.asMap().entries.map((entry) {
                                    final idx = entry.key;
                                    final channel = entry.value;
                                    final channelName = channel['channelname'] ?? channel.toString();
                                    final isSelected = selectedChannelIndexLocal == idx;
                                    final description = channel['channeldescription'] ?? '';
                                    return Tooltip(
                                      message: description.isNotEmpty ? description : channelName,
                                      child: ChoiceChip(
                                        label: Text(channelName, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : Colors.white70)),
                                        labelStyle: TextStyle(
                                          color: isSelected ? Colors.white : Colors.white70,
                                        ),
                                        selected: isSelected,
                                        selectedColor: Colors.blueAccent,
                                        backgroundColor: Colors.grey[700],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        onSelected: (bool selected) {
                                          setState(() {
                                            if (selected) {
                                              selectedChannelIndexLocal = idx;
                                              _composeChannelController.text = channelName;
                                              fetchChannelTags(idx);
                                              // Hide InAppWebView when channel changes
                                              showWebView = false;
                                              selectedTagIndexLocal = null;
                                              selectedTagData = null; // Clear selected tag data
                                            } else {
                                              selectedChannelIndexLocal = null;
                                              pubTags = [];
                                              selectedTagIndexLocal = null;
                                              selectedTagData = null; // Clear selected tag data
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
                    if (hasSearched && pubChannels.isNotEmpty && selectedChannelIndexLocal != null) ...[
                      Row(
                        children: [
                          const Text('Select Tag:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                          if (isLoadingTags)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (pubTags.isEmpty && !isLoadingTags)
                        const Text('No tags found for this channel', style: TextStyle(color: Colors.redAccent)),
                      if (isLoadingTags)
                        const Text('Loading tags for auto-selected channel...', style: TextStyle(color: Colors.white54)),
                      if (pubTags.isNotEmpty)
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: pubTags.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final tag = entry.value;
                            final tagName = tag['tag'] ?? tag['tagName'] ?? tag['tagid']?.toString() ?? 'Tag';
                            final tagDescription = tag['tagdescription'] ?? tag['tagDescription'] ?? '';
                            final isSelected = selectedTagIndexLocal == idx;
                            return Tooltip(
                              message: tagDescription.isNotEmpty ? tagDescription : tagName,
                              child: ChoiceChip(
                                label: Text(tagName, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : Colors.white70)),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                ),
                                selected: isSelected,
                                selectedColor: Colors.green,
                                backgroundColor: Colors.grey[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                onSelected: (bool selected) async {
                                  if (selected) {
                                    final tagId = tag['tagid'] ?? tag['tagId'] ?? 'Unknown TagID';
                                    final channelName = selectedChannelIndexLocal != null 
                                        ? pubChannels[selectedChannelIndexLocal!]['channelname'] ?? 'Unknown Channel'
                                        : 'Unknown Channel';
                                    final entityName = _entityController.text.trim();
                                    print('Selected tag: $tagName');
                                    print('Tag ID: $tagId');
                                    print('Channel Name: $channelName');
                                    print('Entity Name: $entityName');
                                    
                                    // Fetch context data asynchronously
                                    final contextData = await dashboardController.getContextAndPublicKey(entityName, channelName, tagId);
                                    // print("Context Data: $contextData");
                                     if (contextData != null) {
                                        if (contextData["contextform"] != null) {
                                          htmlForm = contextData["contextform"];
                                          print("Context form found, rendering..."); 
                                        } else {
                                          print("No context template found for this tag.");
                                        }
                                      }
                                    setState(() {
                                      selectedTagIndexLocal = idx;
                                      showWebView = true;
                                      selectedTagData = tag; // Store the selected tag data
                                    });
                                  } else {
                                    setState(() {
                                      selectedTagIndexLocal = null;
                                      showWebView = false;
                                      selectedTagData = null; // Clear selected tag data
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
                        margin: const EdgeInsets.only(top: 16, right: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[600]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: InAppWebView(
                                      initialData: InAppWebViewInitialData(
                                        data: appendScriptWithHtml(htmlForm),
                                      ),
                                      onWebViewCreated: (controller) {
                                        webViewController = controller; // Store controller reference
                                        print('🔧 WebView controller stored successfully');
                                        if (!kIsWeb) {
                                          // Add handler for MessageChannel setup
                                          controller.addJavaScriptHandler(
                                            handlerName: 'setupMessageChannel',
                                            callback: (args) {
                                              print('✅ Submit trigger setup complete: ${args[0]}');
                                            },
                                          );
                                          
                                          controller.addJavaScriptHandler(
                                            handlerName: 'onFormSubmit',
                                            callback: (args) {
                                              String jsonString = args[0];
                                              print('Received JSON string: $jsonString');
                                              // Add bounds checking before accessing joinedTags array
                                              if (jsonString.isNotEmpty) {
                                                final entityName = _entityController.text.trim();
                                                final channelName = selectedChannelIndexLocal != null 
                                                ? pubChannels[selectedChannelIndexLocal!]['channelname'] ?? 'Unknown Channel'
                                                : 'Unknown Channel';
                                                final tagId = selectedTagData != null 
                                                    ? (selectedTagData!['tagid'] ?? selectedTagData!['tagId'] ?? 'Unknown TagID').toString()
                                                    : 'Unknown TagID';
                                                print('Entity Name: $entityName');
                                                print('Channel Name: $channelName');
                                                print('Tag ID: $tagId');
                                                createEncryptedDocument(entityName, channelName, tagId, jsonString);
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
                                backgroundColor: Colors.red.withOpacity(0.8),
                                onPressed: () {
                                  setState(() {
                                    showWebView = false;
                                    selectedTagIndexLocal = null;
                                    selectedTagData = null; // Clear selected tag data
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
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
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                // Cancel button - always on the left
                TextButton(
                  onPressed: () => Navigator.pop(context),
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
                            selectedTagData = null; // Clear selected tag data
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
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                              await webViewController!.evaluateJavascript(
                                source: '''
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
                                '''
                              );
                              
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
                                content: Text('WebView not ready. Please wait and try again.'),
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
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ],
            ); // AlertDialog
          },
        );
      },
    );
  }

  Future<String> renderResume(String jsonContent) async {
    final raw = htmlResume;

    final context = Context.create();

    // context.variables['basics'] = jsonDecode(jsonContent)["basics"];
    context.variables = jsonDecode(jsonContent);

    final template = Template.parse(context, Source.fromString(raw));
    final result = await template.render(context);
    return result;
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
                          child: Text('Error: ${snapshot.error}'),
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
    final channelId = channels[index]["channelid"]?.toString() ?? channels[index]["id"]?.toString();
    
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
            selectedjoinedTagIndex = null;
            selectedTagIndex = null;
            docs = [];
            joinedTags = [];
            currentChatMessages = [];
          });
        } else if (selectedChannelIndex != null && selectedChannelIndex! > index) {
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
            selectedjoinedTagIndex = index;
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
            selectedjoinedTagIndex = index;
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
    });
    print('Fetching document details for docId: $docId');
    final docDetails = await dashboardController.getDocumentDetails(docId);
    if (docDetails != null) {
      // print("......................................${docDetails['jsonData']}");
      // print("......................................${docDetails['htmlTheme']}");
      final availableEvents = docDetails['data']['documentDetails']
          ['available_events'] as List<dynamic>;
      if (docDetails["jsonData"] != null) {
        setState(() {
          // currentChatMessages = [];
          selectedjoinedTagIndex = index;
          // selectedDocIndex = index;
          htmlResume = docDetails['htmlTheme'];
          jsonHtmlTheme = docDetails['jsonData'];

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
                    "<form><input type='text' required name='${eventName}' placeholder='Enter text...' /><br><button type='submit'>${eventName}</button></form>",
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
          selectedjoinedTagIndex = index;
          currentChatMessages.add({
            "sender": "Unknown",
            "message":
                "Error while loading data", // Or whatever text you want to show
            "isFile": false,
          });
        });
      }
    }
  }

  Widget buildDocsListOrTagsList() {
    final isChannelOwner = selectedChannelIndex != null &&
        channels[selectedChannelIndex!]["actorsequence"] == 1;

    final bool isLoading = isChannelOwner ? isDocsLoading : isjoinedTagsLoading;
    final List<Map<String, dynamic>> tagsList =
        List<Map<String, dynamic>>.from(joinedTags);
    final List<Map<String, dynamic>> docsList =
        List<Map<String, dynamic>>.from(docs);

    // Use the same loading condition as original
    if (isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Merge lists for a single scroll, tags first
    final List<Map<String, dynamic>> combinedList = [
      ...tagsList.map((item) => {...item, "type": "tag"}),
      ...docsList.map((item) => {...item, "type": "doc"}),
    ];

    // Show generic message if no tags nor docs
    if (combinedList.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            "No document found",
            style: TextStyle(color: subtitleColor),
          ),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        itemCount: combinedList.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final item = combinedList[index];
          final isTag = item["type"] == "tag";

          // Compute correct relative index for docs
          final docRelativeIndex = index - tagsList.length;

          // Selection logic
          final isSelected = isTag
              ? selectedTagIndex == index // use real tag index
              : selectedDocIndex == docRelativeIndex; // relative doc index

          // Display name
          final displayName = isTag
              ? item["tagName"] ?? "Tag ${item["tagId"]}"
              : item["docname"] ?? "Doc $docRelativeIndex";

          return GestureDetector(
            onTap: () {
              if (isTag) {
                setState(() {
                  selectedTagIndex = index;
                  selectedDocIndex = -1; // reset doc selection
                });
                
                getContextAndPublicKey(
                  item["oldEntityId"],
                  item["oldChannelName"],
                  item["tagId"],
                  false,
                  index,
                );
              } else {
                setState(() {
                  selectedDocIndex = docRelativeIndex;
                  selectedTagIndex = -1; // reset tag selection
                });
                getDocumentDetails(item["docid"], docRelativeIndex);
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
                                  : (isDarkMode ? Colors.grey[700] : borderColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isTag ? Icons.label_outline : Icons.description_outlined,
                              color: isSelected
                                  ? (isDarkMode ? Colors.white : primaryAccent)
                                  : subtitleColor,
                              size: 20,
                            ),
                          ),
                        ),
                      )
                    : ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            isTag ? Icons.label_outline : Icons.description_outlined,
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
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
      } else if (!isChannelOwner &&
          selectedjoinedTagIndex != null &&
          joinedTags.isNotEmpty &&
          selectedjoinedTagIndex! >= 0 &&
          selectedjoinedTagIndex! < joinedTags.length) {
        // item["tagName"] ?? "Tag ${item["tagId"]}
        chatTitle =
            "Job: ${joinedTags[selectedjoinedTagIndex!]["tagName"] ?? "Unknown"}";
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
                                    data: appendScriptWithHtml(htmlForm),
                                  ),
                                  onWebViewCreated: (controller) {
                                    if (!kIsWeb) {
                                      controller.addJavaScriptHandler(
                                        handlerName: 'onFormSubmit',
                                        callback: (args) {
                                          String jsonString = args[0];
                                          print(
                                              'Received JSON string: $jsonString');
                                          // Add bounds checking before accessing joinedTags array
                                          if (selectedjoinedTagIndex != null &&
                                              selectedjoinedTagIndex! >= 0 &&
                                              selectedjoinedTagIndex! <
                                                  joinedTags.length) {
                                            createEncryptedDocument(
                                              joinedTags[
                                                      selectedjoinedTagIndex!]
                                                  ["oldEntityId"],
                                              joinedTags[
                                                      selectedjoinedTagIndex!]
                                                  ["oldChannelName"],
                                              joinedTags[
                                                      selectedjoinedTagIndex!]
                                                  ["tagId"],
                                              jsonString,
                                            );
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
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(tr('Close')),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  enabled: !(currentChatMessages.isNotEmpty &&
                      currentChatMessages.last["isFile"] == true),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.upload_file, color: Colors.white),
                tooltip: 'Upload form',
                onPressed: (currentChatMessages.isNotEmpty &&
                        currentChatMessages.last["isFile"] == true)
                    ? null
                    : () => _showUploadMethodDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.attach_file, color: Colors.white),
                tooltip: 'Attach a file',
                onPressed: (currentChatMessages.isNotEmpty &&
                        currentChatMessages.last["isFile"] == true)
                    ? null
                    : uploadFile,
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: (currentChatMessages.isNotEmpty &&
                        currentChatMessages.last["isFile"] == true)
                    ? null
                    : sendMessage,
              ),
            ],
          ),
        ),
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
    List<StatusNode> roots = parseStatusTree(dashboardController.statusJson);
    Widget statusNodeWidget(StatusNode node, {double indent = 0}) {
      bool active = currentDocStatus == node.value;
      Color nodeColor = active
          ? Colors.blueAccent
          : (isDarkMode ? Colors.grey[600]! : Colors.grey[500]!);
      FontWeight nodeFontWeight = active ? FontWeight.bold : FontWeight.normal;

      return Padding(
        padding: EdgeInsets.only(left: indent),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: nodeColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isDarkMode ? Colors.white : Colors.grey[700]!,
                        width: 2),
                  ),
                ),
                Text(
                  node.label,
                  style: TextStyle(
                    color: nodeColor,
                    fontWeight: nodeFontWeight,
                  ),
                ),
              ],
            ),
            ...node.children
                .map((c) => statusNodeWidget(c, indent: indent + 24))
                .toList(),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            "Document Status",
            style: TextStyle(
                fontSize: 20, color: textColor, fontWeight: FontWeight.bold),
          ),
        ),
        ...roots.map((node) => statusNodeWidget(node)).toList(),
      ],
    );
  }

  Widget _buildChannelItem(int index) {
    bool isSelected = selectedChannelIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
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
              fetchJoinedTags(channels[index]["channelname"]);
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
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: (isSidebarCollapsed
                        ? 75.0
                        : (MediaQuery.of(context).size.width > 1200
                            ? 160.0
                            : 140.0)) -
                    20,
                height: 50,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                    horizontal: isSidebarCollapsed ? 4 : 12),
                child: Text(
                  isSidebarCollapsed
                      ? channels[index]["channelname"].length >= 2
                          ? channels[index]["channelname"]
                              .substring(0, 2)
                              .toUpperCase()
                          : channels[index]["channelname"].toUpperCase()
                      : channels[index]["channelname"],
                  style: TextStyle(
                    color: isSelected ? Colors.white : textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: isSidebarCollapsed ? 12 : 14,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: isSidebarCollapsed ? 1 : 2,
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
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                          selectedEntityForSwitching ?? (selectedEntity.isNotEmpty ? selectedEntity : 'No Entity'),
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
            const minWidth = 80.0;  // Increased slightly for better usability
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
                              colors: [primaryAccent, primaryAccent.withOpacity(0.8)],
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
                                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
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
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: primaryAccent, width: 2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                // User info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedEntityForSwitching ?? (selectedEntity.isNotEmpty ? selectedEntity : 'No Entity'),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Online',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
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
                        _buildSimpleProfileMenuItem(Icons.swap_horiz, 'Switch Account'),
                        _buildSimpleProfileMenuItem(Icons.language, 'Select Language'),
                        _buildSimpleProfileMenuItem(Icons.list_alt, 'View Logs'),
                        
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
                            Future.delayed(const Duration(milliseconds: 100), () {
                              _showLogoutDialog();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
        _showSwitchAccountDialog();
        break;
      case 'Select Language':
        _showLanguageDialog();
        break;
      case 'View Logs':
        DashboardLogsView.showLogsDialog(context, dashboardController);
        break;
    }
  }

  // Show switch account dialog
  void _showSwitchAccountDialog() {
    print("Opening switch account dialog - entities: $entities, length: ${entities.length}");
    
    // Fallback test data if entities are empty
    List<dynamic> displayEntities = entities.isNotEmpty 
      ? entities 
      : [
          {'tenant': 'basit.munir19@gmail.com'},
          {'tenant': 'info@advcomm.net'},
        ];
    
    print("Display entities: $displayEntities");
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 320,
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
                          Icons.swap_horiz,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Switch Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Entities list
                // Container(
                //   padding: const EdgeInsets.all(16),
                //   child: Text(
                //     'Debug: Entities length: ${entities.length}, Display entities length: ${displayEntities.length}',
                //     style: TextStyle(color: subtitleColor, fontSize: 12),
                //   ),
                // ),
                if (displayEntities.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: displayEntities.map<Widget>((entity) {
                        final isSelected = entity['tenant'] == selectedEntityForSwitching;
                        final entityName = entity['tenant'] ?? 'Unknown Tenant';
                        
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected 
                              ? primaryAccent.withOpacity(0.1)
                              : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                              ? Border.all(color: primaryAccent.withOpacity(0.3))
                              : null,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: isSelected ? null : () {
                                setState(() {
                                  selectedEntityForSwitching = entity['tenant'];
                                });
                                Navigator.of(context).pop();
                                
                                // Show success notification
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                                        const SizedBox(width: 12),
                                        Text('Switched to $entityName'),
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
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    // Entity icon
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                          ? primaryAccent
                                          : subtitleColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        Icons.business,
                                        color: isSelected 
                                          ? Colors.white
                                          : primaryAccent,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    
                                    // Entity name
                                    Expanded(
                                      child: Text(
                                        entityName,
                                        style: TextStyle(
                                          color: isSelected ? primaryAccent : textColor,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    
                                    // Check icon for selected entity
                                    if (isSelected)
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
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.business_center,
                          color: subtitleColor,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No entities available',
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Cancel button
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
                      final isCurrentLanguage = _currentLocale?.languageCode == locale.languageCode;
                      final languageName = _getLanguageName(locale);
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: isCurrentLanguage 
                            ? primaryAccent.withOpacity(0.1)
                            : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isCurrentLanguage
                            ? Border.all(color: primaryAccent.withOpacity(0.3))
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
                                      Icon(Icons.check_circle, color: Colors.white, size: 20),
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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                        color: isCurrentLanguage ? primaryAccent : textColor,
                                        fontWeight: isCurrentLanguage ? FontWeight.w600 : FontWeight.normal,
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
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
    // Dynamic sidebar width based on screen size and collapse state
    final normalSidebarWidth = constraints.maxWidth > 1200 ? 160.0 : 140.0;
    final collapsedSidebarWidth = 75.0; // Width when collapsed
    final sidebarWidth =
        isSidebarCollapsed ? collapsedSidebarWidth : normalSidebarWidth;
    
    // Initialize docs width if not set, make it responsive
    if (_docsWidth == 250.0) {
      _docsWidth = constraints.maxWidth > 1200 ? 280.0 : 220.0;
    }
    // No need for channelSize since we're always showing full names

    return Stack(
      children: [
        Row(
          children: [
            // Left Sidebar (Channels with Long Press Options)
            Container(
              width: sidebarWidth,
              color: backgroundColor,
              child: Column(
                children: [
                  // Logo Section (always visible)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
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
                                  ...channelsSeq0
                                      .map((index) => _buildChannelItem(index)),

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
                                  ...channelsSeq1
                                      .map((index) => _buildChannelItem(index)),
                                ],
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              "No Channels",
                              style:
                                  TextStyle(color: subtitleColor, fontSize: 12),
                            ),
                          ),
                  ),
                  // Add Channel Button (bottom)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => _showCreateChannelDialog(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        width: sidebarWidth - 20,
                        height: 50,
                        child: isSidebarCollapsed
                            ? const Icon(Icons.add,
                                color: Colors.white, size: 20)
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Add Channel',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  // Discord-like settings area for left sidebar
                  _buildLeftSidebarSettingsArea(sidebarWidth),
                ],
              ),
            ),
            // Vertical divider between Left Sidebar and Middle Panel
            Container(
              width: 1,
              color: borderColor,
            ),
            // Middle Panel (Docs)
            Container(
              width: _docsWidth,
              color: surfaceColor,
              child: Column(
                children: [
                  // Show compose button if "Sent" channel is selected
                  // if (selectedChannelIndex != null &&
                  //     channels[selectedChannelIndex!]["channelname"] == "Sent")
                  if (selectedChannelIndex != null &&
                      channels[selectedChannelIndex!]["actorsequence"] == 0)
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Document',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        onPressed: () {
                          // Show compose dialog instead of toggling mode
                          _showComposeDialog(context);
                        },
                      ),
                    ),
                  buildDocsListOrTagsList(),
                ],
              ),
            ),
            // Resizable divider between Middle Panel and Right Panel
            _buildResizableDivider(),
            // Right Panel (Chat Panel)
            Expanded(
              child: Stack(
                children: [
                  Container(
                    color: cardColor,
                    child: (selectedChannelIndex == null)
                        ? Center(
                            child: Text(
                              "Please select a channel",
                              style: TextStyle(color: textColor),
                            ),
                          )
                        : ((selectedChannelIndex != null &&
                                    channels[selectedChannelIndex!]
                                            ["actorsequence"] ==
                                        1
                                ? isDocsLoading
                                : isjoinedTagsLoading))
                            ? const Center(child: CircularProgressIndicator())
                            : ((selectedChannelIndex != null &&
                                        channels[selectedChannelIndex!]
                                                ["actorsequence"] ==
                                            1
                                    ? (selectedDocIndex == null)
                                    : (selectedjoinedTagIndex == null)))
                                ? Center(
                                    child: Text(
                                      "Please select a doc",
                                      style: TextStyle(color: textColor),
                                    ),
                                  )
                                : buildChatColumn(),
                  ),
                  // Top-Right Button (Menu button for right sidebar)
                  if (selectedChannelIndex != null &&
                      (channels[selectedChannelIndex!]["actorsequence"] == 1
                          ? selectedDocIndex != null
                          : selectedjoinedTagIndex != null))
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
        // Small button positioned at the divider line in front of logo
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
                  isSidebarCollapsed ? Icons.chevron_right : Icons.chevron_left,
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
