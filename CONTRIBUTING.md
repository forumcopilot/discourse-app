# Contributing

Thanks for helping build an open-source Discourse client. This page is the
practical stuff: how to get a build running, what to check before a pull
request, and the two rules that are easy to trip over.

For *what the app is and how it is put together*, read [`README.md`](README.md)
first. For the conventions and current state of each layer, read
[`CLAUDE.md`](CLAUDE.md) — it is written for AI coding tools, but it is the
most accurate description of the codebase we have, and it is kept current.

## Getting a build running

Flutter `^3.6.1` / Dart `^3.6.1`.

```bash
flutter pub get
./buildlib.sh          # macOS / Linux
buildlib.bat           # Windows
```

`buildlib` does three things, and the first is the one people miss: it
runs `dart pub get` inside each nested package (`forumcopilot_sdk`,
`discourse_core`, `discourse_ui`), because the root `flutter pub get`
writes no `package_config` for them and the analyzer then reports
hundreds of unresolved imports. It then runs the `dart_mappable` /
`json_annotation` codegen inside `packages/forumcopilot_sdk` — the only
package with generated code — and `flutter gen-l10n`. Re-run it whenever
you change an ARB file or an annotated class in the SDK.

Android, iOS and macOS builds need a Firebase config file to exist even
though push is off by default — the Google Services gradle plugin and the
Xcode bundle-resource reference both fail hard without it. The committed
`.example` placeholders are enough to compile:

```bash
cp android/app/google-services.json.example       android/app/google-services.json
cp ios/Runner/GoogleService-Info.plist.example    ios/Runner/GoogleService-Info.plist
cp macos/Runner/GoogleService-Info.plist.example  macos/Runner/GoogleService-Info.plist
```

They are gitignored, so real ones cannot be committed by accident. Web,
Windows and Linux skip Firebase and need nothing.

Then:

```bash
flutter run -d <device>       # e.g. -d macos, -d chrome, or an attached phone
```

The forum the app talks to is a compile-time constant —
`packages/discourse_ui/lib/config/app_forum_config.dart`. It ships pointing
at `https://try.discourse.org`, a public sandbox that resets regularly, so
you can post freely there. To develop against a local Discourse instead,
see *Local development against Discourse* in the README; the debug
Android manifest already permits cleartext to `127.0.0.1` for that.

**Do not commit a changed `forumBaseUrl`.** Point it wherever you need to
while working and leave that hunk out of your PR.

## Before you open a pull request

```bash
flutter analyze                                 # must report 0 errors
(cd packages/discourse_core && flutter test)
(cd packages/discourse_ui   && flutter test)
```

`flutter analyze` currently reports a few hundred *infos* and a handful of
warnings, mostly deprecated Material colour roles. Those are known; a PR
should not add to them, and one that removes some is welcome. Errors are
never acceptable.

Test against a real Discourse where you can — the sandbox is fine. Several
of the bugs fixed in this project were invisible in the UI and obvious in
the JSON, so when something looks wrong, compare what the API returns with
what the screen shows before assuming which side is at fault. When a
finding turns out *not* to be a bug, it is still worth a line in the PR:
`docs/ui-audit-app-vs-web.md` keeps a section of those precisely so the
same checks are not repeated.

## Two rules that are easy to trip over

### 1. `packages/forumcopilot_sdk` is a vendored copy — do not change its API here

It is a copy of a canonical SDK (`lib/` and `pubspec.yaml` byte-identical; the canonical `test/` directory is not vendored) that is shared with the
XenForo sibling app. Interface and model changes are made in the canonical
copy first (where they must keep the XenForo connector compiling) and then
synced back. A PR that edits an `IFC*Proxy` interface or an `FC*` model
directly in this repo cannot be merged as-is.

If your change needs a new field or method on the SDK, **open an issue
first** and say what Discourse concept you are trying to express. Additive
changes — a new optional field with a default — are usually
straightforward; renames and signature changes are not. The order of
preference when Discourse does not fit the SDK's shape is documented in
`CLAUDE.md` under *API/SDK strategy*: extend the interface, then surface a
Discourse-specific feature in the app, and only as a last resort map
lossily at the converter. Never reach for a server-side plugin to hide a
mismatch.

### 2. Prefer Discourse's native concepts

This app talks to stock Discourse. Notification levels, tags, server-side
drafts, bookmarks, reactions and structured search are all real Discourse
features with real endpoints — use them as they are rather than coercing
them into the XenForo-shaped names the SDK inherited.

## Commits

Conventional commits, one change per commit:

```
type(scope): what changed, in the imperative

Why it changed. What was observed, what the cause was, and anything a
future reader would otherwise have to rediscover.
```

Types in use: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`. Scope is
the area (`profile`, `search`, `attachments`, `sdk`…). The body matters
more than the subject — the history of this repo is written to be read.

Add a line to `CHANGELOG.md` under **[Unreleased]** for anything a user
would notice. It follows *Keep a Changelog*.

## Releases

Maintainers only — see [`RELEASING.md`](RELEASING.md).

## Conduct

This project follows the [Code of Conduct](CODE_OF_CONDUCT.md). Be kind;
assume good faith; keep review about the code.
