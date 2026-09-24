# Changelog

All notable changes to this project are documented in this file.

The format is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Releases below 1.0 should not be assumed backward-compatible across minor bumps.

## [Unreleased]

Full review, batch 2: things that worked, but not the way Discourse does. Each was checked against a local Discourse with the app's own User API Key scopes. Covered by `packages/discourse_core/test/topic_behaviour_test.dart`, `message_behaviour_test.dart`, `users_staff_behaviour_test.dart` and `packages/discourse_ui/test/notification_route_conversation_test.dart`, `website_display_name_test.dart`.

### Fixed
- **A topic knows it is closed, pinned and watched however you open it.** Opening at your first unread post or at a linked post built the topic without those flags, so a closed topic showed no closed banner, the staff close and pin toggles offered the opposite action, and the bell showed "Normal" on a watched topic.
- **A topic opens after the last post you read**, as on the website (last read + 1, capped at the newest post). A plain tap on a topic while signed in opens there too, instead of at the top.
- **Only posts that were on screen are reported as read**, a second after they appear, instead of every post the app had loaded.
- **A post held for moderation says so.** Discourse answers "enqueued" for a post that needs approval; the app announced it as posted and tried to open a post that did not exist yet. It now shows Discourse's "Post Needs Approval" notice.
- **Delete, close, pin and undelete report a refusal** instead of claiming success, and deleting a post asks the plain question Discourse asks.
- A subcategory's notification level is found (subcategories are nested in `/categories.json`), a bookmark shows its post's author, a resumed new-topic draft keeps its own draft, and the signature box starts off, since Discourse has no signatures.
- **The Messages badge clears.** A message's small-action entries ("added alice") were never reported as read, and Discourse ties the new-reply notification to them, so it stayed unread. Message notifications now open the message at the reply that caused them (`original_post_id`), a message's post count is its highest post number, and the reply box follows `can_create_post`.
- **Saving your profile no longer rewrites your website.** The edit form was filled from Discourse's shortened display form (`website_name`, host and path), which was then saved back as the address. The profile shortens it for display itself.
- **Review queue cards show what is being reviewed**: the flagged post's text (sent at the top level of the row, not in `payload`), each flag's reason and who raised it. Actions are grouped the way the website groups them, with a "Yes" and a "No" dropdown. Before, two identical "Keep post" buttons sat side by side, one agreeing with the flag and one disagreeing. The forum's own confirmation is shown when an action is done, and a reject reason reaches the server (Discourse emails it to a rejected sign-up).
- **Profile activity keeps loading past the first 30.** Only the Replies tab was told when you scrolled, and every feed took the page length as the total, so Likes, Bookmarks, Solved and Replies all stopped at one page, and Topics had no paging at all. Every tab now follows the profile's scroll, a full page means there is more, and Topics pages by offset.
- **Group members no longer repeat the owners on every page or skip members.** Discourse re-sends the full owner list with each page; the app put it at the top of every page and counted it into the next offset.
- **Invite links work for more than one person.** The app sent no redemption count, so the server's default of one applied to a link meant for sharing. It now asks for what the forum's own invite dialog does: 10, or 100 for staff, within the forum's limit.
- **Spam Cleaner is Discourse's Delete spammer.** XenForo's four options did not map to Discourse: the app silenced the user and deleted nothing unless an option was ticked. It is now the website's single action, which deletes the account and every post and blocks the email address, IP address and posted links. It is offered only where Discourse would allow it (`can_be_deleted`: moderators cannot delete established members).
- **Delete account opens your account preferences** on the forum when it lets members delete their own account (`can_delete_account`). There Discourse has its own Delete My Account button. Otherwise the app still points you to the forum's staff.

## [1.0.27] - 2026-09-24

Links in and out of a forum. Covered by `packages/discourse_core/test/discourse_link_test.dart`, `forum_link_requests_test.dart` and `packages/discourse_ui/test/notification_route_test.dart`.

### Changed
- **Copy link and Share give the forum's own address** — `/t/{slug}/{topic_id}/{post_number}`, the first post as the topic, as the forum's website shares them — instead of the slugless `/t/{topic_id}/{post_number}`. This covers a post's Copy link and Share, the topic's Share and View on web, and every topic address in lists and search. The share credit the web adds for signed-in readers (`?u=username`) is left off: it depends on site settings the API does not expose, and it would put the reader's username in every link they copy.
- **Copy link on messages**, as the web has on every post of a message.
- **A link or notification that names a post lands on that post**, not on the first post of its page: the topic loads around the post (`PostPage.gotoPostNumber`). The jump-to-post dialog, "jump to last" and the accepted answer's "Post #N" load the same way, so a target late in a page is no longer missed.
- A notification for a topic with no position opens where a tap on the topic would: the first unread post when signed in.

### Fixed
- **Scrolling up after entering a topic mid-way no longer skips posts or loses your place.** Loading earlier posts asked for the post a whole page back, and Discourse centres that window on it, so the page came back 5 posts short: from posts 35–54 it loaded 9–30, and 31–34 were never shown. It now asks for the post half a page back. And the reader is put back exactly where they were once the earlier posts are in, rather than by a short animated scroll that did not hold — a link to a post near the top of its window had gone on to load page after page and ended 24 posts above the one it named.

### Added
- `DiscourseLink` (discourse_core): reads a URL as a link into a Discourse forum — topic, post number, post short link, subfolder installs, query, fragment — and writes a topic's web address. `DiscourseNotificationRoute.fromLink` turns one into the route a notification would name, and `DiscourseRouteNavigator` takes the reader there for both. `getIdByUrl` uses it: it read slugless `/t/{id}/{n}` links as topic `n`, and now resolves `/p/{post_id}` short links.
- `SingleForumBootstrapPage(route:)` opens a forum at a topic or post, for hosts that open links.
- `DiscourseHost.openForum`: a notification for a forum other than the one on screen is opened by the host, the way it opens any forum. Without it the module replaced the whole navigation stack with its single-forum bootstrap page — in a multi-forum host, the template forum rather than the host's chooser.
- `DiscourseTopicSlugs` (discourse_core): topic slugs recorded from the topic payloads the app already fetches, per forum.

## [1.0.26] - 2026-09-24

Found by re-crawling every directory forum on the Pixel after batch 6. Covered by `packages/discourse_ui/test/render_regressions_test.dart`.

### Fixed
- **A table with a linked image in a cell no longer fails to draw** (introduced in 1.0.22). Email-style signatures and sponsor blocks put a linked logo in a table; the table's column sizing asked the image for a text baseline it cannot give, and the table was left blank with a layout error. Post images now report having no baseline, as they already do in normal layout.
- **Inline maths wider than the screen scrolls sideways** instead of overflowing its line, as display maths already did.
- **A forum whose `/about.json` hangs now opens** instead of failing with "Failed to connect". forum.cfx.re answered every other read in a fraction of a second but sometimes left `/about.json` hanging, and that one optional read ran the whole configuration load into its 10 s timeout. It now gets 4 s of its own; past that the forum opens without it, taking read-only mode from `/site/settings.json` instead. Only the post and member counts in the forum header still wait for it. Covered by `packages/discourse_core/test/config_about_timeout_test.dart`.
- **A topic no longer sits on its loading placeholders until you touch the screen.** Loaded posts were published on the next frame without asking for one; since the placeholders stopped animating (the scroll audit), a topic whose posts arrived after the page-open animation stayed blank — a local topic waited over a minute for a 274 ms answer. `PostController.applyOnNextFrame` now requests the frame. Covered by `packages/discourse_ui/test/post_controller_next_frame_test.dart`.

