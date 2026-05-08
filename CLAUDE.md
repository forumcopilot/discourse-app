# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Flutter app template for a **single-forum** Discourse client. The app is hard-bound to one forum at build time via `lib/config/app_forum_config.dart`. It targets Discourse's stock REST/JSON API + User API Keys directly — there is **no server-side plugin** in v1 (a custom Discourse plugin may be added later if concrete gaps justify it).

This project was scaffolded by copying `byo/xenforoapp/` (Phase 0). At Phase 0, every `Discourse*Proxy` is a sed-renamed copy of its `XenForo*Proxy` counterpart and still calls a non-existent plugin endpoint at runtime — Phase 1 replaces network/auth/converters with real Discourse REST calls. See `PHASE0_NOTES.md` (TODO) for status.

Flutter `^3.6.1` / Dart `^3.6.1`. Targets Android, iOS, macOS, Windows, Linux, web.

## Sister project

`/Volumes/CRUCIAL/byo/xenforoapp/` is the XenForo equivalent. The two projects are intentionally **fully separate** (no shared path-dependency on `forumcopilot_sdk`) — fixes need to be applied to each. The Discourse server source for reference reading lives at `/Volumes/CRUCIAL/discourse`.

## Repository layout (the parts that matter)

- `lib/` — the app. Entry point `lib/main.dart` → `ForumCopilotApp` in `lib/forumcopilot_app.dart` → home `views/single_forum_bootstrap_page.dart`.
- `lib/config/app_forum_config.dart` — **the only file a fork normally edits**: forum name, base URL, optional push backend, Android passkey identifiers. `AppForumConfig.buildSite()` constructs the singleton `Site` used throughout. (Phase 1 will remove `pluginEndpoint` and add User API Key client identifiers.)
- `lib/controllers/` — GetX controllers (`SiteController`, `SiteManager`, `LoginController`, `TopicController`, `PostController`, `PushNotificationController`, `NotificationSettingsController`, `GlobalLoaderController`).
- `lib/services/` — initialization, push, user state, site proxy wiring, notification prefs.
- `lib/views/` — pages and widgets (forum list, topics, threads, posting, PMs, settings, profile, search). Posting flow is BBCode in the XenForo template; Phase 1 converts the composer to Markdown for Discourse.
- `lib/core/` — cross-cutting: `errors/` (with Crashlytics init), `logging/AppLogger`, `memory/MemoryManager`, `cache/`, `async/`.
- `lib/l10n/` — ARB files; generated output in `lib/l10n/generated/` via `flutter gen-l10n` (config in `l10n.yaml`).
- `packages/forumcopilot_sdk/` — local package. Forum-agnostic abstractions: `IFC*Proxy` interfaces, `FC*Result` response wrappers, `SiteContext`, `SiteProxyFactory`, networking (Dio with persistent cookies, Cloudflare hooks). Uses `dart_mappable` + `json_annotation` codegen.
- `packages/discourse_core/` — local package. Discourse implementation of the SDK proxies (`DiscourseProxyFactory` + per-area proxies + Discourse→FC converters). **Phase 0**: contains sed-renamed XenForo code that compiles but fails at runtime. **Phase 1+**: real implementation against stock Discourse REST + User API Keys.
- `docs/guides/` — platform-specific setup notes (macOS file picker entitlements, splash, icons, reset).

## Architecture in one paragraph

`main.dart` runs critical init (error handling, `MemoryManager`, `ForumcopilotSdk.ensureInitialized`, `UserStateService`, `SettingsContext.loadFromDevice`) then `runApp(ForumCopilotApp())`. Firebase + push init runs **in the background after `runApp`** so the UI does not block on it; `PushNotificationController` is created lazily once an FCM token arrives. `ForumCopilotApp` registers `GlobalLoaderController` and `SiteController`, then renders `GetMaterialApp` with a global loader overlay and `UserStateBanner`. The home is `SingleForumBootstrapPage`, which builds the forum's `Site` from `AppForumConfig` and drives the rest of the app. State is managed with **GetX** (`Get.put` / `Obx`); navigation uses `globalNavigatorKey` (defined in `forumcopilot_sdk`) so SDK code can show dialogs (e.g. Cloudflare challenge UI) without a `BuildContext`. All forum I/O goes through `SiteProxyFactory.get*Proxy()` returning the `discourse_core` implementations registered at startup; results follow a uniform `FC*Result { result, resultText, ...payload }` shape.

## Phase plan (current status: Phase 0)

