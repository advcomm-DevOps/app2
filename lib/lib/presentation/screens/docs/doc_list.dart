import 'package:flutter/material.dart';
import '../../models/doc_model.dart';
import 'doc_item.dart';

class DocList extends StatelessWidget {
  final List<Document> documents;
  final VoidCallback onDocSelected;

  const DocList({
    super.key,
    required this.documents,
    required this.onDocSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: documents.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return DocItem(
          document: documents[index],
          onDocSelected: onDocSelected,
        );
      },
    );
  }
}