Full review, batch 1: requests that could not do what the app said they did, each checked against a local Discourse with the app's own User API Key scopes, as a member and as an admin. Covered by `packages/discourse_core/test/topic_post_requests_test.dart`, `message_notification_requests_test.dart` and `staff_account_requests_test.dart`.

- **Mark all as read works.** The app bars pass XenForo's "all forums" id `0`, which went out as `category_id: 0` and marked nothing while the app reported success. No category now means every category, and a category takes its subcategories.
- **A reply to a post is linked to it** (`reply_to_post_number`, also for quote replies and whispers), so its author gets a "replied" notification and the reply is listed under that post.
- **Editing a topic's title saves it** — the title goes with the first post's edit — and editing a reply no longer sends an invented "Re: …" title.
- **The Drafts page no longer fails** once a new-topic draft has a category (stored as a string, read as a number). New drafts store the number, as the web does; older ones still load.
- **"I liked" in search finds what you liked**: Discourse's operator is `in:likes`; `in:liked` searched for the word.
- **The Top list pages**: every other page was skipped and later pages repeated the first (`/top/{period}.json` redirects and drops `page`), and "All" was not all time. It always asks `/top.json?period=`.
- **The message list loads past its first 30**: "more" is Discourse's `more_topics_url`, not a count compared with 20.
- **"You are now a member of …" opens the group** instead of "Username is missing".
- **People pickers offer only groups you can use**: groups you may message for recipients and invites (all visible groups were offered, then refused), groups you may mention for @mentions, and people only in the member directory (a group there opened a profile that could not load).
- **Review-queue actions on flagged posts, users and chat messages work** — they sent the target-prefixed action id and got "not found"; they send the server action.
- **A temporary suspension ends on the chosen date**, not about 56 years later.
- **"Change password" sends the reset email**: the request goes by the account's email address, which Discourse requires with its default settings.
- **The groups list shows every group**: it started on the server's second page and, on a phone (15 a page), stopped after one.
- **A renamed topic shows its new title in the opening post too**, not only in the header.
- **A draft resumed from Drafts names its category** instead of showing a blank category chip.

## [1.0.25] - 2026-09-23

Thread rendering, batch 6: how a post reads. Covered by `packages/discourse_ui/test/post_polish_test.dart`, `packages/discourse_core/test/api_exception_test.dart` and `post_kinds_and_polls_test.dart`, and checked before/after on the Pixel in light and dark themes.

### Changed
- **Post text is 16 with 1.5 line spacing**, Discourse's size on phones, instead of Material's 14/1.4 (long posts read noticeably denser). Chat and the solved-answer excerpt keep their 14.
- **Links are marked by colour alone**, as on the web; they were underlined.
- **@mentions are pills** (rounded, on a light background), as on the web, instead of bold link-coloured text.
- **A post of nothing but emoji shows it large** (`only-emoji`, 32px on the web).
- **Authors' full names show beside their usernames**, as on the web, when the forum has names and the name says more than the username.
- **Followed links show their click count**, the web's small grey badge ("253", "1.2k").
- **Code is coloured by its language and has a copy button.** The a11y palettes are used, with every token colour then held to 4.5:1 contrast on the block in both themes (stock palettes put comments and annotations in greys under 2.5:1); `lang-auto` is detected for short blocks, unknown languages stay plain.
- **`<details>` is discourse-details' ▶ summary** on a light background, not a Material ExpansionTile.
- **Image grids are two masonry columns**, as the web lays them out on a phone (or a sideways carousel for carousel grids), instead of a stack.
- **Errors say what happened, in the reader's language**: no connection, timed out, only for paying members, blocked by the forum's firewall, no access, not found, too many requests, forum not responding — instead of "Payment Required", "Not authorized (HTTP 403)" or "An unexpected error occurred", both on the thread page and in the error dialog (which also drops its Retry where retrying cannot help). A message the forum wrote itself is still shown as it is. `DiscourseErrorKind` in discourse_core classifies; the UI words it.
- `FCPost` carries `authorDisplayName` and `linkClicks` (canonical SDK tapatalk_flutter `615cd205`, synced). Added `flutter_highlight` and `highlight`.

## [1.0.24] - 2026-09-23

Thread rendering, batch 5: link previews. Covered by `packages/discourse_ui/test/onebox_rendering_test.dart` and checked before/after on the Pixel in light and dark themes.

### Fixed
- **Link previews are cards, as on the web** (11,479 posts on 825 forums in the audit). The forum's onebox was drawn as raw markup: favicons at full size, thumbnails across the whole column, the title as an underlined link, no card. It is now a bordered card with the site's 16px icon and name, the title in the link colour, the excerpt, and a small thumbnail beside the text; tapping opens the link. No request is made that the forum did not already make.
- **GitHub previews** show an issue, pull-request or commit icon, the title, "opened … by …" with the date in the reader's time zone and a short excerpt; file previews show their path and code (older previews' numbered lines now read one per line). An inline GitHub avatar is no longer drawn at 48px.
- **PDF previews** show a PDF tile, the file name as a reader would write it (no `%20`) and its size; **tweets** the author's avatar, name and handle, the text, photos or video, and the date with like and retweet counts.
- Links, local dates, code and videos inside a preview keep working: the preview's body is rendered by the same renderer as the post.

## [1.0.23] - 2026-09-23

Thread rendering, batch 4: what Discourse's plugins draw with JavaScript on the web. Covered by `packages/discourse_ui/test/discourse_blocks_rendering_test.dart`, `local_dates_test.dart` and `packages/discourse_core/test/post_kinds_and_polls_test.dart`, and checked before/after on the Pixel in light and dark themes.

### Fixed
- **Moderator actions are one-line notices**, as on the web ("🔒 Closed 3 days ago", "Invited @sam …"), instead of a full post with an author and an empty body (4,076 posts on 643 forums in the audit). The wording is Discourse's own `action_codes`, core and discourse-assign, in all eleven app languages; a moderator's note on the action is shown under it.
- **Spoilers are blurred until tapped**; they were printed in clear. Links inside stay inert until revealed.
- **Local dates show in the reader's time zone** — "Today 3:00 PM", "September 18, 2026 11:12 AM", the post's own format, and the zone's name when the post pins another — instead of the UTC text Discourse writes for email. Also inside GitHub oneboxes.
- **Polls appear once, where the author put them, in every post.** The first post's poll was drawn above the text while the cooked option list, with a vote count frozen at cook time, stayed below; polls in replies had only that list. A vote in a reply's poll, or in a post's second poll, now reaches that poll.
- **Calendar events are a card** — date badge, name, time range in the reader's zone (the next occurrence for a repeating event), place, repeat rule, "Expired" when over — instead of the description alone.
- **Math is typeset** (`flutter_math_fork`) instead of printed as TeX; TeX it cannot parse is shown as its source.
- **Mermaid diagrams** are labelled and offer "View on Web", where the diagram is drawn.
- **Moderator posts are tinted and flag-hidden posts faded**, as on the web.

### Changed
- `FCPost` carries the post's `polls`, its `actionCode`/`actionCodeWho`, `isModeratorAction` and `isHidden` (canonical SDK tapatalk_flutter `4b6ae948`, synced).
- Added `flutter_math_fork`; `intl` and `timezone`, already in the dependency graph, are now direct dependencies.

## [1.0.22] - 2026-09-23

Thread rendering, batch 3: content that disappeared from posts. Covered by `packages/discourse_ui/test/post_media_rendering_test.dart` and `embed_links_test.dart`, and checked before/after on the Pixel in light and dark themes.

