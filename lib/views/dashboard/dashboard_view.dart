import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_starter/custom/services/X25519.dart';
import 'package:flutter_starter/custom/services/sso.dart';
import 'package:flutter_starter/views/dashboard/form_resume.dart';
import '../nav/custom_app_bar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'platform_web.dart' if (dart.library.io) 'platform_non_web.dart';
import 'package:liquid_engine/liquid_engine.dart';
import 'dashboard_controller.dart';
import 'package:flutter/services.dart';

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

  final dio = Dio();
  final String apiUrl = 'http://localhost:3000';
  final String qrurl = 'http://localhost:3001/c/';
  // final String qrurl = 'https://s.xdoc.app/c/';
  List<Map<String, dynamic>> channels = [];
  List<Map<String, dynamic>> docs = [];
  List<Map<String, dynamic>> joinedTags = [];
  List<Map<String, dynamic>> tags = [];
  DashboardController dashboardController =
      DashboardController(); // Initialize the controller

  bool isDocsLoading = false;
  bool isjoinedTagsLoading = false;
  bool isTagsLoading = false;
  bool isUploading = false;
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
  final String htmlResume = getResumeHtml();
  final String htmlResume1 = getResumeHtml1();
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

  @override
  void initState() {
    super.initState();
    initSetup();
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
    await generateX25519KeyPair();
  }

  Future<void> fetchChannels() async {
    try {
      String token = await dashboardController.getJwt();
      dio.options.headers["Authorization"] = "Bearer $token";
      final response = await dio.get('$apiUrl/channels');
      if (response.data != null &&
          response.data is List &&
          (response.data as List).isNotEmpty) {
        // print("Fetched channels: ${response.data}");
        setState(() {
          channels = List<Map<String, dynamic>>.from(response.data);
        });
      } else {
        print("No channels found.");
      }
      validateSection();
    } catch (e) {
      print("Error fetching channels: $e");
    }
  }

  void validateSection() {
    secQr = widget.section;
    if (widget.section == "Job Employer") {
      newSecQr = "Job Applicant";
    } else {
      newSecQr = widget.section;
    }
    final tagid = widget.tagid;
    if (secQr == null) return;

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
                joinNewChannel(secQr!, entityQr!, tagid);
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
          newChannelName: newSecQr!);
      setState(() {
        selectedChannelIndex = index;
        selectedDocIndex = null;
        docs = [];
        currentChatMessages = [];
      });
      fetchDocs(channels[index]["channelname"]);
    }
  }

  void joinNewChannel(String sectionName, String entityName, String? tagid) {
    dashboardController
        .joinChannel(entityName, sectionName, tagid)
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

  // Add this method to show the channel creation dialog

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

  Future<void> fetchTags(String channelName) async {
    try {
      setState(() {
        isTagsLoading = true;
        tags = [];
        selectedTagIndex = null;
      });

      final tagsList = await dashboardController.getTags(channelName);
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
            'Form Preview',
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
                    callback: (args) {
                      String jsonString = args[0];
                      print('Received JSON string: $jsonString');
                      Map<String, dynamic> formData = jsonDecode(jsonString);
                      print('Received JSON: $formData');
                      setState(() {
                        currentChatMessages.add({
                          "sender": "System",
                          "message":
                              "You $action the file: ${fileName.split(':').last.trim()}",
                        });
                      });
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
    final raw = htmlResume1;

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
                      const Text("Resume Preview",
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
                channels[selectedChannelIndex!]["actorsequence"] == "1")
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
                        tag["tagid"];
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
      if (contextData != null) {
        setState(() {
          currentChatMessages = [];
          selectedjoinedTagIndex = index;
          htmlForm = contextData["contexttemplate"];
          currentChatMessages = dashboardController.documentChats[tagId] ?? [];
          currentChatMessages.add({
            "sender": "System",
            "message":
                "Click to open form", // Or whatever text you want to show
            "isFile": false,
          });
        });
      }
    }
  }

  Widget buildDocsListOrTagsList() {
    final isChannelOwner = selectedChannelIndex != null &&
        channels[selectedChannelIndex!]["actorsequence"] == "1";

    final listData = isChannelOwner ? docs : joinedTags;
    final isLoading = isChannelOwner ? isDocsLoading : isjoinedTagsLoading;
    final selectedIndex =
        isChannelOwner ? selectedDocIndex : selectedjoinedTagIndex;

    if (isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (listData.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            isChannelOwner ? "No Docs Available" : "No Tags Available",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: listData.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final item = listData[index];
          final isSelected = selectedIndex == index;

          // Get display name
          final displayName =
              isChannelOwner ? item["docname"] : "Job ${item["tagId"]}";

          return GestureDetector(
            onTap: () {
              getContextAndPublicKey(item["oldEntityId"],
                  item["oldChannelName"], item["tagId"], isChannelOwner, index);
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
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    displayName[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
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
    final isActorSequenceOne = selectedChannelIndex != null &&
        channels[selectedChannelIndex!]["actorsequence"] == "1";
    final chatTitle = isActorSequenceOne
        ? tr("Chat in") + " ${docs[selectedDocIndex!]["docname"]}"
        : tr("Chat in") + " ${joinedTags[selectedjoinedTagIndex!]["tagId"]}";

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            chatTitle,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        const Divider(color: Colors.white70),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              // Chat messages including the System message with InAppWebView
              ...currentChatMessages.map((msg) {
                final isUser = msg["sender"] == "You";
                final isSystem = msg["sender"] == "System";
                final isFile = msg["isFile"] == true;
                final isLastFile = isFile && msg == currentChatMessages.last;

                if (isSystem) {
                  // Special System message that shows form when clicked                 
                  return InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(msg["message"] ?? "Form"),
                          content: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.6,
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
                                      showHtmlPopup(context, jsonString);
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
                    if (isLastFile)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 8),
                        child: Row(
                          mainAxisAlignment: isUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children:
                              dashboardController.actionButtons.map((button) {
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
        const Divider(height: 1, color: Colors.white70),
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
  // Widget buildChatColumn() {
  //   final isActorSequenceOne = selectedChannelIndex != null &&
  //       channels[selectedChannelIndex!]["actorsequence"] == "1";
  //   final chatTitle = isActorSequenceOne
  //       ? tr("Chat in") + " ${docs[selectedDocIndex!]["docname"]}"
  //       : tr("Chat in") + " ${joinedTags[selectedjoinedTagIndex!]["tagId"]}";

  //   return Column(
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Text(
  //           chatTitle,
  //           style: const TextStyle(color: Colors.white, fontSize: 18),
  //         ),
  //       ),
  //       const Divider(color: Colors.white70),
  //       Expanded(
  //         child: ListView(
  //           padding: const EdgeInsets.all(8),
  //           children: [
  //             // InAppWebView at the top
  //             SizedBox(
  //               height: 600,
  //               child: InAppWebView(
  //                 initialData: InAppWebViewInitialData(
  //                   data: appendScriptWithHtml(htmlForm),
  //                 ),
  //                 onWebViewCreated: (controller) {
  //                   if (!kIsWeb) {
  //                     controller.addJavaScriptHandler(
  //                       handlerName: 'onFormSubmit',
  //                       callback: (args) {
  //                         String jsonString = args[0];
  //                         print(
  //                             'Received JSON string..................: $jsonString');
  //                         showHtmlPopup(context, jsonString);
  //                       },
  //                     );
  //                   } else {
  //                     handleWebMessage();
  //                   }
  //                 },
  //               ),
  //             ),

  //             // Chat messages
  //             ...currentChatMessages.map((msg) {
  //               final isUser = msg["sender"] == "You";
  //               final isFile = msg["isFile"] == true;
  //               final isLastFile = isFile && msg == currentChatMessages.last;

  //               return Column(
  //                 crossAxisAlignment: isUser
  //                     ? CrossAxisAlignment.end
  //                     : CrossAxisAlignment.start,
  //                 children: [
  //                   Align(
  //                     alignment:
  //                         isUser ? Alignment.centerRight : Alignment.centerLeft,
  //                     child: Container(
  //                       margin: const EdgeInsets.symmetric(vertical: 4),
  //                       padding: const EdgeInsets.all(10),
  //                       constraints: const BoxConstraints(maxWidth: 300),
  //                       decoration: BoxDecoration(
  //                         color: isUser ? Colors.blueAccent : Colors.grey[700],
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             msg["sender"]!,
  //                             style: const TextStyle(
  //                                 fontSize: 12, color: Colors.white70),
  //                           ),
  //                           const SizedBox(height: 4),
  //                           Text(
  //                             msg["message"]!,
  //                             style: const TextStyle(color: Colors.white),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   if (isLastFile)
  //                     Padding(
  //                       padding: const EdgeInsets.only(top: 4, bottom: 8),
  //                       child: Row(
  //                         mainAxisAlignment: isUser
  //                             ? MainAxisAlignment.end
  //                             : MainAxisAlignment.start,
  //                         mainAxisSize: MainAxisSize.min,
  //                         children:
  //                             dashboardController.actionButtons.map((button) {
  //                           return Row(
  //                             children: [
  //                               _buildActionButton(
  //                                 button["label"]!,
  //                                 () => _handleAction(button["label"]!,
  //                                     msg["message"]!, button["html"]!),
  //                               ),
  //                               const SizedBox(width: 4),
  //                             ],
  //                           );
  //                         }).toList(),
  //                       ),
  //                     ),
  //                 ],
  //               );
  //             }).toList(),
  //           ],
  //         ),
  //       ),
  //       const Divider(height: 1, color: Colors.white70),
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
  //         child: Row(
  //           children: [
  //             Expanded(
  //               child: TextField(
  //                 controller: messageController,
  //                 style: const TextStyle(color: Colors.white),
  //                 decoration: const InputDecoration(
  //                   hintText: 'Type a message...',
  //                   hintStyle: TextStyle(color: Colors.white54),
  //                   filled: true,
  //                   fillColor: Colors.black26,
  //                   border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.all(Radius.circular(8)),
  //                     borderSide: BorderSide.none,
  //                   ),
  //                 ),
  //                 enabled: !(currentChatMessages.isNotEmpty &&
  //                     currentChatMessages.last["isFile"] == true),
  //               ),
  //             ),
  //             const SizedBox(width: 8),
  //             IconButton(
  //               icon: const Icon(Icons.upload_file, color: Colors.white),
  //               tooltip: 'Upload form',
  //               onPressed: (currentChatMessages.isNotEmpty &&
  //                       currentChatMessages.last["isFile"] == true)
  //                   ? null
  //                   : () => _showUploadMethodDialog(context),
  //             ),
  //             IconButton(
  //               icon: const Icon(Icons.attach_file, color: Colors.white),
  //               tooltip: 'Attach a file',
  //               onPressed: (currentChatMessages.isNotEmpty &&
  //                       currentChatMessages.last["isFile"] == true)
  //                   ? null
  //                   : uploadFile,
  //             ),
  //             IconButton(
  //               icon: const Icon(Icons.send, color: Colors.white),
  //               onPressed: (currentChatMessages.isNotEmpty &&
  //                       currentChatMessages.last["isFile"] == true)
  //                   ? null
  //                   : sendMessage,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final bool hasChannels = channels.isNotEmpty;

    return Scaffold(
      appBar: CustomAppBar(
        title: "dashboard.dashboard",
        context: context,
      ),
      body: Stack(
        children: [
          Row(
            children: [
              // Left Sidebar (Channels with Long Press Options)
              Container(
                width: 80,
                color: Colors.grey[900],
                child: Column(
                  children: [
                    // Logo or App Icon at top (optional)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors
                            .transparent, // optional if your logo has its own background
                        backgroundImage: AssetImage(
                            'assets/images/xdoc_logo.png'), // replace with your actual path
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
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedChannelIndex = index;
                                        selectedDocIndex = null;
                                        docs = [];
                                        currentChatMessages = [];
                                      });
                                      if (channels[index]["actorsequence"] ==
                                          "1") {
                                        fetchDocs(
                                            channels[index]["channelname"]);
                                      } else {
                                        fetchJoinedTags(
                                            channels[index]["channelname"]);
                                      }
                                    },
                                    onLongPress: () async {
                                      setState(() {
                                        selectedChannelIndex = index;
                                        selectedDocIndex = null;
                                        docs = [];
                                        currentChatMessages = [];
                                      });
                                      if (selectedChannelIndex != null &&
                                          channels[selectedChannelIndex!]
                                                  ["actorsequence"] ==
                                              "1") {
                                        await fetchTags(
                                            channels[index]["channelname"]);
                                        _showChannelOptionsBottomSheet(
                                            context, index);
                                      } else {
                                        tags = [];
                                      }
                                    },
                                    child: Tooltip(
                                      message: channels[index]["channelname"],
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.blueAccent
                                              : Colors.grey[800],
                                          shape: BoxShape.circle,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        width: 50,
                                        height: 50,
                                        alignment: Alignment.center,
                                        child: Text(
                                          // channels[index]["channelname"]
                                          //     .substring(0, 3)
                                          //     .toUpperCase(),
                                          dashboardController
                                              .getChannelInitials(
                                                  channels[index]
                                                      ["channelname"]),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Text(
                                "No Channels",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
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
                            shape: BoxShape.circle,
                          ),
                          width: 50,
                          height: 50,
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Middle Panel (Docs)
              Container(
                width: 250,
                color: Colors.grey[850],
                child: Column(
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.green,
                    //       minimumSize: const Size(double.infinity, 40),
                    //     ),
                    //     onPressed: () => _showCreateTagDialog(
                    //         context), // You'll define this method
                    //     child: const Text(
                    //       '+',
                    //       style: TextStyle(fontSize: 12),
                    //     ),
                    //   ),
                    // ),
                    buildDocsListOrTagsList(),
                  ],
                ),
              ),

              // Right Panel (Chat Panel)
              Expanded(
                child: Container(
                  color: Colors.grey[800],
                  child: (selectedChannelIndex == null)
                      ? const Center(
                          child: Text(
                            "Please select a channel",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : (
                              // Determine which loading flag to use based on actorsequence
                              (selectedChannelIndex != null &&
                                      channels[selectedChannelIndex!]
                                              ["actorsequence"] ==
                                          "1"
                                  ? isDocsLoading
                                  : isjoinedTagsLoading))
                          ? const Center(child: CircularProgressIndicator())
                          : (
                                  // Determine which selected index to check based on actorsequence
                                  (selectedChannelIndex != null &&
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
                              : buildChatColumn(), // use your reusable function here
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text(
                      'Uploading file...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
