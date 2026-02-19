class Post {
  final int id;
  final String author;
  final String category;
  final String title;
  final String content;
  final int daysAgo;
  final int likes;
  final int comments;
  final bool isMine;

  Post({
    required this.id,
    required this.author,
    required this.category,
    required this.title,
    required this.content,
    required this.daysAgo,
    required this.likes,
    required this.comments,
    bool? isMine,
  }) : isMine = isMine ?? false;

  // 수정용
  Post copyWith({
    String? title,
    String? content,
    String? category,
    int? likes,
    int? comments,
  }) {
    return Post(
      id: id,
      author: author,
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      daysAgo: daysAgo,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isMine: isMine,
    );
  }
}
