import 'package:forumcopilot_sdk/context/site_context.dart';

import '../base_discourse_proxy.dart';

/// Discourse invite proxy — shareable invite links and email invites.
///
/// Discourse-native feature with no XenForo-shaped SDK counterpart, so this
/// proxy stands alone (no `IFC*Proxy` interface) and returns local
/// `DiscourseInvite*Result` types, mirroring how other Discourse-only
/// concepts are surfaced.
///
/// Endpoints used (server: `invites_controller.rb`, `users_controller.rb`):
///   * POST   `/invites.json`                       — create link/email invite
///   * GET    `/u/{username}/invited.json?filter=`  — list own invites
///   * DELETE `/invites.json` (`id` param)          — destroy an invite
///
/// Whether the current user may invite at all is governed server-side by
/// `SiteSetting.invite_allowed_groups` (and trust-level membership therein);
/// there is no client-side capability flag, so callers should treat a
/// `result: false` with a 403-derived message as "you can't invite here"
/// rather than a transient failure.
class DiscourseInviteProxy extends BaseDiscourseProxy {
  DiscourseInviteProxy(SiteContext context) : super(context);

  /// Creates a shareable invite link (no email is sent).
  ///
  /// POST `/invites.json` with `skip_email: true` and no `email`, which is
  /// what makes Discourse mint a redeemable-by-anyone link invite
  /// (`invites_controller#create` → `Invite.generate`). Optional knobs:
  ///   * [maxRedemptions] → `max_redemptions_allowed` (how many signups the
  ///     link is good for; server clamps per site settings).
  ///   * [expiresAt]      → `expires_at`, an ISO-8601 date/time string.
  ///     Omitted = server default (`invite_expiry_days`).
  ///   * [topicId]        → `topic_id`, so redeemers land on that topic.
  ///
  /// The response is a bare `InviteSerializer` payload; [DiscourseInviteResult.invite]
  /// carries the link URL, id and expiry.
  Future<DiscourseInviteResult> createInviteLinkAsync({
    int? maxRedemptions,
    String? expiresAt,
    int? topicId,
  }) async {
    if (!siteContext.isLoggedIn) {
      return DiscourseInviteResult(result: false, resultText: 'Not signed in');
    }
    try {
      final response = await apiPost('/invites.json', body: {
        'skip_email': true,
        if (maxRedemptions != null) 'max_redemptions_allowed': maxRedemptions,
        if (expiresAt != null) 'expires_at': expiresAt,
        if (topicId != null) 'topic_id': topicId,
      });
      return DiscourseInviteResult(
        result: true,
        invite: DiscourseInvite.fromJson(response),
      );
    } on DiscourseApiException catch (e) {
      return DiscourseInviteResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return DiscourseInviteResult(result: false, resultText: 'Error: $e');
    }
  }

  /// Invites [email] by sending them an invite email.
  ///
  /// POST `/invites.json` with `email` (+ optional `custom_message` and
  /// `topic_id`). Discourse both creates the invite and enqueues the email
  /// (unless the site disables `allow_email_invites`, in which case the
  /// server falls back to link-only behavior). Inviting an address that
  /// already belongs to a user is rejected server-side
  /// (`Invite::UserExists`) — that message comes back in `resultText`.
  Future<DiscourseInviteResult> createEmailInviteAsync(
    String email, {
    int? topicId,
    String? customMessage,
  }) async {
    if (!siteContext.isLoggedIn) {
      return DiscourseInviteResult(result: false, resultText: 'Not signed in');
    }
    if (email.trim().isEmpty) {
      return DiscourseInviteResult(result: false, resultText: 'Email required');
    }
    try {
      final response = await apiPost('/invites.json', body: {
        'email': email.trim(),
        if (customMessage != null && customMessage.trim().isNotEmpty)
          'custom_message': customMessage.trim(),
        if (topicId != null) 'topic_id': topicId,
      });
      return DiscourseInviteResult(
        result: true,
        invite: DiscourseInvite.fromJson(response),
      );
    } on DiscourseApiException catch (e) {
      return DiscourseInviteResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return DiscourseInviteResult(result: false, resultText: 'Error: $e');
    }
  }

