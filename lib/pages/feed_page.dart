import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
import 'create_post_page.dart';
import 'detail_page.dart';
import '../widgets/filter_bottomsheet.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/post_api.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  int _currentIndex = 0;
  FeedFilter _filter = FeedFilter.all;

  final PostApi _postApi = PostApi();

  List<Post> posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    debugPrint('1. _loadPosts 들어옴');

    try {
      debugPrint('2. fetchPosts 호출 직전');

      final loaded = await _postApi.fetchPosts();

      debugPrint('3. fetchPosts 호출 끝');
      debugPrint('게시글 개수: ${loaded.length}');

      if (!mounted) return;

      setState(() {
        posts = loaded;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      debugPrint('4. _loadPosts 에러: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _openFilterSheet() async {
    final selected = await showModalBottomSheet<FeedFilter>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FeedFilterSheet(selected: _filter),
    );

    if (selected == null) return;

    setState(() {
      _filter = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredPosts = posts.where((p) {
      if (_filter == FeedFilter.all) return true;
      if (_filter == FeedFilter.post) return p.type == PostType.post;
      return p.type == PostType.question;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search),
          tooltip: '안녕',
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.forum),
            tooltip: '채팅',
          ),
          IconButton(
            onPressed: _openFilterSheet,
            icon: const Icon(Icons.tune),
            tooltip: '필터',
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('에러: $_error'))
          : ListView.separated(
              padding: const EdgeInsets.only(top: 10, bottom: 140),
              itemCount: filteredPosts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final post = filteredPosts[index];

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    final result = await Navigator.push<Object?>(
                      context,
                      MaterialPageRoute(builder: (_) => DetailPage(post: post)),
                    );

                    if (result == null) return;

                    await _loadPosts();
                  },
                  child: PostCard(post: post),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.edit),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // 눌린 탭 기억
          });
        },
        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.wifi), label: '노크'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '집'),
          BottomNavigationBarItem(icon: Icon(Icons.room), label: '방'),
        ],
      ),
    );
  }
}
