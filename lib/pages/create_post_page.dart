import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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
  XFile? _selectedImage;
  bool _isImageUpdated = false;

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
      imagePath: _selectedImage?.path,
    );

    Navigator.pop(context, post);
  }

  // Future<void> _pickImage() async {
  //   final status = await Permission.storage.request();

  //   if (status == PermissionStatus.denied ||
  //       status == PermissionStatus.permanentlyDenied) {
  //     if (!mounted) return;

  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('갤러리 접근 권한이 필요합니다.')));
  //     return;
  //   }

  //   try {
  //     final ImagePicker picker = ImagePicker();
  //     final XFile? localImage = await picker.pickImage(
  //       source: ImageSource.gallery,
  //       imageQuality: 50,
  //     );

  //     if (localImage == null) return;

  //     setState(() {
  //       _selectedImage = localImage;
  //       _isImageUpdated = true;
  //     });
  //   } catch (error) {
  //     if (!mounted) return;

  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다.')));
  //   }
  // }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? localImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (localImage == null) return;

      setState(() {
        _selectedImage = localImage;
        _isImageUpdated = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다. $e')));
    }
  }

  void _deleteImage() {
    setState(() {
      _selectedImage = null;
      _isImageUpdated = true;
    });
  }

  Widget _buildImageSection() {
    if (_selectedImage == null) {
      return CustomBoxContainer(
        width: 270,
        height: 150,
        onTap: () {
          _pickImage();
        },
        borderColor: Colors.grey,
        hasRoundEdge: false,
        child: const Icon(Icons.add, color: Colors.grey, size: 30),
      );
    }

    return CustomBoxContainer(
      width: 270,
      height: 150,
      onTap: () {
        _pickImage();
      },
      image: DecorationImage(
        fit: BoxFit.cover,
        image: FileImage(File(_selectedImage!.path)),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: IconButton(
          onPressed: _deleteImage,
          icon: const Icon(Icons.close),
        ),
      ),
    );
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
            _buildImageSection(),
            const SizedBox(height: 12),

            // 제목 입력
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                hintText: '제목을 입력해주세요',
                border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomBoxContainer extends StatelessWidget {
  const CustomBoxContainer({
    super.key,
    this.hasRoundEdge = true,
    this.center = false,
    this.borderColor,
    this.color = Colors.white,
    this.boxShadow,
    this.width,
    this.height,
    this.child,
    this.image,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
  });

  final bool hasRoundEdge;
  final bool center;
  final Color? borderColor;
  final Color color;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;
  final Widget? child;
  final DecorationImage? image;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        alignment: center ? Alignment.center : null,
        decoration: BoxDecoration(
          borderRadius:
              borderRadius ?? (hasRoundEdge ? BorderRadius.circular(10) : null),
          color: color,
          boxShadow: boxShadow,
          border: borderColor != null ? Border.all(color: borderColor!) : null,
          image: image,
        ),
        child: child,
      ),
    );
  }
}
