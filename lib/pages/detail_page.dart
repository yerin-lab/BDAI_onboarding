import 'package:flutter/material.dart';
import '../models/post.dart';
import 'edit_post_page.dart';
import '../models/reply.dart';
import '../data/reply_api.dart';

class DetailPage extends StatefulWidget {
  final Post post;
  const DetailPage({super.key, required this.post});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final TextEditingController _commentCtrl = TextEditingController();
  final ReplyApi _replyApi = ReplyApi();

  late Post _post;

  List<Reply> _comments = [];
  bool _isLoadingComments = true;
  String? _commentError;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _loadComments();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      print("댓글 요청 시작");
      final replies = await _replyApi.fetchReplies(_post.id);

      print("댓글 개수: ${replies.length}");
      if (!mounted) return;

      setState(() {
        _comments = replies;
        _isLoadingComments = false;
        _commentError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingComments = false;
        _commentError = e.toString();
      });
    }
  }

  Future<void> _addComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    try {
      await _replyApi.createReply(
        postId: _post.id,
        author: '예린',
        content: text,
      );

      _commentCtrl.clear();
      await _loadComments();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('댓글이 등록되었어요')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('댓글 작성 실패: $e')));
    }
  }

  Future<void> _openEdit() async {
    final updated = await Navigator.push<Post>(
      context,
      MaterialPageRoute(builder: (_) => EditPostPage(post: _post)),
    );

    if (updated != null) {
      setState(() => _post = updated);
    }
  }

  Future<bool> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('게시글을 삭제할까요?'),
        content: const Text('삭제한 게시글은 복구할 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _deletePost() async {
    final ok = await _confirmDelete();
    if (!ok) return;

    if (!mounted) return;
    Navigator.pop(context, _post.id);
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
                _deletePost();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatCreatedAt(String createdAt) {
    final dt = DateTime.tryParse(createdAt);
    if (dt == null) return '';

    final diff = DateTime.now().difference(dt);

    if (diff.inMinutes < 1) return '방금';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }

  @override
  Widget build(BuildContext context) {
    print('DetailPage build 실행');
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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
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
                  Text(
                    post.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 18),
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
                        '${_comments.length}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  if (_isLoadingComments)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_commentError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text('댓글을 불러오지 못했어요: $_commentError'),
                    )
                  else if (_comments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('첫 댓글을 남겨보세요!'),
                    )
                  else
                    ..._comments.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CommentTile(
                          comment: c,
                          timeText: _formatCreatedAt(c.createdAt),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _CommentInputBar(controller: _commentCtrl, onSubmit: _addComment),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Reply comment;
  final String timeText;

  const _CommentTile({required this.comment, required this.timeText});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    timeText,
                    style: const TextStyle(color: Colors.black45, fontSize: 12),
                  ),
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
  final Future<void> Function() onSubmit;

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
