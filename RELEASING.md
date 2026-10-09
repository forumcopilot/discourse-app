# Releasing

A release of this repository is a commit on `main` that CI has checked, an annotated `vX.Y.Z` tag on that commit, and a GitHub Release for the tag at <https://github.com/forumcopilot/discourse-app/releases>. Nothing else is published: this is a build-from-source project, and the apps built on it pin a tag and update it separately.

## Versioning

Releases are `1.0.x`. Each one bumps the patch version and the build number in `pubspec.yaml`, e.g. `1.0.49+87` → `1.0.50+88`.

Cut a release when a user-visible fix or feature has landed. Several can go out on the same day.

## Step by step

### 1. Version and changelog

Start from an up-to-date, clean `main`:

```bash
git checkout main
git pull --ff-only origin main
```

Bump `version:` in `pubspec.yaml` (both numbers).

In `CHANGELOG.md`, add a section just below `## [Unreleased]`, in [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) form:

```markdown
## [1.0.50] - 2026-10-08

### Fixed
- **Selecting text in the composer.** After Back had put the keyboard away, a long-press on a word could select to the end of the post. …
```

Use `Added`, `Changed` and `Fixed`, in that order, and only the ones that apply. Dates are `YYYY-MM-DD`.

### 2. Commit and push

Stage the two files by name. Never stage a whole directory: a local checkout may carry an uncommitted forum address in `packages/discourse_ui/lib/config/app_forum_config.dart`.

```bash
git add pubspec.yaml CHANGELOG.md
git commit -m "release: 1.0.50 — text selection in the composer"
git push origin main
```

The subject is `release: <version> — <a few words on what changed>`.

### 3. Wait for CI on that commit

CI (`.github/workflows/ci.yml`) runs on every push to `main`. Do not tag until the run for the release commit has succeeded:

```bash
gh run list --repo forumcopilot/discourse-app --branch main --limit 5
gh run watch <run-id> --repo forumcopilot/discourse-app
```

- A **cancelled** run proves nothing. Another push to `main` cancels the run before it, and the failure then only shows up on a later commit.
- If the run failed, read `gh run view <run-id> --log-failed` before going on.
- If the Debug APK job fails with `Java heap space`, the runner ran out of memory. Run `gh run rerun <run-id> --failed` and release once the rerun is green.

### 4. Tag

Tag the commit CI checked, with an annotated tag whose message matches the commit subject:

```bash
git tag -a v1.0.50 <commit> -m "1.0.50 — text selection in the composer"
git push origin v1.0.50
```

CI also runs on `v*` tags.

### 5. GitHub Release

Pushing the tag does not create a Release, and the Releases page only lists Releases. Create one titled with the bare version, using the version's `CHANGELOG.md` section (without its heading) as the notes:

```bash
awk '/^## \[1.0.50\]/{f=1;next} /^## \[/{f=0} f' CHANGELOG.md > /tmp/notes-1.0.50.md
gh release create v1.0.50 --repo forumcopilot/discourse-app \
  --verify-tag --title "1.0.50" --notes-file /tmp/notes-1.0.50.md
```

`--verify-tag` makes `gh` refuse to create the tag itself, so the Release always points at the tag from step 4.

## Drafting the changelog from the commit log

```bash
git log v1.0.49..HEAD --oneline
```

Group by conventional-commit prefix: `feat` under **Added**, `fix` under **Fixed**, and `refactor`, `chore` or `perf` under **Changed** when a user would notice. Leave out commits nobody using the app would see.

Write each bullet as what changed for the person using the app, not as the commit subject. Lead with a short bold sentence. For example, `fix(composer): a long-press selects one word, and a tap under the post leaves the text` became:

> **Tapping under a short post dismisses a selection** and the keyboard, as tapping elsewhere outside the text does. Before, the empty page below the text took no taps.

## When something is wrong

| What | How |
|---|---|
| The notes on the Release | `gh release edit v1.0.50 --repo forumcopilot/discourse-app --notes-file <notes.md>`, and fix `CHANGELOG.md` on `main` to match |
| The tag points at the wrong commit | Moving a published tag rewrites history for everyone who fetched it. Prefer releasing the next patch version; check with the team before re-tagging. |
