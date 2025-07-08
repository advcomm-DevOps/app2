import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_starter/custom/services/sso.dart';
import 'package:flutter_starter/views/dashboard/form_resume.dart';
import '../nav/custom_app_bar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'platform_web.dart' if (dart.library.io) 'platform_non_web.dart';
import 'package:liquid_engine/liquid_engine.dart';

class DashboardView extends StatefulWidget {
  final String? entity;
  final String? section;
  const DashboardView({super.key, this.entity, this.section});
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int? selectedChannelIndex;
  int? selectedDocIndex;
  String selectedEntity = '';

  final dio = Dio();
  final String apiUrl = 'http://localhost:3000';
  final String qrurl = 'https://s.xdoc.app/c/';
  List<Map<String, dynamic>> channels = [];
  List<Map<String, dynamic>> docs = [];

  bool isDocsLoading = false;
  bool isUploading = false;
  Locale? _currentLocale;

  final TextEditingController messageController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _htmlController = TextEditingController();
  final TextEditingController _channelNameController = TextEditingController();
  final TextEditingController _initialActorIdController =
      TextEditingController();

  final String htmlForm = getResumeForm();
  final String htmlResume = getResumeHtml();
  final String htmlResume1 = getResumeHtml1();
  // Define chat messages for each document
  final Map<String, List<Map<String, dynamic>>> documentChats = {
    "Invoice-06-Mar-2025": [
      {"sender": "User A", "message": "Hello!"},
      {"sender": "User B", "message": "Hi there! How can I help?"},
      {"sender": "User A", "message": "I have a question about the document."},
      {"sender": "User B", "message": "Sure, ask me anything."},
      {"sender": "User A", "message": "Can you explain the payment terms?"},
      {"sender": "User B", "message": "The payment is due within 30 days."},
      {"sender": "User A", "message": "Thanks for the info!"},
      {"sender": "User B", "message": "You're welcome!"},
    ],
    "Invoice-08-Mar-2025": [
      {"sender": "User A", "message": "Hello!"},
      {"sender": "User B", "message": "Hi there! How can I help?"},
      {"sender": "User A", "message": "I have a question about the document."},
      {"sender": "User B", "message": "Sure, ask me anything."},
    ],
  };
  final List<Map<String, String>> actionButtons = [
    {"label": "Accept", "html": "<button>Accept</button>"},
    {
      "label": "Reject",
      "html": """
        <form style='max-width: 300px; padding: 10px; border: 1px solid #ccc; border-radius: 6px;'>
          <label for='rejectedReason' style='display: block; margin-bottom: 6px; font-weight: bold;'>
            Rejected Reason:
          </label>
          <input type='text' id='rejectedReason' name='rejectedReason'
                style='width: 100%; padding: 8px; margin-bottom: 10px;
                        border: 1px solid #ccc; border-radius: 4px;' required>
          <button type='submit'
                  style='background-color: #dc3545; color: white; padding: 8px 16px;
                        border: none; border-radius: 4px; cursor: pointer;'>
            Submit
          </button>
        </form>
      """
    },
    {
      "label": "Dispute",
      "html": """
        <form style='max-width: 300px; padding: 10px; border: 1px solid #ccc; border-radius: 6px;'>
          <label for='dispute1' style='display: block; margin-bottom: 6px; font-weight: bold;'>
            Dispute 1:
          </label>
          <input type='text' id='dispute1' name='dispute1'
                style='width: 100%; padding: 8px; margin-bottom: 10px;
                        border: 1px solid #ccc; border-radius: 4px;' required>
          <label for='dispute2' style='display: block; margin-bottom: 6px; font-weight: bold;'>
            Dispute 2:
          </label>
          <input type='text' id='dispute2' name='dispute2'
                style='width: 100%; padding: 8px; margin-bottom: 10px;
                        border: 1px solid #ccc; border-radius: 4px;' required>
          <button type='submit'
                  style='background-color: #dc3545; color: white; padding: 8px 16px;
                        border: none; border-radius: 4px; cursor: pointer;'>
            Submit
          </button>
        </form>
      """
    },
    {
      "label": "Revise",
      "html": """
        <form style='max-width: 300px; padding: 10px; border: 1px solid #ccc; border-radius: 6px;'>
          <label for='Revise' style='display: block; margin-bottom: 6px; font-weight: bold;'>
            Revise:
          </label>
          <input type='text' id='Revise' name='Revise'
                style='width: 100%; padding: 8px; margin-bottom: 10px;
                        border: 1px solid #ccc; border-radius: 4px;' required>
          <label for='Note' style='display: block; margin-bottom: 6px; font-weight: bold;'>
            Note:
          </label>
          <input type='text' id='Note' name='Note'
                style='width: 100%; padding: 8px; margin-bottom: 10px;
                        border: 1px solid #ccc; border-radius: 4px;' required>
          <button type='submit'
                  style='background-color: #dc3545; color: white; padding: 8px 16px;
                        border: none; border-radius: 4px; cursor: pointer;'>
            Submit
          </button>
        </form>
      """
    },
  ];

