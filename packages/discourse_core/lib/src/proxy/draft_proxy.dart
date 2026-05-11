import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_draft_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_draft.dart';
import 'package:forumcopilot_sdk/models/results/fc_draft_result.dart';

import '../base_discourse_proxy.dart';

/// Discourse implementation of [IFCDraftProxy] (Phase 5.34 — lifted
/// off `DiscoursePostProxy`).
///
/// Discourse stores the inner draft payload as a JSON-encoded string;
/// this proxy is the only place that detail lives, so callers exchange
/// plain `Map<String, dynamic>` blobs.
///
/// Endpoints used:
///   * POST   `/drafts.json`             — save / upsert
///   * GET    `/drafts/{key}.json`       — fetch a single draft
///   * DELETE `/drafts/{key}.json?sequence=N` — discard
///   * GET    `/drafts.json[?page=P]`    — list current user's drafts
class DiscourseDraftProxy extends BaseDiscourseProxy implements IFCDraftProxy {
  DiscourseDraftProxy(SiteContext context) : super(context);

  @override
  Future<FCSaveDraftResult> saveDraftAsync({
    required String draftKey,
    required Map<String, dynamic> data,
    int sequence = 0,
  }) async {
    if (!siteContext.isLoggedIn) {
      return FCSaveDraftResult(result: false, resultText: 'Not signed in');
    }
    try {
      // Discourse expects the data field as a JSON-encoded *string*, not
      // a nested object — the server stores it raw and re-parses on read.
      // Empty drafts are deleted by the server, so callers should pass a
      // non-empty `reply` to actually persist.
      final response = await apiPost('/drafts.json', body: {
        'draft_key': draftKey,
        'sequence': sequence,
        'data': jsonEncode(data),
      });
      final newSequence = (response['draft_sequence'] as num?)?.toInt();
      return FCSaveDraftResult(result: true, sequence: newSequence);
    } on DiscourseApiException catch (e) {
      return FCSaveDraftResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCSaveDraftResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCLoadDraftResult> loadDraftAsync(String draftKey) async {
    if (!siteContext.isLoggedIn) {
      return FCLoadDraftResult(result: false, resultText: 'Not signed in');
    }
    try {
      final response =
          await apiGet('/drafts/${Uri.encodeComponent(draftKey)}.json');
      // Shape: { draft: "<json string>", draft_sequence: N }
      // Older versions sometimes return `draft` as a parsed map directly.
      final rawDraft = response['draft'];
      final seq = (response['draft_sequence'] as num?)?.toInt() ?? 0;
      Map<String, dynamic>? data;
      if (rawDraft is Map) {
        data = rawDraft.cast<String, dynamic>();
      } else if (rawDraft is String && rawDraft.isNotEmpty) {
        try {
          final decoded = jsonDecode(rawDraft);
          if (decoded is Map) data = decoded.cast<String, dynamic>();
        } catch (_) {
          // not JSON — fall through to null.
        }
      }
      if (data == null) {
        return FCLoadDraftResult(result: true);
      }
      final draft = FCDraft(
        draftKey: draftKey,
        sequence: seq,
        data: data,
        title: data['title']?.toString(),
        categoryId: (data['categoryId'] as num?)?.toInt(),
      );
      return FCLoadDraftResult(result: true, draft: draft);
    } on DiscourseApiException catch (e) {
      // 404 just means no draft exists — that's not an error.
      if (e.statusCode == 404) {
        return FCLoadDraftResult(result: true);
      }
      return FCLoadDraftResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCLoadDraftResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCDeleteDraftResult> deleteDraftAsync(
    String draftKey, {
    int sequence = 0,
  }) async {
    if (!siteContext.isLoggedIn) {
      return FCDeleteDraftResult(result: false, resultText: 'Not signed in');
    }
    try {
      await apiDelete(
          '/drafts/${Uri.encodeComponent(draftKey)}.json?sequence=$sequence');
      return FCDeleteDraftResult(result: true);
    } on DiscourseApiException catch (e) {
      return FCDeleteDraftResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return FCDeleteDraftResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCDraftListResult> getMyDraftsAsync({int page = 0}) async {
    if (!siteContext.isLoggedIn ||
        siteContext.currentUsername == null) {
      return FCDraftListResult(
        result: false,
        resultText: 'Not signed in',
        total: 0,
        items: const [],
      );
    }
    try {
      final qs = page > 0 ? '?page=$page' : '';
      final response = await apiGet('/drafts.json$qs');
      final raw = (response['drafts'] as List?) ?? const [];
      final items = raw
          .whereType<Map>()
          .map((d) => _draftFromDiscourseJson(d.cast<String, dynamic>()))
          .toList(growable: false);
      return FCDraftListResult(
        result: true,
        total: items.length,
        items: items,
      );
    } on DiscourseApiException catch (e) {
      return FCDraftListResult(
        result: false,
        resultText: e.userMessage,
        total: 0,
        items: const [],
      );
    } catch (e) {
      return FCDraftListResult(
        result: false,
        resultText: 'Error: $e',
        total: 0,
        items: const [],
      );
    }
  }

  FCDraft _draftFromDiscourseJson(Map<String, dynamic> json) {
    // The list endpoint encodes the inner blob as a JSON string; the
    // single-key endpoint sometimes hands it back as a parsed map.
    // Accept either.
    Map<String, dynamic> parsed;
    final rawData = json['data'];
    if (rawData is Map) {
      parsed = rawData.cast<String, dynamic>();
    } else if (rawData is String && rawData.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawData);
        parsed = decoded is Map ? decoded.cast<String, dynamic>() : {};
      } catch (_) {
        parsed = {};
      }
    } else {
      parsed = {};
    }
    return FCDraft(
      draftKey: (json['draft_key'] ?? '').toString(),
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
      data: parsed,
      topicId: (json['topic_id'] as num?)?.toInt(),
      title: (json['title'] ?? json['topic_title'])?.toString(),
      categoryId: (parsed['categoryId'] as num?)?.toInt(),
      updatedAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
