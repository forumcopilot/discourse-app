import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_tag_proxy.dart';
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
      final list = (response['tags'] as List?) ?? const [];
      final tags = list
          .whereType<Map>()
          .map((t) => _tagFromDiscourseJson(t.cast<String, dynamic>()))
          .where((t) => includePmOnly || !t.pmOnly)
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
