class StatusNode {
  final String label;
  final String value;
  final List<StatusNode> children;
  StatusNode({
    required this.label,
    required this.value,
    this.children = const [],
  });
}