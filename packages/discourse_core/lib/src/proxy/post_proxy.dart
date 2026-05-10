import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_post_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_attachment.dart';
import 'package:forumcopilot_sdk/models/entities/fc_like.dart';
import 'package:forumcopilot_sdk/models/entities/fc_poll.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';
import 'package:forumcopilot_sdk/models/entities/fc_thanks.dart';
import 'package:forumcopilot_sdk/models/results/fc_post_result.dart';

import '../base_discourse_proxy.dart';
import '../data/post/discourse_bookmark.dart';
import '../data/post/discourse_suggested_topic.dart';

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

  /// Carries the (post_id, poll_name) that a parsed [FCPoll] originated
  /// from. The SDK contract for [votePollAsync] is keyed on topic id, but
  /// Discourse needs the post id of the post hosting the poll plus the
  /// poll's name (default 'poll'). We stash both here at parse time so
  /// the vote call doesn't need to refetch the topic.
  static final Expando<_DiscoursePollMeta> _pollMeta = Expando('pollMeta');

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
      final rawPosts = ((stream['posts'] as List?) ?? const [])
          .whereType<Map>()
          .map((p) => p.cast<String, dynamic>())
          .toList();
      final posts =
          rawPosts.map((p) => _postFrom(p, topicId: topicId)).toList();

      // Pull a poll out of the first post if present so the topic header
      // can render a Twitter-style poll card.
      final firstPostJson = rawPosts.isNotEmpty
          ? rawPosts.firstWhere(
              (p) => (p['post_number'] as int?) == 1,
              orElse: () => rawPosts.first,
            )
          : null;
      final poll = firstPostJson == null
          ? null
          : _firstPollFromPost(firstPostJson, topicId: topicId);

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
        // Discourse `reply_count` is cross-thread replies, not total. Use
        // `posts_count - 1`.
        replyCount: (((t['posts_count'] as int?) ?? 1) - 1).clamp(0, 1 << 30),
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
        shortContent: posts.isNotEmpty ? posts.first.content : '',
        poll: poll,
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
      final rawPosts = ((stream['posts'] as List?) ?? const [])
          .whereType<Map>()
          .map((m) => m.cast<String, dynamic>())
          .toList();
      final posts =
          rawPosts.map((p) => _postFrom(p, topicId: topicId)).toList();
      final firstPostJson = rawPosts.firstWhere(
        (p) => (p['post_number'] as int?) == 1,
        orElse: () => const {},
      );
      final poll = firstPostJson.isEmpty
          ? null
          : _firstPollFromPost(firstPostJson, topicId: topicId);
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
        poll: poll,
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
      final rawPosts = ((stream['posts'] as List?) ?? const [])
          .whereType<Map>()
          .map((m) => m.cast<String, dynamic>())
          .toList();
      final posts =
          rawPosts.map((p) => _postFrom(p, topicId: topicId)).toList();
      final firstPostJson = rawPosts.isNotEmpty
          ? rawPosts.firstWhere(
              (p) => (p['post_number'] as int?) == 1,
              orElse: () => rawPosts.first,
            )
          : null;
      final poll = firstPostJson == null
          ? null
          : _firstPollFromPost(firstPostJson, topicId: topicId);
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
        poll: poll,
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
    } on DiscourseApiException catch (e) {
      return FCReplyPostResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCReplyPostResult(result: false, resultText: 'Error: $e');
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
    // We stash (post_id, poll_name) on the FCPoll via [_pollMeta] when
    // parsing; the caller hands us back option ids (poll-option digests),
    // so we can vote without refetching the topic to find the host post.
    if (responseIds.isEmpty) return null;
    // Look up the meta from the first response id — we expose a helper
    // below so the UI doesn't need to know about the Expando, but if it
    // hasn't seen the poll instance we have to fall back to fetching
    // /t/{id}.json to find the first post.
    int? postId;
    String pollName = 'poll';
    final meta = _lookupPollMetaByResponseId(responseIds.first);
    if (meta != null) {
      postId = meta.postId;
      pollName = meta.pollName;
    } else {
      final fallback = await _findFirstPostId(topicId);
      if (fallback == null) return null;
      postId = fallback;
    }
    try {
      final response = await apiPut('/polls/vote', body: {
        'post_id': postId,
        'poll_name': pollName,
        'options[]': responseIds,
      });
      final pollJson = (response['poll'] as Map?)?.cast<String, dynamic>();
      if (pollJson == null) return null;
      final votedAfter = ((response['vote'] as List?) ?? const [])
          .whereType<String>()
          .toList();
      return _pollFromJson(
        pollJson,
        topicId: topicId,
        postId: postId,
        viewerVotes: votedAfter,
      );
    } catch (_) {
      return null;
    }
  }

  /// Reverse-lookup helper: scans recently-parsed polls for one whose
  /// option list contains [responseId]. Cheap because [_pollMeta] is an
  /// Expando keyed on FCPoll instances — we keep a parallel small list of
  /// recent (poll, meta) tuples for this lookup.
  static final List<_RecentPoll> _recentPolls = [];

  _DiscoursePollMeta? _lookupPollMetaByResponseId(String responseId) {
    for (final entry in _recentPolls) {
      for (final opt in entry.poll.responses) {
        if (opt.id == responseId) {
          return _pollMeta[entry.poll];
        }
      }
    }
    return null;
  }

  Future<int?> _findFirstPostId(String topicId) async {
    try {
      final t = await apiGet('/t/$topicId.json');
      final stream = (t['post_stream'] as Map<String, dynamic>?) ?? const {};
      final posts = (stream['posts'] as List?) ?? const [];
      for (final raw in posts.whereType<Map>()) {
        final p = raw.cast<String, dynamic>();
        if ((p['post_number'] as int?) == 1) {
          return (p['id'] as num?)?.toInt();
        }
      }
      // Some endpoints omit post_number; fall back to first.
      if (posts.isNotEmpty) {
        return ((posts.first as Map)['id'] as num?)?.toInt();
      }
    } catch (_) {}
    return null;
  }

  /// Build an FCPoll from a Discourse poll object (`p['polls'][0]`),
  /// stamping the [_pollMeta] sidecar so [votePollAsync] knows which
  /// post_id + poll_name to use.
  FCPoll? _pollFromJson(
    Map<String, dynamic> pollJson, {
    required String topicId,
    required int postId,
    List<String>? viewerVotes,
  }) {
    final name = (pollJson['name'] ?? 'poll').toString();
    final type = (pollJson['type'] ?? 'regular').toString();
    final status = (pollJson['status'] ?? 'open').toString();
    final results = (pollJson['results'] ?? 'always').toString();
    final isClosed = status == 'closed';
    final voters = (pollJson['voters'] as num?)?.toInt();
    final maxRaw = pollJson['max'];
    final int max;
    if (type == 'multiple') {
      max = (maxRaw is num) ? maxRaw.toInt() : 0;
    } else {
      max = 1;
    }
    final voted = (viewerVotes ?? const <String>[]).toSet();
    final options = ((pollJson['options'] as List?) ?? const [])
        .whereType<Map>()
        .map((o) => o.cast<String, dynamic>())
        .map((o) {
      final id = (o['id'] ?? '').toString();
      // Discourse uses `votes` only when the viewer is allowed to see
      // counts; otherwise it omits the field.
      final hasCount = o.containsKey('votes');
      return FCPollResponse(
        id: id,
        text: (o['html'] ?? o['text'] ?? '').toString(),
        voteCount: hasCount ? (o['votes'] as num?)?.toInt() : null,
        viewerVotedFor: voted.contains(id),
      );
    }).toList();

    final hasVoted = voted.isNotEmpty;
    final canViewResults = results == 'always' ||
        (results == 'on_vote' && hasVoted) ||
        (results == 'on_close' && isClosed);
    final canVote = !isClosed && (!hasVoted || (pollJson['can_change_vote'] == true));

    final poll = FCPoll(
      pollId: name,
      topicId: topicId,
      question: (pollJson['title'] ?? '').toString(),
      responses: options,
      voterCount: canViewResults ? voters : null,
      maxVotes: max,
      changeVote: pollJson['can_change_vote'] == true,
      publicVotes: pollJson['public'] == true,
      viewResultsUnvoted: results == 'always',
      closeDate: () {
        final close = pollJson['close']?.toString();
        if (close == null || close.isEmpty) return 0;
        final dt = DateTime.tryParse(close);
        return dt?.millisecondsSinceEpoch ?? 0;
      }(),
      isClosed: isClosed,
      canVote: canVote,
      hasVoted: hasVoted,
      canViewResults: canViewResults,
    );
    _pollMeta[poll] = _DiscoursePollMeta(postId: postId, pollName: name);
    _trackRecentPoll(poll);
    return poll;
  }

  void _trackRecentPoll(FCPoll poll) {
    // Cap the recent-polls list at a small size; this is only a fallback
    // for the Expando lookup path.
    _recentPolls.removeWhere((e) => e.poll.pollId == poll.pollId &&
        e.poll.topicId == poll.topicId);
    _recentPolls.insert(0, _RecentPoll(poll));
    if (_recentPolls.length > 20) {
      _recentPolls.removeRange(20, _recentPolls.length);
    }
  }

  /// Extract the first poll from a Discourse post payload, if any.
  FCPoll? _firstPollFromPost(Map<String, dynamic> p, {required String topicId}) {
    final polls = (p['polls'] as List?) ?? const [];
    if (polls.isEmpty) return null;
    final first = (polls.first as Map?)?.cast<String, dynamic>();
    if (first == null) return null;
    final postId = (p['id'] as num?)?.toInt();
    if (postId == null) return null;
    final votesByPoll = (p['polls_votes'] as Map?)?.cast<String, dynamic>();
    final pollName = (first['name'] ?? 'poll').toString();
    final viewerVotes = ((votesByPoll?[pollName] as List?) ?? const [])
        .whereType<String>()
        .toList();
    return _pollFromJson(
      first,
      topicId: topicId,
      postId: postId,
      viewerVotes: viewerVotes,
    );
  }

  /// Discourse-only: bookmark [postId]. Returns true on success. UI uses
  /// this for the bookmark icon toggle on individual posts.
  Future<bool> bookmarkPostAsync(String postId) async {
    try {
      await apiPost('/bookmarks.json', body: {
        'bookmarkable_type': 'Post',
        'bookmarkable_id': int.tryParse(postId) ?? postId,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Discourse-only: remove the bookmark from [postId]. Discourse's
  /// DELETE endpoint requires the bookmark id (not post id), so we look
  /// it up via /u/{me}/bookmarks.json first. Returns true on success.
  Future<bool> unbookmarkPostAsync(String postId) async {
    final username = siteContext.currentUsername;
    if (username == null || username.isEmpty) return false;
    final pid = int.tryParse(postId);
    if (pid == null) return false;
    try {
      final response = await apiGet(
          '/u/${Uri.encodeComponent(username)}/bookmarks.json');
      final ub = (response['user_bookmark_list'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final bookmarks = (ub['bookmarks'] as List?) ?? const [];
      int? bookmarkId;
      for (final raw in bookmarks.whereType<Map>()) {
        final b = raw.cast<String, dynamic>();
        // Discourse exposes either post_id or bookmarkable_id depending on
        // version. Match against either.
        final matchPostId = b['post_id'] == pid ||
            (b['bookmarkable_type'] == 'Post' && b['bookmarkable_id'] == pid);
        if (matchPostId) {
          bookmarkId = b['id'] as int?;
          break;
        }
      }
      if (bookmarkId == null) return false;
      await apiDelete('/bookmarks/$bookmarkId.json');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Discourse-only: save a server-side draft. [draftKey] follows
  /// Discourse's conventions:
  ///   - 'new_topic'                 — composing a brand-new topic
  ///   - 'topic_{id}'                — reply to topic id
  ///   - 'new_private_message'       — composing a new PM
  ///   - 'topic_{id}'                — reply within a PM thread (Discourse
  ///     uses the same key prefix)
  ///
  /// [data] is a JSON-encodable map containing at least `reply` (body
  /// markdown) and optionally `title`, `categoryId`, `tags`, `action`.
  /// Returns true on success.
  Future<bool> saveDraftAsync({
    required String draftKey,
    required Map<String, dynamic> data,
    int sequence = 0,
  }) async {
    try {
      // Discourse expects the data field as a JSON-encoded *string*, not
      // a nested object — the server stores it raw and re-parses on read.
      // Empty drafts are deleted by the server, so callers should pass a
      // non-empty `reply` to actually persist.
      await apiPost('/drafts.json', body: {
        'draft_key': draftKey,
        'sequence': sequence,
        'data': _encodeDraftData(data),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Discourse-only: load an existing draft by [draftKey]. Returns the
  /// inner data map (e.g. `{reply, title, ...}`) or null when no draft
  /// exists.
  Future<Map<String, dynamic>?> loadDraftAsync(String draftKey) async {
    try {
      final response =
          await apiGet('/drafts/${Uri.encodeComponent(draftKey)}.json');
      // Shape: { draft: "<json string>", draft_sequence: N }
      // Older versions sometimes return draft as a parsed map directly.
      final draft = response['draft'];
      if (draft == null) return null;
      if (draft is Map) {
        return draft.cast<String, dynamic>();
      }
      if (draft is String && draft.isNotEmpty) {
        return _decodeDraftData(draft);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Discourse-only: delete a draft. Used after the composer
  /// successfully submits or when the user explicitly discards.
  Future<bool> deleteDraftAsync(String draftKey, {int sequence = 0}) async {
    try {
      await apiDelete(
          '/drafts/${Uri.encodeComponent(draftKey)}.json?sequence=$sequence');
      return true;
    } catch (_) {
      return false;
    }
  }

  String _encodeDraftData(Map<String, dynamic> data) => jsonEncode(data);

  Map<String, dynamic>? _decodeDraftData(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return decoded.cast<String, dynamic>();
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Discourse-only: fetch the "Suggested Topics" Discourse appends to
  /// every topic page response. Re-fetches `/t/{id}.json` once; the
  /// suggestions array isn't included in any other endpoint we call.
  Future<List<DiscourseSuggestedTopic>> getSuggestedTopicsAsync(
      String topicId) async {
    if (topicId.isEmpty) return const [];
    try {
      final t = await apiGet('/t/$topicId.json');
      // Build a user-id → user-record lookup so we can resolve last
      // posters when Discourse only inlines `posters` (a list of
      // `{user_id, description}`) on each suggested topic.
      final users = <int, Map<String, dynamic>>{};
      for (final raw in ((t['users'] as List?) ?? const []).whereType<Map>()) {
        final u = raw.cast<String, dynamic>();
        final id = u['id'];
        if (id is int) users[id] = u;
      }
      final suggested = (t['suggested_topics'] as List?) ?? const [];
      final out = <DiscourseSuggestedTopic>[];
      for (final raw in suggested.whereType<Map>()) {
        final s = raw.cast<String, dynamic>();
        Map<String, dynamic>? lastUser;
        final posters = (s['posters'] as List?) ?? const [];
        for (final p in posters.whereType<Map>()) {
          // The "last poster" entry has 'Most Recent Poster' in
          // description on stock Discourse.
          final desc = (p['description'] ?? '').toString();
          if (desc.contains('Most Recent Poster')) {
            final uid = p['user_id'] as int?;
            if (uid != null) lastUser = users[uid];
            break;
          }
        }
        // Fallback: use the first poster if no "most recent" tag.
        if (lastUser == null && posters.isNotEmpty) {
          final uid = (posters.first as Map)['user_id'] as int?;
          if (uid != null) lastUser = users[uid];
        }
        out.add(DiscourseSuggestedTopic(
          id: (s['id'] as num).toInt(),
          title: (s['fancy_title'] ?? s['title'] ?? '').toString(),
          slug: s['slug']?.toString(),
          postsCount: (s['posts_count'] as num?)?.toInt(),
          lastActivity:
              DateTime.tryParse(s['bumped_at']?.toString() ?? '') ??
                  DateTime.tryParse(s['last_posted_at']?.toString() ?? ''),
          lastPosterUsername: lastUser?['username']?.toString(),
          lastPosterAvatarTemplate:
              lastUser?['avatar_template']?.toString(),
          hasUnread: (s['unread_posts'] as int? ?? 0) > 0,
          isNew: s['unseen'] == true,
        ));
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  /// Discourse-only: fetch the current user's bookmarks list.
  /// Hits `/u/{username}/bookmarks.json`. Returns a list of
  /// [DiscourseBookmark] entries, newest first (Discourse's default order).
  ///
  /// [page] is 0-indexed and uses Discourse's `page` query param. Pass
  /// `null` (default) for the first page.
  Future<List<DiscourseBookmark>> getBookmarksAsync({int? page}) async {
    final username = siteContext.currentUsername;
    if (username == null || username.isEmpty) return const [];
    try {
      final qs = (page != null && page > 0) ? '?page=$page' : '';
      final response = await apiGet(
          '/u/${Uri.encodeComponent(username)}/bookmarks.json$qs');
      final ub = (response['user_bookmark_list'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final bookmarks = (ub['bookmarks'] as List?) ?? const [];
      return bookmarks
          .whereType<Map>()
          .map((b) => DiscourseBookmark.fromJson(b.cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return const [];
    }
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
      // Discourse returns rendered HTML in `cooked`. The inherited UI is a
      // BBCode renderer (XF baseline) and shows the markup as text — Phase 4
      // swaps the renderer to HTML/Markdown rendering at the UI layer.
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
      bookmarked: (p['bookmarked'] as bool?) ?? false,
      isSolution: (p['accepted_answer'] as bool?) ?? false,
      // Pass mutable empty lists so optimistic-UI code in post_actions.dart
      // can call `.add()` without tripping "Cannot add to an unmodifiable
      // list" (FCPost defaults these to `const []`). Discourse's
      // `actions_summary` only gives us a count + acted flag — we don't
      // know individual likers without /post_actions/users — so we
      // pre-seed `likeCount` placeholder entries so the UI's
      // `likesInfo.length` reads correctly. The current user is placed
      // first when they've liked, so `removeWhere(username==me)` works
      // for un-like.
      likesInfo: _buildLikesInfo(isLiked: isLiked, likeCount: likeCount),
      attachments: <FCAttachment>[],
      inlineAttachments: <FCAttachment>[],
      thanksInfo: <FCThanks>[],
    );
  }

  List<FCLike> _buildLikesInfo({
    required bool isLiked,
    required int likeCount,
  }) {
    final likers = <FCLike>[];
    if (isLiked) {
      likers.add(FCLike(
        userId: siteContext.currentUserId ?? '',
        username: siteContext.currentUsername ?? '',
        avatarUrl: siteContext.loginDataOutput?.user?.iconUrl ?? '',
        timestamp: DateTime.now(),
      ));
    }
    final remaining = (likeCount - likers.length).clamp(0, 1 << 30);
    for (var i = 0; i < remaining; i++) {
      likers.add(FCLike(
        userId: '',
        username: '',
        avatarUrl: '',
        timestamp: null,
      ));
    }
    return likers;
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

/// Sidecar struct stamped on every parsed [FCPoll] so the vote endpoint
/// can be called without re-fetching the topic.
class _DiscoursePollMeta {
  final int postId;
  final String pollName;
  const _DiscoursePollMeta({required this.postId, required this.pollName});
}

/// Holds a strong reference to a recently-parsed poll so the Expando
/// lookup can succeed during a vote round-trip. Ring-buffer cap at 20.
class _RecentPoll {
  final FCPoll poll;
  _RecentPoll(this.poll);
}
