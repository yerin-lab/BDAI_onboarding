import 'package:flutter/material.dart';
import '../models/post.dart';
import 'edit_post_page.dart';

class DetailPage extends StatefulWidget {
  final Post post;
  const DetailPage({super.key, required this.post});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final TextEditingController _commentCtrl = TextEditingController();
  late Post _post;

  // 댓글 mock data
  final List<_Comment> _comments = [
    _Comment(
      author: 'Mark',
      content: '포트폴리오를 managinggc@gmail.com 으로 보내주시면 검토 드릴게요',
      daysAgo: 15,
    ),
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.insert(0, _Comment(author: '예린', content: text, daysAgo: 0));
      _commentCtrl.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  Future<void> _openEdit() async {
    final updated = await Navigator.push<Post>(
      context,
      MaterialPageRoute(builder: (_) => EditPostPage(post: _post)),
    );

    if (updated != null) {
      setState(() => _post = updated); // 상세 화면 즉시 갱신
    }
  }

  void _openMyPostMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('수정'),
              onTap: () {
                Navigator.pop(context);
                _openEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('삭제', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // TODO : 삭제 처리
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = _post;
    final isMine = post.isMine;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, _post),
        ),
        actions: [
          if (isMine)
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onPressed: () => _openMyPostMenu(context),
            ),
        ],
      ),

      // 댓글 입력바가 키보드에 밀려 올라오게
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: Column(
          children: [
            // 스크롤 영역(본문 + 댓글)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  // 제목
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 본문
                  Text(
                    post.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 좋아요/댓글 카운트
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.likes}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 20,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.comments}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // 댓글 목록
                  for (final c in _comments) ...[
                    _CommentTile(comment: c),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),

            // 하단 댓글 입력 바
            _CommentInputBar(controller: _commentCtrl, onSubmit: _addComment),
          ],
        ),
      ),
    );
  }
}

class _Comment {
  final String author;
  final String content;
  final int daysAgo;
  _Comment({
    required this.author,
    required this.content,
    required this.daysAgo,
  });
}

class _CommentTile extends StatelessWidget {
  final _Comment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 프로필 원
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromARGB(255, 216, 216, 216),
          ),
          child: const Icon(Icons.person, size: 18, color: Colors.black54),
        ),
        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.author,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    comment.daysAgo == 0 ? '방금' : '${comment.daysAgo}일 전',
                    style: const TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                  const Spacer(),
                  // '노크하기' 버튼
                ],
              ),
              const SizedBox(height: 6),
              Text(
                comment.content,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _CommentInputBar({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
        ),
        child: Row(
          children: [
            // 왼쪽 프로필
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 216, 216, 216),
              ),
              child: const Icon(Icons.person, size: 18, color: Colors.black54),
            ),
            const SizedBox(width: 10),

            // 입력창
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: '댓글 남기기',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => onSubmit(),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // 게시 버튼
            TextButton(
              onPressed: onSubmit,
              child: const Text(
                '게시',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
