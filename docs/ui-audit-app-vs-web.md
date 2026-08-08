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

## 3. Topic list (home) — open

Per-row, web shows and the app does not:

| Element | Web | App |
|---|---|---|
| Category badge | coloured chip (`discourse`, `general`, `tech`) | absent |
| Tags | chips (`code`, `python`) | absent |
| Like count | `♥ 7` | absent |
| Last reply attribution | "kodit4h1c7022 replied 3 hours ago" with avatar | absent |
| "Hot" badge | shown | absent |
| View count | absent | shown (`👁 792`) |

The category badge is the significant one: Discourse's information
architecture is category-first, and the app's list drops it entirely, so
there is no way to tell which category a topic is in without opening it.
The app also shows views where web shows likes — views are the weaker
signal of the two.

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

## 5. Post content — open

- **Code blocks wrap instead of scrolling.** Observed on "My Python
  solution for 238…": lines break mid-expression
  (`arr = [i for i in nums if i !=` / `0]`), which makes indentation-
  sensitive code unreadable and is actively misleading for Python.
  Web scrolls the block horizontally. This is the highest-severity
  content bug found.

## 6. Cross-cutting

- **Anonymous chat fetch.** `GET /chat/api/me/channels` fires three times
  per anonymous launch and 403s every time — a guest cannot use chat.
  Spun off as its own task.
- **Silent-failure pattern.** Two instances found (profile summary,
  reaction picker) where a failed request rendered *nothing* rather than
  an error. Both fixed here, but the pattern is worth grepping for: any
  `catch` that leaves a section invisible is indistinguishable from
  "empty" to the user, and it is exactly what a rate-limited session hits.

---

## Not covered

Ran out of session before auditing: categories page, notifications,
search, messages/PMs, bookmarks, chat, drafts, settings, composer. The
method above is cheap to repeat — `flutter run -d <device>` plus the same
page in Chrome.

## Suggested order

1. Code-block scrolling (correctness; content is currently wrong).
2. Category badge on topic rows and in the topic view (IA gap).
3. Topic stats bar + last-reply attribution (density parity).
4. Profile: chat button, notification level.
5. Reaction cluster vs. per-emoji chips (decide, then align).
