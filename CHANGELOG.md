# Changelog

All notable changes to this project are documented in this file.

The format is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Releases below 1.0 should not be assumed backward-compatible across minor bumps.

## [Unreleased]

## [1.0.11] - 2026-09-09

### Fixed
- **Emoji in reaction chips and post bodies** now resolve against Discourse's own name table, the one 1.0.10 introduced for titles and excerpts. Reaction glyphs went through the generic emoji library plus a hand-kept alias list for the handful of names it files differently (`:+1:`, `:-1:`, `:hugs:`); the reaction-users sheet and the inline emoji in cooked post HTML had no such cover, so the 866 Discourse names that library does not know fell back to a network image or to nothing. Inline emoji in posts also honour the `:name:tN:` skin-tone suffix now. The alias list is gone, and a test pins the default reaction set so its removal cannot regress them.

### Changed
- The `emojis` package is now a dev dependency: only `packages/discourse_ui/tool/gen_discourse_emoji_data.dart` still uses it, so the app no longer ships it.

## [1.0.10] - 2026-09-09

### Fixed
- **Emoji shortcodes in topic titles and excerpts** now resolve against Discourse's own name table instead of a generic emoji library, whose short names covered fewer than half of Discourse's. A title ending in `:studio_microphone:` showed the raw shortcode in the topic list and the posts app bar; it now shows 🎙️. Aliases (`:slight_smile:`, `:+1:`) and the `:name:tN:` skin-tone suffix resolve too, and names Discourse itself would not render stay untouched. The table is generated from the `discourse-emojis` gem by `packages/discourse_ui/tool/gen_discourse_emoji_data.dart`.

## [1.0.9] - 2026-09-09

### Changed
- **Lighter topic rows and posts** — the UI half of the scroll audit (`docs/perf-audit-2026-09.md`), each cut removing per-row layout, paint or network work:
  - A post shows **one** preview card: a video if it has one, else a tweet, else the first external link. Web oneboxes one link too; the app allowed up to thirty cards, each a network fetch the moment the post appeared.
  - A topic row shows at most **two tag chips** plus "+N".
  - The "alice replied 3h ago" line is text only; the mini avatar beside it is gone (it was the seventh image per row).
  - The metadata row is replies, likes, votes where a forum has them, views, and **one** status badge chosen by what matters most (announcement, solved, locked, hot, pinned, poll, watching), right-aligned — instead of two wrapping rows of up to nine items.

## [1.0.8] - 2026-09-09

### Changed
- **Scroll performance, phases 2 and 3** (`docs/perf-audit-2026-09.md`):
  - The Home feed is virtualized. Each topic row is its own sliver child of a `CustomScrollView`, so only rows near the viewport are built and laid out. Before, the whole loaded feed was one `Column` inside a `ListView`, rebuilt and re-laid-out in full on every load-more and filter change.
  - The five filter lists are kept mounted for their state inside `Offstage` instead of at `Positioned(-10000)` under `Opacity(0)`, and Latest and Unread no longer build a complete second copy of the feed off-screen every frame.
  - Category and tag chips are plain decorated boxes; the antialiased `Material` clip was a saveLayer per chip per row.
  - Only the highlighted post is wrapped in an `AnimatedContainer`; every other post is a `ColoredBox`.
  - One `AvatarActions`, `ImageActions` and `PostActionsHandler` per thread instead of three new objects per post per build.
  - Avatar colour schemes and gradients are memoized per username.
  - Thread pagination triggers eight items from either end instead of three, so a fast fling no longer reaches the end of the loaded window before the next page arrives.
  - Loading skeletons in the topic list and thread are static blocks; the shimmer was a ShaderMask saveLayer every frame during first load.
  - flutter_html style tables are built once per theme and shared, instead of ~45 objects per post per build.
  - `CookedContent.parse` is memoized by cooked HTML (bounded LRU), so a post scrolled back into view is not re-parsed, and each page of a thread is parsed ahead of time on a worker isolate as it arrives.
  - No more `VisibilityDetector` per post (each carried a timer and layout tracking); the visible-post index comes from the list's own position stream. Post rows are keyed by post id at the outermost widget so a prepended page no longer rebuilds them.
  - Custom-emoji reaction images decode at display size.
  - The forum header tints its pattern through the image paint instead of a `ColorFiltered` layer, and no longer wraps itself in `IntrinsicHeight`; same look, one layout pass and no full-header saveLayer.


  Benchmark (Pixel 10a, profile build, meta.discourse.org, eight flings per screen), baseline → phase 1 → this release: topic list build p50 6.9 → 3.3 → 0.8 ms, p90 14.9 → 11.3 → 2.1 ms, frames over 16.7 ms 31 % → 7 % → 3 %, frames over 33 ms 16 → 8 → 1; thread build p50 0.8 → 0.8 → 0.7 ms, p99 30 → 13 → 18 ms (a different, preview-heavy topic was at the top of Latest this run), worst 83 → 51 → 47 ms.

