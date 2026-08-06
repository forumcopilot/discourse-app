import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_tag_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_notification_level.dart';
import 'package:forumcopilot_sdk/models/entities/fc_tag.dart';
import 'package:forumcopilot_sdk/models/results/fc_tag_result.dart';
import 'package:forumcopilot_sdk/models/results/fc_topic_result.dart';

import '../base_discourse_proxy.dart';
import 'topic_proxy.dart';

/// Discourse implementation of [IFCTagProxy] (Phase 5.35 — lifted off
/// `DiscourseTopicProxy`).
///
/// Endpoints used:
///   * GET `/tags.json`                                  — full tag listing
///   * GET `/tags/filter/search.json?q=&limit=`          — autocomplete
///   * GET `/tag/{name}.json[?page=P]`                   — topics by tag
///   * GET `/tag/{name}/notifications.json`              — my watch level
///   * PUT `/tag/{name}/notifications.json`              — set watch level
///
/// The topics-by-tag query reuses [DiscourseTopicProxy.listTopicsByPathAsync]
/// so the user-resolution + category-name lookup logic stays in one place.
class DiscourseTagProxy extends BaseDiscourseProxy implements IFCTagProxy {
  DiscourseTagProxy(SiteContext context) : super(context);

  // Lazily instantiated; only needed for the topics-by-tag query.
  DiscourseTopicProxy? _topicProxy;
  DiscourseTopicProxy get _topicProxyOrCreate =>
      _topicProxy ??= DiscourseTopicProxy(siteContext);

