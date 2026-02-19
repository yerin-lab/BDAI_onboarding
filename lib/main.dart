import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Knock Knock',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // 추후 화면 변경을 위한 탭 번호

  final List<Post> posts = const [
    Post(
      author: '테스트유저',
      category: '일반',
      title: '포트폴리오 첨삭 부탁드립니다.',
      content: '안녕하세요. 저는 데이터사이언스 전공으로 학부 때 졸업하고, 올해 8월 금융공학 석사 졸업을 앞두고 있습니다.',
      daysAgo: 23,
      likes: 1,
      comments: 1,
    ),
    Post(
      author: '예린',
      category: '일반',
      title: 'Flutter 피드 UI 기초로 만드는 중',
      content: '상단바/하단바 만들었고 이제 게시물 리스트 붙이는 중!',
      daysAgo: 2,
      likes: 3,
      comments: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      // 상단바
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
        padding: const EdgeInsets.all(12),
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(post: post);
        },
      ),

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

class Post {
  final String author;
  final String category;
  final String title;
  final String content;
  final int daysAgo;
  final int likes;
  final int comments;

  const Post({
    required this.author,
    required this.category,
    required this.title,
    required this.content,
    required this.daysAgo,
    required this.likes,
    required this.comments,
  });
}

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1) 헤더 (박스 밖)
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.person,
                  size: 18,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  post.author,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz),
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // 2) 회색 컨텐츠 박스
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F5), // 회색 배경
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 카테고리
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    post.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // 제목 + 시간
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${post.daysAgo}일 전',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // 본문
                Text(
                  post.content,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 12),

                // 좋아요 / 댓글
                Row(
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 18,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likes}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 18,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.comments}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
