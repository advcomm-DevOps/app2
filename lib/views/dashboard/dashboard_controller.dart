import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_starter/custom/services/sso.dart';

class DashboardController {
  final Dio dio = Dio();
  final String apiUrl = 'http://localhost:3000';
  final String qrurl = 'https://s.xdoc.app/c/';
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

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

  Future<bool> joinChannel(
      String entityId, String channelName, String? tagid) async {
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
        String updatedChannelName =
            response.data['newChannelName'] ?? channelName;
        // addTagIfNotExists(entityId, updatedChannelName, tagid ?? "defaultTagId");
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
  }) async {
    String parentEntity = await getSelectedEntity();

    // Read existing
    String? existingData = await secureStorage.read(key: "xdoc_tagsList");

    List<dynamic> tagsList = [];
    if (existingData != null) {
      tagsList = jsonDecode(existingData);
    }

    // Build exactly:
    Map<String, dynamic> tagData = {
      parentEntity: {
        "tagId": tagId,
        "old": {
          "entityId": oldEntityId,
          "channelName": oldChannelName,
        },
        "new": {
          "entityId": parentEntity,
          "channelName": newChannelName,
        },
      }
    };

    // Optionally check if parentEntity already exists and replace
    int existingIndex = tagsList.indexWhere((item) => item.containsKey(parentEntity));

    if (existingIndex >= 0) {
      tagsList[existingIndex] = tagData;
    } else {
      tagsList.add(tagData);
    }

    // Save back to storage
    await secureStorage.write(
      key: "xdoc_tagsList",
      value: jsonEncode(tagsList),
    );

    print("Saved tag data: $tagData");
  }


  // Future<void> addTagIfNotExists(
  //     String entityId, String channelName, String tagId) async {
  //   String parentEntity = await getSelectedEntity();
  //   String? existingData = await secureStorage.read(key: "xdoc_tagsList");

  //   // Initialize as Map<String, dynamic>
  //   Map<String, dynamic> joinDataMap = {};

  //   if (existingData != null) {
  //     // Parse JSON to Map
  //     joinDataMap = json.decode(existingData);
  //   }

  //   // Get the map for parentEntity or initialize
  //   Map<String, dynamic> entityMap = joinDataMap[parentEntity] ?? {};

  //   // Get the list for this channelName or initialize
  //   List<Map<String, dynamic>> channelList = [];

  //   if (entityMap[channelName] != null) {
  //     channelList = List<Map<String, dynamic>>.from(entityMap[channelName]);
  //   }

  //   // Check if tagId exists within this channel
  //   bool exists = channelList.any((item) => item['tagId'] == tagId);

  //   if (!exists) {
  //     // Create new data map
  //     final joinData = {
  //       "entityId": entityId,
  //       "tagId": tagId,
  //     };

  //     // Add to channel list
  //     channelList.add(joinData);

  //     // Update entityMap and joinDataMap
  //     entityMap[channelName] = channelList;
  //     joinDataMap[parentEntity] = entityMap;

  //     // Write updated map back to secure storage as JSON string
  //     await secureStorage.write(
  //       key: "xdoc_tagsList",
  //       value: json.encode(joinDataMap),
  //     );

  //     print("Added new joinData under $parentEntity ➔ $channelName: $joinData");
  //   } else {
  //     print(
  //         "tagId $tagId already exists under $parentEntity ➔ $channelName. Not adding duplicate.");
  //   }
  // }

  Future<List<Map<String, dynamic>>> getTagList(String channelName) async {
    //await secureStorage.delete( key: "xdoc_tagsList");
    String parentEntity = await getSelectedEntity();
    String? existingData = await secureStorage.read(key: "xdoc_tagsList");

    if (existingData != null) {
      print(
          'Fetching existing xdoc_tagsList from secure storage: $existingData');

      // Parse JSON string to Map<String, dynamic>
      Map<String, dynamic> joinDataMap = json.decode(existingData);

      // Check if parentEntity exists
      if (joinDataMap.containsKey(parentEntity)) {
        Map<String, dynamic> entityMap = joinDataMap[parentEntity];

        // Check if channelName exists under parentEntity
        if (entityMap.containsKey(channelName)) {
          List<Map<String, dynamic>> tagList =
              List<Map<String, dynamic>>.from(entityMap[channelName]);

          print('Found tags for $parentEntity ➔ $channelName: $tagList');
          return tagList;
        } else {
          print('No tags found under $parentEntity ➔ $channelName');
          return [];
        }
      } else {
        print('No data found for parentEntity: $parentEntity');
        return [];
      }
    } else {
      // Return empty list if no data exists at all
      print('No xdoc_tagsList data found in secure storage');
      return [];
    }
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

  Future<List<dynamic>> getTags(String channelName) async {
    String token = await getJwt();
    try {
      dio.options.headers = {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      };

      final response = await dio.get(
        '$apiUrl/channel/$channelName/tags',
      );

      if (response.statusCode == 200) {
        print("Tags fetched successfully: ${response.data}");
        return response.data; // assuming your API returns a JSON array
      } else {
        print("Failed to fetch tags. Status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio error fetching tags: ${e.message}");
      print("Response: ${e.response?.data}");
    } catch (e) {
      print("Error fetching tags: $e");
    }
    return [];
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
        print("Fetched context and public key successfully: ${response.data}");
        return response.data;
      }
    } on DioException catch (e) {
      print("Dio error fetching context and public key: ${e.message}");
      print("Response: ${e.response?.data}");
    } catch (e) {
      print("Error fetching context and public key: $e");
    }
    return null;
  }

  Future<bool> uploadPublicKey(
      String publicKeyBase64, String privateKeyBase64) async {
    String token = await getJwt();
    try {
      final data = {
        "publicKey": publicKeyBase64,
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
        addOrUpdateEntityKeys(parentEntity, publicKeyBase64, privateKeyBase64);
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
    String? existing = await secureStorage.read(key: "entityKeys");
    Map<String, dynamic> keysMap = {};

    if (existing != null) {
      keysMap = jsonDecode(existing);
    }

    // Add or update this entity's keys
    keysMap[parentEntity] = {
      "publicKey": publicKey,
      "privateKey": privateKey,
    };

    await secureStorage.write(key: "entityKeys", value: jsonEncode(keysMap));
  }

  Future<Map<String, String>?> getSelectedEntityX25519Keys() async {
    String parentEntity = await getSelectedEntity();
    String? existing = await secureStorage.read(key: "entityKeys");

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
}
