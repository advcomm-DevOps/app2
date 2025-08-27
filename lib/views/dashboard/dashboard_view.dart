import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:xdoc/custom/constants.dart';
import 'package:xdoc/custom/services/rsa.dart';
import 'package:xdoc/custom/services/sso.dart';
import 'package:xdoc/views/dashboard/dashboard_model.dart';
import 'package:xdoc/views/dashboard/form_resume.dart';
import '../nav/custom_app_bar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'platform_web.dart' if (dart.library.io) 'platform_non_web.dart';
import 'package:liquid_engine/liquid_engine.dart';
import 'dashboard_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  final String qrurl = kIsWeb
      ? 'https://web.xdoc.app/c/' // If running on Web
      : 'app2://c/';
  // final String qrurl = 'https://web.xdoc.app/c/';
  // final String qrurl = 'xdoc://c/';
  // final String qrurl = 'http://localhost:3001/c/';
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

  List<dynamic> publicInterconnects = [];
  String? selectedInterconnectId;
  List<dynamic> respondentActors = [];
  String? selectedActorId;

  final TextEditingController messageController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _htmlController = TextEditingController();
  final TextEditingController _channelNameController = TextEditingController();

  String htmlForm = getResumeForm();
  String htmlResume = "";
  String jsonHtmlTheme = "";

  List<Map<String, dynamic>> currentChatMessages = [];

  bool get isLastFile {
    if (currentChatMessages.isEmpty) return false;
    final lastMessage = currentChatMessages.last;
    return lastMessage["isFile"] == true;
  }

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

  Future<void> loadSelectedEntity() async {
    final ssoService = SSOService();
    final entity = await ssoService.getSelectedEntity();
    setState(() {
      selectedEntity = '${entity ?? ''}/';
    });
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
  }

  Future<void> initSetup() async {
    await generateRSAKeyPair();
  }

  Future<void> fetchChannels() async {
    try {
      final data = await dashboardController.fetchChannels();
      if (data.isNotEmpty) {
        setState(() {
          channels = data;
        });
      } else {
        print("No channels found.");
      }
      validateSection();
    } catch (e) {
      print("Error fetching channels: $e");
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
                joinNewChannel(secQr!, entityQr!, tagid, tagname);
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
      dashboardController.addTagIfNotExists(
        oldEntityId: entityQr!,
        tagId: tagid!,
        oldChannelName: secQr!,
        newChannelName: newSecQr!,
        tagName: tagname!,
      );
      setState(() {
        selectedChannelIndex = index;
        selectedDocIndex = null;
        docs = [];
        currentChatMessages = [];
      });
      fetchDocs(channels[index]["channelname"]);
    }
  }

  void joinNewChannel(
      String sectionName, String entityName, String? tagid, String? tagname) {
    dashboardController
        .joinChannel(entityName, sectionName, tagid, tagname)
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
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Create New Channel',
                style: TextStyle(
                  color: Colors.white,
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
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create New Tag',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
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
                          labelText: 'Expire At *',
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
                        tagDescriptionController.text.isEmpty ||
                        expireAtController.text.isEmpty) {
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

  Widget buildComposeView() {
    String composeHtml = '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Compose Message</title>
        <style>
            body {
                background-color: transparent;
                color: #ffffff;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            }
            /* Quill Editor Dark Theme Styles */
            #editor {
                height: 300px;
                background-color: #2a2a2a;
                border: 1px solid #555;
                border-radius: 8px;
                color: #ffffff;
            }
            .ql-toolbar {
                background-color: #3a3a3a;
                border: 1px solid #555;
                border-bottom: none;
                border-radius: 8px 8px 0 0;
            }
            .ql-container {
                background-color: #2a2a2a;
                border: 1px solid #555;
                border-top: none;
                border-radius: 0 0 8px 8px;
                color: #ffffff;
            }
            .ql-editor {
                color: #ffffff;
                font-size: 14px;
            }
            .ql-editor.ql-blank::before {
                color: #999;
                font-style: italic;
            }
            /* Toolbar button styles */
            .ql-toolbar .ql-stroke {
                stroke: #ffffff;
            }
            .ql-toolbar .ql-fill {
                fill: #ffffff;
            }
            .ql-toolbar .ql-picker-label {
                color: #ffffff;
            }
            .ql-toolbar .ql-picker-options {
                background-color: #3a3a3a;
                border: 1px solid #555;
            }
            .ql-toolbar .ql-picker-item {
                color: #ffffff;
            }
            .ql-toolbar .ql-picker-item:hover {
                background-color: #4a4a4a;
            }
            .ql-toolbar button:hover {
                background-color: #4a4a4a;
            }
            .ql-toolbar button.ql-active {
                background-color: #4a9eff;
            }
            /* Custom dark form styles */
            .form-control {
                background-color: #2a2a2a !important;
                border-color: #555 !important;
                color: #ffffff !important;
            }
            .form-control:focus {
                background-color: #2a2a2a !important;
                border-color: #4a9eff !important;
                box-shadow: 0 0 0 0.2rem rgba(74, 158, 255, 0.25) !important;
                color: #ffffff !important;
            }
            .form-label {
                color: #b0b0b0 !important;
                font-weight: 500;
            }
        </style>
    </head>
    <body class="bg-transparent text-white">
        <div class="container-fluid p-5">
            <div class="card bg-dark border-secondary shadow">
                <div class="card-body p-4">
                    <form id="composeForm">
                        <div class="mb-3">
                            <label for="to" class="form-label">To:</label>
                            <input type="email" id="to" name="to" class="form-control" placeholder="recipient@example.com" required>
                        </div>
                        
                        <div class="mb-3">
                            <label for="subject" class="form-label">Subject:</label>
                            <input type="text" id="subject" name="subject" class="form-control" placeholder="Enter subject" required>
                        </div>
                        
                        <div class="mb-3">
                            <label for="message" class="form-label">Message:</label>
                            <div id="editor"></div>
                        </div>
                        
                        <div class="d-flex justify-content-end gap-3 pt-3 border-top border-secondary">
                            <button type="submit" class="btn btn-primary">Send Message</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </body>
    </html>
    ''';
    if (kIsWeb) {
      composeHtml =
          '$composeHtml<script>${dashboardController.formHandlingJS}</script>';
    }
    return Container(
      color: Colors.grey[800], // Flutter background
      child: Column(
        children: [
          // Flutter Header
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(bottom: BorderSide(color: Colors.grey[700]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Compose Message',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      isComposeMode = false;
                    });
                  },
                ),
              ],
            ),
          ),

          // InAppWebView with form only
          Expanded(
            child: InAppWebView(
              initialData: InAppWebViewInitialData(data: composeHtml),
              onWebViewCreated: (controller) {
                // Add handlers for communication with the web view
                if (!kIsWeb) {
                  controller.addJavaScriptHandler(
                    handlerName: 'onFormSubmit',
                    callback: (args) {
                      String jsonString = args[0];
                      print('Received JSON string: $jsonString');
                      Map<String, dynamic> formData = jsonDecode(jsonString);
                      print('Received JSON: $formData');

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Message sent successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Exit compose mode
                      setState(() {
                        isComposeMode = false;
                      });
                    },
                  );
                } else {
                  handleWebMessage();
                  final stream = handleWebMessage();
                  stream.listen((jsonString) {
                    print('Received JSON: $jsonString');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Message sent successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Exit compose mode
                    setState(() {
                      isComposeMode = false;
                    });
                  });
                }
              },
              onLoadStop: (controller, url) async {
                // Inject Bootstrap 5 and Quill CSS/JS
                if (!kIsWeb) {
                  await controller.evaluateJavascript(
                      source: dashboardController.formHandlingJS);
                }
              },
            ),
          ),
        ],
      ),
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
      print('Fetched docs........................................: $docsList');
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
    return html = "$html<script>${dashboardController.formHandlingJS}</script>";
  }

  void _handleAction(String action, String fileName, String html) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Form Actions',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey[800],
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
                      updateEncryptedEvent(
                          action, docs[selectedDocIndex!]["docid"], jsonString);
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
          backgroundColor: Colors.grey[800],
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  qrData,
                  style: const TextStyle(color: Colors.white),
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
              child: const Text('Copy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showChannelOptionsBottomSheet(context, index);
              },
              child: const Text('Close'),
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
          title:
              const Text('Upload Form', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[800],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select how you want to upload the form:',
                  style: TextStyle(color: Colors.white70)),
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
          title: const Text('Enter Form URL',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[800],
          content: TextField(
            controller: _urlController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'https://example.com/form',
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white70)),
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
          title: const Text('Enter HTML Form',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[800],
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              controller: _htmlController,
              maxLines: 10,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: '<form>...</form>',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white70)),
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
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey[800],
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
              child:
                  const Text('Close', style: TextStyle(color: Colors.white70)),
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
          child: SizedBox(
            width: double.infinity,
            height: 800,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.blueGrey,
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
      backgroundColor: Colors.grey[850],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedChannelIndex != null &&
                channels[selectedChannelIndex!]["actorsequence"] == 1)
              ListTile(
                leading: const Icon(Icons.qr_code, color: Colors.white),
                title: Text(
                  'Show QR Code for ${channels[index]["channelname"]}',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  String qrData =
                      qrurl + selectedEntity + channels[index]["channelname"];
                  showQrDialog(context, qrData, index);
                },
              ),
            const SizedBox(height: 10),

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
                  leading: const Icon(Icons.label, color: Colors.white70),
                  title: Text(
                    tag["tag"],
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    String qrData = qrurl +
                        selectedEntity +
                        channels[index]["channelname"] +
                        "/" +
                        tag["channeltagid"].toString();
                    showQrDialog(context, qrData, index);
                  },
                );
              }).toList()
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "No Tags Available",
                  style: TextStyle(color: Colors.white54),
                ),
              ),
          ],
        );
      },
    );
  }

  void getContextAndPublicKey(
      oldEntityId, oldChannelName, tagId, isChannelOwner, index) async {
    if (isChannelOwner) {
      setState(() {
        currentChatMessages = [];
        selectedDocIndex = index;
        // currentChatMessages = dashboardController.documentChats[item["docname"]] ?? [];
      });
    } else {
      final contextData = await dashboardController.getContextAndPublicKey(
          oldEntityId, oldChannelName, tagId);

      print("Context Data: $contextData");
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
        channels[selectedChannelIndex!]["actorsequence"] == "1";

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
      return const Expanded(
        child: Center(
          child: Text(
            "No data found",
            style: TextStyle(color: Colors.white),
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

          // Keep correct selection index logic as original
          final isSelected = isTag
              ? (isChannelOwner ? false : selectedjoinedTagIndex == index)
              : (isChannelOwner
                  ? selectedDocIndex == (index - tagsList.length)
                  : false);

          // Display name logic preserved
          final displayName = isTag
              ? item["tagName"] ?? "Tag ${item["tagId"]}"
              : (item["docname"] ?? "Doc ${index - tagsList.length}");

          return GestureDetector(
            onTap: () {
              if (isTag) {
                getContextAndPublicKey(
                  item["oldEntityId"],
                  item["oldChannelName"],
                  item["tagId"],
                  false, // because it's a tag
                  index,
                );
              } else {
                getDocumentDetails(
                    item["docid"],
                    index -
                        joinedTags
                            .length); // or item["docname"] if you need that
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueGrey[700] : Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                // leading: CircleAvatar(
                //   backgroundColor: Colors.blueAccent,
                //   child: Text(
                //     displayName[0].toUpperCase(),
                //     style: const TextStyle(
                //         color: Colors.white, fontWeight: FontWeight.bold),
                //   ),
                // ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius:
                        BorderRadius.circular(8), // Square with rounded corners
                  ),
                  child: Center(
                    child: Text(
                      displayName[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                title: Text(
                  displayName,
                  style: const TextStyle(color: Colors.white),
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
          channels[selectedChannelIndex!]["actorsequence"] == "1";
      if (isChannelOwner && selectedDocIndex != null && docs.isNotEmpty) {
        chatTitle =
            "Document: ${docs[selectedDocIndex!]["docname"] ?? "Unknown"}";
      } else if (!isChannelOwner &&
          selectedjoinedTagIndex != null &&
          joinedTags.isNotEmpty) {
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
            color: Colors.grey[900],
            border: Border(bottom: BorderSide(color: Colors.grey[700]!)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  chatTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
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
                                          createEncryptedDocument(
                                            joinedTags[selectedjoinedTagIndex!]
                                                ["oldEntityId"],
                                            joinedTags[selectedjoinedTagIndex!]
                                                ["oldChannelName"],
                                            joinedTags[selectedjoinedTagIndex!]
                                                ["tagId"],
                                            jsonString,
                                          );
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
      Color nodeColor = active ? Colors.blueAccent : Colors.grey[600]!;
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
                    border: Border.all(color: Colors.white, width: 2),
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
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            "Document Status",
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        ...roots.map((node) => statusNodeWidget(node)).toList(),
      ],
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth <= 768;

          if (isMobile) {
            return _buildMobileLayout(hasChannels);
          } else {
            return _buildTabletDesktopLayout(hasChannels, constraints);
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout(bool hasChannels) {
    return Stack(
      children: [
        Column(
          children: [
            // Top navigation bar for mobile
            Container(
              height: 60,
              color: Colors.grey[900],
              child: Row(
                children: [
                  // Channels dropdown/selector
                  Expanded(
                    child: hasChannels
                        ? DropdownButton<int>(
                            value: selectedChannelIndex,
                            hint: const Text('Select Channel',
                                style: TextStyle(color: Colors.white)),
                            dropdownColor: Colors.grey[800],
                            style: const TextStyle(color: Colors.white),
                            underline: Container(),
                            isExpanded: true,
                            items: channels.asMap().entries.map((entry) {
                              int index = entry.key;
                              Map<String, dynamic> channel = entry.value;
                              return DropdownMenuItem<int>(
                                value: index,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Text(
                                    channel["channelname"],
                                    style: const TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (int? newIndex) {
                              if (newIndex != null) {
                                setState(() {
                                  selectedChannelIndex = newIndex;
                                  selectedDocIndex = null;
                                  docs = [];
                                  currentChatMessages = [];
                                  isComposeMode =
                                      false; // Reset compose mode when switching channels
                                });
                                fetchDocs(channels[newIndex]["channelname"]);
                                fetchJoinedTags(
                                    channels[newIndex]["channelname"]);
                              }
                            },
                          )
                        : const Center(
                            child: Text(
                              "No Channels",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                  ),
                  if (selectedChannelIndex != null)
                    IconButton(
                      onPressed: () async {
                        // if (channels[selectedChannelIndex!]["actorsequence"] == "1") {
                        await fetchTags(
                            channels[selectedChannelIndex!]["channelid"]);
                        _showChannelOptionsBottomSheet(
                            context, selectedChannelIndex!);
                        // }
                      },
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                    ),
                  // Add channel button
                  Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () => _showCreateChannelDialog(context),
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                  // Menu button for channel options
                ],
              ),
            ),
            // Main content area
            Expanded(
              child: selectedChannelIndex == null
                  ? Container(
                      color: Colors.grey[850],
                      child: const Center(
                        child: Text(
                          "Please select a channel",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        // Docs/Tags list (1/3 of screen)
                        Expanded(
                          flex: 1,
                          child: Container(
                            color: Colors.grey[850],
                            child: Column(
                              children: [
                                // Show compose button if "Sent" channel is selected actorsequence
                                // if (selectedChannelIndex != null &&
                                //     channels[selectedChannelIndex!]["channelname"] == "Sent")
                                if (selectedChannelIndex != null &&
                                    channels[selectedChannelIndex!]
                                            ["actorsequence"] ==
                                        0)
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[600],
                                        minimumSize:
                                            const Size(double.infinity, 40),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      icon: Icon(
                                          isComposeMode
                                              ? Icons.close
                                              : Icons.add,
                                          color: Colors.white,
                                          size: 18),
                                      label: Text(
                                        isComposeMode ? 'Close' : 'Document',
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.white),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isComposeMode = !isComposeMode;
                                        });
                                      },
                                    ),
                                  ),
                                buildDocsListOrTagsList(),
                              ],
                            ),
                          ),
                        ),
                        // Chat area (2/3 of screen)
                        Expanded(
                          flex: 2,
                          child: Container(
                            color: Colors.grey[800],
                            child: isComposeMode
                                ? buildComposeView()
                                : ((selectedChannelIndex != null &&
                                            channels[selectedChannelIndex!]
                                                    ["actorsequence"] ==
                                                "1"
                                        ? isDocsLoading
                                        : isjoinedTagsLoading))
                                    ? const Center(
                                        child: CircularProgressIndicator())
                                    : ((selectedChannelIndex != null &&
                                                channels[selectedChannelIndex!]
                                                        ["actorsequence"] ==
                                                    "1"
                                            ? (selectedDocIndex == null)
                                            : (selectedjoinedTagIndex == null)))
                                        ? const Center(
                                            child: Text(
                                              "Please select a doc",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )
                                        : Stack(
                                            children: [
                                              buildChatColumn(),
                                              if (selectedChannelIndex !=
                                                      null &&
                                                  (channels[selectedChannelIndex!]
                                                              [
                                                              "actorsequence"] ==
                                                          "1"
                                                      ? selectedDocIndex != null
                                                      : selectedjoinedTagIndex !=
                                                          null))
                                                Positioned(
                                                  top: 10,
                                                  right: 10,
                                                  child: IconButton(
                                                    icon: const Icon(
                                                        Icons.menu_open,
                                                        color: Colors.white),
                                                    onPressed: () {
                                                      setState(() {
                                                        showRightSidebar = true;
                                                      });
                                                    },
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
        // Right sidebar overlay for mobile
        if (showRightSidebar)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showRightSidebar = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {}, // Prevent dismissal when tapping sidebar
                    child: Container(
                      width: 280,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
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

  Widget _buildTabletDesktopLayout(
      bool hasChannels, BoxConstraints constraints) {
    // Dynamic sidebar width based on screen size - show full names for all non-mobile screens
    final sidebarWidth = 200.0; // Always use wider sidebar for tablet/desktop
    final docsWidth = constraints.maxWidth > 1200 ? 250.0 : 200.0;
    // No need for channelSize since we're always showing full names

    return Stack(
      children: [
        Row(
          children: [
            // Left Sidebar (Channels with Long Press Options)
            Container(
              width: sidebarWidth,
              color: Colors.grey[900],
              child: Column(
                children: [
                  // Logo or App Icon at top (optional)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: constraints.maxWidth > 1200 ? 24 : 20,
                      backgroundColor: Colors.transparent,
                      child: SvgPicture.asset(
                        'assets/images/xdoc_logo.svg',
                        width: constraints.maxWidth > 1200 ? 40 : 32,
                        height: constraints.maxWidth > 1200 ? 40 : 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Channels List
                  Expanded(
                    child: hasChannels
                        ? ListView.builder(
                            itemCount: channels.length,
                            itemBuilder: (context, index) {
                              bool isSelected = selectedChannelIndex == index;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedChannelIndex = index;
                                          selectedDocIndex = null;
                                          docs = [];
                                          currentChatMessages = [];
                                          isComposeMode =
                                              false; // Reset compose mode when switching channels
                                        });
                                        fetchDocs(
                                            channels[index]["channelname"]);
                                        fetchJoinedTags(
                                            channels[index]["channelname"]);
                                      },
                                      child: Tooltip(
                                        message: channels[index]["channelname"],
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.blueAccent
                                                : Colors.grey[800],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          width: sidebarWidth - 20,
                                          height: 50,
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: Text(
                                            channels[index]["channelname"],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Three dots menu button
                                    // if (channels[index]["actorsequence"] == "1")
                                    Positioned(
                                      top: 2,
                                      right: 12,
                                      child: GestureDetector(
                                        onTap: () async {
                                          // Set the channel as selected if not already
                                          if (selectedChannelIndex != index) {
                                            setState(() {
                                              selectedChannelIndex = index;
                                              selectedDocIndex = null;
                                              docs = [];
                                              currentChatMessages = [];
                                              isComposeMode = false;
                                            });
                                          }
                                          await fetchTags(
                                              channels[index]["channelid"]);
                                          _showChannelOptionsBottomSheet(
                                              context, index);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.more_vert,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                              "No Channels",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.white, size: 20),
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
                ],
              ),
            ),
            // Middle Panel (Docs)
            Container(
              width: docsWidth,
              color: Colors.grey[850],
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
                        icon: Icon(isComposeMode ? Icons.close : Icons.add,
                            color: Colors.white),
                        label: Text(
                          isComposeMode ? 'Close' : 'Document',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                        onPressed: () {
                          // Toggle compose mode
                          setState(() {
                            isComposeMode = !isComposeMode;
                          });
                        },
                      ),
                    ),
                  buildDocsListOrTagsList(),
                ],
              ),
            ),
            // Right Panel (Chat Panel)
            Expanded(
              child: Stack(
                children: [
                  Container(
                    color: Colors.grey[800],
                    child: (selectedChannelIndex == null)
                        ? const Center(
                            child: Text(
                              "Please select a channel",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : isComposeMode
                            ? buildComposeView()
                            : ((selectedChannelIndex != null &&
                                        channels[selectedChannelIndex!]
                                                ["actorsequence"] ==
                                            "1"
                                    ? isDocsLoading
                                    : isjoinedTagsLoading))
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : ((selectedChannelIndex != null &&
                                            channels[selectedChannelIndex!]
                                                    ["actorsequence"] ==
                                                "1"
                                        ? (selectedDocIndex == null)
                                        : (selectedjoinedTagIndex == null)))
                                    ? const Center(
                                        child: Text(
                                          "Please select a doc",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )
                                    : buildChatColumn(),
                  ),
                  // Top-Right Button (Menu button for right sidebar)
                  if (selectedChannelIndex != null &&
                      (channels[selectedChannelIndex!]["actorsequence"] == "1"
                          ? selectedDocIndex != null
                          : selectedjoinedTagIndex != null))
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(Icons.menu_open, color: Colors.white),
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
                          color: Colors.grey[850],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
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
}
