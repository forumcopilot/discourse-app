# Changelog

All notable changes to this project are documented in this file.

The format is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Releases below 1.0 should not be assumed backward-compatible across minor bumps.

## [Unreleased]

### Fixed
- **Post link previews no longer treat images as links.** Link, video and tweet cards below a post are now extracted from Discourse's cooked HTML as a DOM, following the same rules the server itself uses in `PrettyText.extract_links` (`aside.onebox[data-onebox-src]`, exclusions for quotes, oneboxes, mentions, hashtags, attachments and in-page anchors). The previous implementation ran cooked HTML through the inherited XenForo `BBCodeProcessor`, whose BBCode tag regexes matched nothing and whose `findPlainUrls` fallback swept the raw markup with a bare `https?://\S+` pattern — so a single onebox'd link produced up to three preview cards (its href, its thumbnail and its favicon), and image uploads showed up as "links in this post".
- **Tapping an inline image opens that image.** The full-screen gallery collected images by scanning post content for `[IMG]` BBCode tags, which never appear in cooked HTML. Images embedded in a post body were therefore absent from the gallery, so a tap opened the wrong image — or reported "No images found to display" on a post with no attachments. It now reads `<img>` elements, preferring the full-size original from the wrapping `a.lightbox` href over the resized `src`, and skips emoji, avatars, favicons and onebox thumbnails.
- **Server-rendered oneboxes are no longer duplicated.** When Discourse has already onebox'd a link, that preview stays in the rendered HTML and the app adds no card of its own. YouTube and Twitter/X embeds go the other way: they become native cards and their nodes are stripped from the HTML, because `flutter_html` cannot render an `<iframe>` and would leave a blank gap.
- **The new-conversation (new PM) composer was still emitting XenForo BBCode.** Phase 5.19 migrated the main composer to Markdown but missed this one, which passed its toolbar action straight through as `[TAG]…[/TAG]`. Discourse parses only a subset of BBCode, so `[LIST]`, `[*]`, `[VIDEO]`, `[LEFT]` and `[CENTER]` were being posted into private messages as literal bracketed text. Both composers now share one mapping (`DiscourseMarkup`), and the Align Left / Center / Right toolbar items — which Discourse has no markup for at all — are removed rather than left as buttons that corrupt the message.
- 33 of 34 analyzer warnings — dead null-aware operators, redundant null comparisons and unnecessary null assertions left behind when the SDK tightened its nullability, plus unused imports. The one remaining warning is in the vendored canonical `forumcopilot_sdk` copy, which is kept byte-identical to its upstream and must be fixed there first.

### Added
- `CookedContent` (`packages/discourse_ui/lib/utils/cooked_content.dart`) — parses a post's cooked HTML and returns the renderable HTML plus the YouTube, Twitter/X, link and image URLs it embeds. Unit-tested against the markup shapes taken from the Discourse source (onebox layout, `discourse-lazy-videos` containers, lightbox wrappers).
- `MediaUrlUtils` — the YouTube / Twitter / video / email URL predicates, extracted from `BBCodeProcessor` where they had nothing to do with BBCode.
- `DiscourseMarkup` — the single source of truth for what the formatting toolbar emits, shared by both composers and unit-tested. Documents which actions map to Markdown, which legitimately map to BBCode (`[u]`, `[quote]`, `[spoiler]` are Discourse's native spelling), and which have no Discourse equivalent at all.

### Removed
- `bbcode_processor.dart` (1,183 lines) and `attachment_utils.dart`. This retires the last of the XenForo content pipeline; Discourse posts are cooked HTML end to end.

### Changed
- `BBCodeCallbacks` renamed to `PostContentCallbacks` (file `custom_bb_stylesheet.dart` → `post_content_callbacks.dart`). It is the tap-callback bundle for `RichTextContent` and has not driven a BBCode renderer for some time.
- Composer methods renamed to match what they actually do: `_insertBBCode` → `_insertMarkup`, `_insertAttachmentBBCode` → `_insertAttachmentRef`.

## 2026-08-05

### Added
- Discourse-native feature wave: bookmark reminders, tag watching, polls, post revisions, whisper and wiki posts, the reviewables queue, invites, do-not-disturb, topic summary, chat DMs and chat reactions.
- Client-side push (Phase 3): with `AppForumConfig.pushApiBaseUrl` set, the User API Key handshake requests the `push` scope and registers a static `push_url`; device identity travels as the handshake `client_id`. The relay backend that forwards to FCM/APNs is still pending — with the URL unset, behavior is byte-identical to before.
- Clickable badges and a trust-level explainer on profiles; avatar upload; Discourse upload limits honored in the composer; cache-first session restore.

### Changed
- Reactions and Q&A votes are first-class `FCPost` fields instead of `Expando` sidecars.
- Post likes and emoji reactions collapsed into one canonical affordance (tap to like, long-press for the picker) instead of two overlapping controls.
- Unified profile experience across "my profile" and "other user's profile".

### Fixed
- Purged fabricated data (−7,700 lines): search results, category posting permissions, group visibility, invite classification and account settings now report what the server actually returned, including reporting failure rather than synthesising a plausible-looking zero.
- Real server signals now populate fields the audit had documented as unrepresentable — attachment upload URLs, group and member totals, bookmark and search pagination.
- Defects found in a full review pass and in live on-device testing against a local Discourse install.

## 2026-08-04

### Changed
- The UI layer was extracted into `packages/discourse_ui`; `lib/` is now a thin runner. This lets the whole app be hosted inside a multi-forum shell.
- `packages/forumcopilot_sdk` is now a byte-identical vendored copy of the canonical SDK; `discourse_core` is repointed at it. Interface changes go to the canonical copy first.
- GetX singletons are namespaced per site so state resets correctly when a different forum is entered.

### Added
- A "Switch forum" drawer entry that appears only when the app is hosted in a multi-forum shell.

---

## Earlier history

This app's build history before 2026-08-04 was tracked as a phase log rather than as releases; it is summarised in the collapsed table at the bottom of [README.md](README.md).

> **Note on versions 0.6.x and 0.7.0.** Entries under those headings were carried over verbatim from the [xenforoapp](https://github.com/forumcopilot/xenforoapp) template when this repository was forked from it, and describe **that** project's XenForo add-on — they reference `forumcopilot.php`, the `xf_fc_device_token` table and XenForo-side direct push dispatch, none of which exist here. They have been removed rather than left in place as inaccurate history. The xenforoapp repository has the accurate versions.

[Unreleased]: https://github.com/forumcopilot/discourse-app/compare/main...HEAD
