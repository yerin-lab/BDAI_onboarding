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
  final ScrollController _scrollController = ScrollController();
  final ReplyApi _replyApi = ReplyApi();

  late Post _post;

  List<Reply> _comments = [];

  bool _isLoadingComments = true;
  bool _isLoadingMore = false;
  bool _hasMoreComments = true;
  String? _commentError;

  int _commentPage = 1;
  static const int _commentLimit = 10;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _loadInitialComments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    print('스크롤 위치: ${position.pixels} / 최대: ${position.maxScrollExtent}');

    if (position.pixels >= position.maxScrollExtent - 200) {
      print('바닥 근처 도달 -> 추가 로드 시도');
      _loadMoreComments();
    }
  }

  Future<void> _loadInitialComments() async {
    print('초기 댓글 로드 시작');

    if (!mounted) return;

    setState(() {
      _isLoadingComments = true;
      _commentError = null;
      _commentPage = 1;
      _hasMoreComments = true;
      _comments = [];
    });

    try {
      final replies = await _replyApi.fetchReplies(
        postId: _post.id,
        page: 1,
        limit: _commentLimit,
      );

      print('초기 로드 댓글 수: ${replies.length}');

      if (!mounted) return;

      setState(() {
        _comments = replies;
        _isLoadingComments = false;
        _hasMoreComments = replies.length == _commentLimit;
      });

      print('초기 로드 후 hasMore: $_hasMoreComments');
    } catch (e) {
      print('초기 댓글 로드 에러: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingComments = false;
        _commentError = e.toString();
      });
    }
  }

  Future<void> _loadMoreComments() async {
    print('추가 로드 진입');
    print(
      '_isLoadingMore: $_isLoadingMore, _hasMoreComments: $_hasMoreComments',
    );

    if (_isLoadingMore || !_hasMoreComments) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _commentPage + 1;
      print('다음 페이지 요청: $nextPage');

      final replies = await _replyApi.fetchReplies(
        postId: _post.id,
        page: nextPage,
        limit: _commentLimit,
      );

      print('추가 로드 댓글 수: ${replies.length}');

      if (!mounted) return;

      setState(() {
        _comments.addAll(replies);
        _commentPage = nextPage;
        _isLoadingMore = false;
        _hasMoreComments = replies.length == _commentLimit;
      });

      print('현재 전체 댓글 수: ${_comments.length}');
      print('추가 로드 후 hasMore: $_hasMoreComments');
    } catch (e) {
      print('추가 댓글 로드 에러: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingMore = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('댓글 추가 로드 실패: $e')));
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
        isMine: true,
      );

      _commentCtrl.clear();
      await _loadInitialComments();

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

  Future<bool> _confirmDeleteComment() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('댓글을 삭제할까요?'),
        content: const Text('삭제한 댓글은 복구할 수 없어요.'),
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

  Future<void> _deleteComment(Reply reply) async {
    final ok = await _confirmDeleteComment();
    if (!ok) return;

    try {
      await _replyApi.deleteReply(reply.id);
      await _loadInitialComments();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('댓글이 삭제되었어요')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('댓글 삭제 실패: $e')));
    }
  }

  Future<void> _editComment(Reply reply) async {
    final controller = TextEditingController(text: reply.content);

    final newText = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('댓글 수정'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: '댓글 내용을 입력하세요'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, controller.text.trim());
            },
            child: const Text('수정'),
          ),
        ],
      ),
    );

    if (newText == null || newText.isEmpty) return;

    try {
      await _replyApi.updateReply(replyId: reply.id, content: newText);
      await _loadInitialComments();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('댓글이 수정되었어요')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('댓글 수정 실패: $e')));
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
                controller: _scrollController,
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
                          onEdit: () => _editComment(c),
                          onDelete: () => _deleteComment(c),
                        ),
                      ),
                    ),

                  if (_isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
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
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CommentTile({
    required this.comment,
    required this.timeText,
    this.onEdit,
    this.onDelete,
  });

  void _openCommentMenu(BuildContext context) {
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
                onEdit?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('삭제', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onDelete?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

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
                  const Spacer(),
                  if (comment.isMine)
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _openCommentMenu(context),
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
