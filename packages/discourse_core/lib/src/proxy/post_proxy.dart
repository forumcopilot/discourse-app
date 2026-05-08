import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_post_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_poll.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';
import 'package:forumcopilot_sdk/models/results/fc_post_result.dart';

import '../base_discourse_proxy.dart';

/// Discourse implementation of [IFCPostProxy].
///
/// Endpoints used:
///   * `/t/{id}.json`               — topic header + first chunk of posts
///   * `/t/{id}/{post_number}.json` — post-anchored view (jump to post)
///   * `/posts/{id}.json`           — single post (with `raw` for edit)
///   * `/posts/{id}/raw`            — raw markdown
///   * POST `/posts.json`           — reply to a topic / new topic
///   * PUT  `/posts/{id}.json`      — edit a post
///   * POST `/post_actions`         — flag/report
class DiscoursePostProxy extends BaseDiscourseProxy implements IFCPostProxy {
  DiscoursePostProxy(SiteContext context) : super(context);

  // Discourse default chunk size for /t/{id}.json post_stream is 20.
  static const int _defaultChunk = 20;

  @override
  Future<FCThreadResult> getThreadAsync(
    String topicId,
    int startNum,
    int lastNum,
    bool returnHtml,
  ) async {
    if (topicId.isEmpty) {
      return _emptyThread(message: 'topicId required');
    }
    try {
      final t = await apiGet('/t/$topicId.json');
      final stream = (t['post_stream'] as Map<String, dynamic>?) ?? const {};
      final posts = ((stream['posts'] as List?) ?? const [])
          .whereType<Map>()
          .map((p) => _postFrom(p.cast<String, dynamic>(), topicId: topicId))
          .toList();

      final details = (t['details'] as Map<String, dynamic>?) ?? const {};
      final createdBy =
          (details['created_by'] as Map<String, dynamic>?) ?? const {};
      final categoryId = (t['category_id'] ?? '').toString();
      final id = (t['id'] ?? topicId).toString();

      String? avatarUrl;
      final tpl = createdBy['avatar_template'] as String?;
      if (tpl != null && tpl.isNotEmpty) {
        final filled = tpl.replaceAll('{size}', '120');
        avatarUrl = filled.startsWith('http')
            ? filled
            : '${siteContext.site.url}$filled';
      }

      return FCThreadResult(
        result: true,
        resultText: '',
        totalPostNum: (t['posts_count'] as int?) ?? posts.length,
        posts: posts,
        // FCTopic header
        id: id,
        title: (t['title'] ?? '').toString(),
        forumId: categoryId,
        forumName: '',
        authorId: (createdBy['id'] ?? '').toString(),
        authorName: (createdBy['username'] ?? '').toString(),
        authorUserType: createdBy['admin'] == true
            ? 'admin'
            : (createdBy['moderator'] == true ? 'moderator' : 'normal'),
        authorIconUrl: avatarUrl,
        timestamp:
            DateTime.tryParse(t['created_at']?.toString() ?? '') ?? DateTime.now(),
        replyCount: (t['reply_count'] as int?) ??
            (((t['posts_count'] as int?) ?? 1) - 1).clamp(0, 1 << 30),
        viewCount: (t['views'] as int?) ?? 0,
        isClosed: (t['closed'] as bool?) ?? false,
        isSubscribed: (t['notification_level'] as int? ?? 1) >= 2,
        canReply: !(t['closed'] == true || t['archived'] == true),
        canReport: true,
        canUpload: true,
        canLike: true,
        isLiked: (t['liked'] as bool?) ?? false,
        likeCount: (t['like_count'] as int?) ?? 0,
        isPinned: (t['pinned'] as bool?) ?? false,
        isAnnouncement: (t['pinned_globally'] as bool?) ?? false,
        url: '${siteContext.site.url}/t/$id',
        shortContent: posts.isNotEmpty ? posts.first.content : null,
      );
    } catch (e) {
      return _emptyThread(message: 'Error: $e');
    }
  }