  /// Lists the current user's invites.
  ///
  /// GET `/u/{username}/invited.json?filter=` where [filter] is one of
  /// `pending`, `expired` or `redeemed` (server default is `redeemed`;
  /// anything else yields an empty list). `pending`/`expired` rows are full
  /// invites (link, email, expiry); `redeemed` rows carry the redeeming
  /// user's username and `redeemed_at` instead (`InvitedUserSerializer`).
  /// The response also includes pending/expired/redeemed counts, surfaced
  /// on the result for tab badges.
  Future<DiscourseInviteListResult> getMyInvitesAsync({
    String filter = 'pending',
  }) async {
    final username = siteContext.currentUsername;
    if (username == null || username.isEmpty) {
      return DiscourseInviteListResult(
        result: false,
        resultText: 'Not signed in',
      );
    }
    try {
      final response = await apiGet(
        '/u/${Uri.encodeComponent(username)}/invited.json',
        query: {'filter': filter},
      );
      final raw = (response['invites'] as List?) ?? const [];
      final invites = raw
          .whereType<Map>()
          .map((i) => DiscourseInvite.fromJson(i.cast<String, dynamic>()))
          .toList(growable: false);
      final counts = (response['counts'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};
      return DiscourseInviteListResult(
        result: true,
        invites: invites,
        pendingCount: (counts['pending'] as num?)?.toInt() ?? 0,
        expiredCount: (counts['expired'] as num?)?.toInt() ?? 0,
        redeemedCount: (counts['redeemed'] as num?)?.toInt() ?? 0,
      );
    } on DiscourseApiException catch (e) {
      return DiscourseInviteListResult(result: false, resultText: e.userMessage);
    } catch (e) {
      return DiscourseInviteListResult(result: false, resultText: 'Error: $e');
    }
  }

  /// Revokes (trashes) an invite the current user created.
  ///
  /// DELETE `/invites.json` with `id` (`invites_controller#destroy`
  /// requires the param and checks `can_destroy_invite?`). A redeemed
  /// invite can't be destroyed — the server answers 403 and the message
  /// lands in `resultText`.
  Future<DiscourseInviteActionResult> destroyInviteAsync(int inviteId) async {
    if (!siteContext.isLoggedIn) {
      return DiscourseInviteActionResult(
        result: false,
        resultText: 'Not signed in',
      );
    }
    try {
      await apiDelete('/invites.json', query: {'id': inviteId.toString()});
      return DiscourseInviteActionResult(result: true);
    } on DiscourseApiException catch (e) {
      return DiscourseInviteActionResult(
        result: false,
        resultText: e.userMessage,
      );
    } catch (e) {
      return DiscourseInviteActionResult(
        result: false,
        resultText: 'Error: $e',
      );
    }
  }
}

/// One invite, as serialized by Discourse (`InviteSerializer` for
/// pending/expired invites and fresh creates; `InvitedUserSerializer` for
/// redeemed rows, which only fill [id], [redeemedAt], [redeemedUsername]
/// and [inviteSource]).
///
/// Beware the asymmetry: on a redeemed row [emailed], [expired] and
/// [canDelete] read `false` because the serializer omits those keys, NOT
/// because the server said no. Don't render them as definite negatives.
class DiscourseInvite {
  final int id;

  /// Shareable URL (`{base_url}/invites/{invite_key}`). Empty for redeemed
  /// rows, where Discourse no longer exposes the link.
  final String link;

  /// Target address for email invites; null for pure link invites (and for
  /// viewers the server hides emails from).
  final String? email;

  final String? customMessage;