  @override
  Future<FCTagListResult> getAllTagsAsync({
    bool includePmOnly = false,
  }) async {
    try {
      final response = await apiGet('/tags.json');
      // When `SiteSetting.tags_listed_by_group` is on, TagsController#index
      // (app/controllers/tags_controller.rb:53-77) puts only UNGROUPED
      // tags in `tags` and moves every grouped tag into
      // `extras.tag_groups[].tags`. Reading `tags` alone silently
      // returned a small subset of the forum's tags while calling itself
      // "all tags", so merge both sources and dedupe by name.
      final rows = <Map<String, dynamic>>[
        ...((response['tags'] as List?) ?? const []).whereType<Map>().map(
            (t) => t.cast<String, dynamic>()),
        ...(((response['extras'] as Map?)?['tag_groups'] as List?) ?? const [])
            .whereType<Map>()
            .expand((g) => ((g['tags'] as List?) ?? const []).whereType<Map>())
            .map((t) => t.cast<String, dynamic>()),
      ];
      final seen = <String>{};
      final tags = rows
          .map((t) => _tagFromDiscourseJson(t))
          .where((t) => includePmOnly || !t.pmOnly)
          .where((t) => t.name.isNotEmpty && seen.add(t.name.toLowerCase()))
          .toList();
      // Sort by topic count desc, then alphabetical for ties — matches
      // the Discourse web /tags page.
      tags.sort((a, b) {
        final byCount = b.count.compareTo(a.count);
        if (byCount != 0) return byCount;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      return FCTagListResult(
        result: true,
        // Exact: /tags.json is unpaginated, and with the tag_groups merge
        // above this really is every tag the viewer can see (minus the
        // pmOnly filter when [includePmOnly] is false).
        total: tags.length,
        items: tags,
      );
    } on DiscourseApiException catch (e) {
      return FCTagListResult(
        result: false,
        resultText: e.userMessage,
        total: 0,
        items: const [],
      );
    } catch (e) {
      return FCTagListResult(
        result: false,
        resultText: 'Error: $e',
        total: 0,
        items: const [],
      );
    }
  }

  @override
  Future<FCTagSearchResult> searchTagsAsync(
    String query, {
    int limit = 10,
  }) async {
    if (query.trim().isEmpty) {
      return FCTagSearchResult(result: true, names: const []);
    }
    try {
      final response = await apiGet('/tags/filter/search.json', query: {
        'q': query.trim(),
        'limit': limit.toString(),
      });
      final results = (response['results'] as List?) ?? const [];
      final names = results
          .whereType<Map>()
          .map((r) => r['name']?.toString() ?? '')
          .where((n) => n.isNotEmpty)
          .toList(growable: false);
      return FCTagSearchResult(result: true, names: names);
    } on DiscourseApiException catch (e) {
      return FCTagSearchResult(
        result: false,
        resultText: e.userMessage,
        names: const [],
      );
    } catch (e) {
      return FCTagSearchResult(
        result: false,
        resultText: 'Error: $e',
        names: const [],
      );
    }
  }

  @override
  Future<FCTopicDataResult> getTopicsByTagAsync(
    String tagName, {
    int page = 0,
  }) async {
    if (tagName.isEmpty) {
      return FCTopicDataResult(
        result: false,
        resultText: 'tag required',
        forumId: '',
        forumName: '',
        canPost: false,
        canUpload: false,
        unreadStickyCount: 0,
        unreadAnnounceCount: 0,
        canSubscribe: false,
        isSubscribed: false,
        requirePrefix: false,
        prefixes: const [],
        totalTopicNum: 0,
        topics: const [],
      );
    }
    return _topicProxyOrCreate.listTopicsByPathAsync(
      path: '/tag/${Uri.encodeComponent(tagName)}.json',
      page: page,
      forumName: '#$tagName',
    );
  }

  // ===== Discourse-native tag watching/muting =====
  //
  // Tags carry the same 0..4 `notification_level` scale as topics and
  // categories (muted 0, regular 1, tracking 2, watching 3,
  // watching_first_post 4) — already modelled by [FCNotificationLevel].
  // Both routes require login on the server.

  /// Discourse-only: the current user's notification level for
  /// [tagName] (`GET /tag/{name}/notifications.json`).
  ///
  /// Users without an explicit per-tag setting read as
  /// [FCNotificationLevel.normal] — the server's default.
  Future<DiscourseTagNotificationResult> getTagNotificationLevelAsync(
    String tagName,
  ) async {
    if (tagName.isEmpty) {
      return const DiscourseTagNotificationResult(
        result: false,
        resultText: 'tag required',
      );
    }
    if (!siteContext.isLoggedIn) {
      return const DiscourseTagNotificationResult(
        result: false,
        resultText: 'Not signed in',
      );
    }
    try {
      final response = await apiGet(
        '/tag/${Uri.encodeComponent(tagName)}/notifications.json',
      );
      final tn = (response['tag_notification'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      return DiscourseTagNotificationResult(
        result: true,
        level: FCNotificationLevel.fromInt(
          (tn['notification_level'] as num?)?.toInt(),
        ),
      );
    } on DiscourseApiException catch (e) {
      return DiscourseTagNotificationResult(
        result: false,
        resultText: e.userMessage,
      );
    } catch (e) {
      return DiscourseTagNotificationResult(
        result: false,
        resultText: 'Error: $e',
      );
    }
  }

  /// Discourse-only: watch/track/mute [tagName] for the current user
  /// (`PUT /tag/{name}/notifications.json`).
  ///
  /// The server reads the nested `tag_notification[notification_level]`
  /// param. Its response (the user's full tag-notification buckets) is
  /// ignored; on success the requested [level] is echoed back.
  Future<DiscourseTagNotificationResult> setTagNotificationLevelAsync(
    String tagName,
    FCNotificationLevel level,
  ) async {
    if (tagName.isEmpty) {
      return const DiscourseTagNotificationResult(
        result: false,
        resultText: 'tag required',
      );
    }
    if (!siteContext.isLoggedIn) {
      return const DiscourseTagNotificationResult(
        result: false,
        resultText: 'Not signed in',
      );
    }
    try {
      await apiPut(
        '/tag/${Uri.encodeComponent(tagName)}/notifications.json',
        body: {
          'tag_notification': {'notification_level': level.level},
        },
      );
      return DiscourseTagNotificationResult(result: true, level: level);
    } on DiscourseApiException catch (e) {
      return DiscourseTagNotificationResult(
        result: false,
        resultText: e.userMessage,
      );
    } catch (e) {
      return DiscourseTagNotificationResult(
        result: false,
        resultText: 'Error: $e',
      );
    }
  }

  FCTag _tagFromDiscourseJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return FCTag(
      id: rawId is num ? rawId.toInt() : null,
      name: (json['name'] ?? json['id'] ?? '').toString(),
      text: (json['text'] ?? json['name'] ?? '').toString(),
      count: (json['count'] as num?)?.toInt() ?? 0,
      description: json['description']?.toString(),
      pmOnly: json['pm_only'] == true,
    );
  }
}

/// Result of [DiscourseTagProxy.getTagNotificationLevelAsync] /
/// [DiscourseTagProxy.setTagNotificationLevelAsync].
///
/// [level] uses [FCNotificationLevel], whose integers map 1:1 to
/// Discourse's `TagUser.notification_levels`: muted 0, regular 1,
/// tracking 2, watching 3, watching-first-post 4. Only meaningful when
/// [result] is true (defaults to [FCNotificationLevel.normal]).
class DiscourseTagNotificationResult {
  final bool result;
  final String? resultText;
  final FCNotificationLevel level;

  const DiscourseTagNotificationResult({
    required this.result,
    this.resultText,
    this.level = FCNotificationLevel.normal,
  });
}
