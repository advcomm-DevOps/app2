import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_starter/custom/services/sso.dart';
import 'package:flutter_starter/custom/services/encryption.dart';
import 'dart:typed_data';

class DashboardController {
  final Dio dio = Dio();
  final String apiUrl = 'http://localhost:3000';
  final String qrurl = 'https://s.xdoc.app/c/';
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
    "8": [
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
        // String updatedChannelName =
        //     response.data['newChannelName'] ?? channelName;
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

    try {
      String? existingData = await secureStorage.read(key: "xdoc_tagsList");
      List<dynamic> tagsList =
          existingData != null ? jsonDecode(existingData) : [];

      Map<String, dynamic> tagData = {
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

  Future<List<Map<String, String>>> getTagList(
      {required String channelName}) async {
    //await secureStorage.delete( key: "xdoc_tagsList");
    // Read existing data
    String parentEntity = await getSelectedEntity();
    String? existingData = await secureStorage.read(key: "xdoc_tagsList");
    print('Fetching existing xdoc_tagsList from secure storage: $existingData');
    List<Map<String, String>> results = [];

    if (existingData != null) {
      List<dynamic> tagsList = jsonDecode(existingData);

      // Find the parent entity
      Map<String, dynamic>? parentEntry = tagsList.firstWhere(
          (item) => item.containsKey(parentEntity),
          orElse: () => null);

      if (parentEntry != null) {
        Map<String, dynamic> parentData = parentEntry[parentEntity];

        // Check if channel exists
        if (parentData.containsKey(channelName)) {
          Map<String, dynamic> channelData = parentData[channelName];

          channelData.forEach((tagId, tagInfo) {
            results.add({
              "tagId": tagId,
              "channelName": channelName,
              "oldChannelName": tagInfo["old"]["channelName"],
              "oldEntityId": tagInfo["old"]["entityId"],
            });
          });
        }
      }
    }

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
    String token = await getJwt(); // If you use JWT like in your other calls
    try {
      dio.options.headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      final response = await dio.get(
        '$apiUrl/document/$docId/details',
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200) {
        print("Fetched document details successfully:");
        if (response.data != null && response.data["documentDetails"] != null) {
          var sk = List<int>.from(response.data["documentDetails"]
              ["current_user_encryptedsymmetrickey"]["data"]);

          List<dynamic> pkList =
              response.data["documentDetails"]["other_actor_publickey"]["data"];
          Uint8List pkUint8List = Uint8List.fromList(pkList.cast<int>());

          var currentUserEncryptedsymmetrickey =
              jsonDecode(dartMapStringToJson(utf8.decode(sk)));

          print(currentUserEncryptedsymmetrickey);

          final senderKeys = await getSelectedEntityX25519Keys();
          if (senderKeys == null) {
            print("❌ Sender keys not found.");
            return response.data;
          }
          final senderPrivateKeyBytes = base64Decode(senderKeys["privateKey"]!);

          final decrypted = await decryptTextFromSender(
            cipherText: currentUserEncryptedsymmetrickey['cipherText']!,
            nonce: currentUserEncryptedsymmetrickey['nonce']!,
            mac: currentUserEncryptedsymmetrickey['mac']!,
            senderPublicKeyBytes: pkUint8List,
            recipientPrivateKeyBytes: senderPrivateKeyBytes,
          );
          print('Decrypted symmetric key: $decrypted');

          print(response.data["documentDetails"]["contextdata"]['cipherText']);
          List<dynamic> tempList = jsonDecode(decrypted);
          List<int> intList = tempList.cast<int>();
          final decrypted1 = await decryptWithSymmetrickey(
            symmetrickey: intList,
            cipherText: response.data["documentDetails"]["contextdata"]
                ['cipherText']!,
            nonce: response.data["documentDetails"]["contextdata"]['nonce']!,
            mac: response.data["documentDetails"]["contextdata"]['mac']!,
          );
          return {
            "data": response.data,
            "jsonData": decrypted1,
            "htmlTheme": response.data["documentDetails"]["contexttemplate"],
          };
        }
        print("Document details fetched successfully: ${response.data}");
        return response.data;
      }
    } on DioException catch (e) {
      print("Dio error fetching document details: ${e.message}");
      print("Response: ${e.response?.data}");
      return e.response?.data;
    } catch (e) {
      print("Error fetching document details: $e");
    }
    return null;
  }

  String dartMapStringToJson(String input) {
    // Step 1: Remove starting and ending curly braces
    String trimmed = input.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      trimmed = trimmed.substring(1, trimmed.length - 1);
    }

    // Step 2: Split by comma for each key-value pair
    final pairs = trimmed.split(',');

    // Step 3: Add double quotes around keys and values
    final entries = pairs
        .map((pair) {
          final kv = pair.split(':');
          if (kv.length < 2) return null;
          final key = kv[0].trim();
          // If value contains ":" (e.g., in base64) join them back
          final value = kv.sublist(1).join(':').trim();
          return '"$key":"$value"';
        })
        .where((e) => e != null)
        .toList();

    // Step 4: Build JSON string
    final jsonString = '{${entries.join(',')}}';
    return jsonString;
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

  Future<Map<String, String>?> getSelectedEntityX25519Keys(
      [String? parentEntity]) async {
    parentEntity ??= await getSelectedEntity();
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

  Future<bool> createEncryptedDocument({
    required String entityName,
    required String channelName,
    required String tagId,
    required String submittedData,
  }) async {
    final symmetrickey = generate32BytesRandom();
    print('Symmetrickey..............$symmetrickey');
    final encryptedContextData = await encryptWithSymmetrickey(
      symmetrickey: symmetrickey,
      plainText: submittedData,
    );
    print('Encrypted Symmetrickey..............$encryptedContextData');
    print(
        'Encrypted Symmetrickey to string..............${encryptedContextData.toString()}');
    final senderKeys = await getSelectedEntityX25519Keys();
    if (senderKeys == null) {
      print("❌ Sender keys not found.");
      return false;
    }
    final senderPrivateKeyBytes = base64Decode(senderKeys["privateKey"]!);
    final senderPublicKeyBytes = base64Decode(senderKeys["publicKey"]!);

    final recipientKeys = await getSelectedEntityX25519Keys(entityName);
    if (recipientKeys == null) {
      print("❌ Recipient keys not found.");
      return false;
    }
    final recipientPrivateKeyBytes = base64Decode(recipientKeys["privateKey"]!);
    final recipientPublicKeyBytes = base64Decode(recipientKeys["publicKey"]!);

    final primaryEntitySymmetricKey = await encryptTextForRecipient(
      plainText: symmetrickey.toString(),
      senderPrivateKeyBytes: senderPrivateKeyBytes,
      senderPublicKeyBytes: senderPublicKeyBytes,
      recipientPublicKeyBytes: recipientPublicKeyBytes,
    );
    print(
        'Encrypted primaryEntitySymmetricKey..............${primaryEntitySymmetricKey}');
    final otherActorSymmetricKey = await encryptTextForRecipient(
      plainText: symmetrickey.toString(),
      senderPrivateKeyBytes: recipientPrivateKeyBytes,
      senderPublicKeyBytes: recipientPublicKeyBytes,
      recipientPublicKeyBytes: senderPublicKeyBytes,
    );
    print(
        'Encrypted otherActorSymmetricKey..............${otherActorSymmetricKey}');
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
        print("Document created successfully: ${response.data}");
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
