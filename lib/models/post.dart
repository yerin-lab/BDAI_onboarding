enum PostType { post, question }

class Post {
  final int id;
  final String author;
  final String category;
  final String title;
  final String content;
  final int daysAgo;
  final int likes;
  final bool isLiked;
  final int comments;
  final bool isMine;
  final PostType type;

  Post({
    required this.id,
    required this.author,
    required this.category,
    required this.title,
    required this.content,
    required this.daysAgo,
    required this.likes,
    required this.isLiked,
    required this.comments,
    this.isMine = false,
    this.type = PostType.post,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author,
    'category': category,
    'title': title,
    'content': content,
    'daysAgo': daysAgo,
    'likes': likes,
    'comments': comments,
    'isMine': isMine,
    'type': type.name,
  };

  factory Post.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String? ?? 'post';

    return Post(
      id: json['id'] as int,
      author: json['author'] as String? ?? '',
      category: json['category'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      daysAgo: json['daysAgo'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      comments: json['comments'] as int? ?? 0,
      type: typeString == 'question' ? PostType.question : PostType.post,
      isMine: json['isMine'] as bool? ?? false,
    );
  }

  Post copyWith({
    String? author,
    String? category,
    String? title,
    String? content,
    int? daysAgo,
    int? likes,
    bool? isLiked,
    int? comments,
    bool? isMine,
    PostType? type,
  }) {
    return Post(
      id: id,
      author: author ?? this.author,
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      daysAgo: daysAgo ?? this.daysAgo,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      comments: comments ?? this.comments,
      isMine: isMine ?? this.isMine,
      type: type ?? this.type,
    );
  }
}