  /// True when Discourse actually emailed the invite (email invites only).
  final bool emailed;

  /// Link invites only: how many redemptions are allowed / used so far.
  final int? maxRedemptionsAllowed;
  final int? redemptionCount;

  final DateTime? createdAt;
  final DateTime? expiresAt;
  final bool expired;

  /// Whether the server says the current user may delete this invite.
  final bool canDelete;

  /// Redeemed rows only: when it was redeemed and by whom.
  final DateTime? redeemedAt;
  final String? redeemedUsername;

  /// The server's own classification of the invite: `"link"` or
  /// `"email"` (`InvitedUserSerializer#invite_source`,
  /// app/serializers/invited_user_serializer.rb:16-18 —
  /// `object.invite.is_invite_link? ? "link" : "email"`). Null on rows
  /// served by `InviteSerializer`, which doesn't emit it.
  final String? inviteSource;

  DiscourseInvite({
    required this.id,
    required this.link,
    this.email,
    this.customMessage,
    this.emailed = false,
    this.maxRedemptionsAllowed,
    this.redemptionCount,
    this.createdAt,
    this.expiresAt,
    this.expired = false,
    this.canDelete = false,
    this.redeemedAt,
    this.redeemedUsername,
    this.inviteSource,
  });

  factory DiscourseInvite.fromJson(Map<String, dynamic> json) {
    // Redeemed rows nest the redeeming user: {id, redeemed_at, user: {...}}.
    final user = (json['user'] as Map?)?.cast<String, dynamic>();
    return DiscourseInvite(
      id: (json['id'] as num?)?.toInt() ?? 0,
      link: json['link']?.toString() ?? '',
      email: json['email']?.toString(),
      customMessage: json['custom_message']?.toString(),
      emailed: json['emailed'] == true,
      maxRedemptionsAllowed: (json['max_redemptions_allowed'] as num?)?.toInt(),
      redemptionCount: (json['redemption_count'] as num?)?.toInt(),
      createdAt: _parseDate(json['created_at']),
      expiresAt: _parseDate(json['expires_at']),
      expired: json['expired'] == true,
      canDelete: json['can_delete_invite'] == true,
      redeemedAt: _parseDate(json['redeemed_at']),
      redeemedUsername: user?['username']?.toString(),
      inviteSource: json['invite_source']?.toString(),
    );
  }

  /// True for shareable link invites.
  ///
  /// Prefer the server's own [inviteSource]. The email heuristic below is
  /// only a fallback for `InviteSerializer` rows (which have `email` but
  /// no `invite_source`) — on its own it misclassified EVERY redeemed
  /// invite as a link invite, because `InvitedUserSerializer` never
  /// includes `email`.
  bool get isLinkInvite => inviteSource != null
      ? inviteSource == 'link'
      : (email == null || email!.isEmpty);

  static DateTime? _parseDate(dynamic value) =>
      value is String && value.isNotEmpty ? DateTime.tryParse(value) : null;
}

/// Result of creating a single invite (link or email).
class DiscourseInviteResult {
  final bool result;
  final String? resultText;
  final DiscourseInvite? invite;

  DiscourseInviteResult({
    required this.result,
    this.resultText,
    this.invite,
  });
}

/// Result of listing the current user's invites.
class DiscourseInviteListResult {
  final bool result;
  final String? resultText;
  final List<DiscourseInvite> invites;

  /// Server-side totals across all filters (for tab badges).
  final int pendingCount;
  final int expiredCount;
  final int redeemedCount;

  DiscourseInviteListResult({
    required this.result,
    this.resultText,
    this.invites = const [],
    this.pendingCount = 0,
    this.expiredCount = 0,
    this.redeemedCount = 0,
  });
}

/// Result of a bare invite action (destroy).
class DiscourseInviteActionResult {
  final bool result;
  final String? resultText;

  DiscourseInviteActionResult({required this.result, this.resultText});
}
