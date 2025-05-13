import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:signals/signals_flutter.dart';
import '../../models/doc_log_model.dart';
import '../../models/doc_model.dart';
import '../../services/doc_services/doc_log_service.dart';
import '../../services/signal_state/channel_state.dart';
import '../../services/signal_state/doc_state.dart';
import '../docs/services/fetch_initial_ui.dart';

class WorkareaScreen extends StatefulWidget {
  const WorkareaScreen({super.key});

  @override
  State<WorkareaScreen> createState() => _WorkareaScreenState();
}

class _WorkareaScreenState extends State<WorkareaScreen> {
  InAppWebViewController? _webViewController;
  // final _showWebView = computed(() => false);
  late FlutterComputed<bool> _showWebView = computed(
    () => showContainerSignal.value,
  );
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final selectedDoc = docState.selectedDocId.watch(context);
    final logs = docLogService.logs.watch(context);
    final isLoading = docLogService.isLoading.watch(context);
    final error = docLogService.error.watch(context);
    final _isVisible = _showWebView.watch(context);
    print("_isVisible: $_isVisible");
    print("selectedDoc: $selectedDoc");
    print("logs: $logs");

    return Column(
      children: [
        if (_isVisible) _buildWebViewContainer(),
        Expanded(
          child:
              selectedDoc == null
                  ? const Center(child: Text('Select a document to view logs'))
                  : Column(
                    children: [
                      if (isLoading) const LinearProgressIndicator(),
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Error: $error',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            print("log index: $log");
                            return _buildLogItem(log, selectedDoc);
                          },
                        ),
                      ),
                      if (selectedDoc != null)
                        _buildDocumentActions(selectedDoc),
                    ],
                  ),
        ),
      ],
    );
  }

  Widget _buildLogItem(DocLog log, String doc) {
    final statusColor = log.isCompleted ? Colors.green : Colors.orange;
    final PaddingRight =
        log.isCompleted
            ? MediaQuery.of(context).size.width * 0.01
            : MediaQuery.of(context).size.width * 0.4;
    final PaddingLeft =
        log.isCompleted
            ? MediaQuery.of(context).size.width * 0.4
            : MediaQuery.of(context).size.width * 0.01;

    return Padding(
      padding: EdgeInsets.only(left: PaddingLeft, right: PaddingRight),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        // width: MediaQuery.of(context).size.width * 0.3,
        // padding: EdgeInsets.only(left: 8, right: PaddingRight),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Log #${log.docLogId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Date: ${log.formattedDate}'),
              Text('Time: ${log.formattedEntryTime}'),
              if (log.isCompleted)
                Text(
                  'Completed: ${log.exitTime!.hour}:${log.exitTime!.minute.toString().padLeft(2, '0')}',
                ),
              if (log.eventPayload.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(log.eventPayload.toString()),
                  ],
                ),
              // if (doc.url != null && doc.url!.isNotEmpty)
              ElevatedButton(
                onPressed:
                    () => {
                      print('doc.url:  pressed'),
                      // setState(() => _showWebView = true),
                      // _openDocument(doc.url!)
                    },
                child: const Text('View Document'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebViewContainer() {
    return Flexible(
      // flex: 8,
      // fit: FlexFit.tight,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed:
                  () => setState(() => _showWebView.internalValue = false),
            ),
            bottom: TabBar(
              onTap: (index) => setState(() => _currentTabIndex = index),
              tabs: const [
                Tab(text: 'Accept'),
                Tab(text: 'Dispute'),
                Tab(text: 'Reject'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Column(
                children: [
                  Flexible(
                    // flex: 8,
                    fit: FlexFit.tight,
                    child: InAppWebView(
                      initialData: InAppWebViewInitialData(
                        data: intialHtmlSignal.value,
                      ),
                      // initialUrlRequest: URLRequest(url: WebUri(doc.url ?? '')),
                      onWebViewCreated: (controller) {
                        _webViewController = controller;
                      },
                    ),
                  ),
                  _buildActionButtons(),
                ],
              ),
              Center(
                child: Column(
                  children: [
                    Expanded(child: Text('Dispute')),
                    _buildActionButtons(),
                  ],
                ),
              ),
              Center(
                child: Column(
                  children: [
                    Expanded(child: Text('Reject')),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildWebViewContainer() {
  //   return DefaultTabController(
  //     length: 3,
  //     child: Column(
  //       children: [
  //         AppBar(
  //           // leading: IconButton(
  //           //   icon: const Icon(Icons.close),
  //           //   onPressed: () => setState(() => _showWebView.disposed = false),
  //           // ),
  //           // title: Text(doc),
  //           bottom: TabBar(
  //             onTap: (index) => setState(() => _currentTabIndex = index),
  //             tabs: const [
  //               Tab(text: 'Accept'),
  //               Tab(text: 'Dispute'),
  //               Tab(text: 'Reject'),
  //             ],
  //           ),
  //         ),
  //         // SizedBox(
  //         //   height: MediaQuery.of(context).size.height * 0.7,
  //         //   child: InAppWebView(
  //         //     initialData: InAppWebViewInitialData(
  //         //       // baseUrl: "about:blank",
  //         //       mimeType: "text/html",
  //         //       encoding: "utf-8",
  //         //       data: intialHtmlSignal.value,
  //         //     ),
  //         //     // initialUrlRequest: URLRequest(url: WebUri(doc.url ?? '')),
  //         //     onWebViewCreated: (controller) {
  //         //       _webViewController = controller;
  //         //     },
  //         //   ),
  //         // ),
  //         _buildActionButtons(),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildDocumentActions(String doc) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed:
                  () => {
                    print('view doc:  pressed'),
                    // setState(() => _showWebView = true),
                    // _openDocument(doc.url!)
                  },
              // onPressed: () => _openDocument(doc.url ?? ''),
              child: const Text('Open Document'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: _saveDocument,
            child: const Text('Save As'),
          ),
          ElevatedButton(
            onPressed: () => _handleAction(_currentTabIndex),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getStatusColor(_currentTabIndex),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  void _openDocument(String url) {
    if (url.isEmpty) return;
    setState(() => _showWebView.autoDispose = true);
  }

  Future<void> _saveDocument() async {
    // Implement platform-specific file saving
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Document saved')));
  }

  void _handleAction(int tabIndex) {
    String action;
    Color color;

    switch (tabIndex) {
      case 0:
        action = 'accepted';
        color = Colors.green;
        break;
      case 1:
        action = 'disputed';
        color = Colors.orange;
        break;
      case 2:
        action = 'rejected';
        color = Colors.red;
        break;
      default:
        action = 'processed';
        color = Colors.blue;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Document $action'), backgroundColor: color),
    );

    setState(() => _showWebView.autoDispose = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedDoc = docState.selectedDocId.value;
    final selectedChannel = channelState.selectedChannelId.value;
    if (selectedDoc != null) {
      docLogService.fetchDocLogs(selectedChannel!, selectedDoc);
    }
  }
}
