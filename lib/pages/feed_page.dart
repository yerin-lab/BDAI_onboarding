import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
import 'create_post_page.dart';
import 'detail_page.dart';
import '../widgets/filter_bottomsheet.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  int _currentIndex = 0;
  FeedFilter _filter = FeedFilter.all;

  final List<Post> posts = [
    Post(
      id: 1,
      author: '테스트유저',
      category: '일반',
      title: '포트폴리오 첨삭 부탁드립니다.',
      content: '안녕하세요. 저는 데이터사이언스 전공으로 학부 때 졸업하고, 올해 8월 금융공학 석사 졸업을 앞두고 있습니다.',
      daysAgo: 23,
      likes: 1,
      comments: 1,
      type: PostType.question,
    ),
    Post(
      id: 2,
      author: '예린',
      category: '일반',
      title: 'Flutter 피드 UI 기초로 만드는 중',
      content: '상단바/하단바 만들었고 이제 게시물 리스트 붙이는 중!',
      daysAgo: 2,
      likes: 3,
      comments: 0,
      isMine: true,
      type: PostType.post,
    ),
  ];

  Future<void> _openCreate(PostType type) async {
    final created = await Navigator.push<Post>(
      context,
      MaterialPageRoute(builder: (_) => CreatePostPage(type: type)),
    );

    if (created != null) {
      setState(() {
        posts.insert(0, created);
      });
    }
  }

  void _openCreateTypeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '어떤 글을 작성할까요?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: const Text('게시글'),
                  onTap: () {
                    Navigator.pop(context);
                    _openCreate(PostType.post);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('질문'),
                  onTap: () {
                    Navigator.pop(context);
                    _openCreate(PostType.question);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
          tooltip: '검색',
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

      body: ListView.separated(
        padding: const EdgeInsets.only(top: 10, bottom: 140), // FAB 공간 확보
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

              setState(() {
                if (result is int) {
                  // 삭제 케이스: id가 돌아옴
                  posts.removeWhere((p) => p.id == result);
                  return;
                }

                if (result is Post) {
                  // 수정/갱신 케이스: Post가 돌아옴
                  final i = posts.indexWhere((p) => p.id == result.id);
                  if (i != -1) posts[i] = result;
                }
              });
            },

            child: PostCard(post: post),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateTypeSheet,
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
