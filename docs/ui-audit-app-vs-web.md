# UI audit: app vs. Discourse web

Method: the app on a signed-in Pixel against `https://try.discourse.org`, the
same forum and account open in Chrome, screen by screen. Findings are only
listed when observed on both sides.

Status key: **fixed** = landed this session · **open** = observed, not yet
addressed.

---

## 1. Reactions — fixed (`4ff153c`)

Covered in the commit. Summary of what was wrong: two different homes for
the same intent (heart with a long-press picker in the zero state, chips
row with a `+` once anyone reacted), no indication in the action row of
what *you* reacted with, per-surface glyph logic that printed `:+1:` as
literal text, and two write paths whose disagreement caused a 429 to fire
a second doomed request.

Two further defects found while verifying on device, both fixed:

- The picker offered eight reactions on a forum whose reaction-list route
  404s and which only accepts a like — seven of them could never succeed.
- Those failures were invisible: a snackbar raised from inside a bottom
  sheet paints *behind* the sheet. Errors now render inline.

## 2. Profile — fixed (`ebec057`, `4051632`, `efc1e13`)

Missing stats, missing Top Replies / Top Topics, sections styled after the
web page instead of the app, and rows with no date. All closed.

Still open on this screen:

- **No Chat button.** Web shows Message *and* Chat; the app shows only
  Send Message even though the forum has chat enabled.
- **No notification-level control.** Web has a "Normal" dropdown
  (Watching / Tracking / Normal / Muted) on the profile; the app has none.
- **No profile banner.** Web renders the user's card background image.
- **Header strip is thinner than web's.** Web: Joined · Last Post · Seen ·
  Views · Trust Level. App: Member Since · Last Activity · Posts, plus a
  trust-level chip. "Seen" and "Views" are absent.

## 3. Topic list (home) — partly fixed

Per-row, web shows and the app does not:

| Element | Web | App |
|---|---|---|
| Category badge | coloured chip (`discourse`, `general`, `tech`) | **added** |
| Tags | chips (`code`, `python`) | already present (audit was wrong) |
| Like count | `♥ 7` | **added** |
| Last reply attribution | "kodit4h1c7022 replied 3 hours ago" with avatar | absent |
| "Hot" badge | shown | absent |
| View count | absent | shown (`👁 792`) |

Category badge and like count are now rendered (`FCTopic` already carried
`forumName` and `likeCount`; the row simply ignored them). The category
chip leads the tag row, filled where tags are outlined, so the hierarchy
reads the way web's does.

Correction to an earlier claim in this document: **tags were already
rendered** — the topics visible in the first screenshots simply had none.
Verified on the Leetcode topic, which shows `tech` `code` `python`.

Still open: last-reply attribution ("X replied 3 hours ago") and the
"Hot" badge.

## 4. Topic view — open

- **Reaction display model differs.** Web renders one combined cluster
  with a single total (`❤️😮 5`); the app renders a separate counted chip
  per reaction (`❤️ 1` `😮 1`). Web's reads better once a post has several
  reactions. Worth a decision rather than drift.
- **No topic stats bar.** Web has `793 views · 7 likes · 4 links ·
  6 users` plus participant avatars under the first post. The app has
  nothing equivalent.
- **No time-gap dividers.** Web inserts "3 years later" between posts far
  apart in time. Long topics in the app read as one flat run.
- **No category badge under the title.**
- **Action row placement diverges.** Web right-aligns the row and gives
  Reply a labelled button; the app left-aligns icons and floats Reply as
  a FAB. Not wrong, but it is the kind of drift worth deciding once.

## 5. Post content — fixed

- **Code blocks wrapped instead of scrolling — fixed.** Lines broke
  mid-expression (`arr = [i for i in nums if i !=` / `0]`) with the
  continuation landing at column 0, so indentation-sensitive code read as
  a different program. `<pre>` now renders through a TagExtension into a
  horizontally scrolling block, matching web. Verified on device: the
  expression is on one line and the block scrolls to reveal the rest.
  Note the block uses plain `Text`, not `SelectableText` — the latter
  claims horizontal drags for selection and swallows the scroll, which
  would have left the block clipped with no way to reach the line ends.

## 6. Categories — one fixed, rest open

