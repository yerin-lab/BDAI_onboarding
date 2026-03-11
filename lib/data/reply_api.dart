import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reply.dart';

class ReplyApi {
  static const String baseUrl = 'http://10.0.2.2:3000';

  Future<List<Reply>> fetchReplies({
    required int postId,
    required int page,
    int limit = 10,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/replies?postId=$postId&_sort=id&_order=desc&_page=$page&_limit=$limit',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;

      return data
          .map((e) => Reply.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('댓글 조회 실패: ${response.statusCode}');
    }
  }

  Future<void> createReply({
    required int postId,
    required String author,
    required String content,
    required bool isMine,
  }) async {
    final uri = Uri.parse('$baseUrl/replies');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'postId': postId,
        'author': author,
        'content': content,
        'createdAt': DateTime.now().toIso8601String(),
        'isMine': isMine,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('댓글 작성 실패');
    }
  }

  Future<void> deleteReply(int replyId) async {
    final uri = Uri.parse('$baseUrl/replies/$replyId');

    final response = await http.delete(uri);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('댓글 삭제 실패: ${response.statusCode}');
    }
  }

  Future<void> updateReply({
    required int replyId,
    required String content,
  }) async {
    final uri = Uri.parse('$baseUrl/replies/$replyId');

    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode != 200) {
      throw Exception('댓글 수정 실패: ${response.statusCode}');
    }
  }

  Future<void> likeReply(int replyId) async {
    final uri = Uri.parse('$baseUrl/replies/$replyId/like');
    final response = await http.post(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('댓글 좋아요 실패');
    }
  }

  Future<void> unlikeReply(int replyId) async {
    final uri = Uri.parse('$baseUrl/replies/$replyId/like');
    final response = await http.delete(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('댓글 좋아요 취소 실패');
    }
  }
}