## [1.0.7] - 2026-09-09

### Changed
- **Scroll performance, phase 1** (see `docs/perf-audit-2026-09.md` for the audit and baseline):
  - A post's cooked HTML is parsed once per post instance instead of on every build of the row. `PostListItem` keeps the extracted content and drops it only when the post or its translation changes.
  - Scrolling a thread no longer rebuilds the whole list. The "n / total" position in the bottom bar is fed by a `ValueNotifier` instead of a `setState` fired by every post's `VisibilityDetector`.
  - Avatars and other cached images decode at display size (`ResizeImage` on the file path — a 240 px avatar was decoded in full for a 40 px slot), start loading in `initState` rather than one frame later, and fetch once instead of twice per widget. SVG avatars, which Discourse allows and serves under a `.png` URL, are sniffed and rendered with `flutter_svg` instead of failing.
  - The avatar placeholder is a flat tinted disc; the shimmer ran an animation controller per avatar until the image landed.
  - The attachment-size fold in `RichTextContent` compiles its regex once and skips posts with no attachment link.
- **Topic rows no longer show the participant avatar cluster.** Five extra network images per row for a detail the author avatar and "alice replied" line already cover. The model still carries `participantIconUrls` for anyone who wants it back.

  Benchmark (Pixel 10a, profile build, meta.discourse.org, eight flings per screen), before → after: topic list build p50 6.9 → 3.3 ms, p90 14.9 → 11.3 ms, frames over 16.7 ms 31 % → 7 %; thread build p99 30 → 13 ms, worst frame 83 → 51 ms, frames over 33 ms 11 → 3; avatar decode failures 10 → 0 and file-to-network fallbacks 88 → 0.

## [1.0.6] - 2026-09-08

### Changed
- **Forum logos are cached on disk.** `BrandImage` now loads raster logos through `CachedNetworkImage` and SVG logos as files through the same `flutter_cache_manager` store (thirty days), instead of re-downloading on every build. Matters most to multi-forum hosts that paint hundreds of directory icons; the single-forum app gains the header and drawer wordmark. Web keeps the plain network SVG loader.

## [1.0.5] - 2026-09-08

### Changed
- **Sign in moved into the drawer header**, next to the "Not signed in" line, as a button — it was the last row of the drawer, below Privacy Policy. Web keeps its Log In in the header for the same reason. Sign out stays at the bottom. The header's own strings are localized and its wordmark renders through `BrandImage` (SVG, dark-logo rule).

## [1.0.4] - 2026-09-08

### Changed
- The drawer is localized (its section labels and rows were the last raw strings in the UI), and the two "Switch forum" rows a hosted build could show are one row at the top, driven by `DiscourseHost.switchForum` with the route-below-the-shell heuristic as fallback.

## [1.0.3] - 2026-09-08

### Added
- **Host hooks** (`DiscourseHost`) for multi-forum apps that mount the module per forum: `switchForum` puts a "Switch forum" entry at the top of the drawer that returns to the host's forum list; `resolveForum` lets the host say which of its forums a push notification belongs to, instead of the module rebuilding the single configured forum. Both are null by default; the single-forum template is unchanged.

## [1.0.2] - 2026-09-08

### Fixed
- Header colours in dark mode: a forum that ships no dark-mode logo keeps its light header colours in dark mode, so its transparent wordmark always sits on the background it was drawn for. Meta's black wordmark no longer lands on a near-black strip.

## [1.0.1] - 2026-09-08

### Added
- **The forum's own header.** The wordmark renders wide and contained at header height instead of squeezed into a 60 px square (which cropped "Discourse" to "iscourse"), on the forum's own header colour with its header text colour, the way the browser shows it. Both come from payloads already fetched: the colour scheme in `/site.json`, the logos in `/site/settings.json`. A forum on the stock scheme keeps the pattern background. SVG logos now render (`flutter_svg`); a good share of forums use them.

### Fixed
- `discourse_ui` ships its own artwork (`packages/discourse_ui/assets/…`) instead of expecting the host app to carry `assets/forum_header_bg.png` and the icon by bare name — a host that did not had a red error dialog on the forum home.
- `discourse_ui` caps the `html` package below 0.15.7, which dropped `Element.matches` while `flutter_html` 3.0.0 still calls it. A fresh consumer resolving 0.15.7 failed to compile; this repo's lock had 0.15.6 and never noticed.

## [1.0.0] - 2026-09-08

The first release that calls itself finished. Since 0.8.0 the same day:
every UI string is localized in eleven languages, deprecated API uses
are at zero, CI checks a fresh clone on Linux and Windows on every push,
the User API Key survives app updates (reproduced and fixed on a Pixel),
the iOS floor is 15.0, and the last XenForo-era code that could not work
on Discourse is gone. Push notifications ship optional and off by
default; the relay lives outside this repo.

