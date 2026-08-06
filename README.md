# Discourse App

An open-source Flutter mobile app for a **single Discourse community**.

Point it at your forum's URL, build it, ship it. It talks to Discourse's **stock REST/JSON API** using **User API Keys** — the same mechanism Discourse's own official app uses. There is **no server-side plugin to install**, no admin API key to hand out, and nothing to run alongside your forum.

Targets Android, iOS, macOS, Windows, Linux, and web. Flutter `^3.6.1` / Dart `^3.6.1`. MIT licensed.

---

## Part of Forum Copilot

This app comes out of **[Forum Copilot](https://forumcopilot.com)**, a service that builds and ships white-label mobile apps for forum communities — branding, app-store releases, and push delivery handled for you.

| Project | Backend | Source |
|---|---|---|
| **discourse-app** *(this repo)* | Discourse | [github.com/forumcopilot/discourse-app](https://github.com/forumcopilot/discourse-app) |
| **xenforoapp** | XenForo (via the Forum Copilot add-on) | [github.com/forumcopilot/xenforoapp](https://github.com/forumcopilot/xenforoapp) |
| **ForumCopilot.com** | Hosted SaaS — multi-forum, push relay, white-label builds | [forumcopilot.com](https://forumcopilot.com) |

This repo is the Discourse-native sibling of `xenforoapp`: same UI shell, same SDK shape, but the data layer speaks Discourse REST instead of an XF plugin.

### 💼 We welcome customization work

Want this app tailored to your community — custom branding, extra screens, a plugin integration we haven't built yet, or the whole thing published to the App Store and Play Store under your name? **We do that.**

**Get in touch: [forumcopilot@gmail.com](mailto:forumcopilot@gmail.com)**

Fork it and go it alone under the MIT license, or hand it to us — both are fine.

---

## How it works

Three layers, each replaceable:

```
┌──────────────────────────────────────────────────────────────┐
│  lib/main.dart          thin runner: init, then runApp()      │
├──────────────────────────────────────────────────────────────┤
│  packages/discourse_ui  every screen, controller and widget   │
│                         + app_forum_config.dart  ← you edit   │
├──────────────────────────────────────────────────────────────┤
│  packages/forumcopilot_sdk    forum-agnostic contracts        │
│                         IFC*Proxy interfaces, FC* entities    │
├──────────────────────────────────────────────────────────────┤
│  packages/discourse_core      the Discourse implementation    │
│                         REST calls + JSON → FC* converters    │
└──────────────────────────────────────────────────────────────┘
                              ↕ HTTPS
                        your Discourse forum
```

**Configuration is compile-time.** `AppForumConfig` in `packages/discourse_ui/lib/config/app_forum_config.dart` holds the forum URL, display name, and branding. There is no runtime forum picker — that is the point of a single-forum app.

**Authentication is Discourse's User API Key handshake.** On first sign-in the app generates an RSA-2048 keypair, opens your forum's own `/user-api-key/new` page in an in-app webview, and the user signs in there — with their password, 2FA, passkey, or SSO, whatever your forum already uses. Discourse returns an encrypted payload; the app decrypts it with its private key and stores the resulting API key. **The app never sees the user's password.** No plugin, no OAuth app registration, no admin token.

**Data flows through a proxy layer.** UI code never calls HTTP directly — it asks `SiteProxyFactory` for a typed proxy (`getTopicProxy()`, `getPostProxy()`, …) and gets back the `discourse_core` implementation. Each proxy calls stock Discourse endpoints and converts the JSON into the SDK's `FC*` entities. Responses share one shape: `FC*Result { result, resultText, …payload }`.

**Posts render as Discourse renders them.** Discourse cooks Markdown to HTML server-side and serves it in the post stream's `cooked` field. The app renders that HTML directly with `flutter_html` — so oneboxes, quotes, code blocks, mentions and emoji look the way your forum's own theme produces them. Embedded YouTube and Twitter/X links are lifted out and given native cards, since a mobile app can't run an iframe.

**State is GetX** (`Get.put` / `Obx`), navigation goes through a `globalNavigatorKey` so SDK code can raise dialogs (e.g. a Cloudflare challenge) without a `BuildContext`.

---

## What works today

<details open>
<summary><b>Browsing &amp; reading</b></summary>

- **Home** — Discourse-native tabs: **Latest / New / Unread / Top**, with a period selector on Top (All / Yearly / Quarterly / Monthly / Weekly / Daily).
- **Categories** — coloured stripe per category (from its own `color` / `text_color`), topic-count badges, sub-categories, category-filtered lists.
- **Topic view** — rendered from Discourse's `cooked` HTML: Markdown, oneboxes, quoted posts, code blocks, mentions, native Unicode emoji, lightboxed images.
- **Tags** — chips on topic rows, tag-filtered lists, and a global Tags directory with search and popularity/alphabetical sort.
- **Polls** — full voting widget with result charts.
- **Suggested Topics** footer, mirroring Discourse web.
- **Solution banner** on accepted answers (`discourse-solved`).
</details>

<details>
<summary><b>Writing</b></summary>

- **Markdown composer** — Discourse-flavored Markdown, the only markup Discourse actually cooks.
- New topic with category + tag selection; reply, quote, edit, delete.
- **Attachments** — image and file uploads via `/uploads`, inserted as real Discourse upload refs.
- **Server-side drafts** — composer state round-trips through `/drafts.json`, so a draft started in the app appears in the web composer and vice versa.
- **Post revisions** — view a post's edit history.
- **Whisper / wiki** — staff whispers and wiki-editable posts.
</details>

<details>
<summary><b>Social &amp; account</b></summary>

- **Likes and emoji reactions** (`discourse-reactions`) behind one canonical affordance — tap to like, long-press for the emoji picker, chips below the post.
- **Bookmarks** with reminders, **follow/unfollow** (`discourse-follow`), **ignore user**.
- **Notifications** — the full `/notifications.json` feed with type-aware rendering and per-type icon badges across all 39 Discourse notification types.
- **Notification levels** — Watching / Tracking / Normal / Muted on topics, categories and tags.
- **Profile** — trust-level chip with explainer, badges, activity tabs (Replies / Topics), inline bio/location/website editing, avatar upload.
- **Account** — change email, change password, notification preferences, do-not-disturb, ignored users, invites.
- **Private messages** — conversation-style, with attachments and likes.
</details>

<details>
<summary><b>Search, chat &amp; moderation</b></summary>

- **Search** — free text plus a structured filter sheet: status (`open` / `closed` / `solved` / `unsolved` / `noreplies` / `archived`), personal scopes (`in:bookmarks` / `in:liked` / `in:posted` / `in:watching` / …), tags, and sort order.
- **Chat** (`discourse-chat`) — channel browser, channel view, composer, DMs, and message reactions. Currently polls; see *Not yet implemented*.
- **Moderation** (staff only) — pin, close, archive, unlist, rename, delete, move topic, merge topics, ban/silence, and the reviewables queue.
</details>

<details>
<summary><b>Localisation</b></summary>

ARB-based, English template at `packages/discourse_ui/lib/l10n/app_en.arb`, with de / es / fr / it / ja / ko / nl / pt / ru / zh. Terminology is Discourse-native — *Topic*, *Category*, *Watching*, *Solution*.
</details>

---

## Not yet implemented

- **Push notifications** — the client side is done: with a relay configured, the User API Key handshake requests the `push` scope and registers a `push_url`, and Discourse POSTs notifications there. What's missing is **the relay backend** that forwards those to FCM/APNs. With no relay configured the app runs exactly as before and needs no Firebase files. (Forum Copilot runs a hosted relay — [get in touch](mailto:forumcopilot@gmail.com).)
- **Chat over MessageBus** — chat polls every 4s today; Discourse web subscribes over MessageBus for sub-second latency. The same swap would speed up topic live-updates and the notification badge.
- **Chat threads and uploads** — reactions work; threaded replies and file uploads don't yet.
- **Markdown preview in the composer** — the editor is text-only for now.
- **Other Discourse plugins** — Calendar, Cakeday, Assign, Templates. Each follows the same recipe as reactions/post-voting: typed model, proxy method, small UI.

---

## Quick start

**Prerequisites:** Flutter `^3.6.1`, plus Xcode (iOS/macOS) and/or Android Studio for the platforms you target.

```bash
git clone https://github.com/forumcopilot/discourse-app.git
cd discourse-app
flutter pub get
./buildlib.sh          # codegen + gen-l10n   (Windows: buildlib.bat)
flutter run -d macos   # or -d chrome, -d <ios-device>, -d <android-id>
```

### Point it at your forum

Edit `packages/discourse_ui/lib/config/app_forum_config.dart`:

```dart
static const String forumName    = 'My Community';
static const String forumBaseUrl = 'https://forum.example.com';

/// Shown to the user on your forum's User API Key grant page.
static const String userApiApplicationName = 'My Community Mobile';
```

That's the minimum. Optional: `forumDescription`, `logoUrl`, `pushApiBaseUrl` (push relay), and the Android passkey identifiers.

The grant redirect defaults to `discourse://auth_redirect` — the universal scheme every Discourse instance already allowlists, so the handshake works against any forum without an admin changing settings. To use your own scheme instead, set `userApiAuthRedirect` and have the forum admin add it to `allowed_user_api_auth_redirects`.

### Codegen

`buildlib.sh` runs `build_runner` inside `packages/forumcopilot_sdk` and `packages/discourse_core`, then `flutter gen-l10n`. **Re-run it after** editing an ARB file or any `dart_mappable` / `json_annotation` annotated class.

> ⚠ On Dart 3.10 the `dart_mappable` build hook fails with `'dart compile' does not support build hooks`. Until that's fixed upstream, hand-edit the affected `.mapper.dart` — recent commits show the pattern.

### Release build

```bash
flutter build apk       # or ios, macos, web, windows, linux
```

---

## Local development against Discourse

Clone Discourse locally and seed it with demo content:

```bash
git clone https://github.com/discourse/discourse.git /path/to/discourse
cd /path/to/discourse
bin/dev                                    # boots Discourse on localhost:4200

# in another shell — idempotent, safe to re-run:
cd /path/to/discourse-app
./scripts/seed_demo.sh                     # or: DISCOURSE_DIR=/elsewhere ./scripts/seed_demo.sh
```

`scripts/seed_discourse_demo.rb` creates 10 users across every trust level (`alice` TL3, `bob` TL2, `carol` TL1, `dave` TL0, `eve` TL4, `mallory` moderator, plus four more; password `demo-password-1234!` for all), 3 categories, 13 tags, ~16 topics covering every state (open, closed, archived, unlisted, pinned, solved, polls, Q&A), ~90 posts, likes, reactions, votes, bookmarks, drafts, badges, 6 PMs, and 5 chat channels. Sign in as `alice` for the fullest view.

Set `forumBaseUrl = 'http://localhost:4200'` to point the app at it. For a physical Android device over USB, `adb reverse tcp:4200 tcp:4200` first.

---

## Repository layout

```
lib/
├─ main.dart                              # init + push bootstrap, then ForumCopilotApp
└─ l10n/                                  # app-level ARB

packages/discourse_ui/                    # the entire UI layer
├─ lib/config/app_forum_config.dart       # ← the file a fork normally edits
├─ lib/controllers/                       # GetX controllers
├─ lib/views/                             # pages + widgets
├─ lib/services/                          # init, push, site proxy wiring
├─ lib/utils/                             # cooked-HTML extraction, URLs, time, files
├─ lib/core/                              # logging, errors, cache, memory
├─ lib/theme/                             # design tokens + theme
└─ lib/l10n/                              # ARB files + generated localisations

packages/forumcopilot_sdk/                # forum-agnostic contracts
├─ lib/interfaces/                        # IFC*Proxy
├─ lib/models/                            # FC* entities + FC*Result wrappers
└─ lib/factory/                           # SiteProxyFactory

packages/discourse_core/                  # the Discourse implementation
├─ lib/factory/                           # DiscourseProxyFactory
├─ lib/src/proxy/                         # per-area proxies (Topic, Post, Search, Chat, …)
├─ lib/src/data/                          # typed Discourse models
├─ lib/src/network/                       # Dio client + User API Key handshake
└─ lib/src/converter/                     # Discourse JSON → FC* entities

scripts/                                  # local dev helpers (demo seeding)
docs/guides/                              # platform setup notes (icons, splash, macOS picker)
CLAUDE.md                                 # codebase guide for AI coding tools
```

---

## Extending it

The `forumcopilot_sdk` interface was originally shaped around XenForo. Where Discourse has a concept that doesn't map cleanly, the rule is: **extend the SDK to express the Discourse concept** — don't bend Discourse to fit the old shape, and don't reach for a server plugin to paper over the gap.

Order of preference:

1. Extend the SDK interface to express the Discourse concept directly.
2. Surface it as a Discourse-specific feature in the app.
3. Lossy-map at the converter layer — last resort only.

Concepts that took route 1 and are now first-class: tags, polls, bookmarks, four-level notification levels, structured search filters, server-side drafts, emoji reactions, post voting, suggested topics, badges, trust levels, accepted answers, and chat.

**To add a feature:** update the interface in `packages/forumcopilot_sdk/lib/interfaces/`, add or extend the entity in `models/`, implement it in `packages/discourse_core/lib/` (proxy + converter), re-run codegen, then build the UI in `packages/discourse_ui/`.

---

## Changelog

Full history is in [CHANGELOG.md](CHANGELOG.md); the phase-by-phase build log is collapsed at the bottom of this file.

### Unreleased

**Cooked-HTML content pipeline** *(replaces the last of the XenForo BBCode code)*
- Post link previews, video cards and the image gallery now read Discourse's cooked HTML as a DOM, mirroring the server's own `PrettyText.extract_links` rules. Previously this ran through the inherited XenForo `BBCodeProcessor`, whose URL regex swept the raw markup — so favicons, onebox thumbnails and avatar `src`s each came back as a "link in this post" and got their own preview card.
- Tapping an inline image now opens the right image. The gallery used to scan for `[IMG]` BBCode tags, which never appear in cooked HTML, so images embedded in a post were invisible to it.
- Oneboxes stay server-rendered instead of being duplicated by an app-side preview card; YouTube and Twitter/X embeds are lifted into native cards and removed from the HTML so nothing renders twice.
- `bbcode_processor.dart` (1,183 lines) and `attachment_utils.dart` deleted; `BBCodeCallbacks` renamed `PostContentCallbacks`. New `CookedContent` extractor covered by unit tests against real Discourse markup.
- Analyzer warnings down from 34 to 1 — dead null-aware operators and redundant null checks left over from the SDK's nullability tightening.

### 2026-08-05

- **Honest-shape SDK fields.** Attachment upload URLs, group totals, bookmark and search pagination now carry real server signals instead of being dropped or synthesised.
- **Purged fabricated data** (−7,700 lines). Search results, category permissions, group visibility, invite classification and account settings now report what the server actually said — including reporting failure rather than inventing a plausible zero.
- **One canonical like/reaction affordance** on posts, replacing two overlapping controls.
- **First-class fields replace all sidecars** — reactions and Q&A votes moved from `Expando` sidecars onto `FCPost` proper. Clickable badges and a trust-level explainer added.
- **Discourse-native feature wave** — bookmark reminders, tag watching, polls, post revisions, whisper/wiki, reviewables, invites, do-not-disturb, topic summary, chat DMs and chat reactions.
- **Unified profile experience**, avatar upload enabled, Discourse upload limits respected, cache-first session restore.
- **Client-side push (Phase 3)** — User API Key `push` scope and `push_url` registration; relay backend still pending.
- Fixes from a live on-device test pass and a full defect review.

### 2026-08-04

- **`discourse_ui` package extracted** — the app becomes a thin runner, so the whole UI can be hosted inside a multi-forum shell.
- **Canonical `forumcopilot_sdk` adopted**; `discourse_core` repointed at it.
- GetX singletons namespaced per site; a "Switch forum" drawer entry appears when hosted in a multi-forum app.

<details>
<summary><b>Earlier: phase-by-phase build log (Phases 0 – 5.31)</b></summary>

| Phase | What |
|---|---|
| **0** | Scaffolding — forked from xenforoapp, packages renamed, app compiles. |
| **1** | Auth + read path. `DiscourseClient`, User API Key handshake, all read-side proxies against stock Discourse REST. |
| **2** | Write path + PMs. Replies, new topics, edit/delete, attachments, conversation-style PMs via `archetype: 'private_message'`. |
| **4** | Composer Markdown swap + `flutter_html` post renderer + native Unicode emoji. |
| **5.0–5.1** | Tags as first-class chips + tag-filtered topic lists. |
| **5.2** | Solved indicator + bookmark proxy. |
| **5.3** | Bookmark button + bookmarks list, trust levels, server-side drafts, poll voting. |
| **5.4** | Four-level notification picker (Watching / Tracking / Normal / Muted). |
| **5.5a** | Suggested Topics footer. |
| **5.6** | Search filters (status / `in:` / tags / sort). |
| **5.7** | User badges row on profile. |
| **5.8** | Follow / unfollow toggle. |
| **5.9** | Moderator surface — archive / unlist / rename in the topic menu. |
| **5.10** | XF cruft removal — dead thanks UI, lossy `subscribeMode`, unreachable interface methods; `acceptedAnswer` → `isSolution`; native terminology in ARB. |
| **5.11** | `discourse-reactions` — typed model, toggle API, picker sheet, chips row. |
| **5.12** | Every remaining `callPluginApi` stub replaced with real Discourse REST or a graceful no-op. First commit with **zero analyzer errors**. |
| **5.13** | Native tag input on new topics — chip field with `/tags/filter/search.json` autocomplete. |
| **5.14** | `discourse-post-voting` — vertical up/down arrows on Q&A topics with optimistic flip. |
| **5.15** | **Discourse Chat** — channels, messages, send/edit/delete, polling lifecycle. |
| **5.16** | Fix: notifications list silently empty — ISO 8601 written where the consumer did `int.parse`. |
| **5.17a–d** | IA reorganization to match Discourse web: Categories (coloured stripes), Home as Latest/New/Unread/Top, Tags tab, Profile consolidation with Messages / Bookmarks / Drafts. |
| **5.18a,c,d** | Hamburger drawer; Chat-or-Messages bottom-nav slot with plugin probe; Users / Groups / Badges directories; UI consistency sweep with shared tokens and widgets. |
| **5.19** | **Fixed the end-to-end attachment flow** — uploads were succeeding then being ignored at post time and garbage-collected after 7 days. Also scopes PM uploads with `for_private_message` (they were publicly reachable by URL). |
| **5.20a–e** | Trimmed dead-end UI (legacy login form, report-user); notification preferences that actually round-trip to `user_option.*`; all 39 notification types with per-type icon badges; Forum Settings rebuilt; XF-shape PM box proxy reduced to a loud shim. |
| **5.22–5.26** | Inline profile editing; change email / password; Replies / Topics activity tabs; ignore user + ignored-users page; move-to-category and merge-topic mod actions. |
| **5.29** | Post-action button style guide — one shared `PostActionButton` recipe, 48×48 targets everywhere. |
| **5.30–5.31** | SDK alignment — follow/unfollow lifted onto `IFCSocialProxy`; accepted-answer methods and `canAcceptAnswer` added to `IFCPostProxy` / `FCPost`. |
| **5.45–5.47** | Server-side read tracking via `/topics/timings`; converter-fidelity audit; on-device bug-fix passes. |

</details>

---

## Before you publish a fork

1. Set the forum URL, name and branding in `app_forum_config.dart`.
2. Set your own bundle / application IDs for Android, iOS and macOS.
3. Set your Apple Development Team in the Xcode project before signing.
4. Configure passkey association files (`assetlinks.json`, `apple-app-site-association`) with your package / team IDs and certificate fingerprints.
5. If wiring push: add your own Firebase config files, and **never commit a service-account JSON**.

---

## Contributing

Issues and pull requests are welcome. For a larger Discourse-native feature, please open an issue first so we can agree on whether the SDK interface should be extended rather than lossily mapped — see *Extending it* above.

Working with Claude Code or another AI coding tool? Point it at `CLAUDE.md` first; it documents the conventions and the current state of each layer.

---

## Need it built for you?

Custom branding, new screens, a plugin integration, or a full App Store / Play Store release under your community's name — we take on that work.

**[forumcopilot@gmail.com](mailto:forumcopilot@gmail.com)** · [forumcopilot.com](https://forumcopilot.com)

---

## License

MIT — see [LICENSE](LICENSE).
