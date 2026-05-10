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
- **Latest / Unread / Subscribed / Participated** feeds, with infinite scroll.
- **Categories** browser, sub-categories, category-filtered topic lists.
- **Topic view** — rendered from Discourse's `cooked` HTML via `flutter_html` (Markdown, oneboxes, quoted posts, syntax-highlighted code, mentions, native emoji).
- **Tags** — chips on topic rows; tap a chip to see all topics with that tag (`/tag/{name}.json`).
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
- **Bookmarks** — toggle on any post; full bookmarks list reachable from your profile (`/u/{me}/bookmarks.json`).
- **Follow / unfollow** users (requires `discourse-follow` plugin).
- **Notifications** — `/notifications.json` feed with type-aware rendering.

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
- **Account-settings page** — Discourse-specific bits (email, username change, 2FA, etc.) still call legacy XF stubs that throw at runtime. Tagged with `TODO(phase-1)` in `packages/discourse_core/lib/src/proxy/account_proxy.dart`.
- **Discourse Chat / Reactions plugin / Post-voting / Calendar** — installed on many Discourse forums but not yet surfaced in this client.
- **New / Top home feed tabs** — `/new.json` and `/top.json` exist on the SDK side but aren't wired into the home page yet (boilerplate-heavy; deferred).

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

- 6 users at every trust level + a moderator (`alice` TL3, `bob` TL2, `carol` TL1, `dave` TL0, `eve` TL4, `mallory` mod). Password for all: `demo-password-1234!`.
- 3 categories (General / Support / Announcements) + 13 tags.
- 8 topics in a variety of states — open, closed-and-archived, unlisted, globally pinned, solved (via `discourse-solved`), with embedded polls, with reply chains.
- 5 bookmarks, 2 server-side drafts, ~10 badge grants, per-topic and per-category notification levels.

Use this to exercise every Phase 5 feature in the app.

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

- **Tags** — first-class field on `FCTopic`.
- **Polls** — `FCPoll` populated from the first post's `polls` field; `votePollAsync` routes to `PUT /polls/vote`.
- **Bookmarks** — `DiscoursePostProxy.bookmarkPostAsync` / `getBookmarksAsync` / `unbookmarkPostAsync`.
- **Notification levels** — `DiscourseSubscriptionProxy.setTopicNotificationLevelAsync` / `setCategoryNotificationLevelAsync` (the XF-style `subscribeTopicAsync(id, int subscribeMode)` is still on the interface but its int gets translated to a Discourse level).
- **Search filters** — `DiscourseSearchFilters` + `DiscourseSearchProxy.searchWithFiltersAsync` exposing the full `/search.json` operator DSL.
- **Drafts** — `DiscourseDraftController` (`saveDraftAsync` / `loadDraftAsync` / `deleteDraftAsync`), keys cross-compatible with the web composer.
- **Badges / trust level / solved / follow / suggested topics** — all surfaced as native Discourse fields rather than lossy mappings to XF concepts.

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
