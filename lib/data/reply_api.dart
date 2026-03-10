import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reply.dart';

class ReplyApi {
  static const String baseUrl = 'http://10.0.2.2:3000';

  Future<List<Reply>> fetchReplies(int postId) async {
    final uri = Uri.parse('$baseUrl/replies?postId=$postId');

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
        'isMine': true,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('댓글 작성 실패');
    }
  }
}
