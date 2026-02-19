class Post {
  final String author;
  final String category;
  final String title;
  final String content;
  final int daysAgo;
  final int likes;
  final int comments;
  final bool isMine;

  const Post({
    required this.author,
    required this.category,
    required this.title,
    required this.content,
    required this.daysAgo,
    required this.likes,
    required this.comments,
    bool? isMine,
  }) : isMine = isMine ?? false;
}
