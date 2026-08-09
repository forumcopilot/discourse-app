# UI audit: app vs. Discourse web

> Companion document: `sdk-gap-audit-discourse.md` compares *payloads*
> rather than screens — what Discourse sends versus what the connector
> reads. It supplies the data for several items still open here, and
> corrects two claims below (see its "Corrections to the UI audit").

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

- **Chat button — implemented, unverified.** Web shows Message *and*
  Chat. The button now renders, gated on the server's `can_chat_user`
  rather than on whether the chat plugin is installed — different
  questions, and only the server knows whether *this* viewer may chat with
  *this* person. It opens (or reuses, via `upsert`) a DM channel.

  **Correction: chat IS enabled on meta.** An earlier note here claimed
  otherwise, from an anonymous probe — signed in, `/chat/api/me/channels`
  returns 200 and `current_user` reports `can_chat: true`,
  `has_chat_enabled: true`. What is false is `can_chat_user` on *other*
  users' profiles, which is a different question: whether this viewer may
  chat with that person. So the button hiding is correct, and its enabled
  state still needs a forum where some user accepts chats.
- **No notification-level control.** Web has a "Normal" dropdown
  (Watching / Tracking / Normal / Muted) on the profile; the app has none.
- **No profile banner.** Web renders the user's card background image.
- **Header strip — Views and Badges added.** Web: Joined · Last Post ·
  Seen · Views · Trust Level. The app now shows Member Since · Last
  Activity · Posts · Views · Badges, plus the trust-level chip. Verified
  on meta: Views 2,250 and Badges 17 for Oniel, matching
  `/u/Oniel.json`. "Seen" now renders too (`last_seen_at`), on a clock rather than an eye —
  Views sits beside it, and two eyes read as the same statistic twice.

## 3. Topic list (home) — partly fixed

Per-row, web shows and the app does not:

| Element | Web | App |
|---|---|---|
| Category badge | coloured chip (`discourse`, `general`, `tech`) | **added** |
| Tags | chips (`code`, `python`) | already present (audit was wrong) |
| Like count | `♥ 7` | **added** |
| Last reply attribution | "kodit4h1c7022 replied 3 hours ago" with avatar | **added** |
| Participant avatar cluster | up to 5 faces per row | **added** |
| "Hot" badge | shown | **added** |
| View count | absent | shown (`👁 792`) |

Category badge and like count are now rendered (`FCTopic` already carried
`forumName` and `likeCount`; the row simply ignored them). The category
chip leads the tag row, filled where tags are outlined, so the hierarchy
reads the way web's does.

Correction to an earlier claim in this document: **tags were already
rendered** — the topics visible in the first screenshots simply had none.
Verified on the Leetcode topic, which shows `tech` `code` `python`.

