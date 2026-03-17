// lib/models/notification.dart
class Notification {
  final int id;
  final int actorId;
  final String actorName;  // Make sure this field exists
  final String? actorAvatar;
  final String verb;
  final String? targetType;
  final int? targetId;
  final Map<String, dynamic>? targetDetails;
  final bool read;
  final DateTime timestamp;
  final String timeAgo;

  Notification({
    required this.id,
    required this.actorId,
    required this.actorName,  // Must be required
    this.actorAvatar,
    required this.verb,
    this.targetType,
    this.targetId,
    this.targetDetails,
    required this.read,
    required this.timestamp,
    required this.timeAgo,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as int,
      actorId: json['actor_id'] as int,
      actorName: json['actor_name'] as String,  // Maps from JSON
      actorAvatar: json['actor_avatar'] as String?,
      verb: json['verb'] as String,
      targetType: json['target_type'] as String?,
      targetId: json['target_id'] as int?,
      targetDetails: json['target_details'] as Map<String, dynamic>?,
      read: json['read'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      timeAgo: json['time_ago'] as String,
    );
  }
}