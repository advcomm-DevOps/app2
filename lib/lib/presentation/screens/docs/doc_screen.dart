import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../../models/doc_model.dart';
import '../../services/signal_state/doc_state.dart';
import '../../services/doc_services/doc_log_service.dart';
import '../../services/doc_services/doc_service.dart';
import '../../services/signal_state/channel_state.dart';
import '../../state/user_state.dart';
import 'doc_appbar/doc_appbar.dart';
import 'doc_list.dart';
import 'services/fetch_initial_ui.dart';

class DocScreen extends StatefulWidget {
  const DocScreen({super.key});

  @override
  State<DocScreen> createState() => DocScreenState();
}

class DocScreenState extends State<DocScreen> {
  // Make this public so ChannelScreen can access it
  final _error = signal<String?>(null);
  // final _docs = signal<List<dynamic>>([]);
  final _selectedChannelSignal = signal<String?>(null);
  Future<void> loadDocumentsForChannel() async {
    final channelId = channelState.selectedChannelId.value;
    if (channelId != null) {
      await docService.fetchDocuments(channelId);
    }
  }

  final List<Map<String, dynamic>> tasks3 = [];
  // late Signal<List<dynamic>> documents = signal<List<dynamic>>([]);
  @override
  void initState() {
    super.initState();
    // _loadInitialDocuments();
    // loadDocumentsForChannel();
  }

  // Future<void> _loadInitialDocuments() async {
  //   final channelId = channelState.selectedChannelId.value;
  //   if (channelId != null) {
  //     await docService.fetchDocuments(channelId);
  //   }
  // }

  Future<void> _loadDocumentsIfChannelChanged() async {
    final channelId = channelState.selectedChannelId.value;
    if (channelId != null) {
      await docService.fetchDocuments(channelId);
    }
  }

  // void addNewTask(String taskName) {
  //   if (taskName.isNotEmpty) {
  //     setState(() {
  //       tasks3.add({
  //         'id': tasks3.length + 1,
  //         'name': taskName,
  //         'pendingActions': 1,
  //         'status': 'pending',
  //       });
  //     });
  //   }
  // }
  void addNewTask(String taskName, List<Document> documents) {
    if (taskName.isNotEmpty) {
      final channelId = channelState.selectedChannelId.value;
      late int id = documents.length + 1;
      setState(() {
        documents.add(
          Document(
            id: id.toString(),
            channelId: channelId!,
            name: taskName,
            startTime: DateTime.now(),
          ),
        );
      });
    }
  }

  void callFirstScreenMethod() {
    // IndividualPage.globalKey.currentState?.initState();
  }
  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController _taskController = TextEditingController();
    final documents = docService.documents.watch(context);
    final selectedChannelId = watchSignal(
      context,
      channelState.selectedChannelId,
    );
    // final selectedChannelName = watchSignal(
    //   context,
    //   channelState.selectedChannelName,
    // );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Document'),
          content: TextField(
            controller: _taskController,
            decoration: const InputDecoration(hintText: 'Enter title name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                print("selectedChannelId: $selectedChannelId");
                // print("selectedChannel: " + selectedChannelName!);
                addNewTask(_taskController.text, documents);
                await fetchInitialHTML(
                  selectedChannelId!,
                  _taskController.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showSearchPopup(BuildContext context) {
    final TextEditingController _entityController = TextEditingController();
    final _channels = signal<List<String>>([]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Channels'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _entityController,
                decoration: const InputDecoration(
                  hintText: 'Enter entity name',
                ),
              ),
              Watch((context) {
                if (_channels.value.isEmpty) {
                  return Container();
                }
                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: _channels.value.length,
                    itemBuilder: (context, index) {
                      final channel = _channels.value[index];
                      return ListTile(
                        title: Text(channel),
                        onTap: () {
                          _selectedChannelSignal.value = channel;
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final entityName = _entityController.text;
                if (entityName.isNotEmpty) {
                  try {
                    final response = await Dio().get(
                      'http://localhost:3002/Channels/$entityName',
                    );
                    _channels.value = List<String>.from(response.data);
                  } catch (e) {
                    _error.value = e.toString();
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = docService.isLoading.watch(context);
    final error = docService.error.watch(context);
    final documents = docService.documents.watch(context);
    final selectedChannelId = channelState.selectedChannelId.watch(context);

    if (selectedChannelId == null) {
      return const Center(child: Text('Select a channel to view documents'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        DocAppbar(
          addNewTask: () => _showAddTaskDialog(context),
          onSearchPressed: () => _showSearchPopup(context),
        ),
        // child: Text(
        //   'Documents',
        //   style: Theme.of(
        //     context,
        //   ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        // ),
        // ),
        if (isLoading)
          const LinearProgressIndicator(minHeight: 2)
        else if (error != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error: $error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          )
        else if (documents.isEmpty)
          const Expanded(child: Center(child: Text('No documents available')))
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDocumentsIfChannelChanged,
              child: DocList(
                documents: documents,
                onDocSelected: () {
                  final selectedDoc = docState.selectedDocId.value;
                  final selectedChannel = channelState.selectedChannelId.value;
                  print("selectedDoc working: $selectedDoc");
                  if (selectedDoc != null) {
                    docLogService.fetchDocLogs(selectedChannel!, selectedDoc);
                  }
                  // _docScreenKey.currentState
                  //     ?.loadDocumentsForChannel();
                  print("selectedDocId: ${docState.selectedDocId.value}");
                },
              ),
            ),
          ),
      ],
    );
  }
}