- **HTML entities were not decoded — fixed.** The general category read
  "If you&#39;re not sure what to pick" in the app and "If you're not
  sure" on web. Discourse returns both `description_text` (tag-free but
  entity-ESCAPED) and `description` (clean); the proxy took the former
  verbatim. Now run through `stripHtmlToText`, which already decodes
  numeric character references. Verified on device.
- **Open: no subcategory nesting shown.** Web groups subcategories under
  their parent; the app renders one flat list.
- The app shows a topic count per category, which web's box layout does
  not — a point in the app's favour, worth keeping.

## 7. Notifications / auth state — open, needs a signed-in device

The Notifications and Profile tabs both render "Sign in to view…". That
is *correct* for the current device state — the session really is gone —
but it blocked auditing these screens. See "Session lost" below.

## 8. Notifications — one fixed, one open

- **Compound timestamps — fixed.** Rows read "a day ago 4:09 PM", a
  relative phrase and a wall-clock time concatenated. Beyond reading as a
  broken sentence it was misleading: timeago renders ~1–2 days as "a day
  ago", so a two-day-old notification showed yesterday's phrasing beside a
  clock time from another day. Web shows a bare `1d` / `2d`. The 1–7 day
  bucket in `formatSmartDateTime` now uses the relative form alone.
- **Open: no filters.** Web has All / Replies / Likes / Mentions / Edits /
  Links / Reactions plus a Filter By dropdown. The app has one flat list.
  Fine for this test account's three notifications, unusable on a busy
  one. The app does have a mark-all-read action, equivalent to web's
  Dismiss All.

## 9. Notification grant screen — one fixed, rest open

- **Stranded the user when our backend was down — fixed** (`b824830`).
  Approving with ForumCopilot unreachable left the user on the screen with
  a snackbar and no way forward, even though the forum-side grant had
  already succeeded and re-tapping Continue would only mint another key.
- **Open: shown after every login, unconditionally.** `login_page`
  prompts on each successful sign-in; "Not now" is not remembered, and
  nothing checks whether a push backend is even configured
  (`defaultPushApiBaseUrl` is empty by default) or whether a grant already
  exists. Re-granting is *cheap* — the notifications client id is derived
  from a stable per-install id in SharedPreferences, so a new key replaces
  the old one server-side rather than accumulating — so this is a UX nag,
  not a leak. Worth gating on a configured backend regardless.
- **Not a bug: logout already revokes the server key.**
  `DiscourseLoginController._revokeNotificationsKey` calls
  `ForumCopilotApiService.revokeDiscourseNotificationKey` and is correctly
  sequenced BEFORE `logoutUserAsync`, which clears the credentials the
  client id is derived from.

## 10. Cross-cutting

- **Anonymous chat fetch.** `GET /chat/api/me/channels` fires three times
  per anonymous launch and 403s every time — a guest cannot use chat.
  Spun off as its own task.
- **Silent-failure pattern.** Two instances found (profile summary,
  reaction picker) where a failed request rendered *nothing* rather than
  an error. Both fixed here, but the pattern is worth grepping for: any
  `catch` that leaves a section invisible is indistinguishable from
  "empty" to the user, and it is exactly what a rate-limited session hits.

---

## Session lost on the test device

Part-way through this audit the Pixel stopped being signed in: no
`GET /session/current.json` on cold start, and the anonymous
`/chat/api/me/channels` double-fetch signature returned. The stored User
API Key appears to be gone from secure storage rather than rejected.

Cause not established. It is NOT the demo forum resetting — the post
count kept climbing (3,907 → 3,909) instead of returning to a baseline.
The plausible candidate is the repeated `flutter run` reinstalls during
this session dropping the Keystore-backed entry. Worth confirming
deliberately, because a real app *update* must not sign users out.

Re-authenticating needs the account password, so it has to be done by
hand on the device; the remaining screens can be audited after that.

## Not covered

Still to audit, all of which need a signed-in session: notifications,
search, messages/PMs, bookmarks, chat, drafts, settings, composer. The
method above is cheap to repeat — `flutter run -d <device>` plus the same
page in Chrome.

## Suggested order

1. Code-block scrolling (correctness; content is currently wrong).
2. Category badge on topic rows and in the topic view (IA gap).
3. Topic stats bar + last-reply attribution (density parity).
4. Profile: chat button, notification level.
5. Reaction cluster vs. per-emoji chips (decide, then align).