Last-reply attribution now renders ("alice replied 3 hours ago", with the
last poster's avatar). It needed a canonical-SDK change first — `FCTopic`
described only whoever *opened* a topic — so `lastPosterName` /
`lastPosterIconUrl` / `lastPostedAt` landed in tapatalk_flutter
(`83a8264`) and were synced here. `xenforo_core` is untouched and still
compiles; XenForo shows last-reply attribution too, so when its thread
model grows the field, that app gets the same row.

Two things the implementation refuses to guess: it stays hidden until
`posts_count > 1` (on a single-post topic the latest poster IS the
author, and "X replied" would be a false statement about the opening
post), and it reads `last_posted_at` rather than `bumped_at`, because a
topic bumps on edits and moves too.

The "Hot" badge now renders too (`is_hot`, flame-tinted since it is the
one badge on the row that is an invitation rather than a status). Verified
on device: it appears on the two topics try.discourse.org flags and on no
others.

## 4. Topic view — open

- **Reaction display — resolved, web's combined style.** The app used a
  separate counted chip per reaction on its own line above the action row.
  It now renders one cluster (`❤️😮 5`) in the action row, where the heart
  used to be, so a post costs one line instead of two. Tap opens the
  picker, long-press lists who reacted, and the viewer's own participation
  is carried in the count's colour. `ReactionChipsRow` is deleted.
- **Topic stats bar — fixed.** Web has `793 views · 7 likes · 4 links ·
  6 users` plus participant avatars under the first post; the app had
  nothing. `TopicStatsBar` now renders views · likes · users under the
  opening post, gated on `postNumber == 1` like the poll and accepted
  answer beside it. Icons rather than web's written labels, matching the
  idiom the topic rows already set for the same numbers, so it needs no
  new translated strings and survives a narrow phone.

  Building it surfaced a real data bug behind it. The three numbers came
  back 0 and the bar rendered as nothing, because only
  `getThreadAsync` populated the topic header — `getThreadByPostAsync`
  and `getThreadByUnreadAsync` never set `viewCount` / `likeCount`, and
  no builder set `participatedUserIds`. Entering a topic at an anchor
  post, which is the *normal* path for a signed-in reader with read
  state, silently produced a header with no numbers. All three builders
  now read them from the same `/t/{id}.json` payload they already had in
  hand. Verified on the Pixel against try.discourse.org: the bar reads
  `798 · 7 · 6`, matching the server exactly.

  **Now complete.** Links and the user count landed with a second
  canonical-SDK change (`40b5d0b`: `isHot`, `participantCount`,
  `linkCount`), so the bar reads views · likes · links · users exactly as
  web does — verified on device at `805 · 7 · 4 · 6`, matching
  `/t/57.json`.

  The user count is now the server's `participantCount`, not
  `participatedUserIds.length`. Those agreed on the topic first measured,
  which is why the substitution looked safe: the posters summary is
  **capped**, so on a busy topic the list under-reports and the two
  diverge. The list length survives only as a fallback when the payload
  reports no count.

  Still absent, deliberately: **participant avatars**.
  `participatedUserIds` gives ids but no avatar URLs, and Discourse builds
  those from a per-user template, so it would cost a second fetch per
  topic.
- **Time-gap dividers — fixed.** Web inserts "3 years later" between posts
  far apart in time; long topics in the app read as one flat run. Now
  rendered, following Discourse's own component exactly
  (`post/time-gap.gjs`): shown when `daysSince > show_time_gap_days`, a
  strict comparison, with the threshold read from `/site/settings.json`
  (`client: true`, default 7) rather than hardcoded — a forum may have
  changed it. Wording thresholds match too: `<30` days → days, `<365` →
  months rounded, else years rounded.

  Verified on meta: `/t/261798.json` predicts exactly one divider in the
  loaded window, 437 days between #17 and #18, and the app renders
  "1 year later" there — singular, via ICU plurals.
- **No category badge under the title.**
- **Author title / group flair — fixed.** Web shows both beside a
  username ("simon Great Contributor", "awesomerobot Kris team") and they
  are different things: a title is free text the forum grants a person,
  flair is the badge of their primary group. The app showed a bare
  username regardless of standing. Now rendered, preferring the title when
  both exist, as Discourse does.

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
- **Subcategory nesting — fixed.** Web groups subcategories under their
  parent; the app rendered one flat list.

  It was never a missing feature. `FCForum` already carried
  `parentId`/`childForums`, the converter already read
  `parent_category_id`, `_buildTree` already assembled the tree, and the
  categories tab already rendered children. The whole path existed and was
  starved of data: `/categories.json` returns **top-level categories
  only** — meta answers 12 with zero children even though the proxy passes
  `include_subcategories=true` — while `/site.json` lists all 45 including
  33 subcategories. Merging the cached site payload in was the entire fix.

  Verified on meta: "News and Events" now groups Announcements (595),
  Blog (246) and Forum summaries (5), matching `/site.json`.
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

## 9b. Threading — done

Both halves now render: "in reply to X" walks a conversation upwards
(tappable, scrolls to the parent), and an "N replies" disclosure walks it
down (fetched on expand). Verified on meta against topics with real
branching.

## 9c. Composer and New Message vs web — audited

Signed in on meta, comparing the app's New Topic / New Message against
web's composer.

**Structurally equivalent.** App: Participants (+ Add) · Subject ·
Message · formatting menu · attach · image · mention · Send. Web:
Recipients (+) · Title · Body · flat toolbar · Send message / Discard.

**Formatting coverage is not the gap it looked like.** The toolbar's "B"
is a *menu*, not a bold button, and it holds thirteen actions — bold,
italic, underline, strikethrough, link, image, video, quote, code,
spoiler, bullet list, numbered list, list item. That is broader than
web's visible toolbar in places (spoiler, video). `DiscourseMarkup`
already emits all of them in the markup Discourse actually cooks.

- **Formatting menu icon — fixed.** It was `format_bold`, which reads as a
  bold button, so the other twelve actions looked absent rather than one
  tap away. Now `text_format`. Applied to both composers, which had
  drifted to the same wrong glyph independently.

Still open on the composer:

- **No preview.** Web renders a live preview (side-by-side on desktop, a
  toggle on mobile). The app has none, so on a Markdown forum you cannot
  see what you typed will look like until it posts. The single biggest
  remaining composer gap.
- **No emoji picker.** Web has one; the app leans on the system keyboard,
  which is a defensible mobile trade.
- **No GIF or AI helper.** Both plugin-dependent on web.
- **No explicit Discard.** Back exits; drafts are saved server-side, so
  nothing is lost — but the exit is less obvious than web's button.

## 9d. Signed-in write flows on try.discourse.org — audited

Reply, quote, edit and draft round-trip, exercised for real.

**Working:** plain reply posts and lands; the draft is deleted on
success; edit loads the post's raw and saves; `--` renders as an en-dash,
which is Discourse's own typographer, not a client quirk; the post
overflow menu (Edit / Delete / Report / Make wiki) matches web's for your
own posts.

**Two bugs found and fixed:**

- **Quote inserted the post's raw source.** Quoting a post that itself
  contained a quote produced a wall of markup — channel ids, thread
  titles, an `onmouseover=` attribute — where the words should be. Web
  never shows this because its quote is *selection-driven*: it copies
  rendered text, so quote markup from the original is never collected.
  The app quotes whole posts, so it now strips what web never picks up,
  and falls back to the post's rendered text when the post is *only* a
  quote and stripping leaves nothing.
- **A stale draft silently ate a fresh quote.** Both the quote fetch and
  the draft restore are async, and the draft only seeds an empty field —
  so whichever lost the race was dropped. In practice the draft won, and
  asking to quote a post produced last week's draft instead. The quote is
  now applied explicitly, on top, with any draft text kept below it —
  which is also what web does, inserting into the open composer rather
  than replacing it.

**Still open:**

- **No edit indicator.** Web marks an edited post with a pencil and
  revision count, tappable for the history. The app has "View history" in
  the overflow menu but shows nothing on the post itself, so an edited
  post is indistinguishable from an untouched one.
- **A reply costs four follow-up requests** — `GET /posts/{id}`,
  `GET /t/{id}/{n}`, `POST /topics/timings`, `GET /t/{id}` — to display
  one new post. Worth a look given the rate-limit work elsewhere.

## 9e. Composer options, attachments, edit history, delete — audited

### What the composer offers, app vs web

| | App | Web |
|---|---|---|
| New topic | Category · Tags · Title · Content · "Sent from mobile app" toggle | Category · Tags · Title · Body |
| New message | Participants (chips, + Add) · Subject · Message | Recipients (+) · Title · Body |
| Edit | Content (raw markdown) | Body (raw markdown) |
| Formatting | 13-action menu: bold, italic, underline, strike, link, image, video, quote, code, spoiler, bullet/numbered list, list item | flat toolbar, ~12 |
| Attach | paperclip (file) · image | upload button |

Close to parity. The app additionally has a "Sent from Discourse mobile
app" signature toggle web has no equivalent for; web additionally has
preview, emoji picker, GIF and an AI helper.

**Verified by posting on try.discourse.org:** reply, reply-with-quote,
edit, new topic (id 1762) and a private message (id 1763) all succeed.
User search for PM recipients works and recipients render as removable
chips.

### Findings

- **New topic does not open what you created — fixed.** After posting,
  the app returned to the category list, leaving the author no
  confirmation beyond the composer closing and no way to their own topic
  except hunting for it below the pinned ones. It now opens the created
  topic, as web does and as this app already did after sending a PM. The
  composer route is *replaced* rather than stacked, so Back goes to the
  list and not to an empty composer.
- **"No users found" before searching — fixed.** The recipient picker
  fires a default "most active users" load on open with an empty query,
  which set the has-searched flag; on a forum where that returns nothing
  the user met "No users found — try a different username" before typing.
  Only a non-empty query counts as a search now. An empty default list is
  not a failed search.
- **Attachments could not be driven end to end.** The system photo picker
  does not accept synthetic taps on its confirm button, so the upload was
  not exercised. A harness limitation, not a defect — the composer's
  upload path is unverified either way.

### Corrections to earlier entries in this document

- **The edit indicator exists.** An earlier note here said edited posts
  carry no pencil. They do — marcy's post #1 on try.discourse.org shows
  one. My own edit showed none because it fell inside Discourse's
  `editing_grace_period`, which deliberately creates no revision. Correct
  behaviour, wrongly recorded.
- **Edit history is implemented.** `GET /posts/{id}/revisions/{n}.json`,
  `DiscoursePostRevision`, and a `PostRevisionPage` all exist, reached
  from the post overflow menu's "View history".
- **Soft delete and recovery are implemented.** Discourse soft-deletes by
  default (`DELETE /posts/{id}`, `DELETE /t/{id}`) and recovers via
  `PUT .../recover`; permanent deletion needs `force_destroy=true` and
  `can_permanently_delete?`. `DiscourseModerationProxy` covers all three,
  and deleted posts render a badge.

## 9f. Category, subcategory and tag views vs web

### Categories list

| | App | Web |
|---|---|---|
| Layout | vertical list, colour tile + name + description | 3-across card grid, colour swatch + name + description |
| Topic count per category | **shown** | not shown in this box style |
| Subcategory nesting | grouped under parent (fixed earlier) | grouped under parent |
| Forum header | banner: logo, name, description, post/member counts | no equivalent — site identity lives in the nav bar |

Different shapes, and the difference is defensible: a card grid needs
width the phone does not have. The app carries *more* here (topic counts,
a forum header), not less.

### Category (subforum) view

| | App | Web |
|---|---|---|
| Header | banner: icon, name, description, **New Topic** button | title in nav; New Topic is the global sidebar button |
| Notification level | overflow → full Watching / Watching First Post / Tracking / Normal / Muted sheet | bell icon, same five levels |
| Latest / New / Hot tabs | **added** | present |
| Tag filter within category | **missing** | `tags >` dropdown chip |

**Per-category tabs — done.** Latest / Hot / New now sit above the
category list, in web's order, backed by
`DiscourseTopicProxy.getCategoryTopicsAsync` (`/c/{id}/l/{filter}.json`).
Named rather than positional, like the Home sub-tabs: Hot only appears
when `top_menu_items` offers the route, and New only when signed in
(`/c/{id}/l/new.json` answers 403 to a guest), so which tabs exist varies.

Pinned topics head the list on **Latest only**. On Hot or New that feed
has its own ordering, so prepending the pinned-by-top section both masked
it and cost an extra `/c/{id}/l/top.json` — web does not do it either.
Verified on device: Hot is a visibly different ordering and now costs one
request instead of two.

### Tags

| | App | Web |
|---|---|---|
| Sort by count / name | present | present |
| Search tags | **present** | absent |
| Layout | list | multi-column `tag × count` |
| Reachable from | hamburger drawer | sidebar + `/tags` |

At parity or better; the app adds a search box web has no equivalent for.

### Resolved while implementing

The category page **does** render its subcategories — `ForumTopicList`
keeps a `_childForums` list and a subforum header. The earlier "not
verified" note was answered by reading the widget rather than hunting for
a forum that has them.

## 10. Cross-cutting

- **Anonymous chat fetch — fixed** (`bf73875`). `GET /chat/api/me/channels`
  fired three times per anonymous launch and 403'd every time. All three
  came from one call site, not three: `DiscourseConfigProxy` route-probes
  the chat plugin on every `getConfig`, and the bootstrap calls `getConfig`
  three times. The probe now resolves once per forum. Not a login gate —
  the probe reads 403 as its *positive* signal ("route exists"), so gating
  it on `isLoggedIn` would delete the answer for guests. Measured on the
  Pixel against try.discourse.org: 7 sends → 5, probe 3 → 1.
  `ChatChannelListPage`'s own fetch *is* login-gated, since that one is
  genuinely per-user.
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

1. ~~Code-block scrolling~~ — done.
2. ~~Category badge on topic rows~~ — done (topic view still open).
3. ~~Topic stats bar~~ — done. Last-reply attribution is still open, and
   is the larger half: `FCTopic` carries no last-poster fields at all, so
   "X replied 3 hours ago" needs a model change in the canonical SDK
   (`/Volumes/CRUCIAL/tapatalk_flutter`) before it can land here — see the
   Canonical SDK note in CLAUDE.md. The data itself is already in the
   `/latest.json` payload (`posters[]` + `last_posted_at`).
4. Profile: chat button, notification level.
5. ~~Reaction cluster vs. per-emoji chips~~ — done, combined style.
