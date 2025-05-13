import 'package:flutter/material.dart';
import '../../models/doc_model.dart';
import 'package:signals/signals_flutter.dart';
import '../../models/doc_model.dart';
import '../../services/signal_state/channel_state.dart';
import '../../services/signal_state/doc_state.dart';

class DocItem extends StatelessWidget {
  final Document document;
  final VoidCallback? onDocSelected;

  const DocItem({super.key, required this.document, this.onDocSelected});

  @override
  Widget build(BuildContext context) {
    final isSelected = docState.selectedDocId.watch(context) == document.name;
    print('isSelected: ....: .... $isSelected');
    return Material(
      type: MaterialType.transparency,
      child: Container(
        // margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: const Icon(Icons.insert_drive_file),
          title: Text(document.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Started: ${document.formattedDate} at ${document.formattedStartTime}',
              ),
              if (document.isCompleted)
                Text(
                  'Completed in ${document.duration?.inHours}h ${document.duration?.inMinutes.remainder(60)}m',
                  style: const TextStyle(color: Colors.green),
                )
              else
                const Text(
                  'In Progress',
                  style: TextStyle(color: Colors.orange),
                ),
            ],
          ),
          onTap: () {
            // Handle document selection
            docState.selectDoc(document.name);
            // channelState.selectChannelId(channel.id);
            onDocSelected?.call();
          },
        ),
      ),
    );
  }
}
