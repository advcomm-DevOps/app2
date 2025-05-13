class Channel {
  String id; // Changed from final to mutable
  final String name;
  final String description;
  final String entityRoles;
  final int initialActorId;
  final int otherActorId;
  final DateTime createdAt;

  Channel({
    required this.id,
    required this.name,
    required this.description,
    required this.entityRoles,
    required this.initialActorId,
    required this.otherActorId,
    required this.createdAt,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'] ?? '${json['InitialActorID']}-${json['OtherActorID']}',
      name: json['ChannelName'],
      description: json['ChannelDescription'],
      entityRoles: json['EntityRoles'],
      initialActorId: json['InitialActorID'],
      otherActorId: json['OtherActorID'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  String get avatarText {
    final words =
        name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.length >= 2) return '${words[0][0]}${words[1][0]}'.toUpperCase();
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }
}