  @override
  Future<FCThreadByPostResult> getThreadByPostAsync(
    String postId,
    int postsPerRequest,
    bool returnHtml,
  ) async {
    if (postId.isEmpty) {
      return _emptyThreadByPost(message: 'postId required');
    }
    try {
      // First find which topic this post lives in.
      final p = await apiGet('/posts/$postId.json');
      final topicId = (p['topic_id'] ?? '').toString();
      if (topicId.isEmpty) {
        return _emptyThreadByPost(message: 'post has no topic_id');
      }
      final postNumber = (p['post_number'] as int?) ?? 1;
      final t = await apiGet('/t/$topicId/$postNumber.json');
      final stream = (t['post_stream'] as Map<String, dynamic>?) ?? const {};
      final posts = ((stream['posts'] as List?) ?? const [])
          .whereType<Map>()
          .map((m) => _postFrom(m.cast<String, dynamic>(), topicId: topicId))
          .toList();
      final details = (t['details'] as Map<String, dynamic>?) ?? const {};
      final createdBy =
          (details['created_by'] as Map<String, dynamic>?) ?? const {};

      return FCThreadByPostResult(
        result: true,
        resultText: '',
        totalPostNum: (t['posts_count'] as int?) ?? posts.length,
        posts: posts,
        position: postNumber,
        id: topicId,
        title: (t['title'] ?? '').toString(),
        forumId: (t['category_id'] ?? '').toString(),
        forumName: '',
        authorId: (createdBy['id'] ?? '').toString(),
        authorName: (createdBy['username'] ?? '').toString(),
        authorUserType: '',
        timestamp:
            DateTime.tryParse(t['created_at']?.toString() ?? '') ?? DateTime.now(),
        canReply: !(t['closed'] == true || t['archived'] == true),
        canReport: true,
        canUpload: true,
      );
    } catch (e) {
      return _emptyThreadByPost(message: 'Error: $e');
    }
  }

  @override
  Future<FCThreadByUnreadResult> getThreadByUnreadAsync(
    String topicId,
    int postsPerRequest,
    bool returnHtml,
  ) async {
    // Use the topic's `last_read_post_number` (when authed) to anchor;
    // /t/{id}/{n}.json returns posts around that anchor. Discourse handles
    // "first unread" implicitly when you open /t/{id}.json — for the SDK
    // contract we just delegate to that and report position=1.
    if (topicId.isEmpty) {
      return _emptyThreadByUnread(message: 'topicId required');
    }
    try {
      final t = await apiGet('/t/$topicId.json');
      final stream = (t['post_stream'] as Map<String, dynamic>?) ?? const {};
      final posts = ((stream['posts'] as List?) ?? const [])
          .whereType<Map>()
          .map((m) => _postFrom(m.cast<String, dynamic>(), topicId: topicId))
          .toList();
      final details = (t['details'] as Map<String, dynamic>?) ?? const {};
      final createdBy =
          (details['created_by'] as Map<String, dynamic>?) ?? const {};
      final unreadAnchor = (t['last_read_post_number'] as int?) ?? 1;

      return FCThreadByUnreadResult(
        result: true,
        resultText: '',
        totalPostNum: (t['posts_count'] as int?) ?? posts.length,
        posts: posts,
        position: unreadAnchor,
        id: (t['id'] ?? topicId).toString(),
        title: (t['title'] ?? '').toString(),
        forumId: (t['category_id'] ?? '').toString(),
        forumName: '',
        authorId: (createdBy['id'] ?? '').toString(),
        authorName: (createdBy['username'] ?? '').toString(),
        authorUserType: '',
        timestamp:
            DateTime.tryParse(t['created_at']?.toString() ?? '') ?? DateTime.now(),
        canReply: !(t['closed'] == true || t['archived'] == true),
        canReport: true,
        canUpload: true,
      );
    } catch (e) {
      return _emptyThreadByUnread(message: 'Error: $e');
    }
  }

  @override
  Future<FCReplyPostResult> replyPostAsync(
    String forumId,
    String topicId,
    String subject,
    String textBody,
    List<String>? attachmentIds,
    String? groupId,
    bool returnHtml,
  ) async {
    try {
      final response = await apiPost('/posts.json', body: {
        'topic_id': int.tryParse(topicId) ?? topicId,
        'raw': textBody,
        'archetype': 'regular',
      });
      return FCReplyPostResult(
        result: true,
        resultText: '',
        postId: (response['id'] ?? '').toString(),
        state: 0,
        postContent:
            returnHtml ? response['cooked']?.toString() : response['raw']?.toString(),
        canEdit: response['can_edit'] == true,
        canDelete: response['can_delete'] == true,
      );
    } catch (e) {
      return FCReplyPostResult(
        result: false,
        resultText: 'Error: $e',
      );
    }
  }

