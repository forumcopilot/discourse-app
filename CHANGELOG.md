# Changelog

All notable changes to this project are documented in this file.

The format is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Releases below 1.0 should not be assumed backward-compatible across minor bumps.

## [Unreleased]

### Added
- **Share / copy link on every post** (`ac8efb5`). Web puts a share control on each post; the app had no way to link to a specific reply.
- **Notifications filter to Unread** (`635442d`) via `/notifications.json?filter=unread`, on the Discourse proxy rather than the shared SDK interface.
- **Category and tags on the topic page** (`5c0cd70`), under the title where web puts them.
- **Terms of Service and Privacy Policy links** in the drawer (`aa5fa49`), from `tos_url` / `privacy_policy_url` in `/site.json` — parsed for a long time, never read.
- **The forum's own logo** in the header and the drawer wordmark (`062f15a`), from `/site/settings.json`.
- **"Accepted by" on the profile's Solved tab** (`3aaf012`) — the actor was dropped by the converter; needed `FCUserReply.actorName` in the canonical SDK.
- **Attachments named the way web names them** (`9b94d16`): `![name|WxH](…)` and `[name|attachment](…) (size)` instead of the literal words "image" and "file". Non-image attachments render as download cards with Share and Download.
- **Resize-to-fit prompt for oversized images** (`a1d4b37`), with a remembered "don't ask again". Shrinks only as far as the limit requires and preserves the format.
- **Bookmarks and Drafts in the drawer's Account section** (`6b348c7`).
- `CONTRIBUTING.md` and `CODE_OF_CONDUCT.md`, and a README link to both.
- `CookedContent` (`packages/discourse_ui/lib/utils/cooked_content.dart`) — parses a post's cooked HTML and returns the renderable HTML plus the YouTube, Twitter/X, link and image URLs it embeds. Unit-tested against the markup shapes taken from the Discourse source (onebox layout, `discourse-lazy-videos` containers, lightbox wrappers).
- `MediaUrlUtils` — the YouTube / Twitter / video / email URL predicates, extracted from `BBCodeProcessor` where they had nothing to do with BBCode.
- `DiscourseMarkup` — the single source of truth for what the formatting toolbar emits, shared by both composers and unit-tested. Documents which actions map to Markdown, which legitimately map to BBCode (`[u]`, `[quote]`, `[spoiler]` are Discourse's native spelling), and which have no Discourse equivalent at all.

### Changed
- **Profile page rebuilt** (`f7f99b2`, `2493d0f`, `29d6e7d`): trust level moves into the info card, badges become a wrapping section above Stats, every block shares one section chrome, the Activity tabs pin while scrolling, and the four feeds share one row that attributes a post only when its author is someone else.
- **One filter-chip style app-wide** (`1b03741`, `8d1447e`); the category list's colour stripe is gone now that the tile carries the real colour.
- **Attachment upload consolidated** (`a1d4b37`): six composer pages carried verbatim copies of the same ~150-line handler; they now share `AttachmentUploadService`. −975 lines.
- **Most Liked By / Most Liked / Most Replied To** on the profile are swipeable strips with names and counts, out of the stats card (`2493d0f`).
- `BBCodeCallbacks` renamed to `PostContentCallbacks` (file `custom_bb_stylesheet.dart` → `post_content_callbacks.dart`). It is the tap-callback bundle for `RichTextContent` and has not driven a BBCode renderer for some time.
- Composer methods renamed to match what they actually do: `_insertBBCode` → `_insertMarkup`, `_insertAttachmentBBCode` → `_insertAttachmentRef`.

### Fixed
- **A fresh clone did not build.** Root `flutter pub get` writes no `package_config` for the three nested packages, so `flutter analyze` reported 289 unresolved-import errors and the Android build failed on the gitignored `google-services.json`. `buildlib.sh` / `buildlib.bat` now run `dart pub get` inside each package first, and the README's Quick start tells you to copy the three committed `.example` Firebase files, which are enough to compile — verified from pristine clones on Android and macOS. Three docs also claimed `discourse_core` has generated code; it has none.
- **A fresh clone could not `pod install` for iOS.** The committed `ios/Podfile.lock` pinned Firebase 12.4.0 and a `firebase_crashlytics` that nothing in `pubspec` depends on any more, while `firebase_core` 4.7.0 demands Firebase 12.12.0 — CocoaPods' resolver could not satisfy both and failed with "specs repository is too out-of-date", which is misleading: the CDN was fine, the lock was stale. Regenerated from a pristine clone: 12.12.0, no Crashlytics. macOS's lock was already current. Verified: with the old lock a fresh clone fails in `pod install`; with the new one it passes through CocoaPods (the Xcode step is untested here — this Mac lacks the iOS platform component).
- **Search results had no topic title** (`b4daa21`). `/search.json` side-loads topics separately and the converter hardcoded `title: ''`. The field also now takes focus on open.
- **Category badge missing on nearly every topic row** (`044a860`). Names came from `/categories.json`, which meta.discourse.org truncates to 12 of 45; `/site.json` has all of them and was already fetched.
- **Messages never showed unread** (`3763459`). The flag read `unread`, which the server hardcodes to 0 as a back-compat stub; a never-opened PM is recognised by a null `last_read_post_number`.
- **Emoji shortcodes rendered literally in list titles and excerpts** (`55cf8d9`) — `:warning:` in the list, ⚠️ once opened.
- **Category page used a hashed colour instead of the category's own**, and repeated the category badge on every row inside it (`f1c0ef3`, `d4a8f53`).
- **Restricted groups showed "0 members"** (`bf3266c`). Discourse withholds `user_count` when `can_see_members` is false; `?? 0` turned that into a claim. Needed `FCGroup.canSeeMembers`.
- **An avatar that would not decode raised a modal error** (`21a6ef0`). Four `CircleAvatar(backgroundImage:)` sites had no failure path; one shared widget now falls back.
- **Images were silently transcoded to JPEG** and downscaled before the size check, so a 20 MB PNG slipped under a 10 MB limit that could never fire (`a1d4b37`). The remaining PNG→JPEG conversion you may still see is Discourse's own server-side policy (`png_to_jpg_quality`), identical for web uploads.
- **`post_number` rendered as a reply count** in the profile activity feed (`29d6e7d`); it reads `#45` now.
- **Bookmarks' empty state** was a bare line of grey text (`0fe2cd0`).
- **Post link previews no longer treat images as links.** Link, video and tweet cards below a post are now extracted from Discourse's cooked HTML as a DOM, following the same rules the server itself uses in `PrettyText.extract_links` (`aside.onebox[data-onebox-src]`, exclusions for quotes, oneboxes, mentions, hashtags, attachments and in-page anchors). The previous implementation ran cooked HTML through the inherited XenForo `BBCodeProcessor`, whose BBCode tag regexes matched nothing and whose `findPlainUrls` fallback swept the raw markup with a bare `https?://\S+` pattern — so a single onebox'd link produced up to three preview cards (its href, its thumbnail and its favicon), and image uploads showed up as "links in this post".
- **Tapping an inline image opens that image.** The full-screen gallery collected images by scanning post content for `[IMG]` BBCode tags, which never appear in cooked HTML. Images embedded in a post body were therefore absent from the gallery, so a tap opened the wrong image — or reported "No images found to display" on a post with no attachments. It now reads `<img>` elements, preferring the full-size original from the wrapping `a.lightbox` href over the resized `src`, and skips emoji, avatars, favicons and onebox thumbnails.
- **Server-rendered oneboxes are no longer duplicated.** When Discourse has already onebox'd a link, that preview stays in the rendered HTML and the app adds no card of its own. YouTube and Twitter/X embeds go the other way: they become native cards and their nodes are stripped from the HTML, because `flutter_html` cannot render an `<iframe>` and would leave a blank gap.
- **The new-conversation (new PM) composer was still emitting XenForo BBCode.** Phase 5.19 migrated the main composer to Markdown but missed this one, which passed its toolbar action straight through as `[TAG]…[/TAG]`. Discourse parses only a subset of BBCode, so `[LIST]`, `[*]`, `[VIDEO]`, `[LEFT]` and `[CENTER]` were being posted into private messages as literal bracketed text. Both composers now share one mapping (`DiscourseMarkup`), and the Align Left / Center / Right toolbar items — which Discourse has no markup for at all — are removed rather than left as buttons that corrupt the message.
- 33 of 34 analyzer warnings — dead null-aware operators, redundant null comparisons and unnecessary null assertions left behind when the SDK tightened its nullability, plus unused imports. The one remaining warning is in the vendored canonical `forumcopilot_sdk` copy, which is kept byte-identical to its upstream and must be fixed there first.

### Removed
- `deploy_plugin.sh` / `deploy_plugin.bat`. Both were inherited from the XenForo sibling app and rsync a plugin to a XenForo server; this app has no server-side plugin and never will in v1. Stale references in `CLAUDE.md` are gone with them, along with a note about composer helpers named `_insertBBCode` that had already been renamed.
- Eleven fully-merged feature branches, local and remote. Every one had zero commits beyond `main`.
- `bbcode_processor.dart` (1,183 lines) and `attachment_utils.dart`. This retires the last of the XenForo content pipeline; Discourse posts are cooked HTML end to end.

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
