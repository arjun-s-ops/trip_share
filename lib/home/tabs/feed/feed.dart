import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_app/routes.dart';
import '../../../../services/notification_services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'sans-serif'),
      home: const HomeFeed(),
    );
  }
}

class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await NotificationService.fetchUnreadCount();
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {}
  }

  Future<void> _openNotifications() async {
    // Clear badge immediately when user taps bell
    setState(() => _unreadCount = 0);
    await Navigator.pushNamed(context, AppRoutes.notifications);
    // Re-check on return in case new ones arrived while on that page
    _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            centerTitle: true,
            floating: true,
            elevation: 0,
            backgroundColor: const Color(0xFFF8F9FA),

            // PLUS BUTTON (LEFT)
            leading: IconButton(
              icon: const Icon(Icons.add, color: Colors.black),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.post);
              },
            ),

            title: Image.asset('assets/logo.png', height: 120),

            // NOTIFICATION BUTTON (RIGHT) with badge
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: _openNotifications,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_none, color: Colors.black),
                      if (_unreadCount > 0)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const PostCard(
                  username: "Celine.photo",
                  caption: "Capturing the serene beauty of the hills today.",
                ),
                const PostCard(
                  username: "Wanggg_",
                  caption: "Perspective is everything in architecture.",
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final String username;
  final String caption;

  const PostCard({super.key, required this.username, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.indigo.shade100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      'https://i.pravatar.cc/150?u=$username',
                      errorBuilder: (context, error, stackTrace) =>
                          Text(username[0]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(username,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const Text('2h ago',
                        style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.more_vert, color: Colors.grey),
              ],
            ),
          ),

          // Photo & Actions
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 350,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://blog.rideally.com/wp-content/uploads/2022/05/Ooty.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Like Pill
              Positioned(
                bottom: -15,
                left: 28,
                child: _buildLikeButton(),
              ),

              // Tilted Share Button
              Positioned(
                bottom: -15,
                right: 28,
                child: _buildTiltedShareButton(),
              ),
            ],
          ),

          // Caption
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        color: Colors.black, fontSize: 14, height: 1.4),
                    children: [
                      TextSpan(
                          text: '$username ',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: caption),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text('View all 30 comments',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, color: Colors.pink, size: 18),
          SizedBox(width: 8),
          Text("Like",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTiltedShareButton() {
    return Container(
      height: 44,
      width: 44,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Center(
        child: Transform.rotate(
          angle: -math.pi / 6,
          child: const Icon(
            Icons.send_rounded,
            color: Color.fromARGB(255, 0, 0, 0),
            size: 20,
          ),
        ),
      ),
    );
  }
}