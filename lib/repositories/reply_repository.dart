import '../data/reply_api.dart';
import '../data/reply_local.dart';
import '../models/reply.dart';

class ReplyRepository {
  final ReplyApi api;
  final ReplyLocal local;

  ReplyRepository({required this.api, required this.local});

  Future<List<Reply>> fetchReplies({
    required int postId,
    required int page,
    int limit = 10,
  }) async {
    try {
      final replies = await api.fetchReplies(
        postId: postId,
        page: page,
        limit: limit,
      );

      await local.saveReplies(
        postId: postId,
        page: page,
        limit: limit,
        replies: replies,
      );

      return replies;
    } catch (e) {
      final cached = await local.getReplies(
        postId: postId,
        page: page,
        limit: limit,
      );

      if (cached.isNotEmpty) {
        return cached;
      }

      rethrow;
    }
  }

  Future<void> createReply({
    required int postId,
    required String author,
    required String content,
    required bool isMine,
  }) async {
    await api.createReply(
      postId: postId,
      author: author,
      content: content,
      isMine: isMine,
    );

    await local.clearRepliesCache(postId);
  }

  Future<void> deleteReply({required int postId, required int replyId}) async {
    await api.deleteReply(replyId);
    await local.clearRepliesCache(postId);
  }

  Future<void> updateReply({
    required int postId,
    required int replyId,
    required String content,
  }) async {
    await api.updateReply(replyId: replyId, content: content);

    await local.clearRepliesCache(postId);
  }
}
