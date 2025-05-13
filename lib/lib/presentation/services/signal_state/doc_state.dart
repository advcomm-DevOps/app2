import 'package:signals/signals.dart';

import '../../models/doc_model.dart';

final docState = DocState();

class DocState {
  final selectedDocId = signal<String?>(null);
  final showDocNames = signal(true); // Controls name visibility

  void toggleNameVisibility() {
    showDocNames.value = !showDocNames.value;
  }

  void selectDocId(String id) {
    selectedDocId.value = id;
  }

  void selectDoc(String id) {
    selectedDocId.value = id;
  }
}
