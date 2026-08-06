import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_post_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_attachment.dart';
import 'package:forumcopilot_sdk/models/entities/fc_like.dart';
import 'package:forumcopilot_sdk/models/entities/fc_poll.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post_vote.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post_reaction.dart';
import 'package:forumcopilot_sdk/models/entities/fc_thanks.dart';
import 'package:forumcopilot_sdk/models/results/fc_post_result.dart';
import 'package:forumcopilot_sdk/models/results/fc_reaction_result.dart';

import '../base_discourse_proxy.dart';
import '../data/post/discourse_post_revision.dart';
import '../data/post/discourse_suggested_topic.dart';
import '../util/html_text.dart';

/// Discourse implementation of [IFCPostProxy].
///
/// Endpoints used:
///   * `/t/{id}.json`               — topic header + first chunk of posts
///   * `/t/{id}/{post_number}.json` — post-anchored window (chunk of posts
///                                    around that post number)
///   * `/posts/{id}.json`           — single post (with `raw` for edit)
///   * `/posts/{id}/raw`            — raw markdown
///   * POST `/posts.json`           — reply to a topic / new topic
///   * PUT  `/posts/{id}.json`      — edit a post
///   * POST `/post_actions`         — flag/report
///   * POST `/solution/accept|unaccept`      — discourse-solved plugin
///   * POST/DELETE `/post_voting/vote`       — discourse-post-voting plugin
///   * PUT/DELETE `/polls/vote`, GET `/polls/voters.json` — poll plugin
///   * GET  `/posts/{id}/revisions/latest|{rev}.json` — edit history
///   * PUT  `/posts/{id}/wiki`      — toggle wiki status
///   * GET  `/discourse-reactions/posts/{id}/reactions-users-list.json`
///                                  — reaction/like actors (plugin), with
///                                    GET `/post_action_users.json` as the
///                                    plugin-less fallback
class DiscoursePostProxy extends BaseDiscourseProxy implements IFCPostProxy {
  DiscoursePostProxy(SiteContext context) : super(context);

