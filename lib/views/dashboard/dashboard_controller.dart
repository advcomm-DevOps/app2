import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:xdoc/custom/constants.dart';
import 'package:xdoc/custom/services/sso.dart';
import 'package:xdoc/custom/services/encryption.dart';
import 'package:xdoc/views/dashboard/dashboard_replication.dart';
import 'dart:typed_data';
import 'package:tenant_replication/tenant_replication.dart';

class DashboardController {
  final Dio dio = Dio();
  // final String apiUrl = 'https://$audDomain';
  final String qrurl = 'https://web.xdoc.app/c/';
  final String apiUrl = 'http://localhost:3000';
  // final String qrurl = 'https://s.xdoc.app/c/';

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final List<Map<String, dynamic>> statusJson = [
    {
      "label": "Under Process",
      "value": "underprocess",
      "children": [
        {"label": "Rejected", "value": "rejected"},
        {"label": "Accepted", "value": "accepted"},
      ]
    },
    {"label": "Review", "value": "review"},
    {"label": "Published", "value": "published"},
    {"label": "Archived", "value": "archived"},
  ];

  final Map<String, List<Map<String, dynamic>>> documentChats = {
    "invoice": [
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
  final List<Map<String, String>> actionButtons1 = [
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
    (function() {
                    // Check if Bootstrap CSS is already loaded
                    if (!document.querySelector('link[href*="bootstrap"]')) {
                      const bootstrapCSS = document.createElement('link');
                      bootstrapCSS.rel = 'stylesheet';
                      bootstrapCSS.href = 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css';
                      document.head.appendChild(bootstrapCSS);
                    }

                    // Check if Quill CSS is already loaded
                    if (!document.querySelector('link[href*="quill.snow.css"]')) {
                      const quillCSS = document.createElement('link');
                      quillCSS.rel = 'stylesheet';
                      quillCSS.href = 'https://cdn.quilljs.com/1.3.6/quill.snow.css';
                      document.head.appendChild(quillCSS);
                    }

                    // Check if Bootstrap JS is already loaded
                    if (!document.querySelector('script[src*="bootstrap"]')) {
                      const bootstrapJS = document.createElement('script');
                      bootstrapJS.src = 'lib/bootstrap.bundle.min.js';
                      document.body.appendChild(bootstrapJS);
                    }

                    // Check if Quill JS is already loaded
                    if (!document.querySelector('script[src*="quill.min.js"]') && !window.Quill) {
                      const quillJS = document.createElement('script');
                      quillJS.src = 'https://cdn.quilljs.com/1.3.6/quill.min.js';
                      quillJS.onload = function() {
                        // Initialize Quill editor after the library loads
                        if (window.Quill && document.getElementById('editor')) {
                          window.quill = new Quill('#editor', {
                            theme: 'snow',
                            placeholder: 'Type your message here...',
                            modules: {
                              toolbar: [
                                [{ 'header': [1, 2, 3, false] }],
                                ['bold', 'italic', 'underline', 'strike'],
                                [{ 'color': [] }, { 'background': [] }],
                                [{ 'list': 'ordered'}, { 'list': 'bullet' }],
                                [{ 'align': [] }],
                                ['link', 'blockquote', 'code-block'],
                                ['clean']
                              ]
                            }
                          });
                          console.log('Quill editor initialized successfully');
                        }
                      };
                      document.body.appendChild(quillJS);
                    } else if (window.Quill && document.getElementById('editor') && !window.quill) {
                      // Quill is already loaded, just initialize the editor
                      window.quill = new Quill('#editor', {
                        theme: 'snow',
                        placeholder: 'Type your message here...',
                        modules: {
                          toolbar: [
                            [{ 'header': [1, 2, 3, false] }],
                            ['bold', 'italic', 'underline', 'strike'],
                            [{ 'color': [] }, { 'background': [] }],
                            [{ 'list': 'ordered'}, { 'list': 'bullet' }],
                            [{ 'align': [] }],
                            ['link', 'blockquote', 'code-block'],
                            ['clean']
                          ]
                        }
                      });
                      console.log('Quill editor initialized successfully');
                    }

                    console.log('Bootstrap 5 and Quill injected successfully');
                  })();
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
      const quillData = window.quill ? window.quill.root.innerHTML : '';
      if (quillData.trim() !== '') {
        nestedData.quillData = quillData; // Add to the object if not empty
      }
      const jsonString = JSON.stringify(nestedData, null, 2);
      if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler('onFormSubmit', jsonString);
      } else {
        window.parent.postMessage({ type: 'onFormSubmit', payload: jsonString }, '*');
      }
    });
  });
