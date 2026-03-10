import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reply.dart';

class ReplyLocal {
  static String _key(int postId, int page, int limit) =>
      'replies_post_${postId}_page_${page}_limit_$limit';

  Future<void> saveReplies({
    required int postId,
    required int page,
    required int limit,
    required List<Reply> replies,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(replies.map((e) => e.toJson()).toList());

    await prefs.setString(_key(postId, page, limit), encoded);
  }

  Future<List<Reply>> getReplies({
    required int postId,
    required int page,
    required int limit,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(postId, page, limit));

    if (raw == null) return [];

    final List decoded = jsonDecode(raw) as List;

    return decoded
        .map((e) => Reply.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> clearRepliesCache(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith('replies_post_${postId}_')) {
        await prefs.remove(key);
      }
    }
  }
}
