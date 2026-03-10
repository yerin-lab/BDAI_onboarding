import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import 'package:flutter/foundation.dart';

class PostApi {
  static const String baseUrl = 'http://10.0.2.2:3000';

  Future<List<Post>> fetchPosts() async {
    final uri = Uri.parse('$baseUrl/posts');
    debugPrint('A. 요청 URL: $uri');

    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    debugPrint('B. 응답 코드: ${response.statusCode}');
    debugPrint('C. 응답 바디: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('게시글 목록 조회 실패: ${response.statusCode}');
    }
  }

  Future<Post> fetchPostDetail(int postId) async {
    final uri = Uri.parse('$baseUrl/posts/$postId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Post.fromJson(data);
    } else {
      throw Exception('게시글 상세 조회 실패: ${response.statusCode}');
    }
  }

  Future<Post> createPost(Post post) async {
    final uri = Uri.parse('$baseUrl/posts');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(post.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Post.fromJson(data);
    } else {
      throw Exception('게시글 작성 실패: ${response.statusCode}');
    }
  }

  Future<Post> updatePost(Post post) async {
    final uri = Uri.parse('$baseUrl/posts/${post.id}');

    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(post.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Post.fromJson(data);
    } else {
      throw Exception('게시글 수정 실패: ${response.statusCode}');
    }
  }

  Future<void> deletePost(int postId) async {
    final uri = Uri.parse('$baseUrl/posts/$postId');
    final response = await http.delete(uri);

    if (response.statusCode != 200) {
      throw Exception('게시글 삭제 실패: ${response.statusCode}');
    }
  }
}
