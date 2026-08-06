# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Flutter app template for a **single-forum** Discourse client. The app is hard-bound to one forum at build time via `lib/config/app_forum_config.dart`. It targets Discourse's stock REST/JSON API + User API Keys directly — there is **no server-side plugin** in v1 (a custom Discourse plugin may be added later if concrete gaps justify it).

This project was scaffolded by copying `byo/xenforoapp/` (Phase 0), but is now **well past Phase 0**: all `Discourse*Proxy` classes call real Discourse REST endpoints (zero plugin-endpoint calls remain), auth uses the User API Key handshake, and the UI lives in the extracted `discourse_ui` package. Remaining XenForo inheritance is tracked per-file, not per-phase.

Flutter `^3.6.1` / Dart `^3.6.1`. Targets Android, iOS, macOS, Windows, Linux, web.

## Sister project

`/Volumes/CRUCIAL/byo/xenforoapp/` is the XenForo equivalent. The two projects are intentionally **fully separate** (no shared path-dependency on `forumcopilot_sdk`) — fixes need to be applied to each. The Discourse server source for reference reading lives at `/Volumes/CRUCIAL/discourse`.

**Canonical SDK**: as of the `canonical-sdk` branch, `packages/forumcopilot_sdk` here is a byte-identical vendored copy of the canonical SDK maintained in `/Volumes/CRUCIAL/tapatalk_flutter/packages/forumcopilot_sdk` (the multi-tenant ForumCopilot app, which will eventually host `discourse_core` as a platform module). Do NOT fork this copy's API surface: make interface/model changes in the canonical copy first (they must keep `xenforo_core` compiling there), then rsync back here. Discourse-specific concepts belong in `discourse_core` or, when promoted, in the canonical SDK under platform-neutral names (e.g. the Discourse emoji reaction entity is `FCPostReaction`; plain `FCReaction` is the XF reaction-type descriptor).

## Repository layout (the parts that matter)

- `lib/` — thin app runner: just `lib/main.dart` (init + push bootstrap), which hands off to `ForumCopilotApp` in `discourse_ui`.
- `packages/discourse_ui/` — the whole UI layer: `config/app_forum_config.dart` (**the file a fork normally edits**: forum name, base URL, optional push backend, passkey identifiers), `controllers/` (GetX), `services/`, `views/`, `core/` (errors/logging/memory/cache/async), `l10n/`, `theme/`.
- `packages/forumcopilot_sdk/` — local package. Forum-agnostic abstractions: `IFC*Proxy` interfaces, `FC*Result` response wrappers, `SiteContext`, `SiteProxyFactory`, networking (Dio with persistent cookies, Cloudflare hooks). Uses `dart_mappable` + `json_annotation` codegen.
- `packages/discourse_core/` — local package. Discourse implementation of the SDK proxies (`DiscourseProxyFactory` + per-area proxies) against stock Discourse REST + User API Keys (`network/discourse_client.dart`, `network/discourse_auth_manager.dart`).
- `docs/guides/` — platform-specific setup notes (macOS file picker entitlements, splash, icons, reset).

## Architecture in one paragraph

`main.dart` runs critical init (error handling, `MemoryManager`, `ForumcopilotSdk.ensureInitialized`, `UserStateService`, `SettingsContext.loadFromDevice`) then `runApp(ForumCopilotApp())`. Firebase + push init runs **in the background after `runApp`** so the UI does not block on it; `PushNotificationController` is created lazily once an FCM token arrives. `ForumCopilotApp` registers `GlobalLoaderController` and `SiteController`, then renders `GetMaterialApp` with a global loader overlay and `UserStateBanner`. The home is `SingleForumBootstrapPage`, which builds the forum's `Site` from `AppForumConfig` and drives the rest of the app. State is managed with **GetX** (`Get.put` / `Obx`); navigation uses `globalNavigatorKey` (defined in `forumcopilot_sdk`) so SDK code can show dialogs (e.g. Cloudflare challenge UI) without a `BuildContext`. All forum I/O goes through `SiteProxyFactory.get*Proxy()` returning the `discourse_core` implementations registered at startup; results follow a uniform `FC*Result { result, resultText, ...payload }` shape.

## Phase plan (current status: Phases 0–2 done, Phase 4 mostly done)

