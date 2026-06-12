import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_post_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_attachment.dart';
import 'package:forumcopilot_sdk/models/entities/fc_like.dart';
import 'package:forumcopilot_sdk/models/entities/fc_poll.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post_vote.dart';
import 'package:forumcopilot_sdk/models/entities/fc_reaction.dart';
import 'package:forumcopilot_sdk/models/entities/fc_thanks.dart';
import 'package:forumcopilot_sdk/models/results/fc_post_result.dart';
import 'package:forumcopilot_sdk/models/results/fc_reaction_result.dart';

import '../base_discourse_proxy.dart';
import '../data/post/discourse_suggested_topic.dart';
import '../util/html_text.dart';

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
      // Phase 5.31 — discourse-solved exposes topic-level
      // `can_accept_answer` to the OP and staff. Per-post
      // canAcceptAnswer in `_postFrom` ANDs this with "not the
      // first post" so the question itself isn't markable.
      final topicCanAccept = (t['can_accept_answer'] as bool?) ?? false;
      final posts = rawPosts
          .map((p) => _postFrom(p,
              topicId: topicId, topicCanAcceptAnswer: topicCanAccept))
          .toList();

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
      final topicCanAccept = (t['can_accept_answer'] as bool?) ?? false;
      final posts = rawPosts
          .map((p) => _postFrom(p,
              topicId: topicId, topicCanAcceptAnswer: topicCanAccept))
          .toList();
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
      final topicCanAccept = (t['can_accept_answer'] as bool?) ?? false;
      final posts = rawPosts
          .map((p) => _postFrom(p,
              topicId: topicId, topicCanAcceptAnswer: topicCanAccept))
          .toList();
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
      // Phase 5.19 — append Markdown image/file refs for each
      // uploaded attachment before posting. See `appendAttachmentMarkdown`
      // for the format (`![image](upload://...)` for images, file
      // attachment syntax for everything else). `attachmentIds`
      // carries Discourse short_urls here, not numeric IDs.
      final rawWithAttachments =
          appendAttachmentMarkdown(textBody, attachmentIds);
      final response = await apiPost('/posts.json', body: {
        'topic_id': int.tryParse(topicId) ?? topicId,
        'raw': rawWithAttachments,
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
      // Phase 5.19 — append Markdown refs for any newly-uploaded
      // attachments before saving the edit. Already-embedded
      // attachments stay in `postContent` as-is.
      final rawWithAttachments =
          appendAttachmentMarkdown(postContent, attachmentIds);
      final body = <String, dynamic>{
        'post': {
          'raw': rawWithAttachments,
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
  Future<FCAcceptAnswerResult> acceptAnswerAsync(String postId) async {
    // Phase 5.31 — discourse-solved plugin endpoint
    //   POST /accept-answer { id: <post_id> }
    // Marks the post as the accepted answer for its topic and bumps
    // the topic's "solved" state. The FCPost.canAcceptAnswer cap is
    // computed at parse time from the topic-level `can_accept_answer`
    // flag.
    if (postId.isEmpty) {
      return FCAcceptAnswerResult(
        result: false,
        resultText: 'No post id supplied',
      );
    }
    try {
      await apiPost('/accept-answer', body: {
        'id': int.tryParse(postId) ?? postId,
      });
      return FCAcceptAnswerResult(result: true, resultText: '');
    } on DiscourseApiException catch (e) {
      if (e.statusCode == 404) {
        return FCAcceptAnswerResult(
          result: false,
          resultText:
              'Accepting answers requires the discourse-solved plugin.',
        );
      }
      return FCAcceptAnswerResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCAcceptAnswerResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCAcceptAnswerResult> unacceptAnswerAsync(String postId) async {
    if (postId.isEmpty) {
      return FCAcceptAnswerResult(
        result: false,
        resultText: 'No post id supplied',
      );
    }
    try {
      await apiPost('/unaccept-answer', body: {
        'id': int.tryParse(postId) ?? postId,
      });
      return FCAcceptAnswerResult(result: true, resultText: '');
    } on DiscourseApiException catch (e) {
      if (e.statusCode == 404) {
        return FCAcceptAnswerResult(
          result: false,
          resultText:
              'Accepting answers requires the discourse-solved plugin.',
        );
      }
      return FCAcceptAnswerResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCAcceptAnswerResult(result: false, resultText: 'Error: $e');
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

  // Phase 5.33 — bookmark methods moved to DiscourseBookmarkProxy
  // (IFCBookmarkProxy). Callers should use
  // `SiteProxyService.getBookmarkProxy().addPostBookmarkAsync` /
  // `removePostBookmarkAsync` / `getBookmarksAsync` instead.

  // Phase 5.34 — draft methods moved to DiscourseDraftProxy
  // (IFCDraftProxy). Callers should use
  // `SiteProxyService.getDraftProxy().saveDraftAsync` /
  // `loadDraftAsync` / `deleteDraftAsync` / `getMyDraftsAsync` instead.

  @override
  Future<FCToggleReactionResult> toggleReactionAsync(
      String postId, String reactionId) async {
    final pid = int.tryParse(postId);
    if (pid == null) {
      return FCToggleReactionResult(
          result: false, resultText: 'Invalid post id');
    }
    try {
      final response = await apiPut(
        '/discourse-reactions/posts/$pid/custom-reactions/'
        '${Uri.encodeComponent(reactionId)}/toggle.json',
      );
      // The plugin echoes the full updated post serializer; rebuild the
      // reaction list from that.
      final reactions = _parseReactions(response.cast<String, dynamic>());
      return FCToggleReactionResult(result: true, reactions: reactions);
    } on DiscourseApiException catch (e) {
      return FCToggleReactionResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCToggleReactionResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCAvailableReactionsResult> getAvailableReactionsAsync() async {
    try {
      final response = await apiGet('/discourse-reactions/custom-reactions');
      final reactions = ((response['reactions'] as List?) ?? const [])
          .whereType<String>()
          .toList(growable: false);
      if (reactions.isEmpty) {
        // Plugin returned an empty list — fall back so the picker still
        // works. Mark result:true since the fallback set is intentional.
        return FCAvailableReactionsResult(
            result: true, reactions: _defaultReactions);
      }
      return FCAvailableReactionsResult(result: true, reactions: reactions);
    } on DiscourseApiException catch (e) {
      // 404 means plugin isn't installed — degrade to the built-in set
      // so the picker stays usable.
      if (e.statusCode == 404) {
        return FCAvailableReactionsResult(
          result: true,
          reactions: _defaultReactions,
        );
      }
      return FCAvailableReactionsResult(
        result: false,
        resultText: e.userMessage,
        reactions: _defaultReactions,
      );
    } catch (e) {
      return FCAvailableReactionsResult(
        result: false,
        resultText: 'Error: $e',
        reactions: _defaultReactions,
      );
    }
  }

  // Stock discourse-reactions enabled set on a fresh install. Used as a
  // fallback so the picker shows something usable while the
  // /custom-reactions endpoint is unreachable.
  static const List<String> _defaultReactions = [
    'heart',
    '+1',
    'laughing',
    'open_mouth',
    'clap',
    'tada',
    'rocket',
    'eyes',
  ];

  @override
  Future<FCPostVoteResult> castPostVoteAsync(
    String postId,
    String direction, {
    FCPostVote? previous,
  }) async {
    final pid = int.tryParse(postId);
    if (pid == null) {
      return FCPostVoteResult(
          result: false, resultText: 'Invalid post id', vote: previous);
    }
    try {
      await apiPost('/vote.json', body: {
        'post_id': pid,
        'direction': direction,
      });
      // Plugin doesn't echo the new vote count; compute it from the
      // previous state plus the requested direction.
      return FCPostVoteResult(
        result: true,
        vote: _applyVoteCast(previous, direction),
      );
    } on DiscourseApiException catch (e) {
      return FCPostVoteResult(
          result: false, resultText: e.userMessage, vote: previous);
    } catch (e) {
      return FCPostVoteResult(
          result: false, resultText: 'Error: $e', vote: previous);
    }
  }

  @override
  Future<FCPostVoteResult> removePostVoteAsync(
    String postId, {
    FCPostVote? previous,
  }) async {
    final pid = int.tryParse(postId);
    if (pid == null) {
      return FCPostVoteResult(
          result: false, resultText: 'Invalid post id', vote: previous);
    }
    try {
      await apiDelete('/vote.json?post_id=$pid');
      return FCPostVoteResult(
        result: true,
        vote: _applyVoteRemove(previous),
      );
    } on DiscourseApiException catch (e) {
      return FCPostVoteResult(
          result: false, resultText: e.userMessage, vote: previous);
    } catch (e) {
      return FCPostVoteResult(
          result: false, resultText: 'Error: $e', vote: previous);
    }
  }

  FCPostVote _applyVoteCast(FCPostVote? prev, String direction) {
    final base = prev ?? FCPostVote();
    if (base.viewerDirection == direction) {
      // No-op: already voted that way. Caller's optimistic flip should
      // also have skipped, but be defensive.
      return base;
    }
    final int delta;
    if (base.viewerVoted) {
      // Switching sides — net swing is ±2.
      delta = direction == 'up' ? 2 : -2;
    } else {
      delta = direction == 'up' ? 1 : -1;
    }
    return FCPostVote(
      voteCount: base.voteCount + delta,
      hasVotes: true,
      viewerDirection: direction,
    );
  }

  FCPostVote _applyVoteRemove(FCPostVote? prev) {
    final base = prev ?? FCPostVote();
    if (!base.viewerVoted) return base;
    return FCPostVote(
      voteCount:
          base.voteCount + (base.viewerDirection == 'up' ? -1 : 1),
      hasVotes: base.voteCount.abs() > 1,
      viewerDirection: null,
    );
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
          // Prefer the plain `title`; fancy_title is entity-encoded
          // HTML, so flatten whichever we end up with (Phase 5.47).
          title: stripHtmlToText(
              (s['title'] ?? s['fancy_title'] ?? '').toString()),
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

  // ===== Helpers =====

  FCPost _postFrom(
    Map<String, dynamic> p, {
    required String topicId,
    bool topicCanAcceptAnswer = false,
  }) {
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

    // Phase 5.36 — reactions and Q&A votes now live as proper FCPost
    // fields (was an Expando sidecar). Empty list / null when the
    // plugin isn't installed.
    final reactions = _parseReactions(p);
    final FCPostVote? vote =
        (p.containsKey('post_voting_vote_count') ||
                p.containsKey('post_voting_has_votes') ||
                p.containsKey('post_voting_user_voted_direction'))
            ? _postVoteFromJson(p)
            : null;

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
      // Phase 5.31 — viewer can accept this post as the topic's
      // answer only when:
      //   1. The topic's `can_accept_answer` flag is true (the
      //      discourse-solved plugin grants this to the topic OP
      //      and staff).
      //   2. The post isn't the OP's first post — you can't mark
      //      the question itself as the answer.
      canAcceptAnswer: topicCanAcceptAnswer &&
          (p['post_number'] as int?) != 1,
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
      reactions: reactions,
      vote: vote,
    );
  }

  List<FCReaction> _parseReactions(Map<String, dynamic> p) {
    final raw = (p['reactions'] as List?) ?? const [];
    if (raw.isEmpty) return const [];
    final current =
        (p['current_user_reaction'] as Map?)?.cast<String, dynamic>();
    final viewerId = current?['id']?.toString();
    final canUndo = current?['can_undo'] == true;
    final out = <FCReaction>[];
    for (final raw in raw.whereType<Map>()) {
      final m = raw.cast<String, dynamic>();
      final id = (m['id'] ?? '').toString();
      final isViewer = viewerId != null && viewerId == id;
      final count = (m['count'] as num?)?.toInt() ?? 0;
      if (count <= 0) continue;
      out.add(FCReaction(
        id: id,
        type: (m['type'] ?? 'emoji').toString(),
        count: count,
        viewerReacted: isViewer,
        canUndo: isViewer ? canUndo : false,
      ));
    }
    return out;
  }

  FCPostVote _postVoteFromJson(Map<String, dynamic> p) {
    return FCPostVote(
      voteCount: (p['post_voting_vote_count'] as num?)?.toInt() ?? 0,
      hasVotes: p['post_voting_has_votes'] == true,
      viewerDirection: p['post_voting_user_voted_direction']?.toString(),
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
