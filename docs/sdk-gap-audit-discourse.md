# SDK gap audit: Discourse fields the app never reads

Companion to `ui-audit-app-vs-web.md`. That one compares screens; this one
compares *payloads* — what Discourse hands us versus what the connector
actually reads. It exists to answer "what else would make the app feel
natively Discourse", with evidence rather than intuition.

## Method, and what it cannot tell you

For each endpoint: fetch the live payload from `try.discourse.org`,
enumerate its keys, and check whether the literal key string appears
anywhere in `packages/discourse_core/lib`.

Two failure modes to keep in mind before trusting a line below:

- **False "unused".** A field read through a variable, a constant, or a
  differently-spelled path shows as unused. Confirm before acting.
- **False "used".** A field whose name appears in a comment, or is parsed
  and then discarded, shows as used. `reply_count` is the worked example:
  the topic converter names it only to explain why it is deliberately
  *not* used (Discourse's `reply_count` is cross-thread replies;
  `posts_count - 1` is what the app wants).

Counts below are "keys never referenced / keys in payload". They are a
starting point for reading, not a backlog.

Measured 2026-08-08 against try.discourse.org, signed out.

**Test forum note.** The app now points at `meta.discourse.org`, because
try.discourse.org is a shallow daily-resetting sandbox: zero threaded
replies, zero small-action posts, no user titles or flair, no
subcategories. Several items below were unverifiable there — not wrong,
just untestable. meta has real threading and flair. It is a **production
forum**, so it is read-only for us: never post from a dev build.

---

## Raw counts

| Payload | Never read |
|---|---|
| `topic_list.topics[]` (`/latest.json`) | 9 / 36 |
| topic view (`/t/{id}.json`) | 32 / 61 |
| topic view `details` | 1 / 6 |
| post (`post_stream.posts[]`) | 32 / 63 |
| user (`/u/{name}.json`) | 23 / 47 |
| category (`/categories.json`) | 27 / 46 |
| site (`/site.json`) | 41 / 41 |

`/site.json` is the striking one: the app reads **nothing** from it. Every
capability it publishes — auth providers, tag permissions, watched words,
legal URLs, theme defaults — is currently either hardcoded, inferred, or
absent.

---

## 1. Corrections to the UI audit

Two items in `ui-audit-app-vs-web.md` should be revised in light of the
payloads.

**Reactions (§1) — the "only accepts a like" conclusion looks wrong.**
That section says the picker offered eight reactions "on a forum whose
reaction-list route 404s and which only accepts a like — seven of them
could never succeed". But `/t/{id}.json` publishes the authoritative list
directly:

```
valid_reactions = [heart, +1, laughing, open_mouth, clap, confetti_ball, hugs]
```

Seven reactions are valid, and the app's own topic view shows ❤️ and 😮
already applied to post #1 — so multiple reactions demonstrably work on
this forum. The 404 was on the *reaction-list route*, which is a different
question from which reactions are accepted.

**Fixed.** The picker is now driven by `valid_reactions`, captured into
`DiscourseValidReactions` from every topic payload (it is the
`discourse_reactions_enabled_reactions` site setting, so any topic load
answers it, and it costs no extra request). The 404 branch survives only
as the genuinely-unknown case — route absent *and* no topic loaded yet —
where it offers the like every Discourse accepts and lets the first topic
load correct it. Verified on the Pixel: the sheet now offers
❤️ 👍 😆 😮 👏 🎊 🤗, exactly the seven the server names, where before it
offered 👍 alone.

**Subcategory nesting (§6) — confirmed on meta, and fixed.** It was
unverifiable on try.discourse.org (zero categories there declare
`subcategory_ids`). meta has 33 subcategories, which showed the real
cause: `/categories.json` returns top-level categories only, even with
`include_subcategories=true`, while `/site.json` carries the lot. The app
had the whole nesting path already — model, converter, tree builder,
renderer — and simply never received children. Now merged from the cached
site payload, at no extra request.

---

## 2. Fields that close an already-open UI audit item

These are the cheapest wins: the gap is known, and the data is already in
a payload the app fetches.

| Open item | Field | Where |
|---|---|---|
| §2 profile "No Chat button" — **done** (unverified, see §2) | `can_chat_user` | `/u/{name}.json` |
| §2 header strip missing "Views" — **done** | `profile_view_count` | `/u/{name}.json` |
| §3 topic row "Hot" badge — **done** | `is_hot` | `/latest.json` |
| §4 stats bar missing "4 links" — **done** | `details.links` | `/t/{id}.json` |
| §4 stats bar users count — **done** | `participant_count` | `/t/{id}.json` |

The last three landed together via canonical SDK `40b5d0b` (`isHot`,
`participantCount`, `linkCount`). Worth keeping the reasoning: the stats
bar had been deriving its user count from `participatedUserIds.length`,
which agreed (6 = 6) only because the posters summary and the participant
count coincide on a small topic. The summary is capped, so they diverge on
busy ones — the list length is now only a fallback.