  final String formHandlingJS = '''
  console.log("🔥 JavaScript code injected and running");
  
  function processFormData(form) {
    const formData = new FormData(form);
    const data = {};
    
    // Convert FormData to nested object
    for (let [key, value] of formData.entries()) {
      const keys = key.match(/(\\w+)/g); // Split by brackets and dots
      let current = data;
      
      for (let i = 0; i < keys.length; i++) {
        const k = keys[i];
        
        // If this is the last key, set the value
        if (i === keys.length - 1) {
          current[k] = value;
        } else {
          // If the next key is a number, ensure current[k] is an array
          if (!isNaN(keys[i+1])) {
            if (!current[k]) {
              current[k] = [];
            }
          } else {
            // Otherwise ensure it's an object
            if (!current[k]) {
              current[k] = {};
            }
          }
          current = current[k];
        }
      }
    }
    
    // Remove the clean function to keep all fields
    return data;
  }

  document.querySelectorAll('form').forEach(form => {
    form.addEventListener('submit', function(event) {
      event.preventDefault();
      
      const nestedData = processFormData(form);
      const jsonString = JSON.stringify(nestedData, null, 2);
      
      if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler('onFormSubmit', jsonString);
      } else {
        window.parent.postMessage({ type: 'onFormSubmit', payload: jsonString }, '*');
      }
    });
  });
''';

  // final String formHandlingJS = '''
  //   console.log("🔥 JavaScript code injected and running");
  //   document.querySelectorAll('form').forEach(form => {
  //     form.addEventListener('submit', function(event) {
  //       event.preventDefault();

  //       const formData = new FormData(form);
  //       const data = {};

  //       formData.forEach((value, key) => {
  //         data[key] = value;
  //       });

  //       const jsonString = JSON.stringify(data);

  //       if (window.flutter_inappwebview) {
  //         window.flutter_inappwebview.callHandler('onFormSubmit', jsonString);
  //       } else {
  //         window.parent.postMessage({ type: 'onFormSubmit', payload: jsonString }, '*');
  //       }
  //     });
  //   });
  // ''';

