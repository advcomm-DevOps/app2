import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:xdoc/custom/constants.dart';
import 'package:xdoc/custom/services/sso.dart';
import 'package:xdoc/custom/services/encryption.dart';
import 'package:xdoc/views/dashboard/dashboard_replication.dart';
import 'dart:typed_data';
import 'package:tenant_replication/tenant_replication.dart';

class DashboardController {
  final Dio dio = Dio();
  final String apiUrl = 'https://$audDomain';
  //final String apiUrl = 'http://localhost:3000';
  final String qrurl = 'https://web.xdoc.app/c/';
  
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

  // Logging system for tracking operations
  final Map<String, List<Map<String, dynamic>>> temporaryLogs = {
    "success": [],
    "fail": [],
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
                          
                          // Add change listener for Quill editor
                          window.quill.on('text-change', function() {
                            handleFormChange();
                          });
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
                      
                      // Add change listener for Quill editor
                      window.quill.on('text-change', function() {
                        handleFormChange();
                      });
                    }

                    console.log('Bootstrap 5 and Quill injected successfully');
                  })();
  console.log("🔥 JavaScript code injected and running");

  function processFormData(form) {
    const formData = new FormData(form);
    const data = {};

    // Convert FormData to nested object
    for (let [key, value] of formData.entries()) {
      const keys = key.match(/([a-zA-Z0-9_]+)/g); // Split by brackets and dots
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

  // Function to handle form changes and send to Flutter
  function handleFormChange() {
    const form = document.querySelector('form');
    if (form) {
      const nestedData = processFormData(form);
      const quillData = window.quill ? window.quill.root.innerHTML : '';
      if (quillData.trim() !== '') {
        nestedData.quillData = quillData;
      }
      const jsonString = JSON.stringify(nestedData, null, 2);
      
      console.log('📝 Form changed, sending data to Flutter');
      if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler('onFormChange', jsonString);
      } else {
        window.parent.postMessage({ type: 'onFormChange', payload: jsonString }, '*');
      }
    }
  }

  // Debounce function to avoid too many calls
  function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  }

  // Debounced version of handleFormChange (300ms delay)
  const debouncedFormChange = debounce(handleFormChange, 300);

  // Add change listeners to all form elements
  document.querySelectorAll('form').forEach(form => {
    // Handle form submission
    form.addEventListener('submit', function(event) {
      event.preventDefault();
      
      // Check HTML5 form validity
      if (!this.checkValidity()) {
        console.log('❌ HTML5 validation failed');
        this.reportValidity(); // Show validation messages
        return; // Don't proceed with submission
      }
      
      console.log('✅ HTML5 validation passed, processing form data');
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

    // Add change listeners to all input, select, and textarea elements
    form.querySelectorAll('input, select, textarea').forEach(element => {
      // Handle input events (for text fields, number fields, etc.)
      element.addEventListener('input', debouncedFormChange);
      
      // Handle change events (for checkboxes, radio buttons, select dropdowns)
      element.addEventListener('change', debouncedFormChange);
    });
    
    console.log('✅ Form change listeners attached');
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

  // PEM helper method
  String _addLineBreaksToPemKey(String pemKey) {
    const lineLength = 64;
    String result = '';
    for (int i = 0; i < pemKey.length; i += lineLength) {
      if (i + lineLength < pemKey.length) {
        result += pemKey.substring(i, i + lineLength) + '\n';
      } else {
        result += pemKey.substring(i);
      }
    }
    return result;
  }

  // Logging helper methods
  void logSuccess(String message) {
    final now = DateTime.now();
    final timestamp = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    
    temporaryLogs["success"]!.add({
      "time": timestamp,
      "message": message,
    });
    
    print("✅ SUCCESS LOG: $message at $timestamp");
  }

  void logFailure(String message) {
    final now = DateTime.now();
    final timestamp = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    
    temporaryLogs["fail"]!.add({
      "time": timestamp,
      "message": message,
    });
    
    print("❌ FAILURE LOG: $message at $timestamp");
  }

  // Method to get all logs
  Map<String, List<Map<String, dynamic>>> getAllLogs() {
    return Map.from(temporaryLogs);
  }

  // Method to clear logs
  void clearLogs() {
    temporaryLogs["success"]!.clear();
    temporaryLogs["fail"]!.clear();
    print("🧹 All logs cleared");
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
        logSuccess("Entity onboarded successfully");
        return true;
      } else {
        print("Failed to onboard entity: ${response.statusCode}");
        logFailure("Failed to onboard entity - Status: ${response.statusCode}");
        return false;
      }
    } on DioException catch (e) {
      print("Dio error onboarding entity: ${e.message}");
      print("Response: ${e.response?.data}");
      logFailure("Dio error onboarding entity: ${e.message} - Response: ${e.response?.data}");
      return false;
    } catch (e) {
      print("Error onboarding entity: $e");
      logFailure("Error onboarding entity: $e");
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
      logSuccess("Public interconnects fetched successfully");
    } catch (e) {
      print('Error fetching public interconnects: $e');
      logFailure("Error fetching public interconnects: $e");
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
        logSuccess("Pub channels fetched successfully for entity '$entity'");
        return response.data; // assuming API returns a JSON array
      } else {
        print("Failed to fetch channels. Status code: ${response.statusCode}");
        logFailure("Failed to fetch pub channels for entity '$entity' - Status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio error fetching channels: ${e.message}");
      print("Response: ${e.response?.data}");
      logFailure("Dio error fetching pub channels for entity '$entity': ${e.message} - Response: ${e.response?.data}");
    } catch (e) {
      print("Error fetching channels: $e");
      logFailure("Error fetching pub channels for entity '$entity': $e");
    }
    return [];
  }
  Future<List<dynamic>> getPubChannelTags(String entity, String channelName) async {
    try {
      final response = await dio.get(
        '$apiUrl/pub/channel/$entity/$channelName/tags',
        options: Options(
          headers: {
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        print("Channel tags fetched successfully: ${response.data}");
        logSuccess("Pub channel tags fetched successfully for entity '$entity', channel '$channelName'");
        return response.data; // assuming API returns a JSON array
      } else {
        print("Failed to fetch channel tags. Status code: ${response.statusCode}");
        logFailure("Failed to fetch pub channel tags for entity '$entity', channel '$channelName' - Status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio error fetching channel tags: ${e.message}");
      print("Response: ${e.response?.data}");
      logFailure("Dio error fetching pub channel tags for entity '$entity', channel '$channelName': ${e.message} - Response: ${e.response?.data}");
    } catch (e) {
      print("Error fetching channel tags: $e");
      logFailure("Error fetching pub channel tags for entity '$entity', channel '$channelName': $e");
    }
    return [];
  }

  // Future<void> loadData(String tableName) async {
  //   try {
  //     String token = await getJwt(); 
  //     final sseManager = SSEManager();
  //     await sseManager.loadData(
  //       url: "$apiUrl/mtdd/load",
  //       token: token,
  //       tableName: tableName
  //     );

  //   } catch (e) {
  //     print("Error fetching channels: $e");
  //   }
  // }
  Future<void> loadData(
    String tableName, {
    Map<String, dynamic>? extraParams, // 👈 allow optional query params
  }) async {
    try {
      String token = await getJwt(); 
      final sseManager = SSEManager();
      await sseManager.loadData(
        url: "$apiUrl/mtdd/load",
        token: token,
        tableName: tableName,
        extraParams: extraParams, // 👈 pass them down
      );
    } catch (e) {
      print("Error fetching $tableName: $e");
      logFailure("Error fetching $tableName: $e");
    }
  }
  // Future<List<Map<String, dynamic>>> fetchChannels() async {
  //   // await loadData("tblchannels", extraParams: {
  //   //   "status": "active",
  //   //   "region": "EU",
  //   // });
  //   await loadData("tblchannels");
  //   await loadData("tblxdocs");
  //   await loadData("tblxdocactors");
  //   final channels = await DashboardReplication.getChannels();
  //   return channels;
  // }

  /// Streaming version of fetchChannels that watches for database changes
  Stream<List<Map<String, dynamic>>> fetchChannelsStream() async* {
    // Load initial data from server (non-blocking)
    loadData("tblchannels");
    loadData("tblxdocs");
    loadData("tblchanneltags");
    loadData("tblxdocactors");
    
    // Stream channels from the database with real-time updates
    yield* DashboardReplication.watchChannels();
  }

  Future<List<dynamic>> getRespondentActors(String interconnectId) async {
    List<dynamic> actors = [];
    try {
      String token = await getJwt();
      dio.options.headers["Authorization"] = "Bearer $token";
      print("apiUrl: $apiUrl");
      final response =
          await dio.get('$apiUrl/respondent-actors/$interconnectId');
          print('Respondent actors response: ${response.data}');
      actors = response.data;
      logSuccess("Respondent actors fetched successfully for interconnect '$interconnectId'");
    } catch (e) {
      print('Error fetching respondent actors: $e');
      logFailure("Error fetching respondent actors for interconnect '$interconnectId': $e");
    }
    return actors;
  }

  Future<bool> createChannel(String channelName, String actorId) async {
    String token = await getJwt();
    print('Creating channel with name: $channelName, actorId: $actorId');
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
      print('Create channel response: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Channel created successfully: ${response.data}");
        logSuccess("Channel '$channelName' created successfully");
        return true;
      } else {
        logFailure("Failed to create channel '$channelName' - Status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio error creating channel: ${e.message}");
      print("Response: ${e.response?.data}");
      logFailure("Dio error creating channel '$channelName': ${e.message} - Response: ${e.response?.data}");
    } catch (e) {
      print("Error creating channel: $e");
      logFailure("Error creating channel '$channelName': $e");
    }
    return false;
  }

  Future<bool> deleteChannel(String channelId) async {
    String token = await getJwt();
    print('Deleting channel with ID: $channelId');
    try {
      // Set headers including Content-Type
      dio.options.headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };
      final response = await dio.delete(
        '$apiUrl/channel/$channelId',
        options: Options(
          contentType: 'application/json',
        ),
      );
      print('Delete channel response: ${response.data}');
      if (response.statusCode == 200) {
        print("Channel deleted successfully: ${response.data}");
        
        // Also delete from SQLite database
        try {
          final sqliteDeleted = await DashboardReplication.deleteChannel(channelId);
          if (sqliteDeleted) {
            print("Channel also deleted from SQLite successfully");
            logSuccess("Channel '$channelId' deleted successfully from both API and SQLite");
          } else {
            print("Warning: Channel deleted from API but not found in SQLite");
            logSuccess("Channel '$channelId' deleted successfully from API (not found in SQLite)");
          }
        } catch (e) {
          print("Error deleting channel from SQLite: $e");
          logFailure("Channel '$channelId' deleted from API but failed to delete from SQLite: $e");
        }
        
        return true;
      } else {
        logFailure("Failed to delete channel '$channelId' - Status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio error deleting channel: ${e.message}");
      print("Response: ${e.response?.data}");
      logFailure("Dio error deleting channel '$channelId': ${e.message} - Response: ${e.response?.data}");
    } catch (e) {
      print("Error deleting channel: $e");
      logFailure("Error deleting channel '$channelId': $e");
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
        
        // Extract newChannelName from the response
        final responseData = response.data as Map<String, dynamic>?;
        final String? returnedNewChannelName = responseData?['newChannelName'];
        
        if (returnedNewChannelName != null) {
          print("✅ New Channel Name from API: $returnedNewChannelName");
          
          // Use the returned newChannelName instead of the passed parameter
          addTagIfNotExists(
            oldEntityId: entityId,
            tagId: tagid!,
            oldChannelName: channelName,
            newChannelName: returnedNewChannelName,
            tagName: tagname!,
          );
        } else {
          print("⚠️ newChannelName not found in response, using fallback: $newSecQr");
          // Fallback to the passed parameter if API doesn't return it
          addTagIfNotExists(
            oldEntityId: entityId,
            tagId: tagid!,
            oldChannelName: channelName,
            newChannelName: newSecQr!,
            tagName: tagname!,
          );
        }
        
        logSuccess("Joined channel '$channelName' successfully - New channel name: ${returnedNewChannelName ?? newSecQr}");
        return true;
      } else {
        print("Failed to join channel: ${response.statusCode}");
        logFailure("Failed to join channel '$channelName' - Status: ${response.statusCode}");
        return false;
      }
    } on DioException catch (e) {
      print("Dio error joining channel: ${e.message}");
      print("Response: ${e.response?.data}");
      logFailure("Dio error joining channel '$channelName': ${e.message} - Response: ${e.response?.data}");
      return false;
    } catch (e) {
      print("Error joining channel: $e");
      logFailure("Error joining channel '$channelName': $e");
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
    // await secureStorage.delete( key: "xdoc_tagsList");
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
        "expireAt": (expireAt.trim().isEmpty) ? null : expireAt,
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
        logSuccess("Tag '$tag' created successfully in channel '$channelName'");
        return true;
      } else {
        logFailure("Failed to create tag '$tag' in channel '$channelName' - Status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio error creating tag: ${e.message}");
      print("Response: ${e.response?.data}");
      logFailure("Dio error creating tag '$tag': ${e.message} - Response: ${e.response?.data}");
    } catch (e) {
      print("Error creating tag: $e");
      logFailure("Error creating tag '$tag': $e");
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
        logSuccess("Docs fetched successfully for channel '$channelName'");
        return response.data; // assuming API returns a JSON array
      } else {
        print("Failed to fetch docs. Status code: ${response.statusCode}");
        logFailure("Failed to fetch docs for channel '$channelName' - Status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio error fetching docs: ${e.message}");
      print("Response: ${e.response?.data}");
      logFailure("Dio error fetching docs for channel '$channelName': ${e.message} - Response: ${e.response?.data}");
    } catch (e) {
      print("Error fetching docs: $e");
      logFailure("Error fetching docs for channel '$channelName': $e");
    }
    return [];
  }

  Future<Map<String, dynamic>?> getContextAndPublicKey(
      String entityName, String channelName, String? tagId) async {
    String token = await getJwt();
    try {
      // Set headers including Content-Type
      dio.options.headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      // Build query parameters conditionally
      final queryParams = {
        "entityName": entityName,
        "channelName": channelName,
      };
      
      // Only add tagId if it's not null
      if (tagId != null) {
        queryParams["tagId"] = tagId;
      }

      final response = await dio.get(
        '$apiUrl/context-and-public-key',
        queryParameters: queryParams,
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200) {
        print("Fetched context and public key successfully:");
        // print("Entity: ${response.data['entityname']}");
        // print("................................");
        // List<dynamic> keyData = response.data['publickey']['data'];
        // print("Public key (raw bytes): $keyData");
        // print("................................");
        // String? existing = await secureStorage.read(key: "entityRSAKeys");
        // print("Existing stored entityRSAKeys: $existing");
        final tagInfo = tagId != null ? ", tag '$tagId'" : " (no tag)";
        logSuccess("Context and public key fetched successfully for entity '$entityName', channel '$channelName'$tagInfo");
        // print("Response data.............: ${response.data}");
        return response.data;
      } else {
        final tagInfo = tagId != null ? ", tag '$tagId'" : " (no tag)";
        logFailure("Failed to fetch context and public key for entity '$entityName', channel '$channelName'$tagInfo - Status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio error fetching context and public key: ${e.message}");
      print("Response: ${e.response?.data}");
      logFailure("Dio error fetching context and public key for entity '$entityName': ${e.message} - Response: ${e.response?.data}");
      return e.response?.data;
    } catch (e) {
      print("Error fetching context and public key: $e");
      logFailure("Error fetching context and public key for entity '$entityName': $e");
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
      final encryptedKeyBase64 = jsonStr;

      // ---- 2) Get your private key ----
      final senderKeys = await getSelectedEntityRSAKeys();
      if (senderKeys == null) {
        print("❌ Sender keys not found.");
        return data;
      }
      final privateKeyPem = senderKeys["privateKey"]!;
      // ---- 3) Decrypt the symmetric key with your private key ----
      final decrypted = await rsaDecryption(encryptedKeyBase64, privateKeyPem);

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

      logSuccess("Document details fetched and decrypted successfully for document '$docId'");
      return {
        "data": data,
        "jsonData": decryptedDoc,
        "htmlTheme": details["contexttemplate"],
        "current_user_active_states": details["current_user_active_states"],
        "expected_state_transitions": details["expected_state_transitions"]
      };
    } on DioException catch (e) {
      print("Dio error fetching document details: ${e.message}");
      print("Response: ${e.response?.data}");
      logFailure("Dio error fetching document details for document '$docId': ${e.message} - Response: ${e.response?.data}");
      return e.response?.data;
    } catch (e) {
      print("Error fetching document details: $e");
      logFailure("Error fetching document details for document '$docId': $e");
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
        logSuccess("Public key uploaded successfully for entity '$parentEntity'");
        return true;
      } else {
        logFailure("Failed to upload public key - Status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio error uploading public key: ${e.message}");
      print("Response: ${e.response?.data}");
      logFailure("Dio error uploading public key: ${e.message} - Response: ${e.response?.data}");
    } catch (e) {
      print("Error uploading public key: $e");
      logFailure("Error uploading public key: $e");
    }
    return false;
  }

  Future<Map<String, dynamic>?> getEntityPublicKey(String entityName) async {
    String token = await getJwt();
    try {
      final data = {
        "tid": entityName,
      };

      // Set headers including Content-Type
      dio.options.headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      final response = await dio.post(
        '$apiUrl/entity/public-key',
        data: jsonEncode(data),
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200) {
        print("Entity public key retrieved successfully: ${response.data}");
        logSuccess("Entity public key retrieved successfully for entity '$entityName'");
        return response.data;
      } else if (response.statusCode == 404) {
        print("Entity not found for entity: $entityName");
        logFailure("Entity not found when retrieving public key for entity '$entityName' - Status: ${response.statusCode}");
        return null;
      } else if (response.statusCode == 422) {
        print("Invalid request: entity name is required");
        logFailure("Invalid request when retrieving public key - entity name is required - Status: ${response.statusCode}");
        return null;
      } else {
        print("Failed to retrieve entity public key. Status code: ${response.statusCode}");
        logFailure("Failed to retrieve entity public key for entity '$entityName' - Status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio error retrieving entity public key: ${e.message}");
      print("Response: ${e.response?.data}");
      logFailure("Dio error retrieving entity public key for entity '$entityName': ${e.message} - Response: ${e.response?.data}");
      return e.response?.data;
    } catch (e) {
      print("Error retrieving entity public key: $e");
      logFailure("Error retrieving entity public key for entity '$entityName': $e");
    }
    return null;
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

  Future<Map<String, String>?> getSelectedEntityRSAKeys(
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
    required String fromChannelName,
    required String channelName,
    String? tagId,
    required String submittedData
  }) async {
    print('Creating encrypted document with entityName: $entityName, channelName: $channelName, tagId: $tagId');
    
    // Validate input parameters
    if (entityName.isEmpty) {
      print("❌ Entity name is empty.");
      logFailure("Entity name is empty when creating encrypted document");
      return false;
    }
    if (channelName.isEmpty) {
      print("❌ Channel name is empty.");
      logFailure("Channel name is empty when creating encrypted document");
      return false;
    }
    if (submittedData.isEmpty) {
      print("❌ Submitted data is empty.");
      logFailure("Submitted data is empty when creating encrypted document - entity: '$entityName', channel: '$channelName'");
      return false;
    }
    
    try {
      // Generate symmetric key
      late final dynamic symmetrickey;
      try {
        symmetrickey = generate32BytesRandom();
        if (symmetrickey == null) {
          print("❌ Failed to generate symmetric key.");
          logFailure("Failed to generate symmetric key for entity '$entityName', channel '$channelName'");
          return false;
        }
      } catch (e) {
        print("❌ Error generating symmetric key: $e");
        logFailure("Error generating symmetric key for entity '$entityName', channel '$channelName': $e");
        return false;
      }
      
      // Encrypt context data with symmetric key
      late final Map<String, dynamic> encryptedContextData;
      try {
        encryptedContextData = await encryptWithSymmetrickey(
          symmetrickey: symmetrickey,
          plainText: submittedData,
        );
      } catch (e) {
        print("❌ Failed to encrypt context data: $e");
        logFailure("Failed to encrypt context data for entity '$entityName', channel '$channelName': $e");
        return false;
      }
      
      // Get sender keys
      final senderKeys = await getSelectedEntityRSAKeys();
      if (senderKeys == null) {
        print("❌ Sender keys not found.");
        logFailure("Sender keys not found for creating encrypted document - entity: '$entityName', channel: '$channelName'");
        return false;
      }
      final senderPublicKeyPem = senderKeys["publicKey"]!;

      // Get recipient keys
      final recipientResponse = await getEntityPublicKey(entityName);
      print('Recipient response: $recipientResponse');
      if (recipientResponse == null || recipientResponse['publicKey'] == null) {
        print("❌ Recipient keys not found.");
        logFailure("Recipient keys not found for entity '$entityName' when creating encrypted document - channel: '$channelName'");
        return false;
      }
      // Normalize the public key format from custom delimiters to standard PEM format
      String recipientPublicPem = recipientResponse['publicKey'];
      if (recipientPublicPem.contains('+++++BEGINRSAPUBLICKEY+++++')) {
        // Extract the key content between delimiters
        final keyContent = recipientPublicPem
            .replaceAll('+++++BEGINRSAPUBLICKEY+++++', '')
            .replaceAll('+++++ENDRSAPUBLICKEY+++++', '')
            .trim();
        
        // Format with proper PEM structure and line breaks
        final formattedKeyContent = _addLineBreaksToPemKey(keyContent);
        recipientPublicPem = '-----BEGIN RSA PUBLIC KEY-----\n$formattedKeyContent\n-----END RSA PUBLIC KEY-----';
      }

      // Encrypt symmetric key with both public keys
      late final String primaryEntitySymmetricKey;
      late final String otherActorSymmetricKey;
      
      try {
        primaryEntitySymmetricKey =
            await rsaEncryption(symmetrickey.toString(), senderPublicKeyPem);
      } catch (e) {
        print("❌ Failed to encrypt symmetric key with sender public key: $e");
        logFailure("Failed to encrypt symmetric key with sender public key for entity '$entityName', channel '$channelName': $e");
        return false;
      }
      
      try {
        otherActorSymmetricKey =
            await rsaEncryption(symmetrickey.toString(), recipientPublicPem);
      } catch (e) {
        print("❌ Failed to encrypt symmetric key with recipient public key: $e");
        logFailure("Failed to encrypt symmetric key with recipient public key for entity '$entityName', channel '$channelName': $e");
        return false;
      }
      String encryptedEventSchema = '';
      
      // Get JWT token
      late final String token;
      try {
        token = await getJwt();
        if (token.isEmpty) {
          print("❌ JWT token is empty.");
          logFailure("JWT token is empty when creating encrypted document - entity: '$entityName', channel: '$channelName'");
          return false;
        }
      } catch (e) {
        print("❌ Error getting JWT token: $e");
        logFailure("Error getting JWT token when creating encrypted document - entity: '$entityName', channel: '$channelName': $e");
        return false;
      }

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
      
      // Encode request body to JSON
      late final String jsonBody;
      try {
        jsonBody = jsonEncode(body);
      } catch (e) {
        print("❌ Failed to encode request body to JSON: $e");
        logFailure("Failed to encode request body to JSON for entity '$entityName', channel '$channelName': $e");
        return false;
      }
      
      // Validate API URL
      if (apiUrl.isEmpty) {
        print("❌ API URL is empty.");
        logFailure("API URL is empty when creating encrypted document for entity '$entityName', channel '$channelName'");
        return false;
      }
      
      final response = await dio.post(
        '$apiUrl/create-encrypted-document/$fromChannelName',
        data: jsonBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // print("Document created successfully: ${response.data}");
        logSuccess("Encrypted document created successfully for entity '$entityName' in channel '$channelName'");
        return true;
      } else {
        print("Failed to create document: ${response.statusCode}");
        print("Error: ${response.data}");
        logFailure("Failed to create encrypted document for entity '$entityName' - Status: ${response.statusCode} - Error: ${response.data}");
        return false;
      }
    } on DioException catch (e) {
      print("Dio error creating document: ${e.message}");
      print("Response: ${e.response?.data}");
      logFailure("Dio error creating encrypted document for entity '$entityName': ${e.message} - Response: ${e.response?.data}");
      return false;
    } catch (e) {
      print("Error creating document: $e");
      logFailure("Error creating encrypted document for entity '$entityName': $e");
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
      final encryptedKeyBase64 = jsonStr;

      // ---- 2) Get your private key ----
      final senderKeys = await getSelectedEntityRSAKeys();
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
        logSuccess("Document '$docid' updated successfully with action '$actionName'");
        return true;
      } else {
        print("Failed to create document: ${updateResponse.statusCode}");
        print("Error: ${updateResponse.data}");
        logFailure("Failed to update document '$docid' with action '$actionName' - Status: ${updateResponse.statusCode}");
        return false;
      }
    } on DioException catch (e) {
      print("Dio error creating document: ${e.message}");
      print("Response: ${e.response?.data}");
      logFailure("Dio error updating document '$docid' with action '$actionName': ${e.message} - Response: ${e.response?.data}");
      return false;
    } catch (e) {
      print("Error creating document: $e");
      logFailure("Error updating document '$docid' with action '$actionName': $e");
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
        logSuccess("Channel details fetched successfully for entity '$entityId', channel '$channelName', tag '$tagId'");
        return response.data; // Assuming API returns JSON object or array
      } else {
        print(
            "Failed to fetch channel details. Status code: ${response.statusCode}");
        logFailure("Failed to fetch channel details for entity '$entityId', channel '$channelName', tag '$tagId' - Status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio error fetching channel details: ${e.message}");
      print("Response: ${e.response?.data}");
      logFailure("Dio error fetching channel details for entity '$entityId', channel '$channelName': ${e.message} - Response: ${e.response?.data}");
    } catch (e) {
      print("Error fetching channel details: $e");
      logFailure("Error fetching channel details for entity '$entityId', channel '$channelName': $e");
    }
    return null;
  }

  Future<dynamic> getReciprocalChannelDetails({
    required String otherUserTid,
    required String otherChannelName,
  }) async {
    String token = await getJwt();
    try {
      dio.options.headers["Authorization"] = "Bearer $token";
      dio.options.headers["Accept"] = "application/json";

      final response = await dio.get(
        '$apiUrl/reciprocal-channel-details',
        queryParameters: {
          'otherUserTid': otherUserTid,
          'otherChannelName': otherChannelName,
        },
      );

      if (response.statusCode == 200) {
        print("Reciprocal channel details fetched successfully: ${response.data}");
        logSuccess("Reciprocal channel details fetched successfully for otherUserTid '$otherUserTid', channel '$otherChannelName'");
        logSuccess('Reciprocal channel details fetched successfully: ${response.data}');
        // API returns { message, channels: [...] }
        return response.data;
      } else if (response.statusCode == 404) {
        print("No reciprocal channel details found. Status code: ${response.statusCode}");
        logFailure("No reciprocal channel details found for otherUserTid '$otherUserTid', channel '$otherChannelName' - Status: ${response.statusCode}");
        return response.data;
      } else {
        print("Failed to fetch reciprocal channel details. Status code: ${response.statusCode}");
        logFailure("Failed to fetch reciprocal channel details for otherUserTid '$otherUserTid', channel '$otherChannelName' - Status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio error fetching reciprocal channel details: ${e.message}");
      print("Response: ${e.response?.data}");
      logFailure("Dio error fetching reciprocal channel details for otherUserTid '$otherUserTid', channel '$otherChannelName': ${e.message} - Response: ${e.response?.data}");
      return e.response?.data;
    } catch (e) {
      print("Error fetching reciprocal channel details: $e");
      logFailure("Error fetching reciprocal channel details for otherUserTid '$otherUserTid', channel '$otherChannelName': $e");
    }
    return null;
  }
}