  @override
  Future<FCQuotePostResult> getQuotePostAsync(String postId) async {
    try {
      final response = await apiGet('/posts/$postId.json');
      final raw = (response['raw'] as String?) ?? '';
      final username = (response['username'] as String?) ?? '';
      // Discourse's quote markdown: [quote="user, post:N, topic:T"]raw[/quote]
      final quote = '[quote="${username}, post:${response['post_number']}, '
          'topic:${response['topic_id']}"]\n$raw\n[/quote]\n\n';
      return FCQuotePostResult(
        result: true,
        resultText: '',
        quoteContent: quote,
      );
    } catch (e) {
      return FCQuotePostResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCRawPostResult> getRawPostAsync(String postId) async {
    try {
      final response = await apiGet('/posts/$postId.json');
      final isFirstPost = (response['post_number'] as int?) == 1;
      String? title;
      if (isFirstPost) {
        // The first post's "title" lives on the topic, not the post.
        try {
          final t = await apiGet('/t/${response['topic_id']}.json');
          title = t['title']?.toString();
        } catch (_) {
          // ignore
        }
      }
      return FCRawPostResult(
        result: true,
        resultText: '',
        postContent: response['raw']?.toString(),
        postTitle: title,
        canEditTitle: isFirstPost && response['can_edit'] == true,
        forumId: response['category_id']?.toString(),
      );
    } catch (e) {
      return FCRawPostResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCSaveRawPostResult> saveRawPostAsync(
    String postId,
    String postTitle,
    String postContent,
    bool returnHtml,
    String? reason,
    List<String>? attachmentIds,
    String? groupId,
    String? prefix,
  ) async {
    try {
      final body = <String, dynamic>{
        'post': {
          'raw': postContent,
          if (reason != null && reason.isNotEmpty) 'edit_reason': reason,
        },
      };
      final response = await apiPut('/posts/$postId.json', body: body);
      // If editing the first post and a title was provided, update topic title.
      // Skipped here because the SDK only knows `postTitle` exists when the
      // first post is being edited; the caller decides.
      return FCSaveRawPostResult(
        result: true,
        resultText: '',
        postContent: returnHtml
            ? response['cooked']?.toString()
            : response['raw']?.toString(),
      );
    } catch (e) {
      return FCSaveRawPostResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCReportPostResult> reportPostAsync(
      String postId, String reason) async {
    try {
      // post_action_type_id 8 = notify_moderators ("It's something else")
      // with a free-form message. If empty, we use 4 = inappropriate.
      final actionTypeId = reason.trim().isEmpty ? 4 : 8;
      await apiPost('/post_actions.json', body: {
        'id': int.tryParse(postId) ?? postId,
        'post_action_type_id': actionTypeId,
        if (reason.trim().isNotEmpty) 'message': reason,
      });
      return FCReportPostResult(result: true, resultText: '');
    } catch (e) {
      return FCReportPostResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCPoll?> votePollAsync(
      String topicId, List<String> responseIds) async {
    // Discourse poll vote: PUT /polls/vote { post_id, poll_name, options[] }.
    // The SDK contract is keyed on topic_id, so we look up the first post id
    // first. Phase 2.0 punt: not yet wired.
    return null;
  }

  // ===== Helpers =====

  FCPost _postFrom(Map<String, dynamic> p, {required String topicId}) {
    final tpl = p['avatar_template'] as String?;
    String? avatarUrl;
    if (tpl != null && tpl.isNotEmpty) {
      final filled = tpl.replaceAll('{size}', '90');
      avatarUrl = filled.startsWith('http')
          ? filled
          : '${siteContext.site.url}$filled';
    }
    final actions = (p['actions_summary'] as List?) ?? const [];
    final like = actions.whereType<Map>().firstWhere(
          (a) => a['id'] == 2,
          orElse: () => <String, dynamic>{},
        );
    final isLiked = like['acted'] == true;
    final canLike = like['can_act'] == true;
    final likeCount = (like['count'] as int?) ?? 0;

    return FCPost(
      id: (p['id'] ?? '').toString(),
      title: '',
      content: (p['cooked'] ?? p['raw'] ?? '').toString(),
      topicId: topicId,
      authorId: (p['user_id'] ?? '').toString(),
      authorName: (p['username'] ?? '').toString(),
      authorIconUrl: avatarUrl,
      authorUserType: p['admin'] == true
          ? 'admin'
          : (p['moderator'] == true ? 'moderator' : 'normal'),
      timestamp: DateTime.tryParse(p['created_at']?.toString() ?? ''),
      postNumber: p['post_number'] as int?,
      canEdit: p['can_edit'] == true,
      canDelete: p['can_delete'] == true,
      canReport: true,
      canLike: canLike,
      isLiked: isLiked,
    );
  }

  FCThreadResult _emptyThread({required String message}) {
    return FCThreadResult(
      result: false,
      resultText: message,
      totalPostNum: 0,
      id: '',
      title: '',
      forumId: '',
      forumName: '',
      authorId: '',
      authorName: '',
      authorUserType: '',
      timestamp: DateTime.now(),
    );
  }

  FCThreadByPostResult _emptyThreadByPost({required String message}) {
    return FCThreadByPostResult(
      result: false,
      resultText: message,
      totalPostNum: 0,
      position: 1,
      id: '',
      title: '',
      forumId: '',
      forumName: '',
      authorId: '',
      authorName: '',
      authorUserType: '',
      timestamp: DateTime.now(),
    );
  }

  FCThreadByUnreadResult _emptyThreadByUnread({required String message}) {
    return FCThreadByUnreadResult(
      result: false,
      resultText: message,
      totalPostNum: 0,
      position: 1,
      id: '',
      title: '',
      forumId: '',
      forumName: '',
      authorId: '',
      authorName: '',
      authorUserType: '',
      timestamp: DateTime.now(),
    );
  }
}
