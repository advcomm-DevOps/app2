class Document {
  final String id;
  String channelId;
  final String name;
  final DateTime startTime; // Changed from createdAt to startTime
  final DateTime? completionTime;

  Document({
    required this.id,
    required this.channelId,
    required this.name,
    required this.startTime,
    this.completionTime,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    try {
      return Document(
        id: '${json['StartTime']}-${json['DocName']}',
        channelId: '', // Will be set in service
        name: json['DocName'] as String,
        startTime: DateTime.parse(json['StartTime'] as String),
        completionTime:
            json['CompletionTime'] != null
                ? DateTime.parse(json['CompletionTime'] as String)
                : null,
      );
    } catch (e) {
      throw FormatException('Failed to create Document from JSON: $e');
    }
  }

  String get formattedDate {
    return '${startTime.day}/${startTime.month}/${startTime.year}';
  }

  String get formattedStartTime {
    return '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  bool get isCompleted => completionTime != null;

  Duration? get duration {
    return completionTime != null
        ? completionTime!.difference(startTime)
        : null;
  }
}