### Fixed
- **Tables render.** flutter_html has no table support, so a table and every word in it vanished — 98% of the text the audit found missing from posts (2,020 posts on 469 forums). Tables are now laid out like the web's mobile view: at least as wide as the post, columns sized by their content with long cells wrapping, and a table too wide even then scrolls sideways in its own box. Header rows are bold with a heavier rule, `style="text-align:…"` is kept, colspan and rowspan work, and links, code and emoji inside cells behave as elsewhere. Rules follow the light/dark theme.
- **Videos appear where the author put them.** YouTube, Vimeo and TikTok embeds show the forum's thumbnail and title with the site's play button, as on the web, instead of a bare image or a card appended under the post; tapping opens the video in its app. The same preview is drawn for player iframes (YouTube, Vimeo, Dailymotion, Twitch, Loom, Wistia, Bilibili, Facebook video, …), older `lazyYT` embeds, and video links the forum did not turn into an embed. A YouTube embed that arrives without a title gets it from forumcopilot.com, as in the ForumCopilot app; embeds that carry their title cost no request.
- **Embeds from other sites show a preview card** instead of nothing. Every `<iframe>` the forum allows (Spotify, SoundCloud, Bandcamp, Reddit, Instagram, Google Maps, Steam, …) becomes a row naming the site and, where the embed says, the track or post; tapping opens the site or its app. The app does not run third-party players inside posts.
- **Uploaded videos and audio play.** `<video>` uploads and Discourse's newer video placeholder show their poster with a play button and open in the app's video player; `<audio>` uploads get an in-place player with a scrubbable progress bar.
- **Tweets keep the preview the forum made** instead of being replaced by a bare link; the author's avatar is drawn small rather than at 400×400. A tweet link the forum did not preview gets the tweet card, filled from forumcopilot.com.
- **Markup hidden with an inline `display: none` stays hidden** (older YouTube oneboxes ship a hidden thumbnail beside the player).

### Changed
- Added `flutter_layout_grid` (table layout with the CSS grid sizing algorithm, including spans).

### Removed
- The video and tweet cards drawn below a post (`VideoCard`); embeds are now drawn in place.

## [1.0.21] - 2026-09-23

Thread rendering, batch 2: forums that turned the app away now open.

### Fixed
- **The app sends the phone's real WebView User-Agent** instead of a hard-coded "Chrome/131" string. That string, chosen years ago to pass Cloudflare, had become the reason forums refused the app: community.home-assistant.io answered it with a Cloudflare 403 and forum.codefloe.com with "Browser Update Required", while both accept the phone's actual WebView User-Agent. The value is read once from the system WebView (`WebViewUserAgent`, in the shared SDK), cached across launches so start-up does not wait for the WebView, and refreshed in the background for the next launch; the in-app Cloudflare challenge uses the same string, so its clearance cookie stays valid. Platforms without a system WebView fall back to a current browser string. Also applies to the ForumCopilot app, which shares the SDK.
- **A rate limit on one forum no longer pauses the others.** The 429 cooldown was one app-wide value; in a multi-forum app, forum A's cooldown stalled every request to forum B. It is now kept per forum.

### Changed
- The vendored `forumcopilot_sdk` is synced with the canonical copy again (tapatalk_flutter `42e35057`), which also brings its fix that stops a legacy login field from persisting a password copy in local storage.

## [1.0.20] - 2026-09-23

Thread rendering, batch 1 of the audit that opened the first 50 topics of all 924 ABDA directory forums on a Pixel 4a and compared posts with the web (292k posts rendered). Every fix below is covered by `test/post_body_rendering_test.dart` and was checked before/after on the Pixel in light and dark themes.

