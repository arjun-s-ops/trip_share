// lib/feed/notification.dart
import 'package:flutter/material.dart';
import '../services/notification_services.dart';
import 'notify.dart' as model;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<_NotifData> _future;

  Future<_NotifData> _loadData() async {
    final notifications = await NotificationService.fetchNotifications();

    // Collect actor IDs from follow-type notifications only
    final followActorIds = notifications
        .where((n) => n.verb == 'started following you')
        .map((n) => n.actorId)
        .toList();

    // Fetch real follow status from backend for all those actors
    final followingIds = followActorIds.isNotEmpty
        ? await NotificationService.fetchFollowingActorIds(followActorIds)
        : <int>{};

    return _NotifData(notifications: notifications, followingActorIds: followingIds);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadData();
    });
  }

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<_NotifData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.notifications.isEmpty) {
            return const Center(child: Text('No notifications'));
          }

          final notifications = snapshot.data!.notifications;
          final followingIds = snapshot.data!.followingActorIds;

          return RefreshIndicator(
            color: Colors.black,
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return NotificationCard(
                  notif: notif,
                  alreadyFollowed: followingIds.contains(notif.actorId),
                  onFollowed: (actorId) {
                    // Update local state immediately without re-fetching
                    setState(() {
                      followingIds.add(actorId);
                    });
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Data holder for notifications + follow status
class _NotifData {
  final List<model.Notification> notifications;
  final Set<int> followingActorIds;
  _NotifData({required this.notifications, required this.followingActorIds});
}

class NotificationCard extends StatefulWidget {
  final model.Notification notif;
  final bool alreadyFollowed;
  final void Function(int actorId) onFollowed;

  const NotificationCard({
    super.key,
    required this.notif,
    required this.alreadyFollowed,
    required this.onFollowed,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _isLoading = false;
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.alreadyFollowed;
  }

  @override
  void didUpdateWidget(NotificationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alreadyFollowed != oldWidget.alreadyFollowed) {
      _isFollowing = widget.alreadyFollowed;
    }
  }

  _NotifStyle _getStyle() {
    switch (widget.notif.verb) {
      case 'started following you':
        return _NotifStyle(icon: Icons.person_add_rounded, color: Colors.indigo);
      case 'joined your trip':
        return _NotifStyle(icon: Icons.directions_car_rounded, color: Colors.teal);
      case 'posted in your trip':
        return _NotifStyle(icon: Icons.photo_rounded, color: Colors.orange);
      default:
        return _NotifStyle(icon: Icons.notifications_rounded, color: Colors.grey);
    }
  }

  String? _getSubtitle() {
    final details = widget.notif.targetDetails;
    if (details == null) return null;

    if (widget.notif.targetType == 'trip') {
      final destination = details['destination'];
      final startDate = details['start_date'];
      if (destination != null && startDate != null) {
        return 'Trip to $destination · $startDate';
      } else if (destination != null) {
        return 'Trip to $destination';
      }
    } else if (widget.notif.targetType == 'post') {
      final caption = details['caption'];
      if (caption != null && caption.toString().isNotEmpty) {
        return '"$caption"';
      }
    }
    return null;
  }

  Future<void> _handleFollowBack() async {
    setState(() => _isLoading = true);
    try {
      final nowFollowing = await NotificationService.followUser(widget.notif.actorId);
      setState(() => _isFollowing = nowFollowing);
      if (nowFollowing) {
        widget.onFollowed(widget.notif.actorId);
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to follow. Try again.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStyle();
    final subtitle = _getSubtitle();
    final isFollowNotif = widget.notif.verb == 'started following you';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.notif.read ? Colors.white : const Color(0xFFEEF0FF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.indigo.shade100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: widget.notif.actorAvatar != null
                      ? Image.network(
                          widget.notif.actorAvatar!,
                          fit: BoxFit.cover,
                          width: 44,
                          height: 44,
                          errorBuilder: (context, error, stackTrace) => Text(
                            widget.notif.actorName[0].toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      : Text(
                          widget.notif.actorName[0].toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: style.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Icon(style.icon, size: 10, color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    children: [
                      TextSpan(
                        text: '${widget.notif.actorName} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: widget.notif.verb),
                    ],
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: style.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  widget.notif.timeAgo,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          if (isFollowNotif)
            _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : GestureDetector(
                    onTap: _isFollowing ? null : _handleFollowBack,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _isFollowing ? Colors.grey.shade200 : Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isFollowing ? 'Following' : 'Follow',
                        style: TextStyle(
                          color: _isFollowing ? Colors.grey.shade600 : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
          else if (!widget.notif.read)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.indigo,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

class _NotifStyle {
  final IconData icon;
  final Color color;
  const _NotifStyle({required this.icon, required this.color});
}