---

## 3. New candidates, by theme

Ordered by how Discourse-specific they are — the top of each list is what
makes the app read as a Discourse client rather than a generic forum app.

### Post-level identity and threading

- ~~**`reply_to_post_number` + `reply_count`** — in-topic reply
  threading.~~ **Done.** Posts now carry replyToPostNumber /
  replyToUsername / replyToIconUrl / replyCount (canonical SDK
  `edee5b9`), and a tappable "↳ in reply to X" row renders above the body,
  scrolling to the parent.

  Two behaviours worth keeping: it is **suppressed when the parent is the
  post directly above**, mirroring Discourse's own
  `suppress_reply_directly_above` — otherwise it fires on nearly every row
  and becomes noise. And a null `reply_to_user` is *not* "no parent":
  Discourse omits it when the target is the opening post, so the row falls
  back to "in reply to post #N".

  Verified on meta.discourse.org (try.discourse.org has no threaded
  replies at all, which is why this waited): named case renders "in reply
  to Stephen" with avatar, unnamed renders "in reply to post #2", the
  directly-above case renders nothing, and tapping jumps to the parent.
- **`post_type`** — small-action posts (user joined, topic closed, tags
  changed). Web renders these as thin grey lines; the app almost certainly
  renders them as ordinary posts, which pads topics with noise.
- ~~**`user_title`, `flair_name`**~~ — **done** (canonical SDK `9c0c359`).
  Rendered beside the username, title preferred over flair when both
  exist. `flair_group_id` / `primary_group_name` remain unread; they would
  only add the flair *colour*, which needs the group's palette.
- `hidden`, `user_deleted`, `can_recover` — moderation states.
- `badges_granted`, `topic_accepted_answer`, `mentioned_users`,
  `link_counts`, `quote_count`, `readers_count` / `reads`.

### From the side-by-side web comparison (meta, signed in)

Read against the same forum in a browser, so these are confirmed
differences rather than payload inferences:

- ~~**Poster avatar cluster on topic rows.**~~ **Done** (canonical SDK
  `ddee877`). Up to five overlapping faces per row, "+N" beyond that,
  skipped when a topic has a single voice. Built from `posters[]` joined
  against the `users[]` the same payload ships, so no extra request.
- ~~**"N Replies" expander under a post.**~~ **Done.** Renders when
  `replyCount > 0`, fetching `/posts/{id}/replies` only on expand — a
  topic can have dozens of answered posts, and pre-loading every child
  would cost a request each for replies most readers never open. Children
  render compactly (avatar, name, post number, excerpt) rather than as
  full posts, which would read as the topic having restarted. Fetched once
  and kept, so collapsing and reopening does not re-ask.

  With the "in reply to" row above it, a topic is now navigable as a
  conversation in both directions.
- ~~**A "Hot" tab.**~~ **Done.** The Home sub-tabs are now Latest / Hot /
  New / Unread / Top, matching web's order, with Hot backed by
  `/hot.json` and shown only when `/site.json`'s `top_menu_items` lists
  it — a forum can turn the route off, and it 404s when it has.
- **Topic vote count.** Web shows "2 votes" on rows in voting categories
  (`can_vote` / `vote_count`).
- **Unread position dot** beside topic titles and post timestamps.
- **In-reply-to placement.** Web puts it compactly at a post's top-right;
  the app uses a left-aligned row above the body. A deliberate divergence
  for narrow screens, not a defect — noted so it is not "fixed" by
  accident.

### Topic behaviour

- **`topic_timer`** — auto-close / auto-delete / publish-to-category
  timers. Web shows "This topic will close in 3 days"; the app closes with
  no warning.
- **`slow_mode_seconds`, `slow_mode_enabled_until`** — the app can post
  into slow mode and take the rejection blind.
- **`has_summary` / `summarizable` / `has_cached_summary`** — the AI
  topic summary. Strongly identified with modern Discourse.
- **`related_topics`** — distinct from the suggested-topics footer the app
  already renders.
