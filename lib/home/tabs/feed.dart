import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeFeed extends StatelessWidget {
  const HomeFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SeeMe"),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.camera),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.paperplane),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          // --- STORIES SECTION ---
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: const [
                _StoryItem(name: "You", isUser: true),
                _StoryItem(name: "Gergio.c", color: Colors.red),
                _StoryItem(name: "Wanggg_", color: Colors.blue),
                _StoryItem(name: "Callista", color: Colors.purple),
                _StoryItem(name: "Ludy", color: Colors.orange),
                _StoryItem(name: "Marcus", color: Colors.green),
              ],
            ),
          ),
          const Divider(height: 1),

          // --- POSTS SECTION ---
          // This calls the class defined at the bottom of this file
          const _PostItem(username: "Celine.photo", caption: "dolor sit amet consectetur..."),
          const _PostItem(username: "Wanggg_", caption: "Loving the view!"),
          const _PostItem(username: "Ludy_Lubis", caption: "Work hard, play hard."),
        ],
      ),
    );
  }
}

// --- HELPER CLASSES DEFINED BELOW ---
// If you deleted these or moved them to another file, the error occurs.

class _StoryItem extends StatelessWidget {
  final String name;
  final bool isUser;
  final Color color;

  const _StoryItem({required this.name, this.isUser = false, this.color = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isUser ? Colors.transparent : Colors.purpleAccent,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: isUser ? Colors.grey[200] : color.withOpacity(0.2),
                  child: isUser
                      ? const Icon(Icons.person, color: Colors.black, size: 30)
                      : Text(name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ),
              if (isUser)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.add_circle, color: Colors.blue, size: 20),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _PostItem extends StatelessWidget {
  final String username;
  final String caption;

  const _PostItem({required this.username, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Post Header
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            child: Text(username[0], style: const TextStyle(fontSize: 12, color: Colors.black)),
          ),
          title: Text(username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          trailing: const Icon(Icons.more_horiz),
        ),

        // Post Image Placeholder
        Container(
          height: 375,
          color: Colors.grey[300],
          width: double.infinity,
          child: const Center(
            child: Icon(Icons.image, size: 60, color: Colors.grey),
          ),
        ),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Icon(CupertinoIcons.heart, size: 26),
              const SizedBox(width: 16),
              const Icon(CupertinoIcons.chat_bubble, size: 26),
              const SizedBox(width: 16),
              const Icon(CupertinoIcons.paperplane, size: 26),
              const Spacer(),
              const Icon(CupertinoIcons.bookmark, size: 26),
            ],
          ),
        ),

        // Likes & Caption
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("350 Likes", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(text: "$username ", style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: caption),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text("View all 30 comments", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ],
    );
  }
}