### Fixed
- **Images keep their proportions.** An upload wider than the screen kept its HTML height while its width shrank, so every large image sat in a band of blank space. The box now follows the image's aspect ratio.
- **No file-name captions under images.** The lightbox caption Discourse ships for its hover overlay (`image1408×768 113 KB`) was printed under every upload; it is dropped, as web hides it.
- **`<hr>` is a thin divider** instead of a heavy black box followed by ~280dp of empty space.
- **Quotes are drawn once**; every quote had a second bar and background from the blockquote inside it.
- **Hidden content stays hidden.** Markup Discourse hides with CSS (`.hidden`, e.g. the full issue body behind a GitHub onebox's excerpt) was printed.
- **An invalid author colour no longer breaks a post.** `<font color="#PG985740">` made flutter_html throw and the post became an error box. Author colours are normalised (all CSS colour names now work, invalid ones are dropped as a browser would), and if flutter_html ever fails on a post again it shows as plain text instead of an error box (`installPostBodyErrorFallback`, installed by `setupErrorHandling`).
- **Author colours stay readable in light and dark themes.** Colours chosen against a light forum are lightened or darkened only as far as needed to reach WCAG 4.5:1 contrast with the current background, keeping their hue.
- **SVG images render** (uploads, favicons) instead of falling back to their alt text.
- **Checklists show which items are ticked** (☑ / ☐ in theme colours).
- **Names that start with an emoji** no longer throw in letter icons ("🎓 Docs"): category icons, forum headers and letter avatars take the first whole character.
- **Solved topics show their answer under the question again.** Current discourse-solved sends `accepted_answers` (a list); only the older `accepted_answer` was read, so the panel was missing on 389 of 417 solved-enabled forums.

### Removed
- **Link-preview cards under posts.** For the first plain link in a post the app fetched the page from the phone and added a card the web never shows; posts now show only what the forum oneboxed.

## [1.0.19] - 2026-09-23

Photos and files: sending them in chat, taking them with the camera, and uploading them at the size the forum's website uses. Tested on a Pixel 4a against a local Discourse.

### Added
- **Images and files in chat.** The chat composer has an attach button — Take photo, Upload image, Attach file. Each file uploads as soon as it is picked (as `chat-composer`, like Discourse's own composer), shows above the input with a spinner and a remove button, and goes with the message by id; a message may be files alone, and the sender sees them at once. Hidden when the forum turns `chat_allow_uploads` off or nothing can be sent in the channel.
- **Take photo, everywhere images are uploaded:** chat, the topic, reply, edit and personal-message composers, a new personal message, and the profile picture. Camera photos are named like a camera names them (`IMG_20260923_113747.jpg`) rather than with a random id, which a post would show as the image's description.

### Changed
- **Photos are uploaded at the size the forum's website uploads them.** Discourse's composer shrinks photos in the browser before uploading, following the forum's `composer_media_optimization_*` and `image_quality` settings; the app now does the same for JPEG photos of 512 KB or more: scaled to 1920 px wide when wider, re-encoded at the forum's quality, turned upright, with metadata such as GPS location removed. A 12-megapixel phone photo used to go up at 3024×4032 and 2–3 MB; it now arrives at 1920×2560 and about 0.5 MB. PNG screenshots, GIFs and other files are left untouched (the website converts PNGs to JPEG as well, which flattens transparency). The original is kept if shrinking would not make it smaller, and the "too large, resize?" question only appears if a photo is still over the forum's limit afterwards. Forums that turn the setting off get full-size uploads, as before.

### Fixed
- An open chat now stays on its newest message while an image or reaction lays out below it; a new photo used to be left half off screen.

## [1.0.18] - 2026-09-23

Chat, reviewed against Discourse's chat plugin and tested on a Pixel 4a against a local Discourse with a second user posting through the API.

### Added
- **Live chat over MessageBus.** An open channel used to re-fetch 50 messages every 4 s — 15 requests a minute against the User API Key's 20/minute and 2,880/day, so a channel left open used up the key's day in about three hours — and never showed other people's edits, deletions or reactions. `DiscourseMessageBus` now long-polls `/message-bus/{client}/poll` the way Discourse web does (held ~25 s, polls at least 6 s apart, Retry-After honoured, a 30 s refetch fallback when the key has no message-bus access). Measured: an idle open channel makes 2.4 requests a minute, a burst of ten messages peaks near 14, and a phone with the screen off makes none. New messages, edits, reactions and deletions appear live; "mark read" is sent at most every 30 s.
- **Images and files in chat.** Discourse sends them in a message's `uploads`, not its cooked HTML, so they were empty bubbles. They are drawn with the topic view's attachment widgets, and an image opens full screen.
- **A chat notification opens its message**, fetched around it, scrolled to and briefly highlighted, with the channel as the title.

### Changed
- **Discourse's words for chat**, in all eleven languages: a **Channels | DMs** switch with unread dots, a "Start new DM" button, a "Create a personal chat" sheet, composer hints ("Chat in #general", "Chat with @bob", and read-only, closed, archived or silenced states), the delete confirmation, and chat notification texts that say whether it was a DM or a channel.
- **No "Inbox" title over Chat | Messages.** Discourse uses that word for the personal-message folder; the Chat | Messages row is now the header and carries the drawer button.
- **Chat appears only for people who can use it**, as on Discourse: the Chat half needs the member's `has_chat_enabled` (the forum's setting, `chat_allowed_groups`, and their own preference), Channels needs `enable_public_channels`, and DMs and the new-DM button need `can_direct_message` (or existing DMs to read).
- Edit, delete and the composer follow Discourse's permissions from the channel's meta: write in an open channel (a closed one if you moderate it), never while silenced; delete your own or anyone's as the forum allows.

### Fixed
- **New DM could open a chat with only yourself.** The sheet sent every pick, groups included, as `target_usernames`, and Discourse drops names it cannot use. It now searches `/chat/api/chatables` (people who cannot chat shown but not pickable), sends groups as `target_groups`, and stops on an unknown name before anything is created.
- **Editing a message removed its attachments** on the server (a missing `upload_ids` reads as "no uploads"). Edits send the message's upload ids and keep its reactions.
- The profile's Chat button no longer depends on the member accepting personal messages.
- A channel that fails to load says so with Retry instead of "No messages yet", and the channel list refreshes its badges when you come back from a channel.

## [1.0.17] - 2026-09-23

Opening a forum: one screen that fills in, and an offline failure that says so. Tested on a Pixel 4a against meta.discourse.org.

### Changed
- **Opening a forum goes straight into the forum.** It used to show a "Connecting to…" dialog stacked on a second spinner, hiding the forum's name, then a blank page while the home fetched the forum's config a second time. Now `SingleForumBootstrapPage` draws the home's own layout while the forum initializes — app bar, the forum's header, the filter bar and topic list as placeholders — and the real home replaces it in place with a short fade. The placeholder keeps the home's geometry (stats lines, chip sizes, wordmark height) so nothing moves when it hands over, and it shows no brand until the forum's config has given one. When initialization fails, that page says so, with Retry; Back works throughout.
- **Offline, opening a forum says so.** A forum that does not answer — offline, DNS failure, connection refused, or no response within the timeout — used to open into an empty home that looked like a forum with no topics. It now gets the failure page, telling the user to check their connection (new `checkConnectionAndRetry` string, all eleven languages). `DiscourseConfigProxy.getConfig` throws when `/about.json` gets no response at all; any answer, even an error, still counts as the forum being up.
- **Entering a forum waits on fewer round trips.** `DiscourseConfigProxy.getConfig` sends its four reads (`/about.json`, the chat probe, `/site.json`, `/site/settings.json`) together rather than one after another, and the push-token sync and the visit record no longer hold the forum back.
- `SiteHomePage(siteVerified: true)` skips the redundant config check, `ForumHeaderWidget(pendingSite:)` draws a forum that is still initializing, `TopicsTabAppBar` takes a `leading`, and `BaseDiscourseProxy.apiGetWithHeaders` returns a response's own headers. `SiteInitializationService.initializeSite` no longer takes progress callbacks, and `ProgressDialog` is removed.

## [1.0.16] - 2026-09-23

Private messages, reviewed end to end against Discourse and tested on an iPhone 17 and a Pixel 4a against meta.discourse.org.

### Added
- **Archive and Move to Inbox.** Discourse files messages by archiving them — there is no user-level delete — and the app had the calls but no way to reach them. The message menu now offers Archive (or Move to Inbox for an archived message), and the Messages tab has an **Inbox | Archive** switch backed by `/topics/private-messages-archive/{username}`.
- **Groups on a message.** A message's groups are listed first in the participants sheet and counted in the header, as Discourse web shows them, and a group picked in the invite search is invited as a group (`POST /t/{id}/invite-group`) — it used to go to the user invite and fail.

### Fixed
- **A private message can be replied to.** Reply and Quote refused unless the topic had a category, answering "Please wait for the topic to load"; a Discourse PM never has one. Whether you may reply now comes from Discourse's own `details.can_create_post`.
- **Images attached to a PM reach the message.** New message, reply and edit posted the text alone, so an uploaded image never appeared.
- **Tapping an image in a message opens it full screen**, as it already did in topics.
- **Participants include the author and everyone who posted.** Discourse leaves out of `allowed_users` anyone covered by one of the message's groups, which removed `system` from system messages ("1 participant").
- **Mark unread works** (`DELETE /t/{id}/timings?last=1`, as Discourse web does); it reported success without a request. **Opening a message marks it read** (`POST /topics/timings`); it never did.
- **Leave is offered only when Discourse allows it** (`can_remove_self_id`) and a refusal is shown; **Close/Open only to those who may** (`can_close_topic`); **Edit title no longer fails** for regular users by also sending the open state.
- Discourse's system entries in a message ("left", "invited") no longer render as empty bubbles; the fake green "online" dot and an unreachable "Report conversation" entry are gone.
- The message list no longer shows its first page twice (Discourse pages hold 30, the list asked in 20s), and the Archive list no longer spins forever (two list widgets shared one VisibilityDetector key).
- **Notifications on Android.** The grant upload was challenged by a Cloudflare rule on the notifications backend that targets outdated Chrome user agents — the SDK's Android agent claims Chrome 131 — and the challenge replay lost the request body. `NotificationKeyService` now sends its own `DiscourseApp-Notifications/1` user agent.

### Changed
- **Private messages speak Discourse, not XenForo.** "Conversation" is gone from the PM screens in all eleven languages, which now follow Discourse's own noun and, wherever one exists, Discourse's official translation (`config/locales/client.*.yml`). The Leave confirmation now says what leaving does — "You will no longer be able to see or reply to it" — instead of claiming it only hides the message. The participant count is a proper plural in every locale.
- `DiscourseMessageDetails` (discourse_core) carries per-message facts the shared SDK cannot: whether the viewer may leave, whether it is archived, and its groups. `DiscoursePrivateConversationProxy` gains `getArchivedConversationsAsync` and `inviteGroupAsync`.

## [1.0.15] - 2026-09-22

### Fixed
- **A notification tapped on the lock screen no longer opens the forum signed out.** Found on an iPhone 17: the session came back on the next cold start, so the key was intact — the read had been *refused*. The plugin throws for a refused read (the iOS Keychain around a lock-state change) and returns null for an empty store, and `loadUserApiCredentials` treated both as "no key". Site init reads the key twice, so one refusal on the second read overwrote a good in-memory key and signed the user out for the session. A refusal is now retried briefly; if it persists, a key the context already holds is kept, and otherwise the session starts signed out with the stored key untouched, so the next launch recovers.
- **iOS keeps the User API Key readable after the first unlock** (`kSecAttrAccessibleAfterFirstUnlock`) instead of only while unlocked. The old class assumed the app never reads the key on a locked device, which push made false. Backup behaviour is unchanged (not `_ThisDeviceOnly`). Existing keys move to the new class on the first launch that reads them, once; sign-out also deletes under the old class for a key no launch has moved yet. Android and macOS are unchanged.
- **A topic that fails to load now says so.** A refused load — typically a private message opened while signed out — rendered as an empty topic with no title, "End of the discussion" and "1 / 0". The list now shows the forum's own reason, a sign-in hint when signed out, and Retry.

### Documentation
- `docs/push.md` states the payload contract a notifications backend has to meet.

## [1.0.14] - 2026-09-10

### Added
- **A notification from the notifications backend now opens what it is about.** The backend delivers Discourse's own vocabulary — `topic_id`, `post_number`, and the post id only when `/notifications.json` exposed one — while tap routing understood the XenForo plugin's `content_type`/`content_id` shape alone. Every delivered notification therefore opened the app on an "Unsupported notification type" dialog. `NotificationRoute` (`discourse_ui`) now decides the destination from the payload alone: the post when its id is known (replies, mentions, quotes, likes, links, messages), otherwise the topic at the page holding that post number, otherwise the notification list. It is pure, so the rules are readable and tested rather than tangled in navigation.
- **The notification list is now a real destination.** A badge, a bookmark reminder or a plugin's own type names nothing to open, and those used to raise an error dialog. `SiteHomePage.initialTab` and `DiscourseSiteController.requestHomeTab()` let anything ask the home page to open on a tab; the request waits if that tab does not exist yet, since the notifications tab only appears once the forum's config has arrived.

### Fixed
- **A notification for the forum already on screen no longer stacks a second copy of it.** Two forums were compared by id, and a multi-forum host that opens forums by address has no ids for them, so the comparison answered "different forum" every time and pushed another home page onto the stack. Forums with ids still compare by id; the rest compare by host.


## [1.0.13] - 2026-09-10

### Added
- **The notifications grant now has a switch, and it is off by default.** After sign-in the app offers a second, notifications-only User API Key that a backend polls on the user's behalf — the way to get push on a forum whose owner has not allowlisted a push URL. That flow ran unconditionally and uploaded the key to a compile-time ForumCopilot address, so every fork asked its users to hand a forum key to a server the fork's author does not run. It is now behind `AppForumConfig.notificationsApiBaseUrl`: empty (the default) means no second handshake and nothing uploaded; a host app sets it once at startup with `setNotificationsApiBaseUrl()`, a fork edits `defaultNotificationsApiBaseUrl`. Deliberately separate from `pushApiBaseUrl`, which is the relay path and changes what the login handshake asks for. The three calls live in `NotificationKeyService` (`discourse_ui`), which documents the contract a backend has to serve; `ForumCopilotApiService`'s copies in the SDK are no longer used.
- **The forum is identified by URL, so a host without directory ids can use the grant.** Upload, device-token sync and revoke all bailed on a null `Site.id`, which is every forum a host opens by address: the key was minted on the forum and then went nowhere, once per sign-in. `site_url` is now the identity and `site_id` rides along only when there is one.
- **A completed grant is remembered per forum**, so signing in again does not ask again; sign-out forgets it. Settings → Notifications gained a *Notifications on this device* row that turns the grant on later (the same page the sign-in flow shows) or off (the backend confirms the revoke before the app forgets the grant — forgetting first would keep delivering to a user who asked for silence).

### Changed
- **The system notification prompt no longer fires at first launch.** It appeared before the user had seen anything worth an alert, and the grant page then assumed iOS had granted it. The grant page's own button now asks the OS first, when the user has just read what the alerts are for, on Android, iOS and macOS alike, and shows a way to the system settings after a refusal. The launch-time prompt remains only for builds with a push relay (`pushApiBaseUrl`), which have no later moment to ask. Token acquisition never depended on the answer; only display does.
- "Approved, but we could not reach…" no longer names ForumCopilot; the backend is whatever the build points at.
- The ForumCopilot host must call `AppForumConfig.setNotificationsApiBaseUrl()` at startup to keep offering the grant once it picks up this version.

### Fixed
- The Android manifest declared `forum_app_channel` as the default notification channel while the app creates, and the push backend targets, `forum_copilot_channel`. Notifications shown by the system while the app was in the background landed on an undeclared channel with default importance and no heads-up.

## [1.0.12] - 2026-09-09

### Changed
- **A host app can name itself on Discourse's grant page.** `application_name` is what Discourse prints on `/user-api-key/new` ("… would like to access your account") and stores on the `UserApiKeyClient` row, so it is also what the user sees later under Preferences → Security → Apps — the one string telling them which app is asking. It was hard-coded to the template's `Discourse Mobile`, which a multi-forum host cannot change because the value is compile-time and the package is shared. `AppForumConfig.setUserApiApplicationName()` now overrides it at startup, the same way `setPushApiBaseUrl()` already does; the compile-time value moved to `defaultUserApiApplicationName` and still applies to forks that set nothing. Both grants read it, the login key and the separate notifications key.

## [1.0.11] - 2026-09-09

### Fixed
- **Emoji in reaction chips and post bodies** now resolve against Discourse's own name table, the one 1.0.10 introduced for titles and excerpts. Reaction glyphs went through the generic emoji library plus a hand-kept alias list for the handful of names it files differently (`:+1:`, `:-1:`, `:hugs:`); the reaction-users sheet and the inline emoji in cooked post HTML had no such cover, so the 866 Discourse names that library does not know fell back to a network image or to nothing. Inline emoji in posts also honour the `:name:tN:` skin-tone suffix now. The alias list is gone, and a test pins the default reaction set so its removal cannot regress them.

### Changed
- The `emojis` package is now a dev dependency: only `packages/discourse_ui/tool/gen_discourse_emoji_data.dart` still uses it, so the app no longer ships it.

## [1.0.10] - 2026-09-09

### Fixed
- **Emoji shortcodes in topic titles and excerpts** now resolve against Discourse's own name table instead of a generic emoji library, whose short names covered fewer than half of Discourse's. A title ending in `:studio_microphone:` showed the raw shortcode in the topic list and the posts app bar; it now shows 🎙️. Aliases (`:slight_smile:`, `:+1:`) and the `:name:tN:` skin-tone suffix resolve too, and names Discourse itself would not render stay untouched. The table is generated from the `discourse-emojis` gem by `packages/discourse_ui/tool/gen_discourse_emoji_data.dart`.

## [1.0.9] - 2026-09-09

### Changed
- **Lighter topic rows and posts** — the UI half of the scroll audit (`docs/perf-audit-2026-09.md`), each cut removing per-row layout, paint or network work:
  - A post shows **one** preview card: a video if it has one, else a tweet, else the first external link. Web oneboxes one link too; the app allowed up to thirty cards, each a network fetch the moment the post appeared.
  - A topic row shows at most **two tag chips** plus "+N".
  - The "alice replied 3h ago" line is text only; the mini avatar beside it is gone (it was the seventh image per row).
  - The metadata row is replies, likes, votes where a forum has them, views, and **one** status badge chosen by what matters most (announcement, solved, locked, hot, pinned, poll, watching), right-aligned — instead of two wrapping rows of up to nine items.

## [1.0.8] - 2026-09-09

### Changed
- **Scroll performance, phases 2 and 3** (`docs/perf-audit-2026-09.md`):
  - The Home feed is virtualized. Each topic row is its own sliver child of a `CustomScrollView`, so only rows near the viewport are built and laid out. Before, the whole loaded feed was one `Column` inside a `ListView`, rebuilt and re-laid-out in full on every load-more and filter change.
  - The five filter lists are kept mounted for their state inside `Offstage` instead of at `Positioned(-10000)` under `Opacity(0)`, and Latest and Unread no longer build a complete second copy of the feed off-screen every frame.
  - Category and tag chips are plain decorated boxes; the antialiased `Material` clip was a saveLayer per chip per row.
  - Only the highlighted post is wrapped in an `AnimatedContainer`; every other post is a `ColoredBox`.
  - One `AvatarActions`, `ImageActions` and `PostActionsHandler` per thread instead of three new objects per post per build.
  - Avatar colour schemes and gradients are memoized per username.
  - Thread pagination triggers eight items from either end instead of three, so a fast fling no longer reaches the end of the loaded window before the next page arrives.
  - Loading skeletons in the topic list and thread are static blocks; the shimmer was a ShaderMask saveLayer every frame during first load.
  - flutter_html style tables are built once per theme and shared, instead of ~45 objects per post per build.
  - `CookedContent.parse` is memoized by cooked HTML (bounded LRU), so a post scrolled back into view is not re-parsed, and each page of a thread is parsed ahead of time on a worker isolate as it arrives.
  - No more `VisibilityDetector` per post (each carried a timer and layout tracking); the visible-post index comes from the list's own position stream. Post rows are keyed by post id at the outermost widget so a prepended page no longer rebuilds them.
  - Custom-emoji reaction images decode at display size.
  - The forum header tints its pattern through the image paint instead of a `ColorFiltered` layer, and no longer wraps itself in `IntrinsicHeight`; same look, one layout pass and no full-header saveLayer.


  Benchmark (Pixel 10a, profile build, meta.discourse.org, eight flings per screen), baseline → phase 1 → this release: topic list build p50 6.9 → 3.3 → 0.8 ms, p90 14.9 → 11.3 → 2.1 ms, frames over 16.7 ms 31 % → 7 % → 3 %, frames over 33 ms 16 → 8 → 1; thread build p50 0.8 → 0.8 → 0.7 ms, p99 30 → 13 → 18 ms (a different, preview-heavy topic was at the top of Latest this run), worst 83 → 51 → 47 ms.

## [1.0.7] - 2026-09-09

### Changed
- **Scroll performance, phase 1** (see `docs/perf-audit-2026-09.md` for the audit and baseline):
  - A post's cooked HTML is parsed once per post instance instead of on every build of the row. `PostListItem` keeps the extracted content and drops it only when the post or its translation changes.
  - Scrolling a thread no longer rebuilds the whole list. The "n / total" position in the bottom bar is fed by a `ValueNotifier` instead of a `setState` fired by every post's `VisibilityDetector`.
  - Avatars and other cached images decode at display size (`ResizeImage` on the file path — a 240 px avatar was decoded in full for a 40 px slot), start loading in `initState` rather than one frame later, and fetch once instead of twice per widget. SVG avatars, which Discourse allows and serves under a `.png` URL, are sniffed and rendered with `flutter_svg` instead of failing.
  - The avatar placeholder is a flat tinted disc; the shimmer ran an animation controller per avatar until the image landed.
  - The attachment-size fold in `RichTextContent` compiles its regex once and skips posts with no attachment link.
- **Topic rows no longer show the participant avatar cluster.** Five extra network images per row for a detail the author avatar and "alice replied" line already cover. The model still carries `participantIconUrls` for anyone who wants it back.

  Benchmark (Pixel 10a, profile build, meta.discourse.org, eight flings per screen), before → after: topic list build p50 6.9 → 3.3 ms, p90 14.9 → 11.3 ms, frames over 16.7 ms 31 % → 7 %; thread build p99 30 → 13 ms, worst frame 83 → 51 ms, frames over 33 ms 11 → 3; avatar decode failures 10 → 0 and file-to-network fallbacks 88 → 0.

## [1.0.6] - 2026-09-08

### Changed
- **Forum logos are cached on disk.** `BrandImage` now loads raster logos through `CachedNetworkImage` and SVG logos as files through the same `flutter_cache_manager` store (thirty days), instead of re-downloading on every build. Matters most to multi-forum hosts that paint hundreds of directory icons; the single-forum app gains the header and drawer wordmark. Web keeps the plain network SVG loader.

## [1.0.5] - 2026-09-08

### Changed
- **Sign in moved into the drawer header**, next to the "Not signed in" line, as a button — it was the last row of the drawer, below Privacy Policy. Web keeps its Log In in the header for the same reason. Sign out stays at the bottom. The header's own strings are localized and its wordmark renders through `BrandImage` (SVG, dark-logo rule).

## [1.0.4] - 2026-09-08

### Changed
- The drawer is localized (its section labels and rows were the last raw strings in the UI), and the two "Switch forum" rows a hosted build could show are one row at the top, driven by `DiscourseHost.switchForum` with the route-below-the-shell heuristic as fallback.

## [1.0.3] - 2026-09-08

### Added
- **Host hooks** (`DiscourseHost`) for multi-forum apps that mount the module per forum: `switchForum` puts a "Switch forum" entry at the top of the drawer that returns to the host's forum list; `resolveForum` lets the host say which of its forums a push notification belongs to, instead of the module rebuilding the single configured forum. Both are null by default; the single-forum template is unchanged.

## [1.0.2] - 2026-09-08

### Fixed
- Header colours in dark mode: a forum that ships no dark-mode logo keeps its light header colours in dark mode, so its transparent wordmark always sits on the background it was drawn for. Meta's black wordmark no longer lands on a near-black strip.

## [1.0.1] - 2026-09-08

### Added
- **The forum's own header.** The wordmark renders wide and contained at header height instead of squeezed into a 60 px square (which cropped "Discourse" to "iscourse"), on the forum's own header colour with its header text colour, the way the browser shows it. Both come from payloads already fetched: the colour scheme in `/site.json`, the logos in `/site/settings.json`. A forum on the stock scheme keeps the pattern background. SVG logos now render (`flutter_svg`); a good share of forums use them.

### Fixed
- `discourse_ui` ships its own artwork (`packages/discourse_ui/assets/…`) instead of expecting the host app to carry `assets/forum_header_bg.png` and the icon by bare name — a host that did not had a red error dialog on the forum home.
- `discourse_ui` caps the `html` package below 0.15.7, which dropped `Element.matches` while `flutter_html` 3.0.0 still calls it. A fresh consumer resolving 0.15.7 failed to compile; this repo's lock had 0.15.6 and never noticed.

## [1.0.0] - 2026-09-08

The first release that calls itself finished. Since 0.8.0 the same day:
every UI string is localized in eleven languages, deprecated API uses
are at zero, CI checks a fresh clone on Linux and Windows on every push,
the User API Key survives app updates (reproduced and fixed on a Pixel),
the iOS floor is 15.0, and the last XenForo-era code that could not work
on Discourse is gone. Push notifications ship optional and off by
default; the relay lives outside this repo.

Not verified for this release: an Xcode build at the new 15.0 floor.
`pod install` resolves; the Mac that cut the release lacks the iOS
platform component. Android, macOS, Windows and Linux were exercised.

### Added
- **CI** (`be591c7`, `0bd34f6`, `d562317`): GitHub Actions runs the README's own Quick start on every push — pub get, `buildlib.sh`, a check that the SDK's generated code is committed, analyze with errors and warnings fatal, every package's tests, a debug APK from the `.example` Firebase placeholder — and `buildlib.bat` on a Windows runner, the first time that script has ever been executed.
- **Handshake test** (`41cc812`): the User API Key flow end to end with the test playing Discourse — request URL, stable client id, RSA-OAEP and PKCS1 payloads, nonce rejection, superseded handshake, push recorded only when this app asked for it.
- **Persistence test** (`f9e33af`): the key survives a process restart, never lands in plain prefs, migrates from older builds, a lost key starts the app signed out rather than crashed, sign-out clears everything.
- **Widget tests** (`0999d76`) for the oversized-image consent sheet and the attachment card.
- **Fork checklist and naming section** in the README (`ed76be2`): every identity placeholder with its file, and a statement that the project is not affiliated with Discourse's makers.
- `docs/push.md` (`4882732`): push ships optional and off by default; what is built, what is not, what a forum admin must enable.
- `v0.8.0` tag and this file's first dated section (`fa5c25f`).

### Changed
- **Every UI string goes through `AppLocalizations`** (`541aed4`, `5c2d938`, `d8cb640`): 366 hard-coded `Text('…')` literals replaced, 262 new English keys, all translated in the ten other locales (`9faf755`, `466ee46`) along with 12 older keys that had been English-only. What remains unlocalized is composed data — "@handle", "#12", "3 / 40", "TL2".
- **Zero deprecated API uses, down from 93** (`6e666ff`): `surfaceVariant`, Radio `groupValue`/`onChanged` → `RadioGroup`, share_plus `SharePlus.instance`, `activeThumbColor`, `onPopInvokedWithResult`, passkeys availability, and the Cloudflare interceptor's webview cache clearing (canonical SDK `9ce8ba6d`). The declared Flutter floor is now 3.32.
- **iOS deployment target 18.4 → 15.0** (`591babf`). The old pin was a workaround for a simulator-only crash (libswiftWebKit, WebKit bug 293831), applied to device builds too; it now applies to the simulator SDK alone. `pod install` verified; an Xcode build is not, this Mac lacks the iOS platform component.
- **Android app label "Discourse" → "Forum App"**, matching iOS and macOS (`f9e33af`).
- Nine analyzer warnings cleared so analyze can gate CI (`5f4514d`).
- Audit doc: the "Not covered" list now records what happened to each item — composer and attachments closed on-device, PM attachments share that path, drafts reviewed against `DraftsController`, chat uploads not implemented (`4882732`).

### Removed
- **XenForo-era code that could not work on Discourse**: in-app registration (`register_page`, `additional_information_page`, `custom_field_widget`, `basic_registration_fields`, `location_service`) — the account proxy always answered "sign up on the web", and the two entry points now open the forum's `/signup`; the password-protected-forum flow (`forum_password_dialog`, `ForumActions.enterProtectedForum`) — Discourse categories use group permissions, so a read-restricted category now opens like any other and keeps its lock badge; the XenForo messages page and its app bars; the pre-consent image optimizer dialog; unreferenced passkey validation helpers and error widgets. 180 localization keys that nothing referenced any more went with them, in all eleven ARBs.
- `packages/forumcopilot_sdk/test/` — XenForo/Tapatalk interface suites with no `main()`, driven from those platforms' own packages. The vendored SDK now carries `lib/` and `pubspec.yaml` only; the rsync rule in `CLAUDE.md` excludes `test/`.

### Fixed
- **Topic page title showed emoji shortcodes literally** (`f0fb34b`) — the list converted `:wave:` since `55cf8d9`, the topic's own app bar did not. Seen on the Pixel.
- **Signed out after an update or restore** (`f9e33af`). Both secure-storage call sites used library defaults — on Android the legacy scheme the library itself warns against. One shared instance now uses EncryptedSharedPreferences with `resetOnError`; the manifest excludes the secure-storage file from Auto Backup and device transfer (a restored blob is unreadable without the Keystore key); a read that throws starts the app signed out instead of crashing, and logs the lost-key signature. Not reproduced on a device this session; the fix follows the library's own guidance.
- **`flutter gen-l10n` aborted from the repo root** (`d562317`) — `l10n.yaml` lives in `discourse_ui`. Both bootstrap scripts run it there; this was CI's first red run.
- `forumcopilot_sdk`'s `test/` directory holds suites with no `main()`; CI no longer tries to run them (`0bd34f6`).


## [0.8.0] - 2026-09-08

### Added
- **Share / copy link on every post** (`ac8efb5`). Web puts a share control on each post; the app had no way to link to a specific reply.
- **Notifications filter to Unread** (`635442d`) via `/notifications.json?filter=unread`, on the Discourse proxy rather than the shared SDK interface.
- **Category and tags on the topic page** (`5c0cd70`), under the title where web puts them.
- **Terms of Service and Privacy Policy links** in the drawer (`aa5fa49`), from `tos_url` / `privacy_policy_url` in `/site.json` — parsed for a long time, never read.
- **The forum's own logo** in the header and the drawer wordmark (`062f15a`), from `/site/settings.json`.
- **"Accepted by" on the profile's Solved tab** (`3aaf012`) — the actor was dropped by the converter; needed `FCUserReply.actorName` in the canonical SDK.
- **Attachments named the way web names them** (`9b94d16`): `![name|WxH](…)` and `[name|attachment](…) (size)` instead of the literal words "image" and "file". Non-image attachments render as download cards with Share and Download.
- **Resize-to-fit prompt for oversized images** (`a1d4b37`), with a remembered "don't ask again". Shrinks only as far as the limit requires and preserves the format.
- **Bookmarks and Drafts in the drawer's Account section** (`6b348c7`).
- `CONTRIBUTING.md` and `CODE_OF_CONDUCT.md`, and a README link to both.
- `CookedContent` (`packages/discourse_ui/lib/utils/cooked_content.dart`) — parses a post's cooked HTML and returns the renderable HTML plus the YouTube, Twitter/X, link and image URLs it embeds. Unit-tested against the markup shapes taken from the Discourse source (onebox layout, `discourse-lazy-videos` containers, lightbox wrappers).
- `MediaUrlUtils` — the YouTube / Twitter / video / email URL predicates, extracted from `BBCodeProcessor` where they had nothing to do with BBCode.
- `DiscourseMarkup` — the single source of truth for what the formatting toolbar emits, shared by both composers and unit-tested. Documents which actions map to Markdown, which legitimately map to BBCode (`[u]`, `[quote]`, `[spoiler]` are Discourse's native spelling), and which have no Discourse equivalent at all.

### Changed
- **Profile page rebuilt** (`f7f99b2`, `2493d0f`, `29d6e7d`): trust level moves into the info card, badges become a wrapping section above Stats, every block shares one section chrome, the Activity tabs pin while scrolling, and the four feeds share one row that attributes a post only when its author is someone else.
- **One filter-chip style app-wide** (`1b03741`, `8d1447e`); the category list's colour stripe is gone now that the tile carries the real colour.
- **Attachment upload consolidated** (`a1d4b37`): six composer pages carried verbatim copies of the same ~150-line handler; they now share `AttachmentUploadService`. −975 lines.
- **Most Liked By / Most Liked / Most Replied To** on the profile are swipeable strips with names and counts, out of the stats card (`2493d0f`).
- `BBCodeCallbacks` renamed to `PostContentCallbacks` (file `custom_bb_stylesheet.dart` → `post_content_callbacks.dart`). It is the tap-callback bundle for `RichTextContent` and has not driven a BBCode renderer for some time.
- Composer methods renamed to match what they actually do: `_insertBBCode` → `_insertMarkup`, `_insertAttachmentBBCode` → `_insertAttachmentRef`.

### Fixed
- **A fresh clone did not build.** Root `flutter pub get` writes no `package_config` for the three nested packages, so `flutter analyze` reported 289 unresolved-import errors and the Android build failed on the gitignored `google-services.json`. `buildlib.sh` / `buildlib.bat` now run `dart pub get` inside each package first, and the README's Quick start tells you to copy the three committed `.example` Firebase files, which are enough to compile — verified from pristine clones on Android and macOS. Three docs also claimed `discourse_core` has generated code; it has none.
- **A fresh clone could not `pod install` for iOS.** The committed `ios/Podfile.lock` pinned Firebase 12.4.0 and a `firebase_crashlytics` that nothing in `pubspec` depends on any more, while `firebase_core` 4.7.0 demands Firebase 12.12.0 — CocoaPods' resolver could not satisfy both and failed with "specs repository is too out-of-date", which is misleading: the CDN was fine, the lock was stale. Regenerated from a pristine clone: 12.12.0, no Crashlytics. macOS's lock was already current. Verified: with the old lock a fresh clone fails in `pod install`; with the new one it passes through CocoaPods (the Xcode step is untested here — this Mac lacks the iOS platform component).
- **Search results had no topic title** (`b4daa21`). `/search.json` side-loads topics separately and the converter hardcoded `title: ''`. The field also now takes focus on open.
- **Category badge missing on nearly every topic row** (`044a860`). Names came from `/categories.json`, which meta.discourse.org truncates to 12 of 45; `/site.json` has all of them and was already fetched.
- **Messages never showed unread** (`3763459`). The flag read `unread`, which the server hardcodes to 0 as a back-compat stub; a never-opened PM is recognised by a null `last_read_post_number`.
- **Emoji shortcodes rendered literally in list titles and excerpts** (`55cf8d9`) — `:warning:` in the list, ⚠️ once opened.
- **Category page used a hashed colour instead of the category's own**, and repeated the category badge on every row inside it (`f1c0ef3`, `d4a8f53`).
- **Restricted groups showed "0 members"** (`bf3266c`). Discourse withholds `user_count` when `can_see_members` is false; `?? 0` turned that into a claim. Needed `FCGroup.canSeeMembers`.
- **An avatar that would not decode raised a modal error** (`21a6ef0`). Four `CircleAvatar(backgroundImage:)` sites had no failure path; one shared widget now falls back.
- **Images were silently transcoded to JPEG** and downscaled before the size check, so a 20 MB PNG slipped under a 10 MB limit that could never fire (`a1d4b37`). The remaining PNG→JPEG conversion you may still see is Discourse's own server-side policy (`png_to_jpg_quality`), identical for web uploads.
- **`post_number` rendered as a reply count** in the profile activity feed (`29d6e7d`); it reads `#45` now.
- **Bookmarks' empty state** was a bare line of grey text (`0fe2cd0`).
- **Post link previews no longer treat images as links.** Link, video and tweet cards below a post are now extracted from Discourse's cooked HTML as a DOM, following the same rules the server itself uses in `PrettyText.extract_links` (`aside.onebox[data-onebox-src]`, exclusions for quotes, oneboxes, mentions, hashtags, attachments and in-page anchors). The previous implementation ran cooked HTML through the inherited XenForo `BBCodeProcessor`, whose BBCode tag regexes matched nothing and whose `findPlainUrls` fallback swept the raw markup with a bare `https?://\S+` pattern — so a single onebox'd link produced up to three preview cards (its href, its thumbnail and its favicon), and image uploads showed up as "links in this post".
- **Tapping an inline image opens that image.** The full-screen gallery collected images by scanning post content for `[IMG]` BBCode tags, which never appear in cooked HTML. Images embedded in a post body were therefore absent from the gallery, so a tap opened the wrong image — or reported "No images found to display" on a post with no attachments. It now reads `<img>` elements, preferring the full-size original from the wrapping `a.lightbox` href over the resized `src`, and skips emoji, avatars, favicons and onebox thumbnails.
- **Server-rendered oneboxes are no longer duplicated.** When Discourse has already onebox'd a link, that preview stays in the rendered HTML and the app adds no card of its own. YouTube and Twitter/X embeds go the other way: they become native cards and their nodes are stripped from the HTML, because `flutter_html` cannot render an `<iframe>` and would leave a blank gap.
- **The new-conversation (new PM) composer was still emitting XenForo BBCode.** Phase 5.19 migrated the main composer to Markdown but missed this one, which passed its toolbar action straight through as `[TAG]…[/TAG]`. Discourse parses only a subset of BBCode, so `[LIST]`, `[*]`, `[VIDEO]`, `[LEFT]` and `[CENTER]` were being posted into private messages as literal bracketed text. Both composers now share one mapping (`DiscourseMarkup`), and the Align Left / Center / Right toolbar items — which Discourse has no markup for at all — are removed rather than left as buttons that corrupt the message.
- 33 of 34 analyzer warnings — dead null-aware operators, redundant null comparisons and unnecessary null assertions left behind when the SDK tightened its nullability, plus unused imports. The one remaining warning is in the vendored canonical `forumcopilot_sdk` copy, which is kept byte-identical to its upstream and must be fixed there first.

### Removed
- `deploy_plugin.sh` / `deploy_plugin.bat`. Both were inherited from the XenForo sibling app and rsync a plugin to a XenForo server; this app has no server-side plugin and never will in v1. Stale references in `CLAUDE.md` are gone with them, along with a note about composer helpers named `_insertBBCode` that had already been renamed.
- Eleven fully-merged feature branches, local and remote. Every one had zero commits beyond `main`.
- `bbcode_processor.dart` (1,183 lines) and `attachment_utils.dart`. This retires the last of the XenForo content pipeline; Discourse posts are cooked HTML end to end.

## 2026-08-05

### Added
- Discourse-native feature wave: bookmark reminders, tag watching, polls, post revisions, whisper and wiki posts, the reviewables queue, invites, do-not-disturb, topic summary, chat DMs and chat reactions.
- Client-side push (Phase 3): with `AppForumConfig.pushApiBaseUrl` set, the User API Key handshake requests the `push` scope and registers a static `push_url`; device identity travels as the handshake `client_id`. The relay backend that forwards to FCM/APNs is still pending — with the URL unset, behavior is byte-identical to before.
- Clickable badges and a trust-level explainer on profiles; avatar upload; Discourse upload limits honored in the composer; cache-first session restore.

### Changed
- Reactions and Q&A votes are first-class `FCPost` fields instead of `Expando` sidecars.
- Post likes and emoji reactions collapsed into one canonical affordance (tap to like, long-press for the picker) instead of two overlapping controls.
- Unified profile experience across "my profile" and "other user's profile".

### Fixed
- Purged fabricated data (−7,700 lines): search results, category posting permissions, group visibility, invite classification and account settings now report what the server actually returned, including reporting failure rather than synthesising a plausible-looking zero.
- Real server signals now populate fields the audit had documented as unrepresentable — attachment upload URLs, group and member totals, bookmark and search pagination.
- Defects found in a full review pass and in live on-device testing against a local Discourse install.

## 2026-08-04

### Changed
- The UI layer was extracted into `packages/discourse_ui`; `lib/` is now a thin runner. This lets the whole app be hosted inside a multi-forum shell.
- `packages/forumcopilot_sdk` is now a byte-identical vendored copy of the canonical SDK; `discourse_core` is repointed at it. Interface changes go to the canonical copy first.
- GetX singletons are namespaced per site so state resets correctly when a different forum is entered.

### Added
- A "Switch forum" drawer entry that appears only when the app is hosted in a multi-forum shell.

---

## Earlier history

This app's build history before 2026-08-04 was tracked as a phase log rather than as releases; it is summarised in the collapsed table at the bottom of [README.md](README.md).

> **Note on versions 0.6.x and 0.7.0.** Entries under those headings were carried over verbatim from the [xenforoapp](https://github.com/forumcopilot/xenforoapp) template when this repository was forked from it, and describe **that** project's XenForo add-on — they reference `forumcopilot.php`, the `xf_fc_device_token` table and XenForo-side direct push dispatch, none of which exist here. They have been removed rather than left in place as inaccurate history. The xenforoapp repository has the accurate versions.

[Unreleased]: https://github.com/forumcopilot/discourse-app/compare/main...HEAD
