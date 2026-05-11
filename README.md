# Discourse App

An open-source Flutter mobile app template for a **single Discourse forum**. Hard-bound to one community at build time via `lib/config/app_forum_config.dart`; talks to Discourse's stock REST/JSON API + User API Keys directly — **no server-side plugin required**.

Targets Android, iOS, macOS, Windows, Linux, and the web. Built on Flutter `^3.6.1` / Dart `^3.6.1`.

---

## Project family

This app is part of a small family of forum mobile apps:

| Project | Backend | Source |
|---|---|---|
| **discourseapp** *(this repo)* | Discourse | [github.com/forumcopilot/discourse-app](https://github.com/forumcopilot/discourse-app) |
| **xenforoapp** | XenForo (via the Forum Copilot add-on) | [github.com/forumcopilot/xenforoapp](https://github.com/forumcopilot/xenforoapp) |
| **ForumCopilot.com** | Hosted SaaS (multi-forum, push relay, white-label apps) | [forumcopilot.com](https://forumcopilot.com) |

The lineage:

- **[ForumCopilot.com](https://forumcopilot.com)** is the original product — a hosted service that builds white-label mobile apps for forum communities and handles push delivery, app-store releases, and per-forum branding.
- **[xenforoapp](https://github.com/forumcopilot/xenforoapp)** is the open-source single-forum template extracted from ForumCopilot for XenForo communities, paired with a server-side `FC_XenForo2` PHP add-on that exposes a unified forum API.
- **discourseapp** *(you are here)* is the Discourse-native sibling: same UI shell, same SDK shape (`forumcopilot_sdk`), but the proxy layer talks to Discourse's stock REST endpoints + User API Keys instead of an XF plugin. No server-side plugin in v1 — the app is a pure REST client.

---

## What works today

The app is past the bootstrap phase and exercises most of Discourse's read + write surface natively.

### Browsing & reading
- **Home** is a Discourse-native TabBar of **Latest / New / Unread / Top**. The Top tab has a period selector (All / Yearly / Quarterly / Monthly / Weekly / Daily) that maps to `/top/{period}.json`.
- **Categories** browser with native Discourse styling — coloured stripe on each tile (parsed from the category's `color`/`text_color`) plus topic-count badge. Sub-categories and category-filtered topic lists.
- **Topic view** — rendered from Discourse's `cooked` HTML via `flutter_html` (Markdown, oneboxes, quoted posts, syntax-highlighted code, mentions, native emoji).
- **Tags** — chips on topic rows; tap a chip to see all topics with that tag (`/tag/{name}.json`); global Tags directory (`/tags.json`) reachable from the hamburger drawer with search + popularity/alphabetical sort.
- **Polls** — voting widget at the top of a topic backed by `PUT /polls/vote` with full chart/result rendering.
- **Suggested Topics** footer card at the bottom of every topic, mirroring Discourse's web client.
- **Solution indicator** — green banner on accepted-answer posts (requires `discourse-solved`).

### Authentication
- **User API Key handshake** — RSA-2048 keypair, OAEP decryption, in-app webview for grant. No plugin needed; lands a stock User API Key with `read/write/session_info/notifications/message_bus/one_time_password` scopes.
- Custom URL scheme `discourseapp://auth-callback` for the grant redirect.

### Writing
- **Markdown composer** — first-party Discourse-flavored Markdown (the BBCode pipeline inherited from XF was removed in Phase 5.10).
- **New topic** with category + tag selection.
- **Reply / quote / edit / delete**.
- **Attachments** — image and file uploads via `/uploads`.
- **Server-side drafts** — composer state round-trips through `/drafts.json` so a draft written in the app appears in the web composer and vice versa (`new_topic` / `topic_{id}` keys).

### Social
- **Like / unlike** posts (`/post_actions`).
- **Emoji reactions** (`discourse-reactions`) — long-press a like to open the emoji picker; chips render under the post body with viewer-reacted highlighting; tap a chip to toggle.
- **Bookmarks** — toggle on any post; full bookmarks list reachable from your profile (`/u/{me}/bookmarks.json`).
- **Follow / unfollow** users (requires `discourse-follow` plugin).
- **Notifications** — `/notifications.json` feed with type-aware rendering; badge count + list both read from the same endpoint.

### Plugin integrations
- **`discourse-solved`** — green Solution banner on accepted answers + `status:solved` / `status:unsolved` search filters.
- **`discourse-reactions`** — emoji reactions picker + chips (see Social).
- **`discourse-post-voting`** — Stack-Overflow-style up/down vote arrows on Q&A topics (topics with `subtype: 'question_answer'`).
- **Discourse Chat** — full channel browser + channel view + composer + DM support. Channels list (`/chat/api/me/channels`) sorted unread-first with mention/unread badges; channel view polls `/chat/api/channels/:id/messages` every 4s for new messages; send / edit / delete / mark-read all wired. UI is ported from the [qhtt xenforoapp](https://github.com/forumcopilot/xenforoapp/) Siropu chat — generic enough that the API swap was clean.
- **`discourse-follow`** — Follow/Unfollow button on user profiles (when the plugin is installed).

### Notification levels
- Tap the bell on any topic or category for the full **Watching / Tracking / Normal / Muted** picker (plus *Watching First Post* on categories) — `POST /t/{id}/notifications`, `POST /category/{id}/notifications`.

### User profile
- Trust level chip (TL0–TL4), badge row, follow button, send-message button, bookmarks button.
- Recent replies feed.

### Search
- Free-text search with a structured filter sheet: status (`open` / `closed` / `solved` / `unsolved` / `noreplies` / `public` / `archived`), personal (`in:bookmarks` / `in:liked` / `in:posted` / `in:watching` / `in:tracking` / `in:seen` / `in:unseen`), tags, sort order (relevance / latest / likes / views / latest_topic).

### Moderation (visible to staff users)
- Pin / unpin · Close / reopen · Archive / unarchive · List / unlist · Rename · Soft and hard delete · Move topic · Split posts · Merge topics · Ban / silence users.

### Localisation
- ARB-based; English template at `lib/l10n/app_en.arb`; per-locale files for de/es/fr/it/ja/ko/nl/pt/ru/zh. Discourse-native terminology — *Topic* / *Category* / *Watching* / *Solution*, not the XF-flavored equivalents.

---

## Not yet implemented

- **Push notifications** — disabled by default. Discourse's `push_url` registration is wired on the User API Key, but the relay backend that converts those POSTs into FCM/APNs deliveries is shared with [xenforoapp's push setup](https://github.com/forumcopilot/xenforoapp#push-notifications-optional) and is the Phase 3 deliverable. Until then the app starts cleanly without Firebase config files.
- **Chat over MessageBus** — Chat currently polls every 4s. The Discourse web client subscribes to `/chat/:channel_id` over MessageBus + websockets for sub-second latency. A follow-up phase could swap polling for MessageBus subscription (would also benefit topic live-updates and the notifications badge).
- **Chat reactions + threads + uploads** — Chat messages don't yet support emoji reactions, threaded replies, or file uploads. Each is a separate plugin endpoint (`/chat/api/channels/:cid/messages/:mid/reactions`, `/chat/api/channels/:cid/threads/...`).
- **Account-settings page** — Email + password updates land via the proxy (Phase 5.12), but inline username change, 2FA setup, and avatar upload are still stubbed out.
- **Other Discourse plugins** — Calendar, Cakeday, Assign, Templates aren't surfaced yet. Each follows the reactions / post-voting / chat pattern (typed model + proxy method + small UI).
- **Markdown preview in the composer** — text-only editor for now; rendered preview is a planned follow-up.

The Phase 5.x history at the bottom of this README has the full feature timeline.

---

## Prerequisites

- **Flutter SDK** `^3.6.1`
- **Dart SDK** `^3.6.1`
- **Xcode** (for iOS and macOS builds)
- **Android Studio / Android SDK** (for Android builds)

---

## Build and run

### 1. Install Flutter

Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) and confirm `flutter doctor` is happy.

### 2. Clone

```bash
git clone https://github.com/forumcopilot/discourse-app.git
cd discourse-app
```

### 3. Configure your forum

Edit `lib/config/app_forum_config.dart` and set the forum URL, name, and User API Key client identifiers:

```dart
static const String forumName = 'My Discourse Forum';
static const String forumBaseUrl = 'https://forum.example.com';
// User API Key client identifiers (registered once per app build):
static const String userApiKeyClientId = 'com.example.discourseapp';
static const String userApiKeyApplicationName = 'My Discourse App';
```

Optionally set `forumDescription`, `logoUrl`, push-relay endpoint, and Android passkey identifiers.

### 4. Install dependencies

```bash
flutter pub get
```

### 5. Generate SDK and localisations

```bash
./buildlib.sh          # codegen for forumcopilot_sdk + flutter gen-l10n
                       # Windows: buildlib.bat
```

`buildlib.sh` runs `dart run build_runner build --delete-conflicting-outputs` inside `packages/forumcopilot_sdk` and `packages/discourse_core`, then `flutter gen-l10n`. **Re-run it whenever** you change an ARB file or a `dart_mappable`-annotated class.

> ⚠ On Dart 3.10 the `dart_mappable` build hook is currently broken (`'dart compile' does not support build hooks, use 'dart build' instead`). When you hit this, hand-edit the affected `.mapper.dart` file — see the recent commits for `acceptedAnswer → isSolution` or the `trustLevel` addition for the pattern.

### 6. Run

```bash
flutter run -d macos     # or -d chrome, -d <ios-device>, -d <android-id>
```

### 7. Release build

```bash
flutter build macos      # or ios, android, web
```

---

## Local development against Discourse

The simplest setup is to clone Discourse locally and seed it with demo data.

```bash
git clone https://github.com/discourse/discourse.git /path/to/discourse
cd /path/to/discourse
bin/dev                                                 # boots Discourse at localhost:4200

# in another shell, populate demo content (idempotent):
cd /path/to/discourseapp
./scripts/seed_demo.sh                                  # wraps bin/rails runner

# … or point at a different Discourse install:
DISCOURSE_DIR=/elsewhere ./scripts/seed_demo.sh
```

The seed script (`scripts/seed_discourse_demo.rb`) creates:

- **10 users** spread across trust levels: `alice` TL3, `bob` TL2, `carol` TL1, `dave` TL0, `eve` TL4 (Leader), `mallory` (moderator), plus `frank` / `grace` / `henry` / `ivy` for diversity in chat + topics. Password for all: `demo-password-1234!`.
- **3 categories** (General / Support / Announcements) + **13 tags**.
- **~16 topics** in a variety of states — open, closed-and-archived, unlisted, globally pinned, solved (via `discourse-solved`), with embedded polls, with Q&A subtype (`discourse-post-voting`), with reply chains. Timestamps are spread from 8 min ago through 2 weeks ago so the Latest feed feels real.
- **~90 posts**, **80+ likes**, **~25 emoji reactions** (via `discourse-reactions`), **6 post-voting up/down votes**.
- **10 bookmarks**, **2 server-side drafts**, **~10 badge grants**, per-topic and per-category notification levels.
- **6 PMs (conversation-style)** covering every demo user — 1:1, 3-person group, mod-question. These populate the Messages tab.
- **5 chat channels**:
  - `#demo-watercooler` — 35 messages, 10 members, with one synthetically-edited message so the *(edited)* indicator renders.
  - `#mobile-dev` — 13 messages, focused tech thread.
  - `alice ↔ bob` DM — 6 messages.
  - (plus older test channels from previous runs)

Re-running is idempotent throughout. Use this to exercise every Phase 5 feature in the app — log in as `alice` for the most-populated view (PMs, drafts, bookmarks, badges).

---

## Repository layout

```
lib/                                       # the app
├─ config/app_forum_config.dart            # the only file a fork normally edits
├─ controllers/                            # GetX controllers
├─ services/                               # init, push, site proxy wiring
├─ views/                                  # pages + widgets
├─ core/                                   # logging, error handling, cache
├─ l10n/                                   # ARB files + generated output
└─ utils/                                  # url helpers, time formatting, drafts

packages/forumcopilot_sdk/                 # forum-agnostic abstractions
├─ lib/interfaces/                         # IFC*Proxy contracts
├─ lib/models/                             # FC*Result wrappers + entities
└─ lib/factory/                            # SiteProxyFactory

packages/discourse_core/                   # Discourse implementation
├─ lib/factory/                            # DiscourseProxyFactory
├─ lib/src/proxy/                          # Per-area proxies (Account, Topic, Post, Search, ...)
├─ lib/src/data/                           # Typed Discourse models (bookmark, badge, suggested topic, ...)
├─ lib/src/network/                        # Dio + User API Key handshake
└─ lib/src/converter/                      # Discourse JSON → FC* entities

scripts/                                   # Local dev helpers
├─ seed_discourse_demo.rb                  # Rails-runner seed (idempotent)
└─ seed_demo.sh                            # Wrapper for local discourse install

docs/guides/                               # Platform-specific setup notes
CLAUDE.md                                  # Codebase guide for Claude Code / AI tooling
```

---

## Architecture

`main.dart` runs critical init (error handling, `MemoryManager`, `ForumcopilotSdk.ensureInitialized`, `UserStateService`, `SettingsContext.loadFromDevice`) then `runApp(ForumCopilotApp())`. Firebase + push init runs **in the background after `runApp`** so the UI doesn't block on it; `PushNotificationController` is created lazily once an FCM token arrives.

`ForumCopilotApp` registers `GlobalLoaderController` and `SiteController`, then renders `GetMaterialApp` with a global loader overlay and a `UserStateBanner`. The home is `SingleForumBootstrapPage`, which builds the forum's `Site` from `AppForumConfig` and drives the rest of the app.

State is managed with **GetX** (`Get.put` / `Obx`). Navigation uses `globalNavigatorKey` (defined in `forumcopilot_sdk`) so SDK code can show dialogs (e.g. Cloudflare challenge UI) without a `BuildContext`. All forum I/O goes through `SiteProxyFactory.get*Proxy()` returning the `discourse_core` implementations registered at startup; results follow a uniform `FC*Result { result, resultText, ...payload }` shape.

### Discourse-native escape hatches

The `forumcopilot_sdk` interface was originally XenForo-shaped. Where Discourse has a concept that doesn't map cleanly, we **extend the SDK** rather than coerce Discourse to fit:

- **Tags** — first-class field on `FCTopic`; `newTopic(..., tags: [...])` on `IFCTopicProxy`; `searchTagsAsync` for composer autocomplete.
- **Polls** — `FCPoll` populated from the first post's `polls` field; `votePollAsync` routes to `PUT /polls/vote`.
- **Bookmarks** — `DiscoursePostProxy.bookmarkPostAsync` / `getBookmarksAsync` / `unbookmarkPostAsync`.
- **Notification levels** — `DiscourseSubscriptionProxy.setTopicNotificationLevelAsync` / `setCategoryNotificationLevelAsync` (the XF-style `subscribeTopicAsync(id, int subscribeMode)` is still on the interface but its int gets translated to a Discourse level).
- **Search filters** — `DiscourseSearchFilters` + `DiscourseSearchProxy.searchWithFiltersAsync` exposing the full `/search.json` operator DSL.
- **Drafts** — `DiscourseDraftController` (`saveDraftAsync` / `loadDraftAsync` / `deleteDraftAsync`), keys cross-compatible with the web composer.
- **Reactions** — `DiscourseReaction` + `toggleReactionAsync(postId, value)` / `getAvailableReactionsAsync`. Sidecar Expando on `FCPost` so the model stays untouched.
- **Post voting** — `DiscoursePostVote` + `castPostVoteAsync(postId, 'up'|'down')` / `removePostVoteAsync`. Same Expando pattern.
- **Suggested Topics** — `DiscourseSuggestedTopic` + `getSuggestedTopicsAsync(topicId)`.
- **Chat** — full `DiscourseChatProxy` (channels list, channel meta, history with `target_message_id + direction`, polling helper, send/edit/delete, mark-read). Static `forCurrentSite()` factory.
- **Badges / trust level / solved / follow** — all surfaced as native Discourse fields rather than lossy mappings to XF concepts.

Callsites that use these features cast `proxy is DiscoursePostProxy` (or similar) at the boundary, falling back to the XF-shaped interface when the proxy is a different implementation.

---

## Editing notes

- **Forum config is compile-time.** Changes to `lib/config/app_forum_config.dart` require a rebuild; there is no runtime override. `siteId = 1` is the stable local-storage key — don't change it unless you intend to invalidate persisted state.
- **Adding a UI string.** Edit `lib/l10n/app_en.arb` (template) plus the per-locale ARBs you want translated, then `flutter gen-l10n` (or rerun `buildlib.sh`).
- **Adding/changing an SDK model or proxy.** Update the interface in `packages/forumcopilot_sdk/lib/interfaces/`, the result/entity in `models/`, then implement on the Discourse side in `packages/discourse_core/lib/` (proxy + converter). Re-run `build_runner` in whichever package(s) you touched.
- **Cloudflare interceptor.** `ForumcopilotSdk.ensureInitialized` takes `onCloudflareStart`/`onCloudflareEnd` callbacks; the app uses them to hide/show the global spinner so the Cloudflare challenge UI is visible. Preserve this when refactoring init.
- **Linting.** `analysis_options.yaml` extends `package:flutter_lints/flutter.yaml`.

---

## Phase history

| Phase | What |
|---|---|
| **0** | Scaffolding — forked from xenforoapp, packages renamed, app compiles. |
| **1** | Auth + read path. Real `DiscourseClient`, User API Key handshake, all read-side proxies against stock Discourse REST. |
| **2** | Write path + PMs. Replies, new topics, edit/delete, attachments, conversation-style PMs via `archetype: 'private_message'`. |
| **4** | Composer Markdown swap + `flutter_html` post renderer + native Unicode emoji. |
| **5.0–5.1** | Tags as first-class chips + tag-filtered topic lists. |
| **5.2** | Solved indicator + bookmark proxy. |
| **5.3** | Bookmark button + bookmarks list, trust levels, server-side drafts, polls voting. |
| **5.4** | 4-level notification picker (Watching / Tracking / Normal / Muted). |
| **5.5a** | Suggested Topics footer. |
| **5.6** | Search filters (status / in: / tags / sort). |
| **5.7** | User badges row on profile. |
| **5.8** | Follow / unfollow toggle. |
| **5.9** | Moderator surface — archive / unlist / rename in topic menu. |
| **5.10** | XF cruft removal — drop dead thanks UI, BBCode renderer, lossy `subscribeMode`, retire unreachable interface methods, rename `acceptedAnswer → isSolution`, native terminology in ARB. |
| **5.11** | `discourse-reactions` plugin — typed model + Expando sidecar on FCPost + toggle API + ReactionPickerSheet (long-press the like button) + chips row below post body. |
| **5.12** | Replaced every remaining `callPluginApi` stub with real Discourse REST or graceful no-ops — forgot password / register / email update / password update / profile update / device push / passkey / report-user. First commit where `flutter analyze` returns **zero errors**. |
| **5.13** | Native tag input on new topics — chip field with `/tags/filter/search.json` autocomplete, configurable maxTags cap, `extraHeader` slot on the composer. `IFCTopicProxy.newTopic` grew an optional `tags: List<String>?` parameter. |
| **5.14** | `discourse-post-voting` plugin — typed `DiscoursePostVote` model, `POST/DELETE /vote.json`, vertical up/down arrow column on Q&A topics with optimistic flip + revert. |
| **5.15** | **Discourse Chat support** — channels + messages + send/edit/delete + polling lifecycle. ChatChannelListPage (sorted unread-first, mention badges, DM/TopicChat/Category icons), ChatChannelView (auto-scroll, load-older on scroll-up, long-press → edit/delete sheet), ChatComposer (rounded input + send button). UI ported from the qhtt xenforoapp's Siropu chat. Static `DiscourseChatProxy.forCurrentSite()` accessor avoids touching the typed IFC*Proxy registry. |
| **5.16** | Fix: notifications list silently empty because `_toAlert` wrote ISO 8601 into `FCAlert.timestamp` while the consumer did `int.parse`. Convert to millisecond-epoch string in the proxy. |
| **5.17b** | **Tags tab** — new primary bottom-nav surface (`Home / Categories / Tags / Messages / Notifications / Profile`). `DiscourseTag` model + `DiscourseTopicProxy.getAllTagsAsync` (sorted by topic count desc, PM-only hidden by default). `TagsTab` widget with search input + sort-mode toggle (popularity ↔ alphabetical); rows show name + description + count badge. Drills into the existing `TagTopicsPage` from Phase 5.1. First step of the wider home/forums reorganization — see commit history for the staged plan (5.17a Categories rename, 5.17c Home sub-tabs Latest/New/Unread/Top, 5.17d Profile consolidation). |
| **5.17a** | **Discourse-native Categories** — the "Forums" tab is now Categories everywhere it surfaces. Each tile gets a coloured stripe down its left edge (parsed from the category's `color` / `text_color` hex) and a topic-count badge in the chip row. `DiscourseForumProxy` stamps a `DiscourseCategoryMeta` Expando sidecar (color / text-color / topic-count / post-count / slug) so the SDK's `FCForum` stays untouched — the rendering layer reads the sidecar via a public `metaFor(FCForum)` accessor. |
| **5.17c** | **Home as TabBar** — replace the XF-flavoured Latest/Unread/Subscribed/Participated sub-tabs with Discourse-native Latest / New / Unread / Top. New `NewTopicsList` widget (setState-based, no GetX, ~210 LOC) backed by `/new.json` via the existing `getNewTopicAsync`. New `TopTopicsList` widget plus `DiscourseTopicProxy.getTopTopicsGlobalAsync({period})` mapping to `/top/{period}.json`; ChoiceChip strip lets the user flip between All / Yearly / Quarterly / Monthly / Weekly / Daily. Both lists mirror the public surface of `LatestTopicsList` (`buildTopicItems` / `buildEmptyState` / `buildErrorOrNotSignedInWidget` / `resetList` / `refreshList` / `loadMore` / `hasMoreItems`) so `TopicListTab`'s IndexedStack hidden state-holder pattern just slots them in. |
| **5.17d** | **Profile consolidation + bottom nav back to 5 items** — Messages moves out of the primary bottom nav and into Profile (Discourse web nests PMs in the user menu the same way). Bottom nav becomes `Home / Categories / Tags / Notifications / Profile`. New `_ProfileActionsSection` on the Profile tab with three rows — **Messages** (opens the existing `PrivateMessageListTab` via a new `MessagesPage` Scaffold wrapper), **Bookmarks**, and **Drafts**. Drafts is brand-new: `DiscourseDraft` model + `DiscoursePostProxy.getMyDraftsAsync` against `/drafts.json`, `DraftsListPage` renders each draft (icon / topic title / body excerpt / time-ago / delete button) and resumes into the right composer surface (`topic_*` → ReplyPage, `new_topic` → NewTopicPage, fallback → PostPage). Closes the entire Phase 5.17 reorganization — the app's primary IA now matches Discourse's web client. |
| **5.18a** | **Hamburger drawer + Chat-or-Messages bottom-nav slot** — adds a leading drawer ("More" menu) following Discourse web's mobile IA. Bottom nav becomes `Home / Categories / {Chat or Messages} / Notifications / Profile`: the third slot is **Chat** when the `discourse-chat` plugin is installed, otherwise **Messages** (PMs). Detection uses a route probe on `/chat/api/me/channels` (404 ⇒ plugin missing, anything else ⇒ installed) — `/site.json`'s `enabled_plugins` field isn't exposed to anonymous viewers, so probing is the most portable signal. `SiteDrawer` widget hosts Tags (moved here from bottom nav), placeholder rows for Users / Groups / Badges (real screens land in 5.18c), Notification settings, Privacy & Terms (5.18b), and Sign in / Sign out. New `ChatTabAppBar` + an `embedded` mode on `ChatChannelListPage` so the channels list renders cleanly inside the parent Scaffold. Profile Messages row hides automatically when Messages is the bottom-nav slot to avoid duplication. |
| **5.18c** | **Community directories — Users / Groups / Badges.** Three new screens reachable from the drawer's Community section, replacing the 5.18a placeholder rows. **Users**: `DiscourseDirectoryItem` model (username + avatar + 7 activity stats) + `DiscourseUserProxy.getDirectoryItemsAsync({period, order, page})` against `/directory_items.json`. `UsersDirectoryPage` exposes both selectors (Sort: Likes / Posts / Topics / Active; Period: All / Year / Quarter / Month / Week / Day) as horizontal ChoiceChip strips with infinite scroll. Rows tap into the existing `UserProfilePage`. **Groups**: new `DiscourseGroup` model + Discourse-only `DiscourseGroupProxy` (mirrors `DiscourseChatProxy`'s `forCurrentSite()` factory) with `getGroupsAsync` / `getGroupAsync` / `getGroupMembersAsync` against `/groups.json` and `/groups/{name}/members.json`. `GroupsListPage` shows every visible group with built-in groups (admins, staff, trust_level_*) muted. `GroupDetailPage` shows header (name + bio + member count) plus paginated members list. **Badges**: `DiscourseUserProxy.getAllBadgesAsync` against `/badges.json`, sorted by grant_count desc. `BadgesDirectoryPage` groups by tier (Gold / Silver / Bronze sections) with a bottom-sheet detail view on tap (description + grant count). |
| **5.18d** | **UI consistency sweep across Phase 5.17 / 5.18 surfaces.** Audit found isolated divergences in the new screens — hardcoded `withOpacity(0.3)` / `withOpacity(0.4)` instead of design tokens, ad-hoc `radius: 18 / 20 / 24` instead of a single avatar scale, `letterSpacing: 0.8` magic number on uppercase section labels, duplicated `AppBar` + empty-state boilerplate across 7+ files. Fixes: (1) four new tokens — `opacityDivider` (0.4), `avatarRadiusS/L` (18 / 24, joining the existing `avatarRadiusM` 20), `letterSpacingExtraWide` (0.8); (2) three new shared widgets — `SimpleListAppBar` (replaces per-screen AppBar literals on every drawer-pushed destination + Chat tab), `EmptyStateView` (icon + message + optional hint column with a `.scrollable` variant for `RefreshIndicator` use), `TrustLevelChip` (used in Users directory + group members); (3) full sweep of every Phase 5.17 / 5.18 file replacing magic numbers with tokens and ad-hoc widgets with the new shared ones. No behavioural change — purely visual / structural consistency. |
| **5.19** | **Fix end-to-end image-attachment flow against Discourse.** The XF→Discourse port left attachments completely broken: upload to `/uploads.json` succeeded and the app captured the upload's numeric id, but every post-proxy method (`newTopic` / `replyPostAsync` / `saveRawPostAsync` / `createMessageAsync`) accepted `attachmentIds` and **ignored them** — POSTing to `/posts.json` with `raw: textBody` and no reference to the upload. Discourse stored the orphaned upload for 7 days then garbage-collected it. The composer's "tap to insert" also emitted XenForo `[ATTACH=42][/ATTACH]` BBCode that Discourse's Markdown engine doesn't parse. Fixes: (1) `DiscourseAttachmentProxy` now passes `upload_type` correctly (stops hardcoding `'composer'`), drops the no-op `synchronous=true` param, and sends `for_private_message=true` for PM uploads so the upload's access is scoped to sender + recipient (without that flag, PM attachment URLs are public to anyone who knows them — a real privacy leak); (2) new `BaseDiscourseProxy.appendAttachmentMarkdown(raw, attachmentRefs)` helper builds Discourse Markdown image refs (`![image](upload://abc.png)`) or file refs (`[file\|attachment](upload://abc.zip)`) from each upload's `short_url` and appends them to the post body before submission, with dedup against refs already inline; (3) all four composer pages (new-topic / reply / new-PM / reply-PM) plus the two edit pages (edit-post / edit-PM-message) now store the upload's `short_url` (carried via `FCAttachmentUploadResult.groupId` because the XF-shaped SDK has no dedicated short_url field) in `_attachmentIds` instead of the useless numeric id; (4) `MessageComposePage._insertAttachmentBBCode` rewritten to emit Discourse Markdown at the cursor instead of XF BBCode, with the proxy's append helper deduping against inline refs so attachments aren't doubled. End-to-end: attach photo → upload → on send, body gets `\n\n![image](upload://...)` appended → Discourse renders inline. |
| **5.20a** | **Trim dead-end UI surfaces.** A static audit of every proxy method showed two UIs that visibly failed on Discourse: the **legacy username/password login form** (form fields captured but ignored — `_handleLogin` immediately opens the User API Key webview, which is what handles credentials / 2FA / passkeys / SSO) and the **"Report user" menu item** on user profiles (`userProxy.reportUserAsync` returns guidance text saying "open one of their posts and use the flag action" — net-negative UX vs just hiding the button). Fixes: (1) `login_page.dart` rebuilt as a single "Sign in with {domain}" CTA — explanation copy ("you'll be taken to {domain} to sign in"), forgot-password link kept, reassurance footer ("your password is never seen by this app"), passkey OutlinedButton removed (passkey login happens inside the webview on Discourse's own login screen). Drops ~250 LOC and four passkey-validation imports; (2) `user_profile_page.dart` "Report user" PopupMenuItem + `_handleReportUser` (286-line dialog flow) deleted. Per-post flagging via `reportPostAsync` remains fully wired in `post_actions.dart`. Adjacent Ban / Spam Cleaner menu items left untouched. |
| **5.20b** | **Notification preferences sync server-side.** The legacy notification settings page had nine XF-shaped per-type toggles (newPosts / replies / mentions / quotes / likes / subscriptions / PMs / system) that persisted to SharedPreferences only — flipping anything did nothing the server could see. Discourse doesn't model notifications as per-type opt-out: it decides what is a notification, and the user controls *delivery cadence* (email frequency, like aggregation, etc.). Fix: rebuild the page against Discourse's real preference surface (`user_option.*` on `PUT /u/{u}.json`, with the field set from `UserUpdater::OPTION_ATTR`). New typed model `DiscourseUserNotificationPrefs` + two proxy methods (`DiscourseAccountProxy.getNotificationPrefsAsync` / `updateNotificationPrefsAsync`). New `NotificationSettingsPage` surfaces six controls that genuinely round-trip: **Email when away** (`email_level`: Always / Only when away / Never), **Email for messages** (`email_messages_level`, same enum), **Send activity digest** (`email_digests` toggle + Daily/Weekly/Monthly picker via `digest_after_minutes`), **Mailing list mode** (`mailing_list_mode` toggle, auto-disables digest), **When someone likes my post** (`like_notification_frequency`: Always / First-time-then-daily / First-time-only / Never), **When I reply** (`notification_level_when_replying`: Watching / Tracking / Normal). Each control PUTs immediately on change with optimistic UI + revert on network failure. Drops ~780 LOC of dead toggle code. |
| **5.20c** | **Full notification type coverage + per-type icon badges.** Discourse documents 39 notification types in `app/models/notification.rb`; the proxy's `_readableNotification` and `_alertActionVerb` only knew 12 — the other 27 (reactions, all five chat-plugin types, bookmark/event/topic reminders, post-approval, badge grants with name, group mentions, membership requests, consolidated digests, watching-first-post, code-review approval, assignment, votes-released, new-features, admin-problems, linked-consolidated, custom plugin notifications) silently fell through to a generic "New activity in '{topic}'". The render layer also never set a per-type icon — every row looked identical. Fix: (1) `social_proxy.dart` extended with constants for every documented type and a friendly-text branch each, reading supplementary fields (`group_name`, `chat_channel_title`, `badge_name`, `count`, etc.) out of the notification's `data` blob; (2) `_alertActionVerb` extended to emit a verb for each new type (`reaction`, `chat`, `reminder`, `approved`, `assigned`, etc.); (3) new `NotificationBadgeStyle.forAction` helper in `notification_list_item.dart` maps each verb to an `IconData` + a theme-colour role; (4) avatar wrapped in a `Stack` so a small overlay badge — Material-rounded icon on the right tint (primary for replies/mentions, error for likes, tertiary for reactions/reminders/badges, etc.) — renders bottom-right with a surface-coloured ring so it punches out of the avatar in both light + dark themes. Notifications now scan visually like Discourse web: you can tell a like from a chat mention from a badge grant at a glance. |
| **5.20d** | **Forum Settings page rebuilt as a curated Discourse-native section list.** Previously the page called `getUserSettingsCategories` (STUB returns `[]` on Discourse — Discourse exposes preferences as a flat `user_option.*` block, not as XF-style nested categories) and rendered a permanent "No settings available" empty state with just a Delete Account block at the bottom. Rebuilt with three real entries: **Notifications** (deep-links to the `NotificationSettingsPage` we shipped in 5.20b), **Manage account on web** (opens `/my/preferences` in the system browser for everything we don't model in-app — themes, sidebar tags, watched categories, security, group memberships), **Delete account** (existing dialog + external launch to forum's contact / staff flow; Discourse handles deletion per its own policy). The standalone `settings_category_page.dart` (per-category sub-screen for the XF categories model) is now unreachable and deleted. The three STUB methods on `DiscourseAccountProxy` (`getUserSettingsCategories` / `getUserSettings` / `updateUserSettings`) stay as no-op IFC contract fulfilment but no longer drive any UI. |
| **5.20e** | **Dormant-shim the XF-shape PM box proxy.** `DiscoursePrivateMessageProxy` was 433 LOC of working Discourse REST calls that mapped the XF traditional "inbox / sent boxes with single messages" contract onto Discourse's topic-shaped reality (`/topics/private-messages-{inbox,sent}/{u}.json`). Every method was WIRED but **0 UI callsites** reached any of them — the app's live PM flow uses `IFCPrivateConversationProxy` (conversation-style) exclusively. The 433 LOC was a trap: anyone wiring future PM UI to it would get a half-broken XF-shape view of Discourse PMs (the lossy `markPmReadAsync` / `markPmUnreadAsync` were no-ops). Replaced with a thin 130-LOC shim where every method fails loudly with `"Use IFCPrivateConversationProxy on Discourse — discourseapp models PMs as conversations, not as XF-style inbox / sent boxes."` IFC contract still satisfied so the typed factory registry compiles; future contributors get a clear pointer instead of stumbling into the shape mismatch. The pre-5.20e implementation is recoverable from git history at commit `83ca240` if a real XF-shape use case ever emerges. |
| **5.22** | **Inline profile editing (Bio / Location / Website).** The user's own profile (Profile tab → `ProfileInfoSection`) was previously read-only; editing bio / location / website meant leaving the app. New `EditProfilePage` (~250 LOC) wires `DiscourseAccountProxy.updateProfile` against `PUT /u/{me}.json` with the three top-level user-profile fields Discourse's `UserUpdater` recognises (`bio_raw`, `location`, `website`). Multiline About field with 3000-char counter; URL field with basic spaces-rejection; AppBar Save button with loading spinner; pops with `true` on success and ProfileTab re-fetches user info to re-render with the new values. Side-by-side **Edit profile / Settings** row replaces the lone Settings tonal button in the Profile tab header. Avatar upload was already wired in `profile_picture_section.dart` from earlier work (camera-badge overlay calls `uploadAvatarAsync` two-step against `/uploads.json` + `/u/{me}/preferences/avatar/pick.json`). Display Name editing intentionally deferred — `user.name` isn't surfaced through the `FCUser` converter today, so we can't seed the field with the existing value. The web-prefs link in Settings covers it. |

---

## Open-source safety checklist

Before publishing your own fork:

1. Set forum URL, name, and branding values in `app_forum_config.dart`.
2. Register your own User API Key client identifiers (one per app build).
3. Set your own bundle/application IDs for Android/iOS/macOS.
4. Set your Apple Development Team in Xcode project settings before signing.
5. Configure passkey association files (`assetlinks.json`, `apple-app-site-association`) with your package/team IDs and certificate fingerprints.
6. If wiring push later: add your own Firebase config files; never commit a service-account JSON.

---

## Contributing

Issues and pull requests welcome. For larger Discourse-native features, please open an issue first so we can discuss whether the SDK interface needs an extension (`DiscourseFooProxy` method) versus a lossy XF mapping.

When working with Claude Code or another AI coding tool, `CLAUDE.md` documents the codebase conventions and phase plan — point your agent at it first.

---

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for the full text.
