class Reply {
  final int id;
  final int postId;
  final String author;
  final String content;
  final String createdAt;
  final bool isMine;

  Reply({
    required this.id,
    required this.postId,
    required this.author,
    required this.content,
    required this.createdAt,
    this.isMine = false,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['id'] as int,
      postId: json['postId'] as int,
      author: json['author'] as String,
      content: json['content'] as String,
      createdAt: json['createdAt'] as String,
      isMine: (json['isMine'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'author': author,
      'content': content,
      'createdAt': createdAt,
      'isMine': isMine,
    };
  }

  Reply copyWith({
    int? id,
    int? postId,
    String? author,
    String? content,
    String? createdAt,
    bool? isMine,
  }) {
    return Reply(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      author: author ?? this.author,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isMine: isMine ?? this.isMine,
    );
  }
}
