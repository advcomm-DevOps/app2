import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../nav/custom_app_bar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int? selectedChannelIndex;
  int? selectedDocIndex;

  final dio = Dio();
  final String token = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ik1JSUNJIn0.eyJzdWIiOiJtb2hzZW5hbGk0MzQzQGdtYWlsLmNvbSIsInRpZCI6Im1vaHNlbmFsaTQzNDNAZ21haWwuY29tIiwiYXVkIjoiYXV0aC54ZG9jLmFwcCIsImlhdCI6MTc0MTQxNDc5NywiZXhwIjoxNzQxNDE4Mzk3LCJpc3MiOiJhdXRoLnhkb2MuYXBwIn0.BXXBKOuIErz8chjDNXbmFCzYDpKR1HErRTuexZ74Ebw6PRoxFC74GTsTimvipwsIZA6VJWb3Cwd6iI35gmllfKhR1d0NTDZE1_lnlU7KQcd7pX7r5YtiUTC2oic6Wd_6SUaLeiQd51VwYWmBuQH_F8z1EuxLWWde-5pFTUC7yOfn__jeMoDW-esN7XRbAbiE7A6BAz8m57Vk9NWI0rJ0Sj-VKJK_gQtDTfcyBcYMN3e3c6Q99yv6dGMW1hq9jM2CIosunU_jczq5p8fV-7Ykzg3PIJaVl1tga3grVZIRF58v65YmsRqWLti4Bpdc04H00UNugL8M3RlcgBt5C1iKkBSTvdDDv4YKXAE45TYlxAmlE8fNYZNIGJW0d3AuSuvAbZc5aNJrH9T8nK0bx68vP0fk_idwt9XWlNcUWlErUfZ2-LulgH3onKYbthF2JrYFY0u-2QvTE-ljD-dFN4YKflFNg9N-INTMBCGC1y6E-94iHbj87Wy1-v5WQb1ZR7OP7QDs9nSrNo8aGhlvVSmaMvL7NdbUrA4RiWbt4fBmPEQuNXi9FpgYF70wB7ggXX-LU9-CCmOIW5-Y1JYZ73XBVKDIxNdzv2aQRbmDzkFhpm0ckFBMg2iDCyzAQmHR_8kCXSp7WP08HCG8bRQyRGZJ7R7Fr-BJCi8kIj8o2wnyNQ8';

  List<Map<String, dynamic>> channels = [];
  List<Map<String, dynamic>> docs = [];

  bool isDocsLoading = false;
  bool isUploading = false;
  Locale? _currentLocale;

  final TextEditingController messageController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _htmlController = TextEditingController();

  // Define chat messages for each document
  final Map<String, List<Map<String, String>>> documentChats = {
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

  // Current chat messages being displayed
  List<Map<String, String>> currentChatMessages = [];

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

  @override
  void initState() {
    super.initState();
    fetchChannels();
  }

  Future<void> fetchChannels() async {
    try {
      dio.options.headers["Authorization"] = "Bearer $token";
      final response = await dio.get('https://api.xdoc.app/channels');
      setState(() {
        channels = List<Map<String, dynamic>>.from(response.data);
      });
    } catch (e) {
      print("Error fetching channels: $e");
    }
  }

  Future<void> fetchDocs(String channelName) async {
    try {
      setState(() {
        isDocsLoading = true;
        docs = [];
        selectedDocIndex = null;
        currentChatMessages = [];
      });

      dio.options.headers["Authorization"] = "Bearer $token";
      final response = await dio.get('https://api.xdoc.app/docs/$channelName');

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
    try {
      // Pick a file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'png', 'jpg', 'jpeg'],
      );

      if (result != null) {
        setState(() {
          isUploading = true;
        });

        PlatformFile file = result.files.first;
          setState(() {
            currentChatMessages.add({
              "sender": "You",
              "message": "Uploaded file: ${file.name} (${(file.size / 1024).toStringAsFixed(1)} KB)"
            });
          });
        
        // // Create form data
        // FormData formData = FormData.fromMap({
        //   "file": await MultipartFile.fromFile(file.path!,
        //       filename: file.name),
        //   "channel": channels[selectedChannelIndex!]["ChannelName"],
        //   "doc": docs[selectedDocIndex!]["DocName"],
        // });

        // // Set headers
        // dio.options.headers["Authorization"] = "Bearer $token";
        // dio.options.headers["Content-Type"] = "multipart/form-data";

        // // Upload file
        // final response = await dio.post(
        //   'https://api.xdoc.app/upload',
        //   data: formData,
        //   onSendProgress: (int sent, int total) {
        //     print("Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%");
        //   },
        // );

        // if (response.statusCode == 200) {
        //   // Add a message about the uploaded file
        //   setState(() {
        //     currentChatMessages.add({
        //       "sender": "You",
        //       "message": "Uploaded file: ${file.name} (${(file.size / 1024).toStringAsFixed(1)} KB)"
        //     });
        //   });

        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text('File uploaded successfully!'),
        //       backgroundColor: Colors.green,
        //     ),
        //   );
        // }
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

    // Optionally, send the message to backend here
  }
  void _showUploadMethodDialog(BuildContext context) {
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
                    _showUrlInputDialog(context);
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
                    _showHtmlInputDialog(context);
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

void _showUrlInputDialog(BuildContext context) {
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
                _showPreviewDialog(context, _urlController.text, isUrl: true);
              }
            },
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
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
                _showPreviewDialog(context, _htmlController.text, isUrl: false);
              }
            },
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
void _showPreviewDialog(BuildContext context, String content, {required bool isUrl}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      InAppWebViewController? webViewController;

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
            initialUrlRequest: isUrl
                 ? URLRequest(url: WebUri(content))
                : null,
            initialData: !isUrl
                ? InAppWebViewInitialData(data: content)
                : null,
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isUrl ? 'URL form submitted' : 'HTML form submitted',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Confirm Upload', style: TextStyle(color: Colors.white)),
          ),
        ],
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
                child: hasChannels
                    ? ListView.builder(
                        itemCount: channels.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedChannelIndex = index;
                                selectedDocIndex = null;
                                docs = [];
                                currentChatMessages = [];
                              });
                              fetchDocs(channels[index]["ChannelName"]);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                color: selectedChannelIndex == index
                                    ? Colors.blue
                                    : Colors.grey[700],
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  channels[index]["ChannelName"],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),

              // Middle Panel (Docs)
              Container(
                width: 250,
                color: Colors.grey[850],
                child: isDocsLoading
                    ? const Center(child: CircularProgressIndicator())
                    : docs.isNotEmpty
                        ? ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  docs[index]["DocName"],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                selected: selectedDocIndex == index,
                                selectedTileColor: Colors.grey[700],
                                onTap: () {
                                  setState(() {
                                    selectedDocIndex = index;
                                    currentChatMessages = documentChats[docs[index]["DocName"]] ?? [];
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
                                            " ${docs[selectedDocIndex!]["DocName"]}",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ),
                                    const Divider(color: Colors.white70),
                                    Expanded(
                                      child: ListView.builder(
                                        padding: const EdgeInsets.all(8),
                                        itemCount: currentChatMessages.length,
                                        itemBuilder: (context, index) {
                                          final msg = currentChatMessages[index];
                                          final isUser = msg["sender"] == "You";
                                          return Align(
                                            alignment: isUser
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(vertical: 4),
                                              padding: const EdgeInsets.all(10),
                                              constraints: const BoxConstraints(maxWidth: 300),
                                              decoration: BoxDecoration(
                                                color: isUser
                                                    ? Colors.blueAccent
                                                    : Colors.grey[700],
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    msg["sender"]!,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white70),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    msg["message"]!,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const Divider(height: 1, color: Colors.white70),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 6),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: messageController,
                                              style:
                                                  const TextStyle(color: Colors.white),
                                              decoration: const InputDecoration(
                                                hintText: 'Type a message...',
                                                hintStyle:
                                                    TextStyle(color: Colors.white54),
                                                filled: true,
                                                fillColor: Colors.black26,
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(8)),
                                                  borderSide: BorderSide.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.upload_file,color: Colors.white),
                                            tooltip: 'Upload form',
                                            onPressed: () => _showUploadMethodDialog(context),
                                            //onPressed: uploadFile,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.attach_file,color: Colors.white),
                                            tooltip: 'Attach a file',
                                            onPressed: uploadFile,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.send,color: Colors.white),
                                            onPressed: sendMessage,
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
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
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
      ),
    );
  }
}

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_starter/views/nav/custom_app_bar.dart';

// class DashboardView extends StatefulWidget {
//   @override
//   _DashboardViewState createState() => _DashboardViewState();
// }

// class _DashboardViewState extends State<DashboardView> {
//   Locale? _currentLocale;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final newLocale = EasyLocalization.of(context)!.locale;
//     if (_currentLocale != newLocale) {
//       setState(() {
//         _currentLocale = newLocale;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: "dashboard.dashboard",
//         context: context,
//       ),
//       body: Column(
//         children: [
//           // Row before WebView
//           Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "dashboard.welcome".tr(), // Localized welcome text
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//           ),

//           // WebView
//           Expanded(
//             child: InAppWebView(
//               initialFile: "lib/html/form.html",
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
