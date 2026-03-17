// lib/services/notification_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notify.dart';
import 'auth_service.dart';

class NotificationService {
  static const String baseUrl = 'http://192.168.1.52:8000/api';

  /// Fetch all notifications for the logged-in user.
  static Future<List<Notification>> fetchNotifications() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Notification.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications (${response.statusCode})');
    }
  }

  /// Returns the count of unread notifications.
  static Future<int> fetchUnreadCount() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.where((n) => n['read'] == false).length;
    }
    return 0;
  }

  /// Fetch follow status for a list of actor IDs in one call each.
  /// Returns a Set of actor IDs that the current user is already following.
  static Future<Set<int>> fetchFollowingActorIds(List<int> actorIds) async {
    final token = await AuthService.getToken();
    final Set<int> followingIds = {};

    await Future.wait(actorIds.toSet().map((id) async {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/profile/$id/'),
          headers: {'Authorization': 'Token $token'},
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['is_following'] == true) {
            followingIds.add(id);
          }
        }
      } catch (_) {}
    }));

    return followingIds;
  }

  /// Mark a single notification as read.
  static Future<void> markAsRead(int id) async {
    final token = await AuthService.getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/read/$id/'),
      headers: {'Authorization': 'Token $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to mark as read');
    }
  }

  /// Mark all notifications as read.
  static Future<void> markAllRead() async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/read-all/'),
      headers: {'Authorization': 'Token $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to mark all as read');
    }
  }

  /// Follow or unfollow a user by their ID.
  /// Returns true if now following, false if unfollowed.
  static Future<bool> followUser(int userId) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/follow/$userId/'),
      headers: {'Authorization': 'Token $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['following'] as bool;
    } else {
      throw Exception('Failed to follow user (${response.statusCode})');
    }
  }
}