''';

  String getChannelInitials(String name) {
    List<String> words = name.trim().split(' ');
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase();
    } else if (words.isNotEmpty && words[0].isNotEmpty) {
      return words[0][0].toUpperCase();
    } else {
      return '';
    }
  }

  Future<String> getJwt() async {
    final FlutterSecureStorage secureStorage = FlutterSecureStorage();
    final String? jwtToken = await secureStorage.read(key: "JWT_Token");
    return jwtToken ?? '';
  }

  Future<bool> onboardEntity() async {
    String token = await getJwt(); // Assuming you have this function to get JWT
    try {
      final onboardData = {
        "entityRole": "all",
      };

      dio.options.headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      final response = await dio.post(
        '$apiUrl/onboard',
        data: jsonEncode(onboardData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Onboarded entity successfully: ${response.data}");
        return true;
      } else {
        print("Failed to onboard entity: ${response.statusCode}");
        return false;
      }
    } on DioException catch (e) {
      print("Dio error onboarding entity: ${e.message}");
      print("Response: ${e.response?.data}");
      return false;
    } catch (e) {
      print("Error onboarding entity: $e");
      return false;
    }
  }

  Future<List<dynamic>> getPublicInterconnects() async {
    List<dynamic> publicInterconnects = [];
    try {
      String token = await getJwt();
      dio.options.headers["Authorization"] = "Bearer $token";
      final response = await dio.get('$apiUrl/public-interconnects');
      publicInterconnects = response.data;
    } catch (e) {
      print('Error fetching public interconnects: $e');
    }
    return publicInterconnects;
  }
  Future<List<dynamic>> getPubChannels(String entity, int actorId) async {
    try {
      final response = await dio.get(
        '$apiUrl/pub/channels/$entity',
        queryParameters: {
          "ActorID": actorId,
        },
        options: Options(
          headers: {
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        print("Channels fetched successfully: ${response.data}");
        return response.data; // assuming API returns a JSON array
      } else {
        print("Failed to fetch channels. Status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio error fetching channels: ${e.message}");
      print("Response: ${e.response?.data}");
    } catch (e) {
      print("Error fetching channels: $e");
    }
    return [];
  }

  Future<void> loadData(String tableName) async {
    try {
      String token = await getJwt(); 
      final sseManager = SSEManager();
      await sseManager.loadData(
        url: "$apiUrl/mtdd/load",
        token: token,
        tableName: tableName
      );

    } catch (e) {
      print("Error fetching channels: $e");
    }
  }
  Future<List<Map<String, dynamic>>> fetchChannels() async {
    await loadData("tblchannels");
    await loadData("tblxdocactors");
    final channels = await DashboardReplication.getChannels();
    return channels;
  }

  /// Streaming version of fetchChannels that watches for database changes
  Stream<List<Map<String, dynamic>>> fetchChannelsStream() async* {
    // Load initial data from server (non-blocking)
    loadData("tblchannels");
    loadData("tblxdocactors");
    
    // Stream channels from the database with real-time updates
    yield* DashboardReplication.watchChannels();
  }

  Future<List<dynamic>> getRespondentActors(String interconnectId) async {
    List<dynamic> actors = [];
    try {
      String token = await getJwt();
      dio.options.headers["Authorization"] = "Bearer $token";
      final response =
          await dio.get('$apiUrl/respondent-actors/$interconnectId');
      actors = response.data;
    } catch (e) {
      print('Error fetching respondent actors: $e');
    }
    return actors;
  }

  Future<bool> createChannel(String channelName, String actorId) async {
    String token = await getJwt();
    try {
      final channelData = {
        "initialActorID": actorId,
        "channelName": channelName,
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
        print("Channel created successfully: ${response.data}");
        return true;
      }
    } on DioException catch (e) {
      print("Dio error creating channel: ${e.message}");
      print("Response: ${e.response?.data}");
    } catch (e) {
      print("Error creating channel: $e");
    }
    return false;
  }

  Future<String> getSelectedEntity() async {
    final ssoService = SSOService();
    final String? entity = await ssoService.getSelectedEntity();
    return entity ?? '';
  }

  Future<bool> joinChannel(String entityId, String channelName, String? tagid,
      String? tagname,String? newSecQr) async {
    String token = await getJwt();
    print(
        'Joining channel with entityId: $entityId, channelName: $channelName, tagid: $tagid');
    try {
      final joinData = {
        "entityId": entityId,
        "channelName": channelName,
        "tagId": tagid
      };

      dio.options.headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      final response = await dio.post(
        '$apiUrl/join-channel',
        data: jsonEncode(joinData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Joined channel successfully: ${response.data}");
        addTagIfNotExists(
          oldEntityId: entityId,
          tagId: tagid!,
          oldChannelName: channelName,
          newChannelName: newSecQr!,
          tagName: tagname!,
        );
        return true;
      } else {
        print("Failed to join channel: ${response.statusCode}");
        return false;
      }
    } on DioException catch (e) {
      print("Dio error joining channel: ${e.message}");
      print("Response: ${e.response?.data}");
      return false;
    } catch (e) {
      print("Error joining channel: $e");
      return false;
    }
  }

  Future<void> addTagIfNotExists({
    required String oldEntityId,
    required String tagId,
    required String oldChannelName,
    required String newChannelName,
    required String tagName,
  }) async {
    String parentEntity = await getSelectedEntity();

    try {
      String? existingData = await secureStorage.read(key: "xdoc_tagsList");
      List<dynamic> tagsList =
          existingData != null ? jsonDecode(existingData) : [];

      Map<String, dynamic> tagData = {
        "tagName": tagName,
        "old": {
          "entityId": oldEntityId,
          "channelName": oldChannelName,
        },
      };

      int parentIndex = tagsList.indexWhere((item) =>
          item is Map<String, dynamic> && item.containsKey(parentEntity));

      if (parentIndex >= 0) {
        Map<String, dynamic> parentData = tagsList[parentIndex][parentEntity];

        if (parentData.containsKey(newChannelName)) {
          var channelEntry = parentData[newChannelName];
          if (channelEntry is Map<String, dynamic>) {
            if (!channelEntry.containsKey(tagId)) {
              channelEntry[tagId] = tagData;
              parentData[newChannelName] = channelEntry;
            }
          } else {
            parentData[newChannelName] = {
              tagId: tagData,
            };
          }
        } else {
          parentData[newChannelName] = {
            tagId: tagData,
          };
        }

        tagsList[parentIndex] = {parentEntity: parentData};
      } else {
        tagsList.add({
          parentEntity: {
            newChannelName: {
              tagId: tagData,
            },
          },
        });
      }

      await secureStorage.write(
        key: "xdoc_tagsList",
        value: jsonEncode(tagsList),
      );

      print(
          "Saved/updated tag data for $parentEntity ➔ $newChannelName ➔ $tagId");
    } catch (e) {
      print("Error saving tag data: $e");
    }
  }

  Future<void> removeTagById({
    required String channelName,
    required String tagId,
  }) async {
    String parentEntity = await getSelectedEntity();
    String? existingData = await secureStorage.read(key: "xdoc_tagsList");

    if (existingData == null) return; // Nothing to remove

    List<dynamic> tagsList = jsonDecode(existingData);

    // Find the index of the parent entity
    int parentIndex = tagsList.indexWhere(
      (item) => item is Map<String, dynamic> && item.containsKey(parentEntity),
    );

    if (parentIndex >= 0) {
      Map<String, dynamic> parentData = tagsList[parentIndex][parentEntity];

      if (parentData.containsKey(channelName)) {
        Map<String, dynamic> channelData = parentData[channelName];

        if (channelData.containsKey(tagId)) {
          channelData.remove(tagId);

          // If channelData is empty, remove the channel
          if (channelData.isEmpty) {
            parentData.remove(channelName);
          } else {
            parentData[channelName] = channelData;
          }

          // If parentData is empty, remove the parent entity
          if (parentData.isEmpty) {
            tagsList.removeAt(parentIndex);
          } else {
            tagsList[parentIndex] = {parentEntity: parentData};
          }

          // Save the updated data
          await secureStorage.write(
            key: "xdoc_tagsList",
            value: jsonEncode(tagsList),
          );
        }
      }
    }
  }
  Future<void> deleteTagsList() async {
    try {
      await secureStorage.delete(key: "xdoc_tagsList");
      print("🗑️ Deleted key: xdoc_tagsList");
    } catch (e) {
      print("❌ Error deleting key xdoc_tagsList: $e");
    }
  }
  Future<List<Map<String, String>>> getTagList(
      {required String channelName}) async {
    //  await secureStorage.delete( key: "xdoc_tagsList");
    String parentEntity = await getSelectedEntity();
    String? existingData = await secureStorage.read(key: "xdoc_tagsList");
    print('Fetching existing xdoc_tagsList from secure storage: $existingData');

    final List<Map<String, String>> results = [];

    if (existingData == null) return results;

    final List<dynamic> tagsList = jsonDecode(existingData);

    // Find the parent entity entry safely
    Map<String, dynamic>? parentEntry;
    for (final item in tagsList) {
      if (item is Map<String, dynamic> && item.containsKey(parentEntity)) {
        parentEntry = item;
        break;
      }
    }

    if (parentEntry == null) return results;

    final parentData = parentEntry[parentEntity];
    if (parentData is! Map<String, dynamic>) return results;

    // Check if channel exists
    if (!parentData.containsKey(channelName)) return results;

    final channelData = parentData[channelName];
    if (channelData is! Map<String, dynamic>) return results;

    channelData.forEach((tagId, tagInfo) {
      if (tagInfo is Map<String, dynamic>) {
        final old = (tagInfo["old"] is Map<String, dynamic>)
            ? tagInfo["old"] as Map<String, dynamic>
            : const {};
        results.add({
          "tagId": tagId.toString(),
          "tagName": tagInfo["tagName"]?.toString() ?? "", // ← added
          "channelName": channelName,
          "oldChannelName": old["channelName"]?.toString() ?? "",
          "oldEntityId": old["entityId"]?.toString() ?? "",
        });
      }
    });

    return results;
  }

  Future<bool> createTag(String tag, String tagDescription, String expireAt,
      String channelName) async {
    String token = await getJwt();
    try {
      final tagData = {
        "tag": tag,
        "tagDescription": tagDescription,
        "expireAt": expireAt,
      };

      // Set headers including Content-Type
      dio.options.headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      final response = await dio.post(
        '$apiUrl/channel/$channelName/tag',
        data: jsonEncode(tagData),
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Tag created successfully: ${response.data}");
        return true;
      }
    } on DioException catch (e) {
      print("Dio error creating tag: ${e.message}");
      print("Response: ${e.response?.data}");
    } catch (e) {
      print("Error creating tag: $e");
    }
    return false;
  }

  Future<List<dynamic>> getTags(int channelid) async {
    await loadData("tblchanneltags");
    final channelTags = await DashboardReplication.getChannelTags(channelid);
    return channelTags;
  }

  Future<List<dynamic>> getDocs(String channelName) async {
    String token = await getJwt();
    try {
      dio.options.headers["Authorization"] = "Bearer $token";
      dio.options.headers["Accept"] = "application/json";

      final response = await dio.get(
        '$apiUrl/docs/$channelName',
      );

      if (response.statusCode == 200) {
        print("Docs fetched successfully: ${response.data}");
        return response.data; // assuming API returns a JSON array
      } else {
        print("Failed to fetch docs. Status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio error fetching docs: ${e.message}");
      print("Response: ${e.response?.data}");
    } catch (e) {
      print("Error fetching docs: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>?> getContextAndPublicKey(
      String entityName, String channelName, String tagId) async {
    String token = await getJwt();
    try {
      // Set headers including Content-Type
      dio.options.headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      final response = await dio.get(
        '$apiUrl/context-and-public-key',
        queryParameters: {
          "entityName": entityName,
          "channelName": channelName,
          "tagId": tagId,
        },
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200) {
        print("Fetched context and public key successfully:");
        return response.data;
      }
    } on DioException catch (e) {
      print("Dio error fetching context and public key: ${e.message}");
      print("Response: ${e.response?.data}");
      return e.response?.data;
    } catch (e) {
      print("Error fetching context and public key: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> getDocumentDetails(String docId) async {
    final token = await getJwt();

    try {
      dio.options.headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      final response = await dio.get(
        '$apiUrl/document/$docId/details',
        options: Options(contentType: 'application/json'),
      );

      if (response.statusCode != 200) return response.data;

      final data = response.data;
      if (data == null) return null;

      final details = data["documentDetails"] as Map<String, dynamic>?;
      if (details == null) {
        print("❌ documentDetails is null");
        return data;
      }

      print("Fetched document details successfully");

      final keyBuf = details["current_user_encryptedsymmetrickey"]
          as Map<String, dynamic>?;
      if (keyBuf == null) {
        print("❌ current_user_encryptedsymmetrickey is null");
        return data;
      }

      // Step 1: get the bytes
      final List<int> rawBytes = List<int>.from(keyBuf["data"]);

      // Step 2: turn into a JSON string
      final jsonStr = String.fromCharCodes(rawBytes);

      // Step 3: parse JSON
      final Map<String, dynamic> codesMap = json.decode(jsonStr);

      // Step 4: extract values into a List<int>
      final codes = codesMap.values.map((e) => e as int).toList();

      // Step 5: convert char codes -> base64 string
      final encryptedKeyBase64 = String.fromCharCodes(codes);

      // Step 6: decode base64 into bytes
      // final Uint8List encryptedKeyBytes = base64.decode(encryptedKeyBase64);
      // print("Encrypted key (base64) length: ${encryptedKeyBase64.length}");
      // print("Encrypted key (bytes) length:  ${encryptedKeyBytes.length}");

      // ---- 2) Get your private key ----
      final senderKeys = await getSelectedEntityX25519Keys();
      if (senderKeys == null) {
        print("❌ Sender keys not found.");
        return data;
      }
      final privateKeyPem = senderKeys["privateKey"]!;

      // ---- 3) RSA decrypt the symmetric key ----
      // Choose ONE of these, depending on your rsaDecryption signature:

      // A) If rsaDecryption expects a Base64-encoded string of the ciphertext:
      final decrypted = await rsaDecryption(encryptedKeyBase64, privateKeyPem);

      // B) If rsaDecryption expects raw bytes (Uint8List), use this instead:
      // final decrypted = await rsaDecryption(encryptedKeyBytes, privateKeyPem);

      // print('Decrypted symmetric key (as text): $decrypted');

      // Your backend returns the symmetric key as a JSON array of ints (e.g. "[1,2,3...]")
      final List<dynamic> tempList = jsonDecode(decrypted);
      final List<int> symmetricKey = tempList.cast<int>();

      // ---- 4) Decrypt the document with that symmetric key ----
      final ctx = details["contextdata"] as Map<String, dynamic>?;
      if (ctx == null) {
        print("❌ contextdata is null");
        return {
          "data": data,
          "jsonData": null,
          "htmlTheme": details["contexttemplate"]
        };
      }

      final cipherText = ctx['cipherText'];
      final nonce = ctx['nonce'];
      final mac = ctx['mac'];

      if (cipherText == null || nonce == null || mac == null) {
        print("❌ Missing cipherText/nonce/mac in contextdata");
        return {
          "data": data,
          "jsonData": null,
          "htmlTheme": details["contexttemplate"]
        };
      }

      final decryptedDoc = await decryptWithSymmetrickey(
        symmetrickey: symmetricKey,
        cipherText: cipherText,
        nonce: nonce,
        mac: mac,
      );

      return {
        "data": data,
        "jsonData": decryptedDoc,
        "htmlTheme": details["contexttemplate"],
      };
    } on DioException catch (e) {
      print("Dio error fetching document details: ${e.message}");
      print("Response: ${e.response?.data}");
      return e.response?.data;
    } catch (e) {
      print("Error fetching document details: $e");
      return null;
    }
  }

  Future<bool> uploadPublicKey(String publicKey, String privateKey) async {
    String token = await getJwt();
    try {
      final data = {
        "publicKey": publicKey,
      };

      // Set headers including Content-Type
      dio.options.headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      final response = await dio.put(
        '$apiUrl/entity/public-key',
        data: jsonEncode(data), // Explicitly encode to JSON
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        String parentEntity = await getSelectedEntity();
        addOrUpdateEntityKeys(parentEntity, publicKey, privateKey);
        print("Public key uploaded successfully: ${response.data}");
        return true;
      }
    } on DioException catch (e) {
      print("Dio error uploading public key: ${e.message}");
      print("Response: ${e.response?.data}");
    } catch (e) {
      print("Error uploading public key: $e");
    }
    return false;
  }

  Future<void> addOrUpdateEntityKeys(
      String parentEntity, String publicKey, String privateKey) async {
    String? existing = await secureStorage.read(key: "entityRSAKeys");
    Map<String, dynamic> keysMap = {};

    if (existing != null) {
      keysMap = jsonDecode(existing);
    }

    // Add or update this entity's keys
    keysMap[parentEntity] = {
      "publicKey": publicKey,
      "privateKey": privateKey,
    };

    await secureStorage.write(key: "entityRSAKeys", value: jsonEncode(keysMap));
  }

  Future<Map<String, String>?> getSelectedEntityX25519Keys(
      [String? parentEntity]) async {
    parentEntity ??= await getSelectedEntity();
    String? existing = await secureStorage.read(key: "entityRSAKeys");

    if (existing != null) {
      Map<String, dynamic> keysMap = jsonDecode(existing);

      if (keysMap.containsKey(parentEntity)) {
        Map<String, dynamic> entityKeys = keysMap[parentEntity];
        return {
          "publicKey": entityKeys["publicKey"],
          "privateKey": entityKeys["privateKey"],
        };
      }
    }

    // Return null if not found
    return null;
  }

  Future<bool> createEncryptedDocument({
    required String entityName,
    required String channelName,
    required String tagId,
    required String submittedData,
  }) async {
    print('Creating encrypted document with entityName: $entityName, channelName: $channelName, tagId: $tagId');
    final symmetrickey = generate32BytesRandom();
    final encryptedContextData = await encryptWithSymmetrickey(
      symmetrickey: symmetrickey,
      plainText: submittedData,
    );
    final senderKeys = await getSelectedEntityX25519Keys();
    if (senderKeys == null) {
      print("❌ Sender keys not found.");
      return false;
    }
    final senderPublicKeyPem = senderKeys["publicKey"]!;

    final recipientKeys = await getSelectedEntityX25519Keys(entityName);
    if (recipientKeys == null) {
      print("❌ Recipient keys not found.");
      return false;
    }
    final recipientPublicPem = recipientKeys["publicKey"]!;

    final primaryEntitySymmetricKey =
        await rsaEncryption(symmetrickey.toString(), senderPublicKeyPem);
    final otherActorSymmetricKey =
        await rsaEncryption(symmetrickey.toString(), recipientPublicPem);
    String encryptedEventSchema = '';
    String token = await getJwt(); // Get your JWT token
    try {
      final body = {
        "entityName": entityName,
        "channelName": channelName,
        "tagId": tagId,
        "otherActorSymmetricKey": otherActorSymmetricKey.toString(),
        "primaryEntitySymmetricKey": primaryEntitySymmetricKey.toString(),
        "encryptedContextData": encryptedContextData,
        "encryptedEventSchema": encryptedEventSchema
      };

      dio.options.headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };
      print('Request body...........................: $body');
      final response = await dio.post(
        '$apiUrl/create-encrypted-document',
        data: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // print("Document created successfully: ${response.data}");
        return true;
      } else {
        print("Failed to create document: ${response.statusCode}");
        print("Error: ${response.data}");
        return false;
      }
    } on DioException catch (e) {
      print("Dio error creating document: ${e.message}");
      print("Response: ${e.response?.data}");
      return false;
    } catch (e) {
      print("Error creating document: $e");
      return false;
    }
  }

  Future<bool> updateEncryptedEvent({
    required String actionName,
    required String docid,
    required String submittedData,
  }) async {
    try {
      String token = await getJwt();
      print(submittedData);
      print('Updating document with ID: $docid');

      dio.options.headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      final response = await dio.get(
        '$apiUrl/document/$docid/details',
        options: Options(contentType: 'application/json'),
      );

      if (response.statusCode != 200) return false;

      final data = response.data;
      if (data == null) return false;

      final details = data["documentDetails"] as Map<String, dynamic>?;
      if (details == null) {
        print("❌ documentDetails is null");
        return false;
      }

      print("Fetched document details successfully");

      // ---- 1) Read the Buffer that holds a Base64 STRING ----
      final keyBuf = details["current_user_encryptedsymmetrickey"]
          as Map<String, dynamic>?;
      if (keyBuf == null) {
        print("❌ current_user_encryptedsymmetrickey is null");
        return false;
      }

      // Step 1: get the bytes
      final List<int> rawBytes = List<int>.from(keyBuf["data"]);

      // Step 2: turn into a JSON string
      final jsonStr = String.fromCharCodes(rawBytes);

      // Step 3: parse JSON
      final Map<String, dynamic> codesMap = json.decode(jsonStr);

      // Step 4: extract values into a List<int>
      final codes = codesMap.values.map((e) => e as int).toList();

      // Step 5: convert char codes -> base64 string
      final encryptedKeyBase64 = String.fromCharCodes(codes);
      print("Encrypted key (base64): $encryptedKeyBase64");

      // Step 6: decode base64 into bytes
      // final Uint8List encryptedKeyBytes = base64.decode(encryptedKeyBase64);
      // print("Encrypted key (base64) length: ${encryptedKeyBase64.length}");
      // print("Encrypted key (bytes) length:  ${encryptedKeyBytes.length}");

      // ---- 2) Get your private key ----
      final senderKeys = await getSelectedEntityX25519Keys();
      if (senderKeys == null) {
        print("❌ Sender keys not found.");
        return false;
      }
      final privateKeyPem = senderKeys["privateKey"]!;

      // ---- 3) RSA decrypt the symmetric key ----
      final decryptedBase64 =
          await rsaDecryption(encryptedKeyBase64, privateKeyPem);

      // Parse string "[71, 190, ...]" → List<int>
      final List<int> decryptedBytes = decryptedBase64
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((s) => int.parse(s.trim()))
          .toList();

      final Uint8List symmetrickey = Uint8List.fromList(decryptedBytes);

      print('Decrypted symmetric key (bytes): $symmetrickey');

      final encryptedEventSchema = await encryptWithSymmetrickey(
        symmetrickey: symmetrickey,
        plainText: submittedData,
      );

      final body = {
        "xdocId": docid,
        "encryptedContextData": details["contextdata"],
        "eventName": actionName,
        "encryptedEventSchema": encryptedEventSchema,
      };

      dio.options.headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      print('Request body...........................: $body');

      final updateResponse = await dio.put(
        '$apiUrl/update-encrypted-document',
        data: jsonEncode(body),
      );

      if (updateResponse.statusCode == 200 ||
          updateResponse.statusCode == 201) {
        print("Document updated successfully: ${updateResponse.data}");
        return true;
      } else {
        print("Failed to create document: ${updateResponse.statusCode}");
        print("Error: ${updateResponse.data}");
        return false;
      }
    } on DioException catch (e) {
      print("Dio error creating document: ${e.message}");
      print("Response: ${e.response?.data}");
      return false;
    } catch (e) {
      print("Error creating document: $e");
      return false;
    }
  }

  Future<dynamic> getChannelDetailsForJoin({
    required String entityId,
    required String channelName,
    required String tagId,
  }) async {
    String token = await getJwt(); // If you use JWT like in your getDocs
    try {
      dio.options.headers["Authorization"] = "Bearer $token";
      dio.options.headers["Accept"] = "application/json";

      final response = await dio.get(
        '$apiUrl/channel-details-for-join',
        queryParameters: {
          'entityId': entityId,
          'channelName': channelName,
          'tagId': tagId,
        },
      );

      if (response.statusCode == 200) {
        print("Channel details fetched successfully: ${response.data}");
        return response.data; // Assuming API returns JSON object or array
      } else {
        print(
            "Failed to fetch channel details. Status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio error fetching channel details: ${e.message}");
      print("Response: ${e.response?.data}");
    } catch (e) {
      print("Error fetching channel details: $e");
    }
    return null;
  }
}