Not verified for this release: an Xcode build at the new 15.0 floor.
`pod install` resolves; the Mac that cut the release lacks the iOS
platform component. Android, macOS, Windows and Linux were exercised.

### Added
- **CI** (`be591c7`, `0bd34f6`, `d562317`): GitHub Actions runs the README's own Quick start on every push — pub get, `buildlib.sh`, a check that the SDK's generated code is committed, analyze with errors and warnings fatal, every package's tests, a debug APK from the `.example` Firebase placeholder — and `buildlib.bat` on a Windows runner, the first time that script has ever been executed.
- **Handshake test** (`41cc812`): the User API Key flow end to end with the test playing Discourse — request URL, stable client id, RSA-OAEP and PKCS1 payloads, nonce rejection, superseded handshake, push recorded only when this app asked for it.
- **Persistence test** (`f9e33af`): the key survives a process restart, never lands in plain prefs, migrates from older builds, a lost key starts the app signed out rather than crashed, sign-out clears everything.
- **Widget tests** (`0999d76`) for the oversized-image consent sheet and the attachment card.
- **Fork checklist and naming section** in the README (`ed76be2`): every identity placeholder with its file, and a statement that the project is not affiliated with Discourse's makers.
- `docs/push.md` (`4882732`): push ships optional and off by default; what is built, what is not, what a forum admin must enable.
- `v0.8.0` tag and this file's first dated section (`fa5c25f`).

### Changed
- **Every UI string goes through `AppLocalizations`** (`541aed4`, `5c2d938`, `d8cb640`): 366 hard-coded `Text('…')` literals replaced, 262 new English keys, all translated in the ten other locales (`9faf755`, `466ee46`) along with 12 older keys that had been English-only. What remains unlocalized is composed data — "@handle", "#12", "3 / 40", "TL2".
- **Zero deprecated API uses, down from 93** (`6e666ff`): `surfaceVariant`, Radio `groupValue`/`onChanged` → `RadioGroup`, share_plus `SharePlus.instance`, `activeThumbColor`, `onPopInvokedWithResult`, passkeys availability, and the Cloudflare interceptor's webview cache clearing (canonical SDK `9ce8ba6d`). The declared Flutter floor is now 3.32.
- **iOS deployment target 18.4 → 15.0** (`591babf`). The old pin was a workaround for a simulator-only crash (libswiftWebKit, WebKit bug 293831), applied to device builds too; it now applies to the simulator SDK alone. `pod install` verified; an Xcode build is not, this Mac lacks the iOS platform component.
- **Android app label "Discourse" → "Forum App"**, matching iOS and macOS (`f9e33af`).
- Nine analyzer warnings cleared so analyze can gate CI (`5f4514d`).
- Audit doc: the "Not covered" list now records what happened to each item — composer and attachments closed on-device, PM attachments share that path, drafts reviewed against `DraftsController`, chat uploads not implemented (`4882732`).

### Removed
- **XenForo-era code that could not work on Discourse**: in-app registration (`register_page`, `additional_information_page`, `custom_field_widget`, `basic_registration_fields`, `location_service`) — the account proxy always answered "sign up on the web", and the two entry points now open the forum's `/signup`; the password-protected-forum flow (`forum_password_dialog`, `ForumActions.enterProtectedForum`) — Discourse categories use group permissions, so a read-restricted category now opens like any other and keeps its lock badge; the XenForo messages page and its app bars; the pre-consent image optimizer dialog; unreferenced passkey validation helpers and error widgets. 180 localization keys that nothing referenced any more went with them, in all eleven ARBs.
- `packages/forumcopilot_sdk/test/` — XenForo/Tapatalk interface suites with no `main()`, driven from those platforms' own packages. The vendored SDK now carries `lib/` and `pubspec.yaml` only; the rsync rule in `CLAUDE.md` excludes `test/`.

### Fixed
- **Topic page title showed emoji shortcodes literally** (`f0fb34b`) — the list converted `:wave:` since `55cf8d9`, the topic's own app bar did not. Seen on the Pixel.
- **Signed out after an update or restore** (`f9e33af`). Both secure-storage call sites used library defaults — on Android the legacy scheme the library itself warns against. One shared instance now uses EncryptedSharedPreferences with `resetOnError`; the manifest excludes the secure-storage file from Auto Backup and device transfer (a restored blob is unreadable without the Keystore key); a read that throws starts the app signed out instead of crashing, and logs the lost-key signature. Not reproduced on a device this session; the fix follows the library's own guidance.
- **`flutter gen-l10n` aborted from the repo root** (`d562317`) — `l10n.yaml` lives in `discourse_ui`. Both bootstrap scripts run it there; this was CI's first red run.
- `forumcopilot_sdk`'s `test/` directory holds suites with no `main()`; CI no longer tries to run them (`0bd34f6`).


## [0.8.0] - 2026-09-08

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
