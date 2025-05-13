class DocLog {
  final int docLogId;
  final Map<String, dynamic> eventPayload;
  final DateTime entryTime;
  final DateTime? exitTime;

  DocLog({
    required this.docLogId,
    required this.eventPayload,
    required this.entryTime,
    this.exitTime,
  });

  factory DocLog.fromJson(Map<String, dynamic> json) {
    return DocLog(
      docLogId: json['DocLogID'],
      eventPayload: json['EventPayload'] ?? {},
      entryTime: DateTime.parse(json['Entrytime']),
      exitTime:
          json['Exittime'] != null ? DateTime.parse(json['Exittime']) : null,
    );
  }

  String get formattedEntryTime =>
      '${entryTime.hour}:${entryTime.minute.toString().padLeft(2, '0')}';
  String get formattedDate =>
      '${entryTime.day}/${entryTime.month}/${entryTime.year}';
  bool get isCompleted => exitTime != null;
}