  /// Windowed topic fetch.
  ///
  /// When [startNum] <= 1 this fetches `/t/{id}.json` (topic header + the
  /// first chunk of posts, Discourse default chunk size 20). When
  /// [startNum] > 1 it fetches `/t/{id}/{startNum}.json`, which the server
  /// resolves via `TopicView#filter_posts_near`: a window of `chunk_size`
  /// posts with roughly a quarter of the chunk *before* the anchor post
  /// number and the rest at/after it.
  ///
  /// CONTRACT with the UI layer (post_controller.dart):
  ///   * The returned window is NOT page-aligned. The UI must derive the
  ///     actually-loaded window from the returned posts' [FCPost.postNumber]
  ///     values and dedupe merges by [FCPost.id] — both are always populated
  ///     here from the Discourse payload.
  ///   * [FCThreadResult.totalPostNum] carries the topic's
  ///     `highest_post_number` (falling back to `posts_count`) so the UI can
  ///     compute hasMore in both directions from post numbers. Note post
  ///     numbers are not gap-free when posts have been deleted, which is why
  ///     `highest_post_number` is preferred over `posts_count`.
  ///   * [lastNum] is advisory only; the server decides the window size.
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
      final t = await apiGet(
          startNum > 1 ? '/t/$topicId/$startNum.json' : '/t/$topicId.json');
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
        totalPostNum: (t['highest_post_number'] as int?) ??
            (t['posts_count'] as int?) ??
            posts.length,
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
        // notification_level lives under `details` in the topic-view
        // serializer; keep a top-level fallback for other payload shapes.
        isSubscribed: ((details['notification_level'] as int?) ??
                (t['notification_level'] as int?) ??
                1) >=
            2,
        canReply: !(t['closed'] == true || t['archived'] == true),
        // Optimistic, with no per-topic signal in the payload: the topic
        // view serializer's `details` has can_edit/can_delete/etc. for
        // MODERATION, but nothing for flag/upload/like at topic level
        // (like state is per-POST, in each post's actions_summary — see
        // _postFrom, which reads the real flags). The server enforces
        // these regardless; a 403 surfaces as a normal failure result.
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
      return _emptyThread(message: describeApiError(e));
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
      // Same windowing mechanism as [getThreadAsync]: /t/{id}/{n}.json
      // returns the chunk containing post number n (filter_posts_near).
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
        totalPostNum: (t['highest_post_number'] as int?) ??
            (t['posts_count'] as int?) ??
            posts.length,
        posts: posts,
        // The anchor post's number; it is contained in the returned
        // window (filter_posts_near centers the chunk on it).
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
        // Optimistic — see the sibling mapper above; no per-topic
        // flag/upload signal exists in this payload.
        canReport: true,
        canUpload: true,
        poll: poll,
      );
    } catch (e) {
      return _emptyThreadByPost(message: describeApiError(e));
    }
  }

  @override
  Future<FCThreadByUnreadResult> getThreadByUnreadAsync(
    String topicId,
    int postsPerRequest,
    bool returnHtml,
  ) async {
    // Use the topic's `last_read_post_number` (present when authed) as the
    // anchor. The plain /t/{id}.json only carries the *first* chunk of
    // posts, so when the anchor falls outside it we re-fetch
    // /t/{id}/{anchor}.json, which returns the chunk containing the anchor
    // (filter_posts_near) — same windowing mechanism as [getThreadAsync].
    if (topicId.isEmpty) {
      return _emptyThreadByUnread(message: 'topicId required');
    }
    try {
      var t = await apiGet('/t/$topicId.json');
      final unreadAnchor = (t['last_read_post_number'] as int?) ?? 1;
      var stream = (t['post_stream'] as Map<String, dynamic>?) ?? const {};
      var rawPosts = ((stream['posts'] as List?) ?? const [])
          .whereType<Map>()
          .map((m) => m.cast<String, dynamic>())
          .toList();
      final anchorLoaded = unreadAnchor <= 1 ||
          rawPosts.any((p) => (p['post_number'] as int?) == unreadAnchor);
      if (!anchorLoaded) {
        t = await apiGet('/t/$topicId/$unreadAnchor.json');
        stream = (t['post_stream'] as Map<String, dynamic>?) ?? const {};
        rawPosts = ((stream['posts'] as List?) ?? const [])
            .whereType<Map>()
            .map((m) => m.cast<String, dynamic>())
            .toList();
      }
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

      return FCThreadByUnreadResult(
        result: true,
        resultText: '',
        totalPostNum: (t['highest_post_number'] as int?) ??
            (t['posts_count'] as int?) ??
            posts.length,
        posts: posts,
        // The returned window covers the anchor: either it was already in
        // the first chunk, or we re-fetched the chunk around it above. (If
        // the anchor post was deleted, filter_posts_near still returns the
        // posts nearest to it; the UI derives the real window from the
        // returned postNumbers.)
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
        // Optimistic — see the sibling mapper above; no per-topic
        // flag/upload signal exists in this payload.
        canReport: true,
        canUpload: true,
        poll: poll,
      );
    } catch (e) {
      return _emptyThreadByUnread(message: describeApiError(e));
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
      return FCReplyPostResult(result: false, resultText: describeApiError(e));
    }
  }

  /// Discourse-only: reply to a topic as a staff **whisper** — a post only
  /// staff (and the whisper-allowed groups) can see.
  ///
  /// Same create path as [replyPostAsync] but with `whisper: "true"`, which
  /// posts_controller boolean-casts and turns into
  /// `post_type = Post.types[:whisper]` after a `guardian.can_create_whisper?`
  /// check. Non-staff callers get a 403 `invalid_whisper_access`, surfaced
  /// here as `result: false` with the server's message.
  Future<FCReplyPostResult> replyWhisperAsync(
    String topicId,
    String textBody, {
    List<String>? attachmentIds,
    bool returnHtml = true,
  }) async {
    try {
      final rawWithAttachments =
          appendAttachmentMarkdown(textBody, attachmentIds);
      final response = await apiPost('/posts.json', body: {
        'topic_id': int.tryParse(topicId) ?? topicId,
        'raw': rawWithAttachments,
        'archetype': 'regular',
        'whisper': 'true',
      });
      return FCReplyPostResult(
        result: true,
        resultText: '',
        postId: (response['id'] ?? '').toString(),
        state: 0,
        postContent: returnHtml
            ? response['cooked']?.toString()
            : response['raw']?.toString(),
        canEdit: response['can_edit'] == true,
        canDelete: response['can_delete'] == true,
      );
    } on DiscourseApiException catch (e) {
      return FCReplyPostResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCReplyPostResult(result: false, resultText: describeApiError(e));
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
      return FCQuotePostResult(result: false, resultText: describeApiError(e));
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
      return FCRawPostResult(result: false, resultText: describeApiError(e));
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
      return FCSaveRawPostResult(result: false, resultText: describeApiError(e));
    }
  }

  @override
  Future<FCReportPostResult> reportPostAsync(
      String postId, String reason) async {
    try {
      // post_action_type_id 7 = notify_moderators ("It's something else")
      // with a free-form `message` (permitted by post_actions_controller
      // for flag types). If empty, we use 4 = inappropriate.
      // (See db/fixtures/003_post_action_types.rb; 8 is spam.)
      final actionTypeId = reason.trim().isEmpty ? 4 : 7;
      await apiPost('/post_actions.json', body: {
        'id': int.tryParse(postId) ?? postId,
        'post_action_type_id': actionTypeId,
        if (reason.trim().isNotEmpty) 'message': reason,
      });
      return FCReportPostResult(result: true, resultText: '');
    } catch (e) {
      return FCReportPostResult(result: false, resultText: describeApiError(e));
    }
  }

  @override
  Future<FCAcceptAnswerResult> acceptAnswerAsync(String postId) async {
    // Phase 5.31 — discourse-solved plugin endpoint (engine mounted at
    // /solution):
    //   POST /solution/accept { id: <post_id> }
    // Marks the post as the accepted answer for its topic and bumps
    // the topic's "solved" state. The FCPost.canAcceptAnswer cap comes
    // from the plugin's per-post `can_accept_answer` serializer field.
    if (postId.isEmpty) {
      return FCAcceptAnswerResult(
        result: false,
        resultText: 'No post id supplied',
      );
    }
    try {
      await apiPost('/solution/accept', body: {
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
      return FCAcceptAnswerResult(result: false, resultText: describeApiError(e));
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
      await apiPost('/solution/unaccept', body: {
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
      return FCAcceptAnswerResult(result: false, resultText: describeApiError(e));
    }
  }

  @override
  Future<FCPoll?> votePollAsync(
      String topicId, List<String> responseIds) async {
    // Discourse poll vote: PUT /polls/vote { post_id, poll_name, options[] }.
    // Every parsed FCPoll carries its hosting post's id ([FCPoll.postId])
    // and the poll's name ([FCPoll.pollId]); the caller hands us back
    // option ids (poll-option digests), so we resolve the poll from the
    // recently-parsed list and vote without refetching the topic. When
    // the poll instance isn't known (cold cache) we fall back to fetching
    // /t/{id}.json to find the first post.
    if (responseIds.isEmpty) return null;
    int? postId;
    String pollName = 'poll';
    final poll = _lookupPollByResponseId(responseIds.first);
    if (poll != null && poll.postId != null) {
      postId = int.tryParse(poll.postId!);
      pollName = poll.pollId;
    }
    if (postId == null) {
      final fallback = await _findFirstPostId(topicId);
      if (fallback == null) return null;
      postId = fallback;
    }
    try {
      final response = await apiPut('/polls/vote', body: {
        'post_id': postId,
        'poll_name': pollName,
        'options': responseIds,
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

  /// Discourse-only: retract the current user's vote(s) in a poll.
  ///
  /// DELETE `/polls/vote` with `post_id` + `poll_name` (the poll plugin's
  /// polls_controller#remove_vote requires exactly those two params). The
  /// server echoes the updated poll (`{ poll: ... }`), returned here as a
  /// re-parsed [FCPoll] with the viewer's votes cleared — or null on any
  /// failure (closed poll, not voted, plugin missing).
  ///
  /// [topicId] is only carried onto the returned [FCPoll]; pass it when you
  /// have it so the poll keeps its identity for the UI.
  Future<FCPoll?> removePollVoteAsync(
    int postId,
    String pollName, {
    String? topicId,
  }) async {
    try {
      // Like removePostVoteAsync: the controller reads params, so send
      // them as query parameters on the DELETE.
      final response = await apiDelete('/polls/vote', query: {
        'post_id': postId,
        'poll_name': pollName,
      });
      final pollJson = (response['poll'] as Map?)?.cast<String, dynamic>();
      if (pollJson == null) return null;
      return _pollFromJson(
        pollJson,
        topicId: topicId ?? '',
        postId: postId,
        viewerVotes: const [],
      );
    } catch (_) {
      return null;
    }
  }

  /// Discourse-only: list who voted for what in a **public** poll.
  ///
  /// GET `/polls/voters.json` with `post_id` + `poll_name` and optional
  /// `option_id` (a poll-option digest) + `page` (25 voters per option per
  /// page). Only works when the poll was created with `public=true`
  /// (`Poll#can_see_voters?`) — otherwise the server replies 400, surfaced
  /// as `result: false`.
  ///
  /// The response groups voters by option digest
  /// (`voters[option_id] = [user...]`); number-type polls return one flat
  /// list instead, which lands under the `''` key here.
  Future<DiscoursePollVotersResult> getPollVotersAsync(
    int postId,
    String pollName, {
    String? optionId,
    int page = 1,
  }) async {
    try {
      final response = await apiGet('/polls/voters.json', query: {
        'post_id': postId,
        'poll_name': pollName,
        if (optionId != null && optionId.isNotEmpty) 'option_id': optionId,
        'page': page,
      });
      final voters = response['voters'];
      final byOption = <String, List<DiscoursePollVoter>>{};
      if (voters is Map) {
        voters.forEach((key, value) {
          byOption[key.toString()] = _parsePollVoters(value);
        });
      } else if (voters is List) {
        byOption[''] = _parsePollVoters(voters);
      }
      return DiscoursePollVotersResult(
        result: true,
        resultText: '',
        votersByOption: byOption,
      );
    } on DiscourseApiException catch (e) {
      return DiscoursePollVotersResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return DiscoursePollVotersResult(result: false, resultText: describeApiError(e));
    }
  }

  List<DiscoursePollVoter> _parsePollVoters(Object? raw) {
    return ((raw is List ? raw : const [])
        .whereType<Map>()
        .map((m) {
      final entry = m.cast<String, dynamic>();
      // Ranked-choice polls nest the user under `user` (with a `rank`);
      // regular/multiple polls inline the user fields directly.
      final user =
          (entry['user'] as Map?)?.cast<String, dynamic>() ?? entry;
      return DiscoursePollVoter(
        username: (user['username'] ?? '').toString(),
        name: user['name']?.toString(),
        avatarTemplate: user['avatar_template']?.toString(),
      );
    }).toList());
  }

  /// Reverse-lookup helper: scans recently-parsed polls for one whose
  /// option list contains [responseId], so [votePollAsync] (whose SDK
  /// contract only carries topic id + option ids) can read the hosting
  /// post id and poll name off the [FCPoll] itself.
  static final List<_RecentPoll> _recentPolls = [];

  FCPoll? _lookupPollByResponseId(String responseId) {
    for (final entry in _recentPolls) {
      for (final opt in entry.poll.responses) {
        if (opt.id == responseId) {
          return entry.poll;
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

  /// Build an FCPoll from a Discourse poll object (`p['polls'][0]`).
  /// The hosting post's id lands on [FCPoll.postId] (and the poll's
  /// name on [FCPoll.pollId]) so vote/voters calls can be made without
  /// refetching the topic.
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
      postId: postId.toString(),
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
      return FCToggleReactionResult(result: false, resultText: describeApiError(e));
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
        resultText: describeApiError(e),
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

  /// Discourse-native: the people behind a post's reaction/like counts,
  /// paged. **Not** on [IFCPostProxy] — the SDK's XenForo-shaped contract
  /// ships actors inline with the post; Discourse never does, so the list
  /// is fetched on demand when the user opens the reactions sheet.
  ///
  /// Primary source, discourse-reactions:
  /// `GET /discourse-reactions/posts/{id}/reactions-users-list.json`
  /// (plugin `config/routes.rb:17-19` → `custom_reactions#reactions_users_list`,
  /// `app/controllers/discourse_reactions/custom_reactions_controller.rb:166-192`).
  ///   * `reaction_value` — emoji shortcode; OMIT it for "everyone", which
  ///     unions reaction rows with plain likes
  ///     (`lib/post_reactions_query.rb:38-63`).
  ///   * `page` — 0-based, server does `.to_i.clamp(0..)`.
  ///   * `limit` — server clamps to 1..50, defaulting to 30.
  /// Response: `{ users: [{id, username, name, avatar_template, reaction}],
  /// total_rows: n }`. The rows carry no timestamp (the controller drops
  /// the query's `created_at`), so [FCLike.timestamp] stays null; `reaction`
  /// lands in [FCLike.reactionEmoji]. The endpoint is readable while
  /// logged out (`before_action :ensure_logged_in, except: ...:166`).
  ///
  /// Fallback when the plugin is absent/disabled (both 404 — the route is
  /// unmounted, or `requires_plugin` rejects it): stock
  /// `GET /post_action_users.json?id={postId}&post_action_type_id=2`
  /// (`config/routes.rb:1333` →
  /// `app/controllers/post_action_users_controller.rb:6-54`), which pages
  /// with `page` + `limit` (max 200) and returns
  /// `{ post_action_users: [...], total_rows_post_action_users: n }`
  /// serialized by `PostActionUserSerializer` (id/username/avatar_template
  /// — no reaction, no timestamp). `total_rows_post_action_users` is only
  /// emitted when the total EXCEEDS the page size (:51), so we fall back to
  /// the row count.
  ///
  /// Never throws: failures come back as `result: false` with the server's
  /// message and an empty user list.
  Future<FCReactionUsersResult> getReactionUsersAsync(
    String postId, {
    String? reactionId,
    int page = 0,
    int limit = 30,
  }) async {
    final pid = int.tryParse(postId);
    if (pid == null) {
      return FCReactionUsersResult(
        result: false,
        resultText: 'Invalid post id',
        users: <FCLike>[],
      );
    }
    final safePage = page < 0 ? 0 : page;
    final safeLimit = limit.clamp(1, 50);

    try {
      final query = <String, dynamic>{
        'page': safePage,
        'limit': safeLimit,
      };
      if (reactionId != null && reactionId.isNotEmpty) {
        query['reaction_value'] = reactionId;
      }
      final response = await apiGet(
        '/discourse-reactions/posts/$pid/reactions-users-list.json',
        query: query,
      );
      final users = ((response['users'] as List?) ?? const [])
          .whereType<Map>()
          .map((u) => _likeFromReactionRow(u.cast<String, dynamic>()))
          .toList();
      return FCReactionUsersResult(
        result: true,
        users: users,
        total: (response['total_rows'] as num?)?.toInt() ?? users.length,
      );
    } on DiscourseApiException catch (e) {
      if (e.statusCode == 404) {
        return _postActionLikeUsers(pid, page: safePage, limit: safeLimit);
      }
      return FCReactionUsersResult(
        result: false,
        resultText: e.userMessage,
        users: <FCLike>[],
      );
    } catch (e) {
      return FCReactionUsersResult(
        result: false,
        resultText: describeApiError(e),
        users: <FCLike>[],
      );
    }
  }

  /// Plugin-less fallback for [getReactionUsersAsync] — stock Discourse's
  /// like actors (`post_action_type_id: 2`).
  Future<FCReactionUsersResult> _postActionLikeUsers(
    int postId, {
    required int page,
    required int limit,
  }) async {
    try {
      final response = await apiGet('/post_action_users.json', query: {
        'id': postId,
        'post_action_type_id': 2,
        'page': page,
        'limit': limit,
      });
      final users = ((response['post_action_users'] as List?) ?? const [])
          .whereType<Map>()
          .map((u) => _likeFromReactionRow(u.cast<String, dynamic>()))
          .toList();
      return FCReactionUsersResult(
        result: true,
        users: users,
        total: (response['total_rows_post_action_users'] as num?)?.toInt() ??
            (page * limit + users.length),
      );
    } on DiscourseApiException catch (e) {
      return FCReactionUsersResult(
        result: false,
        resultText: e.userMessage,
        users: <FCLike>[],
      );
    } catch (e) {
      return FCReactionUsersResult(
        result: false,
        resultText: describeApiError(e),
        users: <FCLike>[],
      );
    }
  }

  /// Map one actor row (either endpoint) to [FCLike]. `reaction` is only
  /// present on the discourse-reactions payload.
  FCLike _likeFromReactionRow(Map<String, dynamic> u) {
    final reaction = u['reaction']?.toString();
    return FCLike(
      userId: (u['id'] ?? '').toString(),
      username: (u['username'] ?? '').toString(),
      avatarUrl: _avatarFromTemplate(u['avatar_template'] as String?) ?? '',
      // Discourse identifies reactions by emoji shortcode ('heart',
      // 'laughing', …) — the same token toggleReactionAsync consumes.
      reactionEmoji: (reaction != null && reaction.isNotEmpty) ? reaction : null,
    );
  }

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
      // discourse-post-voting engine is mounted at /post_voting with
      // `resource :vote` → POST /post_voting/vote.
      await apiPost('/post_voting/vote.json', body: {
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
          result: false, resultText: describeApiError(e), vote: previous);
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
      // DELETE /post_voting/vote — the controller reads `post_id` from
      // params, so pass it as a proper query parameter.
      await apiDelete('/post_voting/vote.json', query: {'post_id': pid});
      return FCPostVoteResult(
        result: true,
        vote: _applyVoteRemove(previous),
      );
    } on DiscourseApiException catch (e) {
      return FCPostVoteResult(
          result: false, resultText: e.userMessage, vote: previous);
    } catch (e) {
      return FCPostVoteResult(
          result: false, resultText: describeApiError(e), vote: previous);
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
          // The "last poster" entry is flagged locale-independently via
          // `extras` containing 'latest' ("latest" or "latest single",
          // see TopicPostersSummary). The localized description string
          // is only a fallback.
          final extras = (p['extras'] ?? '').toString();
          final desc = (p['description'] ?? '').toString();
          if (extras.contains('latest') ||
              desc.contains('Most Recent Poster')) {
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

  /// Discourse-only: fetch one revision of a post's edit history.
  ///
  /// GET `/posts/{id}/revisions/latest.json` when [revision] is null,
  /// otherwise `/posts/{id}/revisions/{revision}.json`. Discourse numbers
  /// revisions from 2 (revision N = diff between version N-1 and N), so
  /// the server rejects [revision] < 2 — we short-circuit that client-side.
  ///
  /// Visibility: the server only shows edit history to everyone when
  /// `SiteSetting.edit_history_visible_to_public` is on or the post is a
  /// wiki; otherwise it's the author + staff (`can_view_edit_history?`).
  /// A 403 comes back as a clean `result: false`; a 404 usually means the
  /// post has never been edited (no PostRevision rows).
  Future<DiscoursePostRevisionResult> getPostRevisionAsync(
    int postId, {
    int? revision,
  }) async {
    if (revision != null && revision < 2) {
      return DiscoursePostRevisionResult(
        result: false,
        resultText: 'Revision numbers start at 2.',
      );
    }
    try {
      final path = revision == null
          ? '/posts/$postId/revisions/latest.json'
          : '/posts/$postId/revisions/$revision.json';
      final r = await apiGet(path);
      final body = (r['body_changes'] as Map?)?.cast<String, dynamic>();
      final title = (r['title_changes'] as Map?)?.cast<String, dynamic>();
      return DiscoursePostRevisionResult(
        result: true,
        resultText: '',
        revision: DiscoursePostRevision(
          postId: (r['post_id'] as num?)?.toInt() ?? postId,
          currentRevision: (r['current_revision'] as num?)?.toInt() ?? 0,
          firstRevision: (r['first_revision'] as num?)?.toInt() ?? 0,
          lastRevision: (r['last_revision'] as num?)?.toInt() ?? 0,
          previousRevision: (r['previous_revision'] as num?)?.toInt(),
          nextRevision: (r['next_revision'] as num?)?.toInt(),
          currentVersion: (r['current_version'] as num?)?.toInt() ?? 0,
          versionCount: (r['version_count'] as num?)?.toInt() ?? 0,
          username: (r['username'] ?? '').toString(),
          displayUsername: r['display_username']?.toString(),
          avatarTemplate: r['avatar_template']?.toString(),
          createdAt: DateTime.tryParse(r['created_at']?.toString() ?? ''),
          editReason: r['edit_reason']?.toString(),
          bodyInlineHtml: body?['inline']?.toString(),
          bodySideBySideHtml: body?['side_by_side']?.toString(),
          bodySideBySideMarkdown: body?['side_by_side_markdown']?.toString(),
          titleInlineHtml: title?['inline']?.toString(),
          titleSideBySideHtml: title?['side_by_side']?.toString(),
          diffError: r['diff_error'] == true,
          canEdit: r['can_edit'] == true,
        ),
      );
    } on DiscourseApiException catch (e) {
      if (e.statusCode == 403) {
        return DiscoursePostRevisionResult(
          result: false,
          resultText: 'Edit history is not visible for this post.',
        );
      }
      if (e.statusCode == 404) {
        return DiscoursePostRevisionResult(
          result: false,
          resultText: 'This post has no edit history.',
        );
      }
      return DiscoursePostRevisionResult(
          result: false, resultText: e.userMessage);
    } catch (e) {
      return DiscoursePostRevisionResult(
          result: false, resultText: describeApiError(e));
    }
  }

  /// Discourse-only: toggle a post's **wiki** status (community-editable).
  ///
  /// PUT `/posts/{id}/wiki` with a required `wiki` param; the server runs
  /// `guardian.ensure_can_wiki!` (author at TL3+ or staff) and revises the
  /// post. Success is an empty 200 body.
  Future<DiscourseSetWikiResult> setWikiAsync(int postId, bool wiki) async {
    try {
      await apiPut('/posts/$postId/wiki.json', body: {'wiki': wiki});
      return DiscourseSetWikiResult(result: true, resultText: '');
    } on DiscourseApiException catch (e) {
      return DiscourseSetWikiResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return DiscourseSetWikiResult(result: false, resultText: describeApiError(e));
    }
  }

  // ===== Helpers =====

  FCPost _postFrom(
    Map<String, dynamic> p, {
    required String topicId,
  }) {
    final avatarUrl = _avatarFromTemplate(p['avatar_template'] as String?);
    final like = _likeSummary(p);
    final isLiked = like.isLiked;
    final canLike = like.canLike;
    final likeCount = like.count;

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
      // Phase 5.31 — discourse-solved serializes `can_accept_answer`
      // per POST (plugin.rb add_to_serializer(:post, ...)). The server
      // guardian already excludes the first post and whispers, so the
      // field can be trusted as-is.
      canAcceptAnswer: p['can_accept_answer'] == true,
      // `version` (post_serializer.rb) is the post's public revision
      // count — 1 for never-edited posts, bumped on each ninja-window-
      // exceeding edit. Drives the "edited" indicator + edit-history
      // gating in the UI.
      editVersion: (p['version'] as num?)?.toInt(),
      isWiki: p['wiki'] == true,
      // Discourse's `actions_summary` carries a COUNT and an acted flag,
      // never the actors. The count now lives in its own field and the
      // actor list is fetched on demand via [getReactionUsersAsync] when
      // the user opens the likes/reactions sheet — we no longer fabricate
      // blank FCLike placeholders just to make `likesInfo.length` read
      // correctly (that produced blank avatars and dead-end profiles).
      likeCount: likeCount,
      // Mutable (growable) empty lists: optimistic-UI code in
      // post_actions.dart calls `.add()` / `.removeWhere()` on these, and
      // FCPost defaults them to `const []`.
      likesInfo: <FCLike>[],
      attachments: <FCAttachment>[],
      inlineAttachments: <FCAttachment>[],
      thanksInfo: <FCThanks>[],
      reactions: reactions,
      vote: vote,
    );
  }

  /// Resolve an `avatar_template` into an absolute avatar URL.
  ///
  /// Discourse serializes `/user_avatar/.../{size}/123_2.png` (relative on
  /// most installs, absolute when a CDN is configured).
  String? _avatarFromTemplate(String? tpl) {
    if (tpl == null || tpl.isEmpty) return null;
    final filled = tpl.replaceAll('{size}', '90');
    return filled.startsWith('http') ? filled : '${siteContext.site.url}$filled';
  }

  /// The `actions_summary` row for the like action
  /// (`PostActionType::LIKE_POST_ACTION_ID == 2`).
  ///
  /// `count` is dropped by the serializer when zero, `can_act` is absent
  /// once the viewer has acted, and `can_undo` only appears while the
  /// undo window is open (post_serializer.rb:331-393).
  ({bool isLiked, bool canLike, bool canUndo, int count}) _likeSummary(
      Map<String, dynamic> p) {
    final actions = (p['actions_summary'] as List?) ?? const [];
    final like = actions.whereType<Map>().firstWhere(
          (a) => a['id'] == 2,
          orElse: () => <String, dynamic>{},
        );
    return (
      isLiked: like['acted'] == true,
      canLike: like['can_act'] == true,
      canUndo: like['can_undo'] == true,
      count: (like['count'] as num?)?.toInt() ?? 0,
    );
  }

  /// Build the emoji-chip row for a post.
  ///
  /// With discourse-reactions installed the serializer emits `reactions`
  /// and folds plain likes into its `heart` entry — so the chips are the
  /// complete picture and `actions_summary[id==2].count` is already
  /// counted there.
  ///
  /// WITHOUT the plugin there is no `reactions` key at all. We synthesize
  /// a single `heart` chip from the like count so the chips row is the
  /// one and only like/reaction surface on BOTH server configurations.
  /// Note the synthetic chip must be toggled through the like path
  /// (`POST/DELETE /post_actions`), not `toggleReactionAsync` — the
  /// plugin's toggle route does not exist on these forums.
  List<FCPostReaction> _parseReactions(Map<String, dynamic> p) {
    if (!p.containsKey('reactions')) {
      final like = _likeSummary(p);
      if (like.count <= 0) return const [];
      return [
        FCPostReaction(
          // `heart` is discourse-reactions' default main reaction id
          // (SiteSetting.discourse_reactions_reaction_for_like,
          // settings.yml:9-13) — using it keeps the chip identity
          // stable across the two server configurations.
          id: 'heart',
          type: 'emoji',
          count: like.count,
          viewerReacted: like.isLiked,
          canUndo: like.isLiked && like.canUndo,
        ),
      ];
    }
    final raw = (p['reactions'] as List?) ?? const [];
    if (raw.isEmpty) return const [];
    final current =
        (p['current_user_reaction'] as Map?)?.cast<String, dynamic>();
    final viewerId = current?['id']?.toString();
    final canUndo = current?['can_undo'] == true;
    final out = <FCPostReaction>[];
    for (final raw in raw.whereType<Map>()) {
      final m = raw.cast<String, dynamic>();
      final id = (m['id'] ?? '').toString();
      final isViewer = viewerId != null && viewerId == id;
      final count = (m['count'] as num?)?.toInt() ?? 0;
      if (count <= 0) continue;
      out.add(FCPostReaction(
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

  /// Sentinel timestamp for failed/empty results (see [_emptyThread]).
  static final DateTime _noTimestamp =
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

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
      // Sentinel on a `result: false` object — there is no thread and
      // therefore no timestamp. Epoch rather than DateTime.now(), which
      // read as a real "just now" thread if anything rendered it.
      timestamp: _noTimestamp,
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
      // Sentinel on a `result: false` object — there is no thread and
      // therefore no timestamp. Epoch rather than DateTime.now(), which
      // read as a real "just now" thread if anything rendered it.
      timestamp: _noTimestamp,
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
      // Sentinel on a `result: false` object — there is no thread and
      // therefore no timestamp. Epoch rather than DateTime.now(), which
      // read as a real "just now" thread if anything rendered it.
      timestamp: _noTimestamp,
    );
  }
}

/// One voter row from `/polls/voters.json` (Discourse's
/// `UserNameSerializer`: id, username, name, avatar_template — we keep
/// the display-relevant trio).
class DiscoursePollVoter {
  final String username;

  /// Full name; null when the site has `enable_names` off or the user
  /// hasn't set one.
  final String? name;

  /// Avatar template with a `{size}` placeholder.
  final String? avatarTemplate;

  const DiscoursePollVoter({
    required this.username,
    this.name,
    this.avatarTemplate,
  });
}

/// Result of [DiscoursePostProxy.getPollVotersAsync]. Voters are grouped
/// by option digest ([FCPollResponse.id]); number-type polls return a
/// single ungrouped list, stored under the `''` key.
class DiscoursePollVotersResult {
  final bool result;
  final String resultText;
  final Map<String, List<DiscoursePollVoter>> votersByOption;

  const DiscoursePollVotersResult({
    required this.result,
    required this.resultText,
    this.votersByOption = const {},
  });
}

/// Result of [DiscoursePostProxy.getPostRevisionAsync].
class DiscoursePostRevisionResult {
  final bool result;
  final String resultText;
  final DiscoursePostRevision? revision;

  const DiscoursePostRevisionResult({
    required this.result,
    required this.resultText,
    this.revision,
  });
}

/// Result of [DiscoursePostProxy.setWikiAsync] — no payload, the server
/// replies with an empty body on success.
class DiscourseSetWikiResult {
  final bool result;
  final String resultText;

  const DiscourseSetWikiResult({
    required this.result,
    required this.resultText,
  });
}

/// Holds a strong reference to a recently-parsed poll so
/// [DiscoursePostProxy._lookupPollByResponseId] can resolve an option
/// digest back to its poll during a vote round-trip. Ring-buffer cap
/// at 20.
class _RecentPoll {
  final FCPoll poll;
  _RecentPoll(this.poll);
}
