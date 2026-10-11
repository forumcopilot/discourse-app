import 'dart:convert' show utf8;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../context/discourse_site_context_extension.dart';
import '../data/message/discourse_message_details.dart';
import '../data/site/discourse_site_capabilities.dart';

/// A small line naming the app a post was written in ("Sent from ABDA"),
/// which a host app adds to the end of each topic, reply and message its
/// members create.
///
/// Off unless a host installs one ([current]), and the member can turn it off
/// ([enabled], the host's settings switch). [BaseDiscourseProxy.apiPost]
/// applies it to every `POST /posts.json` ([applyTo]); an edit
/// (`PUT /posts/{id}`) and a chat message never get one.
///
/// The line must never change what the forum accepts:
///
/// * It counts toward Discourse's checks on the post body, so a post that
///   fails them on its own is sent as written ([fitsWithout]) and gets the
///   forum's usual refusal. Otherwise "thanks!" or a post in capitals would
///   go through from the app where the web refuses it.
/// * The name links to [homepage] only where Discourse will take the link
///   ([linkAllowed]): a member at trust level 0 may put only
///   `newuser_max_links` links in a post, and one whose posts link the same
///   host `newuser_spam_host_threshold` (3) times has the next one refused
///   as spam (Post#has_host_spam?).
class DiscoursePostSignature {
  const DiscoursePostSignature({required this.appName, required this.homepage});

  /// The app's name as the line shows it: "Sent from [appName]".
  final String appName;

  /// Where [appName] links, as an absolute URL.
  final String homepage;

  /// The line the host installed; null (the default) leaves posts as written.
  static DiscoursePostSignature? current;

  /// Whether the member wants the line (the host's settings switch).
  static bool enabled = true;

  /// The Markdown appended to a post: one paragraph of small text.
  String line({required bool linked}) => linked
      ? '<small>Sent from [$appName]($homepage)</small>'
      : '<small>Sent from $appName</small>';

  /// A "Sent from" line ending a post's raw, from any app that writes one
  /// the way [line] does.
  static final RegExp _trailingLine = RegExp(
      r'\s*<small>Sent from (?:\[[^\]\n]+\]\([^)\s]+\)|[^<\[\n]+)</small>\s*$');

  /// [raw] without a "Sent from" line at its end: what a whole-post quote
  /// takes. A web quote copies the reader's selection, which rarely
  /// reaches the footnote.
  static String withoutLine(String raw) => raw.replaceFirst(_trailingLine, '');

  /// [body] with the line at the end of its `raw`, when [path] creates a
  /// post, a line is installed and wanted, and the post meets the forum's
  /// rules without it. What [BaseDiscourseProxy.apiPost] sends.
  static Object? applyTo(SiteContext siteContext, String path, Object? body) {
    final signature = current;
    if (signature == null || !enabled) return body;
    if (path != '/posts.json' || body is! Map<String, dynamic>) return body;
    final raw = body['raw'];
    if (raw is! String || raw.trim().isEmpty) return body;

    // A message is created with its archetype; a reply to one names a topic
    // that loaded as a message. A message not yet loaded counts as a topic,
    // whose rules are the stricter.
    final isMessage = body['archetype'] == 'private_message' ||
        DiscourseMessageDetails.isMessage('${body['topic_id'] ?? ''}');
    final isFirstPost = body['title'] != null;
    final caps = DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl);
    if (!fitsWithout(raw, caps, isMessage: isMessage, isFirstPost: isFirstPost)) {
      return body;
    }

    final signed =
        '${raw.trimRight()}\n\n${signature.line(linked: linkAllowed(siteContext))}';
    if (signed.runes.length > caps.maxPostLength) return body;
    return <String, dynamic>{...body, 'raw': signed};
  }

  /// Whether the member may post a link to the app's homepage without the
  /// post being refused or flagged: trust level 1 (the host-spam check
  /// skips them) and `link_posting_access` "full" ("limited" means only the
  /// forum's allowlisted domains). A forum that predates the field, or a
  /// session restored offline, gets no link.
  ///
  /// Messages get the same rule. Only a reply to an existing message skips
  /// the host-spam check: a new one is checked before its topic exists
  /// (PostCreator#valid?), and the links in replies count toward it.
  @visibleForTesting
  static bool linkAllowed(SiteContext siteContext) {
    final level = siteContext.trustLevel;
    return level != null &&
        level >= 1 &&
        siteContext.linkPostingAccess == 'full';
  }

  /// Whether [raw] passes Discourse's checks on a post body by itself:
  /// StrippedLengthValidator (the minimum length) and
  /// TextSentinel.body_sentinel (enough different characters, a letter or
  /// digit, not all capitals).
  ///
  /// `body_min_entropy` and `allow_uppercase_posts` are not sent to apps, so
  /// Discourse's defaults stand in for them (7, and capitals not allowed).
  @visibleForTesting
  static bool fitsWithout(
    String raw,
    DiscourseSiteCapabilities caps, {
    required bool isMessage,
    required bool isFirstPost,
  }) {
    final minimum = isMessage
        ? caps.minPersonalMessageLength
        : (isFirstPost ? caps.minFirstPostLength : caps.minPostLength);
    var stripped = raw
        .replaceAll(RegExp(r'<!--(.*?)-->'), '')
        .replaceAll(RegExp(r':\w+(:\w+)?:'), 'X')
        .replaceAll(RegExp(r'\.{2,}'), '…')
        .replaceAll(RegExp(r',{2,}'), ',');
    if (caps.preventUploadsOnlyPosts) {
      stripped = stripped.replaceAll(RegExp(r'!\[.*\]\(.+\)'), '');
    }
    if (stripped.trim().runes.length < minimum) return false;

    // TextSentinel.body_sentinel's entropy, scaled for a message as it is.
    const bodyMinEntropy = 7;
    var minEntropy = bodyMinEntropy;
    final minPost = caps.minPostLength;
    final minMessage = caps.minPersonalMessageLength;
    if (isMessage) {
      minEntropy = (bodyMinEntropy * minMessage / minPost).truncate();
      if (minEntropy > minMessage) minEntropy = (minMessage * 0.7).truncate();
    } else if (minEntropy > minPost) {
      minEntropy = (minPost * 0.7).truncate();
    }
    if (utf8.encode(raw.trim()).toSet().length < minEntropy) return false;

    if (!RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(raw)) return false;
    final hasLetter = RegExp(r'\p{L}', unicode: true).hasMatch(raw);
    final hasLowercase = RegExp(r'[\p{Ll}\p{Lo}]', unicode: true).hasMatch(raw);
    return !hasLetter || hasLowercase;
  }
}
