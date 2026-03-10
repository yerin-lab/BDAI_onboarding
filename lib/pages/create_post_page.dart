import 'package:flutter/material.dart';
import '../models/post.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key, this.type = PostType.post});

  final PostType type;

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  final List<String> _categories = const [
    '취업/자소서',
    '이력서/포트폴리오',
    '에세이/스토리텔링',
    '마케팅/광고',
    '일상',
  ];
  String? _selectedCategory;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('카테고리를 선택해주세요.')));
      return;
    }

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목을 입력해주세요.')));
      return;
    }

    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('내용을 입력해주세요.')));
      return;
    }

    final post = Post(
      id: 1,
      author: '나',
      category: _selectedCategory!,
      title: title,
      content: content,
      daysAgo: 0,
      likes: 0,
      isLiked: false,
      comments: 0,
      type: widget.type,
    );

    Navigator.pop(context, post);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        centerTitle: true,
        title: const Text('글쓰기'),
        actions: [TextButton(onPressed: _submit, child: const Text('등록'))],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 카테고리 선택 (드롭다운)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategory,
                  hint: const Text('카테고리를 선택하세요'),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 제목 입력
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                hintText: '제목을 입력해주세요',
                border: InputBorder.none,
              ),
            ),

            const Divider(height: 24),

            // 내용 입력
            Expanded(
              child: TextField(
                controller: _contentCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: '내용을 입력해주세요.',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