  // Current chat messages being displayed
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
    final entity = widget.entity;
    final sec = widget.section;
    super.initState();
    fetchChannels();
    loadSelectedEntity();
    print("entity................:$entity section...........: $sec");
  }

  Future<String> getJwt() async {
    final FlutterSecureStorage secureStorage = FlutterSecureStorage();
    final String? jwtToken = await secureStorage.read(key: "JWT_Token");
    return jwtToken ?? '';
  }

  Future<void> fetchChannels() async {
    try {
      String token = await getJwt();
      dio.options.headers["Authorization"] = "Bearer $token";
      final response = await dio.get('$apiUrl/channels');
      setState(() {
        channels = List<Map<String, dynamic>>.from(response.data);
      });
      _validateSection();
    } catch (e) {
      print("Error fetching channels: $e");
    }
  }

  void _validateSection() {
    final sec = widget.section;

    if (sec == null || sec.isEmpty) return;

    final exists = channels.any((channel) => channel['channelname'] == sec);
    final index =
        channels.indexWhere((channel) => channel['channelname'] == sec);

    if (!exists) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Channel Not Found'),
            content: Text(
                'Channel "$sec" does not exist in the available channels. Do you want to add it?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // User chose not to add
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _addNewChannel(sec);
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        );
      });
    } else {
      setState(() {
        selectedChannelIndex = index;
        selectedDocIndex = null;
        docs = [];
        currentChatMessages = [];
      });
      fetchDocs(channels[index]["channelname"]);
    }
  }

  void _addNewChannel(String sectionName) {
    setState(() {
      channels.add({
        "channelname": sectionName,
        "channeldescription": "Manually added section",
        "entityroles": "all",
        "initialactorid": "",
        "otheractorid": ""
      });
      docs.add({
        "docname": sectionName + " Document",
        "starttime": DateTime.now().toIso8601String(),
        "completiontime": null
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Section "$sectionName" added to channels.')),
    );
  }

  // Add this method to create a channel
  Future<void> createChannel() async {
    String token = await getJwt();
    try {
      final channelData = {
        "initialActorID": _initialActorIdController.text.trim(),
        "channelName": _channelNameController.text.trim(),
      };

      // Set headers including Content-Type
      dio.options.headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      final response = await dio.post(
        '$apiUrl/channel',
        data: jsonEncode(channelData), // Explicitly encode to JSON
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh the channels list
        fetchChannels();
        // Clear the form
        _channelNameController.clear();
        _initialActorIdController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Channel created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      print("Dio error creating channel: ${e.message}");
      print("Response: ${e.response?.data}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create channel: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print("Error creating channel: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create channel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Add this method to show the channel creation dialog
  void _showCreateChannelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Channel',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[800],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _channelNameController,
                decoration: const InputDecoration(
                  labelText: 'Channel Name',
                  labelStyle: TextStyle(color: Colors.white70),
                  hintText: 'Enter channel name',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _initialActorIdController,
                decoration: const InputDecoration(
                  labelText: 'Initial Actor ID',
                  labelStyle: TextStyle(color: Colors.white70),
                  hintText: 'Enter initial actor ID',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
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
                if (_channelNameController.text.isNotEmpty &&
                    _initialActorIdController.text.isNotEmpty) {
                  createChannel();
                  Navigator.pop(context);
                }
              },
              child:
                  const Text('Create', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showCreateDocDialog(BuildContext context) {
    final TextEditingController toController = TextEditingController();
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController bodyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom +
                        60, // Leave space for buttons
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'New Document',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.close, color: Colors.white70),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: toController,
                        decoration: const InputDecoration(
                          labelText: 'To',
                          labelStyle: TextStyle(color: Colors.white70),
                          hintText: 'Enter recipient',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: UnderlineInputBorder(),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: subjectController,
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          labelStyle: TextStyle(color: Colors.white70),
                          hintText: 'Enter subject',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: UnderlineInputBorder(),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: bodyController,
                        decoration: const InputDecoration(
                          labelText: 'Body',
                          labelStyle: TextStyle(color: Colors.white70),
                          hintText: 'Enter message',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Row(
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.upload_file, color: Colors.white),
                        tooltip: 'Upload form',
                        onPressed: () => _showUploadMethodDialog(context),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.attach_file, color: Colors.white),
                        tooltip: 'Attach a file',
                        onPressed: uploadFile,
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        tooltip: 'Send',
                        onPressed: () {
                          if (toController.text.isNotEmpty &&
                              bodyController.text.isNotEmpty) {
                            sendMessage();
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
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
    String token = await getJwt();
    try {
      setState(() {
        isDocsLoading = true;
        docs = [];
        selectedDocIndex = null;
        currentChatMessages = [];
      });

      dio.options.headers["Authorization"] = "Bearer $token";
      final response = await dio.get('$apiUrl/docs/$channelName');

      setState(() {
        docs = List<Map<String, dynamic>>.from(response.data);
        isDocsLoading = false;
      });
    } catch (e) {
      setState(() {
        isDocsLoading = false;
      });
      print("Error fetching docs: $e");
    }
  }

  Future<void> uploadFile() async {
    String token = await getJwt();
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
    return html = "$html<script>$formHandlingJS</script>";
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
              // Left Sidebar (Channels)
              Container(
                width: 150,
                color: Colors.grey[900],
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        onPressed: () => _showCreateChannelDialog(context),
                        child: const Text(
                          '+ Add Channel',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    Expanded(
                      child: hasChannels
                          ? ListView.builder(
                              itemCount: channels.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    color: selectedChannelIndex == index
                                        ? Colors.blue
                                        : Colors.grey[700],
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedChannelIndex = index;
                                                selectedDocIndex = null;
                                                docs = [];
                                                currentChatMessages = [];
                                              });
                                              fetchDocs(channels[index]
                                                  ["channelname"]);
                                            },
                                            child: Text(
                                              channels[index]["channelname"],
                                              style: const TextStyle(
                                                  color: Colors.white),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        PopupMenuButton(
                                          icon: const Icon(Icons.more_vert,
                                              color: Colors.white, size: 20),
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'qr_code',
                                              child: Text('QR Code'),
                                            ),
                                          ],
                                          onSelected: (value) {
                                            if (value == 'qr_code') {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    // title: const Text('Channel Name'),
                                                    content:
                                                        SingleChildScrollView(
                                                      // Add this wrapper
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(qrurl +
                                                              selectedEntity +
                                                              channels[index][
                                                                  "channelname"]),
                                                          const SizedBox(
                                                              height: 20),
                                                          SizedBox(
                                                            // Constrain the QR code size
                                                            width: 300,
                                                            height: 300,
                                                            child: QrImageView(
                                                              data: qrurl +
                                                                  selectedEntity +
                                                                  channels[
                                                                          index]
                                                                      [
                                                                      "channelname"],
                                                              version:
                                                                  QrVersions
                                                                      .auto,
                                                              backgroundColor:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(),
                                                        child:
                                                            const Text('Close'),
                                                      )
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : const Center(child: CircularProgressIndicator()),
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        onPressed: () => _showCreateDocDialog(
                            context), // You'll define this method
                        child: const Text(
                          '+ Compose',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    Expanded(
                      child: isDocsLoading
                          ? const Center(child: CircularProgressIndicator())
                          : docs.isNotEmpty
                              ? ListView.builder(
                                  itemCount: docs.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                        docs[index]["docname"],
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      selected: selectedDocIndex == index,
                                      selectedTileColor: Colors.grey[700],
                                      onTap: () {
                                        setState(() {
                                          selectedDocIndex = index;
                                          currentChatMessages = documentChats[
                                                  docs[index]["docname"]] ??
                                              [];
                                        });
                                      },
                                    );
                                  },
                                )
                              : const Center(
                                  child: Text(
                                    "No Docs Available",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                    ),
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
                      : isDocsLoading
                          ? const Center(child: CircularProgressIndicator())
                          : (selectedDocIndex == null)
                              ? const Center(
                                  child: Text(
                                    "Please select a doc",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              : Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        tr("Chat in") +
                                            " ${docs[selectedDocIndex!]["docname"]}",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ),
                                    const Divider(color: Colors.white70),
                                    Expanded(
                                      child: ListView(
                                        padding: const EdgeInsets.all(8),
                                        children: [
                                          // InAppWebView at the top
                                          SizedBox(
                                            height: 600,
                                            child: InAppWebView(
                                              initialData:
                                                  InAppWebViewInitialData(
                                                data: appendScriptWithHtml(
                                                    htmlForm),
                                              ),
                                              onWebViewCreated: (controller) {
                                                if (!kIsWeb) {
                                                  controller
                                                      .addJavaScriptHandler(
                                                    handlerName: 'onFormSubmit',
                                                    callback: (args) {
                                                      String jsonString =
                                                          args[0];
                                                      print(
                                                          'Received JSON string..................: $jsonString');
                                                      showHtmlPopup(
                                                          context, jsonString);
                                                      // Map<String, dynamic>
                                                      //     formData = jsonDecode(
                                                      //         jsonString);
                                                      // print('Received JSON.........................: $formData');
                                                    },
                                                  );
                                                } else {
                                                  handleWebMessage();
                                                }
                                              },
                                            ),
                                          ),

                                          // Chat messages (manually add each as a widget)
                                          ...currentChatMessages.map((msg) {
                                            final isUser =
                                                msg["sender"] == "You";
                                            final isFile =
                                                msg["isFile"] == true;
                                            final isLastFile = isFile &&
                                                msg == currentChatMessages.last;

                                            return Column(
                                              crossAxisAlignment: isUser
                                                  ? CrossAxisAlignment.end
                                                  : CrossAxisAlignment.start,
                                              children: [
                                                Align(
                                                  alignment: isUser
                                                      ? Alignment.centerRight
                                                      : Alignment.centerLeft,
                                                  child: Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(vertical: 4),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    constraints:
                                                        const BoxConstraints(
                                                            maxWidth: 300),
                                                    decoration: BoxDecoration(
                                                      color: isUser
                                                          ? Colors.blueAccent
                                                          : Colors.grey[700],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          msg["sender"]!,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white70),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          msg["message"]!,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                if (isLastFile)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4, bottom: 8),
                                                    child: Row(
                                                      mainAxisAlignment: isUser
                                                          ? MainAxisAlignment
                                                              .end
                                                          : MainAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: actionButtons
                                                          .map((button) {
                                                        return Row(
                                                          children: [
                                                            _buildActionButton(
                                                              button["label"]!,
                                                              () => _handleAction(
                                                                  button[
                                                                      "label"]!,
                                                                  msg[
                                                                      "message"]!,
                                                                  button[
                                                                      "html"]!),
                                                            ),
                                                            const SizedBox(
                                                                width: 4),
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
                                    const Divider(
                                        height: 1, color: Colors.white70),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 6),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: messageController,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                              decoration: const InputDecoration(
                                                hintText: 'Type a message...',
                                                hintStyle: TextStyle(
                                                    color: Colors.white54),
                                                filled: true,
                                                fillColor: Colors.black26,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8)),
                                                  borderSide: BorderSide.none,
                                                ),
                                              ),
                                              enabled: !isLastFile,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.upload_file,
                                                color: Colors.white),
                                            tooltip: 'Upload form',
                                            onPressed: isLastFile
                                                ? null
                                                : () => _showUploadMethodDialog(
                                                    context),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.attach_file,
                                                color: Colors.white),
                                            tooltip: 'Attach a file',
                                            onPressed:
                                                isLastFile ? null : uploadFile,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.send,
                                                color: Colors.white),
                                            onPressed:
                                                isLastFile ? null : sendMessage,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