- **Phase 0** — ✅ scaffolding (copy from xenforoapp, rename).
- **Phase 1** — ✅ auth + read path: `DiscourseClient`, User API Key handshake (`/user-api-key/new` + RSA decryption + in-app webview grant), real config/account/user/forum/topic/post/search proxies. Live-tested against the local Discourse install at `/Volumes/CRUCIAL/discourse`.
- **Phase 2** — ✅ write path + PMs: reply/new topic/edit/delete via `/posts`, PMs via `archetype: 'private_message'`, attachments via `/uploads`, native 4-level `notification_level` subscriptions. Also landed beyond plan: reactions, bookmarks, server-side drafts, tags, groups, badges, user directory, chat (partial), moderation, `/topics/timings` read tracking.
- **Phase 3** — ⏳ push: **client side done**, relay side pending. When `AppForumConfig.pushApiBaseUrl` is set, the handshake requests the `push` scope and registers `push_url = <pushApiBaseUrl>/discourse/push` (static — Discourse substring-matches `push_url` against `allowed_user_api_push_urls`, so no per-device URLs); `userApiPushEnabled` is recorded only when scope+push_url were sent AND the server echoed `push: true`. Device identity is the handshake `client_id`, which Discourse tags onto every payload it POSTs to `push_url` (`HubPushNotificationPusher`); the app sends `discourse_client_id` in the relay's `/devices/register` body so the relay can map client_id → FCM token. `DiscourseDeviceProxy` reflects the model honestly (no Discourse device endpoints exist; unregister = key revoke on logout). **Remaining, all server-side:** (1) the relay backend must actually serve `POST /discourse/push` and forward by `client_id` (path contract defined in `AppForumConfig.discoursePushUrl` — change there if the relay differs, and store the `discourse_client_id` field from `/devices/register`); (2) the forum admin must add the exact push_url to `allowed_user_api_push_urls` and keep `push` in `allow_user_api_key_scopes`; (3) unauthenticated relay ingestion should be verified/hardened (Discourse sends `push_api_secret_key` in the payload). With `pushApiBaseUrl` empty, everything is byte-identical to pre-push behavior.
- **Phase 4** — ✅ done. UI polish, spacing tokens, skeleton loaders; composer emits Discourse Markdown; the BBCode pipeline is deleted and post content is parsed as cooked HTML (`utils/cooked_content.dart`, mirroring `PrettyText.extract_links` in the Discourse source). Optional `FC_Discourse` plugin still not needed.

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
- **Adding a UI string.** Edit `packages/discourse_ui/lib/l10n/app_en.arb` (template) plus the per-locale ARBs you want translated, then `flutter gen-l10n` (or rerun `buildlib.sh`). Supported locales are declared in `main.dart`.
- **Adding/changing an SDK model or proxy.** Update the interface in `packages/forumcopilot_sdk/lib/interfaces/`, the result/entity in `models/`, then implement on the Discourse side in `packages/discourse_core/lib/` (proxy + converter). Re-run `build_runner` in whichever package(s) you touched.
- **Push.** Disabled by default (`AppForumConfig.pushApiBaseUrl = ''`). Client wiring is complete (see Phase 3 above): setting `pushApiBaseUrl` makes the next login request the `push` scope with `push_url = <pushApiBaseUrl>/discourse/push`; Discourse POSTs notifications there and the relay forwards to FCM/APNs keyed by the `client_id` in each payload. Existing logins predate the grant and must re-login (a key's scopes/push_url are immutable) — the notification settings page surfaces this. Contract docs live on `AppForumConfig.discoursePushUrl`.
- **Cloudflare interceptor.** `ForumcopilotSdk.ensureInitialized` takes `onCloudflareStart`/`onCloudflareEnd` callbacks; the app uses them to hide/show the global spinner so the Cloudflare challenge UI is visible. Preserve this when refactoring init.
- **Linting.** `analysis_options.yaml` extends `package:flutter_lints/flutter.yaml` and excludes `Original/**`.

## Remaining XenForo inheritance

Both entries that used to live here are resolved: every `Discourse*Proxy` calls real Discourse REST (zero `callPluginApi` remain, Phase 5.12), and the BBCode pipeline is gone — `bbcode_processor.dart` and `attachment_utils.dart` are deleted, and post content is read as cooked HTML by `packages/discourse_ui/lib/utils/cooked_content.dart`.

What's left is naming and shape, not behavior:

- **`forumcopilot_sdk` is XenForo-shaped by origin.** Interface names, `FC*Result` wrappers and some field semantics still reflect XF. Follow the API/SDK strategy above rather than working around the shape.
- **Composer helper names.** `MessageComposePage._insertBBCode` / `_insertAttachmentBBCode` (and the PM composer equivalents) emit Discourse **Markdown** despite their names — the bodies are correct, the identifiers are stale.
- **`DiscoursePrivateMessageProxy`** is a deliberate loud shim (Phase 5.20e): Discourse models PMs as topics, so the XF inbox/sent-box contract fails fast with a pointer to `IFCPrivateConversationProxy`.
- **`FCPost.inlineAttachments`** is always empty on Discourse — uploads are embedded directly in the cooked HTML. The field and its render branch are kept only for SDK compatibility.
- **`deploy_plugin.sh`** deploys a plugin that does not exist in v1. Ignore it.