- **Phase 0** — scaffolding complete: project copied from xenforoapp, packages renamed, app code references `discourse_core` and `Discourse*Proxy` classes. Compiles, but every API call still tries to POST to a non-existent plugin endpoint — runtime failure expected.
- **Phase 1** — auth + read path: `DiscourseClient` (Dio + User API Key headers), User API Key handshake (`/user-api-key/new` + RSA decryption + in-app webview for grant), real implementations of `IFCConfigProxy`, `IFCAccountProxy`, `IFCUserProxy`, `IFCForumProxy`, `IFCTopicProxy`, `IFCPostProxy`, `IFCSearchProxy`. Live-test against the local Discourse install at `/Volumes/CRUCIAL/discourse`.
- **Phase 2** — write path + PMs: `replyPost`, `newTopic`, edit/delete via `/posts`. PM flows via `archetype: 'private_message'`. Attachments via `/uploads`. Subscriptions with `notification_level` (Watching/Tracking/Normal/Muted).
- **Phase 3** — push + social: wire Discourse's `push_url` → existing FCM relay backend (same one xenforoapp uses). `IFCSocialProxy`, `IFCDeviceProxy`, `IFCModerationProxy`.
- **Phase 4** — composer Markdown conversion + polish + decide on optional `FC_Discourse` plugin if real gaps emerge.

## API/SDK strategy (load-bearing)

Prefer growing the app/SDK to use Discourse's native API concepts (notification levels, tags, server-side drafts, bookmarks, structured search filters, reactions) rather than coercing Discourse to fit the XenForo-shaped `IFC*Proxy` SDK. Order of preference when a Discourse concept doesn't fit:
1. Extend the SDK interface to express the Discourse concept directly.
2. Surface a Discourse-specific feature in the app.
3. Lossy-map at the converter layer (last resort).

Do **not** reach for a server plugin to mask a mismatch.

## Common commands

Bootstrap a fresh checkout (run from repo root):

```bash
flutter pub get
./buildlib.sh          # codegen for forumcopilot_sdk + flutter gen-l10n
                       # Windows: buildlib.bat
```

`buildlib.sh` runs `dart run build_runner build --delete-conflicting-outputs` inside `packages/forumcopilot_sdk` and then `flutter gen-l10n`. **Re-run it whenever** you change ARB files, or any `dart_mappable` / `json_annotation` annotated class in the SDK. `discourse_core` also has codegen — if you touch its annotated classes, run `dart run build_runner build --delete-conflicting-outputs` inside `packages/discourse_core` as well.

Run / build:

```bash
flutter run -d macos                  # also: -d chrome, -d <ios-device>, -d <android-id>
flutter build macos                   # release; output under build/macos/Build/Products/Release/
flutter analyze
```

Tests:

```bash
flutter test                          # app-level (just test/widget_test.dart)
flutter test test/widget_test.dart -p chrome              # single file / single platform
```

macOS-only utilities:

```bash
./reset_storage.sh                    # wipes the local macOS app container (BUNDLE_ID=com.example.forumapp)
```

`deploy_plugin.sh` was inherited from xenforoapp; it deploys the (non-existent in v1) Discourse plugin. Ignore until Phase 4 if a plugin is actually shipped.

## Editing notes

- **Forum config is compile-time.** Changes to `lib/config/app_forum_config.dart` require a rebuild; there is no runtime override. `siteId = 1` is the stable local-storage key — don't change it unless you intend to invalidate persisted state.
- **Adding a UI string.** Edit `lib/l10n/app_en.arb` (template) plus the per-locale ARBs you want translated, then `flutter gen-l10n` (or rerun `buildlib.sh`). Supported locales are declared in `main.dart`.
- **Adding/changing an SDK model or proxy.** Update the interface in `packages/forumcopilot_sdk/lib/interfaces/`, the result/entity in `models/`, then implement on the Discourse side in `packages/discourse_core/lib/` (proxy + converter). Re-run `build_runner` in whichever package(s) you touched.
- **Push.** Disabled by default; deferred until Phase 3. When wired, Discourse's `push_url` (registered on the User API Key) POSTs notifications to our relay backend, which translates to FCM/APNs. Reuses the same backend as xenforoapp.
- **Cloudflare interceptor.** `ForumcopilotSdk.ensureInitialized` takes `onCloudflareStart`/`onCloudflareEnd` callbacks; the app uses them to hide/show the global spinner so the Cloudflare challenge UI is visible. Preserve this when refactoring init.
- **Linting.** `analysis_options.yaml` extends `package:flutter_lints/flutter.yaml` and excludes `Original/**`.

## Known issues (inherited from xenforoapp)

- `lib/views/settings/notification_settings_page.dart:176` references `PushNotificationService.baseUrl`, which is not defined on that service. Reported by the analyzer as `undefined_getter`. Doesn't crash at runtime unless that page is opened — fix when wiring up the push backend.
- All `Discourse*Proxy` methods in `packages/discourse_core/lib/src/proxy/*` still call a XenForo-style `callPluginApi(method, params)` — this will fail against Discourse at runtime. Fix per-proxy in Phase 1+.
- BBCode utilities (`lib/utils/bbcode_processor.dart`, `lib/views/widgets/custom_bb_stylesheet.dart`, BBCode buttons in posting flows) are XenForo-flavored. To be replaced with Markdown rendering in Phase 4 (or earlier if posting needs to work for testing).
