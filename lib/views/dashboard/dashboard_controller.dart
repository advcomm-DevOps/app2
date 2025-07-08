import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_starter/custom/services/sso.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'platform_web.dart' if (dart.library.io) 'platform_non_web.dart';

class DashboardController {
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
  final TextEditingController _initialActorIdController = TextEditingController();

  final String htmlForm = '''
    <!DOCTYPE html>
<html>
<head>
  <title>Simple Inline Styled Form</title>
</head>
<body style="background-color:#f4f4f4; font-family:Arial, sans-serif; padding:20px;">

  <div style="max-width:400px; margin:0 auto; background:white; padding:20px; border-radius:8px; box-shadow:0 0 10px rgba(0,0,0,0.1);">
    <h2 style="text-align:center; color:#333;">Contact Us</h2>

    <form action="#" method="POST">
      <label for="name" style="display:block; margin-bottom:5px; color:#555;">Name</label>
      <input type="text" id="name" name="name" required
             style="width:100%; padding:10px; margin-bottom:15px; border:1px solid #ccc; border-radius:4px;">

      <label for="email" style="display:block; margin-bottom:5px; color:#555;">Email</label>
      <input type="email" id="email" name="email" required
             style="width:100%; padding:10px; margin-bottom:15px; border:1px solid #ccc; border-radius:4px;">

      <label for="message" style="display:block; margin-bottom:5px; color:#555;">Message</label>
      <textarea id="message" name="message" rows="4" required
                style="width:100%; padding:10px; border:1px solid #ccc; border-radius:4px; margin-bottom:15px;"></textarea>

      <button type="submit"
              style="width:100%; padding:10px; background-color:#007BFF; color:white; border:none; border-radius:4px; cursor:pointer;">
        Submit
      </button>
    </form>
  </div>

</body>
</html>
  ''';
  
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
    document.querySelectorAll('form').forEach(form => {
      form.addEventListener('submit', function(event) {
        event.preventDefault();

        const formData = new FormData(form);
        const data = {};

        formData.forEach((value, key) => {
          data[key] = value;
        });

        const jsonString = JSON.stringify(data);

        if (window.flutter_inappwebview) {
          window.flutter_inappwebview.callHandler('onFormSubmit', jsonString);
        } else {
          window.parent.postMessage({ type: 'onFormSubmit', payload: jsonString }, '*');
        }
      });
    });
  ''';
  
  List<Map<String, dynamic>> currentChatMessages = [];

  bool get hasChannels => channels.isNotEmpty;
  bool get isLastFile {
    if (currentChatMessages.isEmpty) return false;
    final lastMessage = currentChatMessages.last;
    return lastMessage["isFile"] == true;
  }
  bool get kIsWeb => identical(0, 0.0);

  void didChangeDependencies(BuildContext context) {
    final newLocale = EasyLocalization.of(context)!.locale;
    if (_currentLocale != newLocale) {
      _currentLocale = newLocale;
    }
  }

  Future<void> loadSelectedEntity() async {
    final ssoService = SSOService();
    final entity = await ssoService.getSelectedEntity();
    selectedEntity = '${entity ?? ''}/';
  }

  void initState(String? entity, String? section) {
    loadSelectedEntity();
    fetchChannels();
    print("entity................:$entity section...........: $section");
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
      channels = List<Map<String, dynamic>>.from(response.data);
      _validateSection();
    } catch (e) {
      print("Error fetching channels: $e");
    }
  }

  void _validateSection() {
    // Implementation remains the same as in original code
  }

  void setSelectedChannelIndex(int? index) {
    selectedChannelIndex = index;
    selectedDocIndex = null;
    docs = [];
    currentChatMessages = [];
  }

  void setSelectedDocIndex(int? index) {
    selectedDocIndex = index;
    currentChatMessages = documentChats[docs[index!]["docname"]] ?? [];
  }

  void addNewChannel(String sectionName) {
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
  }

  Future<void> createChannel() async {
    String token = await getJwt();
    try {
      final channelData = {
        "initialActorID": _initialActorIdController.text.trim(),
        "channelName": _channelNameController.text.trim(),
      };

      dio.options.headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      final response = await dio.post(
        '$apiUrl/channel',
        data: jsonEncode(channelData),
        options: Options(contentType: 'application/json'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchChannels();
        _channelNameController.clear();
        _initialActorIdController.clear();
      }
    } on DioException catch (e) {
      print("Dio error creating channel: ${e.message}");
      print("Response: ${e.response?.data}");
    } catch (e) {
      print("Error creating channel: $e");
    }
  }

  void showCreateChannelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Channel', style: TextStyle(color: Colors.white)),
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
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
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
              child: const Text('Create', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void showCreateDocDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Document', style: TextStyle(color: Colors.white)),
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
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
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
              child: const Text('Create', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchDocs(String channelName) async {
    String token = await getJwt();
    try {
      isDocsLoading = true;
      docs = [];
      selectedDocIndex = null;
      currentChatMessages = [];

      dio.options.headers["Authorization"] = "Bearer $token";
      final response = await dio.get('$apiUrl/docs/$channelName');

      docs = List<Map<String, dynamic>>.from(response.data);
      isDocsLoading = false;
    } catch (e) {
      isDocsLoading = false;
      print("Error fetching docs: $e");
    }
  }

  Future<void> uploadFile() async {
    String token = await getJwt();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'png', 'jpg', 'jpeg', 'zip'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        isUploading = true;

        FormData formData = FormData.fromMap({
          "file": await MultipartFile.fromFile(file.path!, filename: file.name),
          "channelName": channels[selectedChannelIndex!]["channelname"],
          "description": docs[selectedDocIndex!]["docname"],
        });
        
        dio.options.headers["Authorization"] = "Bearer $token";
        dio.options.headers["Content-Type"] = "multipart/form-data";

        final response = await dio.post(
          '$apiUrl/upload',
          data: formData,
          onSendProgress: (int sent, int total) {
            print("Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%");
          },
        );

        if (response.statusCode == 200) {
          currentChatMessages.add({
            "sender": "You",
            "isFile": true,
            "message": "Uploaded file: ${file.name} (${(file.size / 1024).toStringAsFixed(1)} KB)"
          });
        }
      }
    } catch (e) {
      print("Error uploading file: $e");
    } finally {
      isUploading = false;
    }
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    currentChatMessages.add({"sender": "You", "message": text});
    messageController.clear();
  }

  String appendScriptWithHtml(String html) {
    return "$html<script>$formHandlingJS</script>";
  }

  void handleAction(String action, String fileName, String html, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Form Preview', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[800],
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            child: InAppWebView(
              initialData: InAppWebViewInitialData(data: appendScriptWithHtml(html)),
              onWebViewCreated: (controller) {
                if (!kIsWeb) {
                  controller.addJavaScriptHandler(
                    handlerName: 'onFormSubmit',
                    callback: (args) {
                      String jsonString = args[0];
                      print('Received JSON string: $jsonString');
                      Map<String, dynamic> formData = jsonDecode(jsonString);
                      print('Received JSON: $formData');
                      currentChatMessages.add({
                        "sender": "System",
                        "message": "You $action the file: ${fileName.split(':').last.trim()}",
                      });
                    },
                  );
                } else {
                  handleWebMessage();
                }
              },
            ),
          ),
        );
      },
    );
  }

  void showUploadMethodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Form', style: TextStyle(color: Colors.white)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showUrlInputDialog(context);
                    },
                    child: const Text('By URL', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showHtmlInputDialog(context);
                    },
                    child: const Text('By HTML', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void showUrlInputDialog(BuildContext context) {
    _urlController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Form URL', style: TextStyle(color: Colors.white)),
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
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                if (_urlController.text.isNotEmpty) {
                  Navigator.pop(context);
                  showPreviewDialog(context, _urlController.text, isUrl: true);
                }
              },
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void showHtmlInputDialog(BuildContext context) {
    _htmlController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter HTML Form', style: TextStyle(color: Colors.white)),
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
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                if (_htmlController.text.isNotEmpty) {
                  Navigator.pop(context);
                  showPreviewDialog(context, _htmlController.text, isUrl: false);
                }
              },
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void showPreviewDialog(BuildContext context, String content, {required bool isUrl}) {
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
              initialUrlRequest: isUrl ? URLRequest(url: WebUri(content)) : null,
              initialData: !isUrl ? InAppWebViewInitialData(data: content) : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Confirm Upload', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}