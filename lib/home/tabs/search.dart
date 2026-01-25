import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchGrid extends StatelessWidget {
  const SearchGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Search Bar Header
          SliverAppBar(
            floating: true,
            pinned: false,
            elevation: 0,
            title: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7), // Light grey iOS style
                borderRadius: BorderRadius.circular(10),
              ),
              child: const TextField(
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  prefixIcon: Icon(CupertinoIcons.search, color: Colors.grey, size: 20),
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          
          // Image Grid
          SliverPadding(
            padding: const EdgeInsets.all(2),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 columns to match your image
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                childAspectRatio: 0.8, // Taller items
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // Placeholder for actual images
                    child: Center(
                      child: Icon(Icons.photo, color: Colors.white.withOpacity(0.5), size: 40),
                    ),
                  );
                },
                childCount: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}