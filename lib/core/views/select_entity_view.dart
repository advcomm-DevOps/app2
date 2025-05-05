import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uids_io_sdk_flutter/auth_logout.dart';
import 'package:uids_io_sdk_flutter/gmail_sso.dart';
import '../services/entity_selection_service.dart';

class SelectEntityView extends StatefulWidget {
  const SelectEntityView({super.key});

  @override
  _SelectEntityViewState createState() => _SelectEntityViewState();
}

class _SelectEntityViewState extends State<SelectEntityView> {
  final SharedPreferencesService _spService = SharedPreferencesService();
  List<String> tenants = [];
  String? username;
  List<String> refreshTokens = [];
  int? hoveredIndex; // Keep track of the hovered index

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _spService.getSelectEntityConfigurations();
    if (data != null) {
      setState(() {
        tenants = List<String>.from(data['tenants'] ?? []);
        username = data['username'];
        refreshTokens = List<String>.from(data['refreshTokens'] ?? []);
      });
    }
  }

  Future<void> _selectEntity(String tenant) async {
    int index = tenants.indexOf(tenant);
    if (index == -1 || username == null) return;

    final FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String selectedRefreshToken = refreshTokens[index];
    if (selectedRefreshToken.isEmpty) return;
    String? idpname_backend = await secureStorage.read(key: "idpname_backend");
    String? deviceId = await secureStorage.read(key: "DeviceId");
    GmailSSO.getJwtFromBackend(
      username!,
      idpname_backend ?? '',
      tenant,
      selectedRefreshToken,
      deviceId ?? '',
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthLogout.logout(context),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400, // Constrain the width for web view
            padding: const EdgeInsets.all(20.0),
            child: tenants.isEmpty
                ? const Center(
                    child:
                        CircularProgressIndicator()) // Center the loading indicator
                : Column(
                    children: [
                      const Text(
                        'Select Entity',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16), // Space between text and list
                      ListView.builder(
                        shrinkWrap:
                            true, // Ensure ListView takes only required space
                        physics:
                            const NeverScrollableScrollPhysics(), // Prevent ListView from scrolling independently
                        padding: const EdgeInsets.all(16),
                        itemCount: tenants.length,
                        itemBuilder: (context, index) {
                          return MouseRegion(
                            onEnter: (_) {
                              setState(() {
                                hoveredIndex = index; // Track the hover index
                              });
                            },
                            onExit: (_) {
                              setState(() {
                                hoveredIndex = null; // Reset hover index
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                  bottom: 8), // Space between cards
                              decoration: BoxDecoration(
                                color: hoveredIndex == index
                                    ? Colors.grey[200]
                                    : Colors
                                        .white, // Change background on hover
                                border: Border.all(
                                  color: Colors.grey, // Border color
                                  width: 1, // Border width
                                ),
                                borderRadius:
                                    BorderRadius.circular(8), // Rounded corners
                              ),
                              child: ListTile(
                                title: Text(tenants[index]),
                                onTap: () => _selectEntity(tenants[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
