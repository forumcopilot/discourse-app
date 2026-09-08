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

- **Home** — Discourse-native tabs: **Latest / Hot / New / Unread / Top** (Hot appears when the forum offers it), with a period selector on Top (All / Yearly / Quarterly / Monthly / Weekly / Daily). The forum's own logo and wordmark in the header and drawer.
- **Categories** — each category's tile in its own `color` / `text_color`, topic-count badges, sub-categories, category-filtered lists with Latest / Hot / New.
- **Topic view** — rendered from Discourse's `cooked` HTML: Markdown, oneboxes, quoted posts, code blocks, mentions, native Unicode emoji, lightboxed images. Category and tags under the title, file attachments as download cards, and share / copy-link on every post.
- **Tags** — chips on topic rows, tag-filtered lists, and a global Tags directory with search and popularity/alphabetical sort.
- **Polls** — full voting widget with result charts.
- **Suggested Topics** footer, mirroring Discourse web.
- **Solution banner** on accepted answers (`discourse-solved`).
</details>

<details>
<summary><b>Writing</b></summary>

- **Markdown composer** — Discourse-flavored Markdown, the only markup Discourse actually cooks.
- New topic with category + tag selection; reply, quote, edit, delete.
- **Attachments** — image and file uploads via `/uploads`, written the way Discourse web writes them (`![name|WxH]`, `[name|attachment] (size)`). An image over the forum's size limit offers to resize just enough to fit, keeping its format.
- **Server-side drafts** — composer state round-trips through `/drafts.json`, so a draft started in the app appears in the web composer and vice versa.
- **Post revisions** — view a post's edit history.
- **Whisper / wiki** — staff whispers and wiki-editable posts.
</details>

<details>
<summary><b>Social &amp; account</b></summary>

- **Likes and emoji reactions** (`discourse-reactions`) behind one canonical affordance — tap to like, long-press for the emoji picker, chips below the post.
- **Bookmarks** with reminders, **follow/unfollow** (`discourse-follow`), **ignore user**.
- **Notifications** — the full `/notifications.json` feed with type-aware rendering and per-type icon badges across all 39 Discourse notification types, filterable to Unread.
- **Notification levels** — Watching / Tracking / Normal / Muted on topics, categories and tags.
- **Profile** — trust level (with explainer) and badges as their own sections, the Discourse summary (top replies and topics, most liked by, most replied to, top links), and activity tabs (Replies / Topics / Likes / Solved) that stay pinned while you scroll. Inline bio/location/website editing, avatar upload.
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

- **Push notifications** — the client side is done: with a relay configured, the User API Key handshake requests the `push` scope and registers a `push_url`, and Discourse POSTs notifications there. What's missing is **the relay backend** that forwards those to FCM/APNs. See [docs/push.md](docs/push.md) for the decision and what an admin has to enable. With no relay configured the app runs exactly as before and needs no real Firebase project — the committed `.example` placeholders are enough to compile (see Quick start). (Forum Copilot runs a hosted relay — [get in touch](mailto:forumcopilot@gmail.com).)
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
./buildlib.sh          # resolves the nested packages, codegen, gen-l10n   (Windows: buildlib.bat)

# Android / iOS / macOS builds require a Firebase config file to *exist*,
# even with push disabled. The committed .example placeholders are enough
# to compile — copy them, and replace with real ones only if you wire push.
cp android/app/google-services.json.example        android/app/google-services.json
cp ios/Runner/GoogleService-Info.plist.example     ios/Runner/GoogleService-Info.plist
cp macos/Runner/GoogleService-Info.plist.example   macos/Runner/GoogleService-Info.plist

flutter run -d macos   # or -d chrome, -d <ios-device>, -d <android-id>
```

Web, Windows and Linux skip Firebase entirely and need no config file. The three files above are gitignored, so your real ones can never be committed by accident.

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

`buildlib.sh` resolves each nested package (`dart pub get` in all three — root `flutter pub get` does not do this, and skipping it leaves the analyzer with hundreds of unresolved imports), runs `build_runner` inside `packages/forumcopilot_sdk`, then `flutter gen-l10n`. **Re-run it after** editing an ARB file or any `dart_mappable` / `json_annotation` annotated class in the SDK. The SDK is the only package with generated code.

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

See [`CHANGELOG.md`](CHANGELOG.md). It follows *Keep a Changelog*; the **[Unreleased]** section is what has landed since the last tagged release.

---

## Before you publish a fork

Everything that identifies the app is a placeholder. The checked-in values build and run against the Discourse sandbox, and nothing more; a store will reject `com.example`, and "Forum App" is not a name. Change all of these:

| What | Where | Placeholder today |
|---|---|---|
| Forum URL, name, description, branding | `packages/discourse_ui/lib/config/app_forum_config.dart` | `https://try.discourse.org`, `Discourse` |
| Android application id and namespace | `android/app/build.gradle` (`applicationId`, `namespace`), and move `android/app/src/main/kotlin/com/example/forumapp/MainActivity.kt` to the matching package path | `com.example.forumapp` |
| Android app name | `android/app/src/main/AndroidManifest.xml` (`android:label`) | `Forum App` |
| iOS bundle id, display name | `ios/Runner.xcodeproj` (`PRODUCT_BUNDLE_IDENTIFIER`, three configurations), `ios/Runner/Info.plist` (`CFBundleDisplayName`, `CFBundleName`) | `com.example.forumapp`, `Forum App` |
| macOS bundle id, product name | `macos/Runner/Configs/AppInfo.xcconfig` (`PRODUCT_BUNDLE_IDENTIFIER`, `PRODUCT_NAME`) | `com.example.forumapp`, `Forum App` |
| Package name the passkey / app-link config refers to | `AppForumConfig.androidPackageName`, plus your hosted `assetlinks.json` and `apple-app-site-association` with your team id and certificate fingerprints | `com.example.forumapp` |
| Icons and splash | `assets/`, then `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create` | Forum Copilot artwork |
| Apple Development Team | Xcode signing settings | none |
| Firebase, only if you wire push | your own `google-services.json` / `GoogleService-Info.plist` in place of the `.example` placeholders; **never commit a service-account JSON** | placeholders |
| Local dev helper | `reset_storage.sh` (`BUNDLE_ID`) | `com.example.forumapp` |

### Naming

This project is not affiliated with, endorsed by, or an official product of Civilized Discourse Construction Kit, Inc. "Discourse" is their trademark. A fork should be named for the community it serves, not as "the Discourse app", and its store listing should say it is a third-party client.

---

## Contributing

Issues and pull requests are welcome — see **[CONTRIBUTING.md](CONTRIBUTING.md)** for how to get a build running, what to check before a PR, and the two rules that are easy to trip over (the vendored SDK, and preferring Discourse's native concepts). The project follows a [Code of Conduct](CODE_OF_CONDUCT.md).

For a larger Discourse-native feature, please open an issue first so we can agree on whether the SDK interface should be extended rather than lossily mapped — see *Extending it* above.

Working with Claude Code or another AI coding tool? Point it at `CLAUDE.md` first; it documents the conventions and the current state of each layer.

---

## Need it built for you?

Custom branding, new screens, a plugin integration, or a full App Store / Play Store release under your community's name — we take on that work.

**[forumcopilot@gmail.com](mailto:forumcopilot@gmail.com)** · [forumcopilot.com](https://forumcopilot.com)

---

## License

MIT — see [LICENSE](LICENSE).