- ~~`can_vote` / `vote_count` / `user_voted`~~ — **done.** Topic rows show
  "N votes" where the forum runs topic voting. `thumbnails` (list-row
  images), `featured_link`, `word_count`, `pinned_until` / `unpinned`
  (per-user unpin, distinct from the app's `isPinned`) remain.

### User / profile

- `badge_count`, `featured_user_badge_ids`, `accepted_answers` — profile
  density the audit §2 already calls thin.
- `can_send_private_messages` — the app decides whether to show Send
  Message without asking the server.
- ~~`last_seen_at`~~ — **done**; the profile shows Seen beside Last
  Activity. They are different facts: a lurker reads daily and posts
  rarely.
- `muted`, `invited_by`, `pending_count`, `can_edit_name` /
  `can_edit_username` / `can_edit_email`.

### Category

- ~~`subcategory_ids` and friends~~ — **done**; see the §6 correction
  above. `subcategory_list_style` / `show_subcategory_list` (web's box vs
  list rendering) remain unread.
- **`topic_template`** — prefills the composer for categories that define
  one. A category expecting a bug-report template currently gets a blank
  box, which is a quietly bad experience.
- `minimum_required_tags` — composer validation the server will enforce
  anyway; better caught before submit.
- `default_view`, `default_list_filter`, `default_top_period`,
  `sort_order` — per-category default sorting.
- `topics_day` / `week` / `month` / `year` / `all_time`,
  `uploaded_logo_dark` / `uploaded_background_dark`, `description_excerpt`.

### Site-wide (`/site.json`)

The app now reads a narrow slice — `top_menu_items` (drives the Hot tab),
`can_tag_topics`, `uncategorized_category_id`, `tos_url`,
`privacy_policy_url` — resolved once per forum, for the same reason as the
chat probe. The rest below is still unread.

- ~~**`auth_providers`**~~ — **withdrawn, and this document was wrong to
  recommend it.** Discourse login in this app is a single CTA that opens
  Discourse's own login page in the User API Key handshake webview, so the
  forum already renders every provider it supports, inside that webview.
  Native buttons would duplicate it and could drift out of sync. Left
  unread deliberately.
- ~~**`can_tag_topics`**~~ — **done.** The new-topic composer only offers
  the tag field when the forum says this user may tag. Before, the field
  was always shown and the server refused the tags on submit: the user
  typed them, lost them, and learned why only after the round trip.
  **Now verified on device**, and the earlier note here was misleading:
  meta answers `can_tag_topics: false` to a *guest* but `true` to the
  signed-in TL1 account, so the field correctly appears. Confirmed by
  reading `/site.json` from the logged-in browser session rather than
  anonymously — worth remembering that every capability on that payload is
  per-viewer.

  `can_create_tag` is now read too, and it is the sharper case: meta lets
  that same TL1 user *apply* existing tags but not *invent* new ones. The
  field accepted free text on Enter, which the server would then reject on
  submit — losing every tag on the post. Typing an unknown tag now simply
  does not commit; suggestions still do. `can_tag_pms` remains unread.
- ~~**`censored_regexp`, `watched_words_replace`, `watched_words_link`**~~
  — **withdrawn; this entry was wrong.** Discourse feeds these into
  `PrettyText.cook` on the *server* (`lib/pretty_text.rb`), so the
  `cooked` HTML the app renders is already censored and replaced. They
  matter only to a client that cooks markdown itself for a live composer
  preview, which this app does not — it posts markdown and lets the server
  cook. Applying them to cooked content would be redundant.
- `hashtag_configurations` / `hashtag_icons` — `#hashtag` rendering inside
  cooked content.
- ~~`tos_url`, `privacy_policy_url`~~ — **done.** Both render in Settings
  when the forum publishes them, resolved against the forum base since
  they may be relative ("/tos") or absolute. Verified on meta.
- `top_tags`, `navigation_menu_site_top_tags` — tag discovery.
- `homepage_choices`, `top_menu_items`, `filters` — which tabs a forum
  actually wants surfaced, instead of the app's fixed five.
- `default_light_color_scheme`, `default_dark_color_scheme`,
  `user_color_schemes`, `user_themes` — forum theming.
- `uncategorized_category_id`, `email_configured`,
  `full_name_required_for_signup`.

---

## Suggested order

Judged on user-visible impact per unit of work, not payload size.

1. ~~`reply_to_post_number` threading~~ — done.
2. ~~The five §2 cheap wins~~ — three done (`is_hot`, `participant_count`,
   `details.links`). Remaining: `can_chat_user` (profile Chat button) and
   `profile_view_count` (profile header "Views"), both `FCUser`-side.
3. **`post_type` small actions** — removes noise from every long topic.
4. **`/site.json` capability reads** — `auth_providers` first (login is a
   dead end without it), then tag permissions and watched words.
5. **`topic_timer` + slow mode** — stops the app from failing silently
   against rules the server is enforcing.
6. **`user_title` / flair** — cheap, and very recognisably Discourse.

Anything here that needs a new `FCTopic` / `FCPost` / `FCUser` field must
land in the canonical SDK first — see the Canonical SDK note in CLAUDE.md.
`lastPosterName` / `lastPosterIconUrl` / `lastPostedAt` (tapatalk_flutter
`83a8264`) is the worked example: additive named fields with defaults, so
`xenforo_core` compiles untouched. The one trap is that `FCThreadResult`
and its three siblings re-declare every base field and forward it, so a new
`FCTopic` field must be repeated there too — and `build_runner clean` is
required, because an incremental run leaves those subclass mappers stale.
