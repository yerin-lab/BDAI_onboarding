import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
import 'create_post_page.dart';
import 'detail_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  int _currentIndex = 0;

  final List<Post> posts = [
    const Post(
      author: '테스트유저',
      category: '일반',
      title: '포트폴리오 첨삭 부탁드립니다.',
      content: '안녕하세요. 저는 데이터사이언스 전공으로 학부 때 졸업하고, 올해 8월 금융공학 석사 졸업을 앞두고 있습니다.',
      daysAgo: 23,
      likes: 1,
      comments: 1,
    ),
    const Post(
      author: '예린',
      category: '일반',
      title: 'Flutter 피드 UI 기초로 만드는 중',
      content: '상단바/하단바 만들었고 이제 게시물 리스트 붙이는 중!',
      daysAgo: 2,
      likes: 3,
      comments: 0,
      isMine: true,
    ),
  ];

  Future<void> _openCreate() async {
    final created = await Navigator.push<Post>(
      context,
      MaterialPageRoute(builder: (_) => const CreatePostPage()),
    );

    if (created != null) {
      setState(() {
        posts.insert(0, created);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {},
            icon: const Icon(Icons.tune),
            tooltip: '필터',
          ),
        ],
      ),

      body: ListView.separated(
        padding: const EdgeInsets.only(top: 10, bottom: 140), // FAB 공간 확보
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final post = posts[index];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailPage(post: post)),
              );
            },
            child: PostCard(post: post),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
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
