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

**Subcategory nesting (§6) — not verifiable on this forum.** Zero
categories on try.discourse.org currently declare `subcategory_ids`, so
"the app renders one flat list" cannot be confirmed or denied here. The
fields to drive it (`subcategory_ids`, `subcategory_count`,
`show_subcategory_list`, `subcategory_list_style`) all exist in the
payload. Needs a forum that actually has subcategories.

---

## 2. Fields that close an already-open UI audit item

These are the cheapest wins: the gap is known, and the data is already in
a payload the app fetches.

| Open item | Field | Where |
|---|---|---|
| §2 profile "No Chat button" | `can_chat_user` | `/u/{name}.json` |
| §2 header strip missing "Views" | `profile_view_count` | `/u/{name}.json` |
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

- **`reply_to_post_number` + `reply_count`** — in-topic reply threading.
  Discourse's defining reading affordance: "↳ in reply to X", expandable
  inline. The app renders a flat run of posts, so a branching conversation
  reads as if everyone is talking past each other. Highest-value item in
  this document.
- **`post_type`** — small-action posts (user joined, topic closed, tags
  changed). Web renders these as thin grey lines; the app almost certainly
  renders them as ordinary posts, which pads topics with noise.
- **`user_title`, `flair_name`, `flair_group_id`, `primary_group_name`** —
  titles and group flair beside a username. Very visible on Discourse, and
  entirely absent here.
- `hidden`, `user_deleted`, `can_recover` — moderation states.
- `badges_granted`, `topic_accepted_answer`, `mentioned_users`,
  `link_counts`, `quote_count`, `readers_count` / `reads`.

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
- `can_vote` / `vote_count` / `user_voted` (topic voting), `thumbnails`
  (list-row images), `featured_link`, `word_count`, `pinned_until` /
  `unpinned` (per-user unpin, distinct from the app's `isPinned`).

### User / profile

- `badge_count`, `featured_user_badge_ids`, `accepted_answers` — profile
  density the audit §2 already calls thin.
- `can_send_private_messages` — the app decides whether to show Send
  Message without asking the server.
- `muted`, `invited_by`, `pending_count`, `can_edit_name` /
  `can_edit_username` / `can_edit_email`.

### Category

- `subcategory_ids` and friends — see the §6 correction above.
- **`topic_template`** — prefills the composer for categories that define
  one. A category expecting a bug-report template currently gets a blank
  box, which is a quietly bad experience.
- `minimum_required_tags` — composer validation the server will enforce
  anyway; better caught before submit.
- `default_view`, `default_list_filter`, `default_top_period`,
  `sort_order` — per-category default sorting.
- `topics_day` / `week` / `month` / `year` / `all_time`,
  `uploaded_logo_dark` / `uploaded_background_dark`, `description_excerpt`.

### Site-wide (`/site.json` — nothing is read today)

- **`auth_providers`** — social/SSO login buttons. The login page cannot
  currently offer what the forum actually supports; it has to guess.
- **`can_tag_topics`, `can_create_tag`, `can_tag_pms`** — tag permissions.
  The composer offers tagging without knowing whether it is allowed.
- **`censored_regexp`, `watched_words_replace`, `watched_words_link`** —
  watched words. Web applies these client-side; the app does not, so
  moderated text can render raw.
- `hashtag_configurations` / `hashtag_icons` — `#hashtag` rendering inside
  cooked content.
- `tos_url`, `privacy_policy_url` — legal links, and likely a store
  requirement.
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

1. **`reply_to_post_number` threading** — the single largest read-experience
   gap, and the most Discourse-specific thing missing.
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
