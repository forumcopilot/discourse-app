# Changelog

All notable changes to this project are documented in this file.

The format is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Releases below 1.0 should not be assumed backward-compatible across minor bumps.

## [Unreleased]

### Fixed
- **Back returns to the screen you were on.**
  - **On Android, Back on the Categories, Chat, Notifications or Profile tab returns to the forum's first tab.** Back again then leaves the forum. It used to leave the forum, or close the single-forum app, from whichever tab was showing. An open drawer still closes first. iOS is unchanged: its edge swipe leaves the forum from any tab, as tab bars work there.
  - **A push notification for a forum you have left opens the forum, then the topic.** In a multi-forum host, the forum's controller outlives the forum, so the app took it for still open. It opened the topic straight over the host's list, in default colours, and Back skipped the forum. The host now opens it, as it does from its list (`DiscourseHost.openForum`).
  - **A forum that failed to start pops only its own page.** Every rebuild scheduled another pop, which could close the page under it too.

## [1.0.36] - 2026-09-27

### Added
- **The message lists Discourse has:**
  - The chip row reads Inbox, Unread, New, Sent and Archive, as the topic filters on Home do. Group inboxes follow when you are in a group with messages. There were only Inbox and Archive.
  - A search button at the end of the row opens search with `in:messages` filled in; Discourse needs a search term alongside it. Search's filters also offer "My messages" (`FCSearchPersonal.messages` in the canonical SDK).
  - Each list stays loaded between switches, and reloads when you come back if a message was read, filed or left meanwhile.
- **Remove people and groups from a message:** a remove button beside each in the participants list, when Discourse allows it (`can_remove_allowed_users`), with Discourse's own confirmation. You leave through Leave, not this button.
- **Delete a message** from its menu, when Discourse allows it: staff, or its author while it is under a day old with one post.
- **New messages keep a draft** as you write, as topics and replies do. It is stored the way Discourse's web composer stores one: its own `new_private_message_<time>` key, with the recipients. Drafts started on the web resume in the app, and the other way round. A draft is also saved when you only change the recipients.
  - The Drafts list opens a new-message draft in New Message, with its recipients, title and text. It shows it with a mail icon under its title, or "New Message" if it has none. It used to show "(untitled new topic)" and tapping it did nothing.
  - `DiscourseDraftController` takes an `extraDataBuilder` for fields that change while writing, and a `touch()` to save them. `initialize()` returns the restored draft.
  - New Message no longer loads the inbox to find out whether uploads are allowed. It reads the same permission as the other composers.
- **Polls in private messages.** A poll in a message is drawn where its author put it, with results, voting, changing or removing a vote and the voters list, as in topics. Messages showed nothing in its place: the SDK's message model had no polls (`FCConversationMessage.polls`, added in the canonical SDK), and `DiscoursePostProxy.pollsFromPostJson` now parses a message's polls the way it parses a post's, so a vote finds its message.

### Changed
- **Private messages open in the topic page**, from every entry point: the inbox, notifications, push, links, bookmarks and New Message. A Discourse message is a topic, and the app had a separate copy of the reading and composing screens for them, which had fallen behind. The same message opened in one or the other depending on how you got there. Messages now get everything a topic post has:
  - reactions and who reacted, bookmarks with reminders, and reply to a specific message
  - delete, edit history, wiki, "in reply to" and "N replies"
  - display names, titles and flair; hidden and moderator posts shown as on the web; link click counts
  - small actions such as "invited …" or "left", and posts from another point in the message
  - opening at your first unread message (it always opened at the end), loading earlier messages as you scroll, and time-gap dividers
  - drafts in replies, and the same composer as topics, which returns you to your new message
  - "Suggested Messages" at the end
  - What only messages have moves with them: the participants under the title (tap for the list and Invite), and Archive or Move to Inbox, Mark as unread, Edit title, Close or Open and Leave in the menu. The inbox refreshes afterwards, and drops a message you archived or left. There is no "You are subscribed" banner on messages: every message is watched.
  - The participants sheet uses the standard sheet title under the drag handle, with Invite beside it, and list rows.
  - Moving a message between Inbox and Archive shows it in the other list when you switch to it. Both lists stay loaded between switches, so the other one kept showing where the message used to be until you pulled to refresh.
  - `ConversationPage`, `ConversationItem`, `ConversationHeaderWidget`, `ConversationAppBar`, `ReplyConversationPage` and `EditConversationMessagePage` are removed (about 4,000 lines); `DiscourseMessageDetails` is now filled by the topic loaders too (`fromTopicView`, `isMessage`, participants and the viewer's rights), and uploads in a message's reply or edit are sent as the message's (`for_private_message`).
- **New Message is the shared composer** (`MessageComposePage`) with the recipients above the title, instead of a separate copy that had drifted from it. It gains what the other composers have: photos prepared as the forum's own composer would (scaled and recompressed when the forum asks for it, and a question before shrinking one over the size limit; the copy uploaded them as picked), the same attachment rows and toolbar, and a readable reason when a send fails. Once sent it opens the new message, as before and as New Topic does, through `NewConversationPage.open`; the message list under it refreshes. `MessageComposePage` takes a `contentLabel`, and its own error message no longer shows raw "Exception: …" text.
- **Uploads go into the text, where you are writing, as on the web.**
  - A picked file appears as Discourse's placeholder, `[Uploading: name…]()`, on its own line at the cursor. When the upload lands, the placeholder becomes the Markdown Discourse renders for that kind of file.
  - A photo can go between paragraphs, and a draft keeps its uploads.
  - Uploads used to sit in a list under the text and were added to the end on send. Only images could be placed, by tapping a row with nothing saying so, and removing a row left its Markdown in the post.
- **A strip of tiles above the toolbar** shows the uploads: a thumbnail for a photo, the kind of file otherwise, a spinner while uploading, and a remove badge with a 48dp target.
  - Removing a tile takes its Markdown out of the text. Deleting the Markdown by hand drops the tile, and the upload is not added back on send.
  - The strip replaces a titled list that flashed a spinner at every change. The chat composer uses the same tiles; its remove button was 28dp.
- **Photos and videos from the gallery:** the photo button now offers videos too. Videos used to be reachable only through the paperclip, which on iOS opens Files rather than Photos.
- **Videos and audio play in the post,** posted as `![name|video]` / `![name|audio]` as the web writes them; they were posted as file links. AVIF, JXL, HEIF and ICO count as images, as on the web.
- **Three or more photos picked together go in a `[grid]`,** as the web composer does it.
- **Several files picked at once appear together**, then upload one by one.
- **A failed upload shows one message, not two.** The page already said why, and a generic "Failed to upload" followed it.
- **Filenames with `[`, `]`, `|` and similar characters** are escaped in the Markdown so they don't break the link.
- **Attachments in posts and chat:**
  - Tapping the second or third photo in a post opens the viewer on that photo; it opened on the first. The viewer's order follows the post.
  - Files open signed in. Tapping one downloads it with a progress ring (tap to cancel), then offers it to the system's share and open sheet. It used to open in the browser, which is signed out, so a file in a private message, or on a forum that keeps files from guests, was a 404. Share still shares the link, and the Download tooltip is translated.
  - Secure uploads show and play. The app sends your key with a request only to the forum's own address and only for its upload paths, never to an image host, a CDN or the S3 address a secure upload redirects to. Redirects are followed one hop at a time, so the key cannot travel with one (`ForumMediaAuth`, `ForumMedia`).
  - Chat uploads look and work like post uploads: several photos in a grid without filename captions, and files, videos and audio in the post's cards. Chat files could not be opened at all, and chat videos did not play.
  - Post images have 8dp corners like grids; a small inline icon keeps square ones.
  - An upload the forum cannot find shows the broken-picture box, not an invisible gap.
  - A video's viewer and screen-reader label say "Video" rather than the file's hash name.

### Fixed
- **"1 vote", not "1 votes"**, under a poll, in every language with plural forms.
- **Pictures on a forum served over plain http** (a local or intranet forum) showed nothing. Discourse writes its uploads as `//host/uploads/…`, and the app always read that as https. It now uses the forum's own scheme, as a browser does.
- **A remote picture the forum could not download** shows the broken-picture box. Discourse replaces it with `span.broken-image` holding an SVG sprite icon, which the app could not draw, so the post showed nothing there.

## [1.0.35] - 2026-09-26

### Changed
- **The topic page around the posts follows the same spec:**
  - **The first post's title** is `titleLarge` (22sp), the size the app bar gives it, instead of 16sp w700.
  - **The reaction cluster** (the like control on any post with reactions) is a 48dp target like the Reply, Like and Bookmark buttons beside it, with 18dp glyphs and a 14sp count; it was ~26dp high with 16dp glyphs and a bold 12sp count.
  - **"N replies" and "in reply to …"** take a 48dp tap (they were ~24–26dp lines of 12sp text), and "N replies" reads like a text button.
  - **Less space between a post's text and its actions**: the body no longer adds 24dp of its own on top of the actions row's 12 (about 60dp of gap on text posts).
  - **One 1dp rule between posts** (was 2dp at 30% opacity).
  - **Banners** (closed, pinned, deleted, subscribed, the message page's closed banner and the account-state banner) are 56dp for one line with full 48dp close buttons; the close buttons were squeezed to ~20dp.
  - **Vote arrows** are full 48dp buttons (were ~36×40); the author's name gives way instead of overflowing next to a long full name and badges; the edited pencil is 16dp with a wider tap.
  - **The solved-answer card** has 12dp corners like other cards and shows four whole lines of the answer (a fifth was cut in half).
  - **The image viewer** titles itself "2 / 5" when a post has several images (it showed the image's URL) and uses standard icon sizes.
- **Composers and forms follow one spec** (Reply, New Topic, Edit post, New Message, Edit message and conversation, chat, Edit profile):
  - **Submit is a labelled button** ("Create Topic", "Reply", "Send", "Save") at the end of the app bar, as Material 3's full-screen forms have it; Edit profile and Change email use the same button. It was an unlabelled icon in the same colour as Back (and a bold text button on those two). `MessageComposePage` takes a `submitLabel`; the new `createTopic` string uses Discourse's own translation in each of the app's languages.
  - **Fields are the theme's outlined fields with the label in the field**, 56dp for one line and the body at least ten lines. The composer drew its own filled, borderless 12dp boxes under separate labels; the tag field was a 200dp-wide dense box; Edit profile had 14sp w600 labels above its fields.
  - **The category is a line with its badge**, not an outlined box that looked tappable and wasn't.
  - **Tags** are a full-width field with a "2/5" counter and the chosen tags as input chips under it; suggestions and tags take a 48dp tap (they were 32dp), and the count is 12sp (was 11).
  - **Chat** types in 16sp like every other composer (was 14); its send button is 48dp (was 44), an upload's remove button 28dp (was 18) and file names 12sp (were 11).
  - **Attachment rows** are the same in every composer (48dp thumbnail, 16sp name, a full-size remove button), and the whisper chip is a standard chip.
  - **New Message follows the same spec** (it is a separate copy of the composer that had drifted): recipients in an outlined field with standard chips, the message box ten lines (was five), translated toolbar tooltips. Folding it back into the shared composer is left for later: it changes how the new conversation opens afterwards.
- **Post bodies (posts, messages and chat) share one rhythm and one card:**
  - **One 12dp gap between blocks** of every kind (paragraphs, lists, headings, quotes, code, tables, previews, polls, images), and none after the last one. Lists were glued to the paragraph after them (4dp), blocks drawn by the app had 20dp above and 8 below, and every post and quote ended in 12dp of empty space.
  - **Headings h1–h6** are 24, 22, 20, 18, 16 and 16sp, medium weight, never smaller than the text around them (h5 and h6 were 13 and 11sp).
  - **Code** is one 14sp size for blocks and inline code (inline was larger than blocks, and chat code was 12sp); blocks have 12dp corners, inline code is a small rounded chip, and the copy button no longer shows text through it.
  - **One card for embedded things** (`EmbeddedCard`: 12dp corners, 12dp padding, a 1dp outline): link previews, embeds, tweets (one design instead of two), events, details, polls, audio and file attachments. There were seven corner radii and several paddings and fills. Images and grids have 8dp corners and an 8dp gap, and a failed image looks the same everywhere (`BrokenImagePlaceholder`).
  - **Quotes** have 12dp padding on every side (they were 8 above and ~20 below) and a medium-weight attribution line.
  - **Polls** sit at the post's margin (they were inset twice), options are 48dp rows that wrap instead of truncating, and Vote is a standard button. The details toggle is a 48dp row with a chevron.
  - **Chat text is 16sp** like posts and messages (it was 14); the sender's name is 14sp and the time 12sp (both were 11sp), and reaction chips are Material 3 chips with 48dp targets (were 22dp).
  - **Nothing readable below 12sp**: link click counts (were 11 and 10sp) and upload captions (10sp).
- **The remaining screens follow the same spec:**
  - **No bold text outside headings.** Titles, names and labels on the badge, group, profile, drawer, trust-level, search-filter and notification screens drop their w600/w700 for the type scale's own weights; a chosen option is medium weight, as elsewhere.
  - **Names are headings from the type scale**: the forum's name in its header is `titleLarge` (was a hand-set 20sp bold), a category's `headlineSmall` (a hand-set 24sp w600), a profile's username `headlineSmall` (was `titleLarge`, the size of the text around it) and a group's name `titleLarge` (was `titleMedium` w600).
  - **The message page's header is the topic page's**: the title on the left at `titleLarge`, then the participants with a 48dp tap to open the list. It was centred over a tinted pattern at 16sp w600.
  - **Settings** puts dividers between groups, not under every row, and its supporting text is 14sp (was 12). Notification settings show the current choice under the setting's name, as Android does; a long choice squeezed the name onto two or three lines. The explanation moves into the picker.
  - **The notification-level and trust-level sheets** mark the current level with the theme's selected row and a check, and their descriptions are 14sp (were 12).
  - **The report dialog** uses standard radio rows: the reason beside its radio at 16sp and the description under it at 14sp (the reason sat above the radio's centre at 14sp w500 and the description was 12sp).
  - **Turn on notifications** scrolls at large text sizes instead of overflowing, with the buttons kept at the bottom; its footnote is at full contrast and left-aligned.
  - **Badges on a profile** are 32dp chips with readable tier colours (gold and silver were faint on light backgrounds), and "+N more" is a full-size chip.
  - **The profile's side margin is 16dp** like every other screen (it was 24, as was the forum header's), and the avatar's camera button is a 48dp target (was 36).
  - **Small text is 12sp**: `StyleBuilders.smallTextStyle` forced 14 onto it, and the translated-post label, the profile's like counts, bookmark reminder hints and the drawer's footer were 11sp (the footer also faded).
  - **Menu icons are Material's: 24dp in `onSurfaceVariant`**, red only for destructive items. Menus mixed 20 and 24dp icons in primary, secondary, onSurface and onSurfaceVariant (the message menu's Copy link and Report were blue).
  - **The review queue's topic link** is a 48dp target (it was the text's line).

### Fixed
- **Suggested Topics no longer show "?" avatars** (from 1.0.34) when a forum sends suggested topics without a poster; they show a topic glyph in the avatar's place.
- **Multiple-choice polls show empty boxes until you pick.** Every option was drawn with a ticked box (`Icons.check_box_outlined` is Material's outlined *ticked* box), so a poll looked already answered.
- **An untitled poll no longer opens with a blank band.** Discourse polls usually have no title, and the card kept a line and a gap for one; the pinned poll bar says "Poll" for them instead of nothing.

## [1.0.34] - 2026-09-26

### Changed
- **Empty, error and signed-out screens share one design** (`EmptyStateView`): a 48dp icon, a `titleMedium` headline, a `bodyMedium` line under it, then Retry or the screen's actions, centred, and scrolling instead of overflowing at a large text size. About 25 screens had drawn their own, from an 80dp icon with a 24sp bold headline to one grey line of text, some with raw exception text and many with no way to try again. `EmptyStateWidget`, `ErrorStateWidget` and `ErrorOrChild` are removed.
  - **Every error offers Try again** where the screen can reload: Hot, New, Top, category and tag lists, Tags, review queue, edit history, search, user search, reactions, notification settings.
  - **Errors say what went wrong in plain words** ("Couldn't reach the forum…") through `describeError`, instead of "Error loading messages: Exception: …".
  - **Filters and headers stay above the state.** A failed category list keeps its header and Latest/Hot/New chips, a failed forum list keeps the forum header, and Top shows "No top topics in the week period" under its period chips, where another period can be picked (it showed nothing before).
  - **Signed out** (`NotSignedInView`, on Notifications, Messages, Chat and more) uses the same design with standard Sign in and Register buttons.
- **Every list uses one row: Material 3's list item.** A 40dp avatar or tile, the headline in `titleMedium` (16sp), supporting text in `bodyMedium` (14sp), a meta line in `bodySmall` (12sp) with 16dp icons, 12dp above and below, and a divider inset to the text. The same kind of row ran from 57dp to 213dp before, with its text anywhere from 11sp to 16sp.
  - **Topics lead with their title.** Avatar, title (two lines at most), category and tags, then who replied last and when with the reply and like counts. About 90–115dp instead of ~200, so about twice as many topics fit on a screen. The home, category, tag and search lists all use it; Suggested Topics uses the same sizes; the loading skeleton has the row's shape, so the list no longer jumps when topics arrive.
  - **Messages** read like an inbox: the subject is the headline, who wrote last and how many are in it underneath, the time and unread count at the end (was ~140dp, the sender's name first in the same size as the subject).
  - **Notifications** have a 40dp avatar (was 56) and no tinted background; **chat channels** have 16sp names and 14sp descriptions (were 14 and 12); **categories** have a 40dp tile and a plain meta line instead of count pills (were 92–140dp).
  - **Unread is marked one way everywhere** (new `UnreadBadge`): Material 3's badge at the end of the row, a count or a dot, and the headline in full weight while read rows step back. Notifications tinted the row and led with a dot, messages and topics drew their own pills, chat bolded and drew another.
  - **People and the other lists** follow the same row: the users directory, user search, group members (40dp avatars, were 36), groups, ignored users, Bookmarks, Drafts, profile activity and Top Topics/Replies, and Tags (whose bell is a full 48dp button). Profile details are standard two-line rows with 24dp icons. Dividers are the same everywhere; some lists had none, some faded ones, one had two.
  - **Category and tag chips** on topic rows are 12sp (were 11sp, the category in w600) and take a tap 32dp high (were ~20dp).
  - Search history rows start at the screen margin (they were inset twice), and Bookmarks' title no longer carries an icon.
- **Section headers are Material 3's list subheaders** (new `SectionHeader`): `titleSmall`, sentence case, in the primary colour (the drawer's in `onSurfaceVariant`). The drawer, Account & preferences, Notifications settings and badge tiers had 11sp ALL CAPS labels. Profile sections, Activity and Suggested Topics are `titleMedium` without the extra weight.

### Fixed
- **Notifications says it couldn't load instead of "No notifications yet"** when the forum can't be reached. The proxy reports a failure as a result rather than an exception, and the tab read it as an empty page.
- **Hot, New and Tags no longer show a failure as an empty list.** Each used one line of text for both.

## [1.0.33] - 2026-09-26

### Changed
- **One look per component, from the theme: Material 3's own.** App bars, dialogs, sheets, snackbars, buttons, text fields, menus and filter chips each came in several looks, because screens restyled them one by one. `AppTheme` now sets them once, mostly by leaving Material 3's defaults alone, and ~70 files lost their overrides (about 1,500 lines):
  - **App bars:** every title is `titleLarge` (22sp) aligned to the start, and every bar is flat until content scrolls under it. They were left-aligned 20sp with a permanent shadow on the tabs and lists, centred 22sp on Search, Chat, Reply, Bookmarks and every ABDA screen, and bold on some. Topic and category titles that don't fit one line drop to two lines of `titleMedium` (new `AdaptiveAppBarTitle`), measured at the reader's text size and against the width the title really has.
  - **Dialogs:** Material 3's 28dp corners, `headlineSmall` title and `bodyMedium` text, instead of five title styles (20sp bold, coloured, 22sp in three weights) and three confirm-button shapes.
  - **Sheets:** 28dp top corners and a drag handle on every sheet, with one heading style (new `SheetTitle`, `titleMedium`) directly under it. They had 12dp or 16dp corners, a handle on two of them, and headings at w500–w700 with 12–28dp above.
  - **Buttons** are Material 3's: 40dp, fully rounded, 14sp labels. The Reply button on topic and message pages, a member's Send Message and the Delete account button were 56dp raised pills with 16sp bold labels; dialog buttons had 8dp or 12dp corners.
  - **Text fields** are 56dp outlined fields with 4dp corners (were 48dp with 8dp). **Search fields** (topic search, user search, the Tags filter) are Material 3 search bars: a filled 56dp pill.
  - **Snackbars** float, in one shape, instead of four margin/shape recipes.
  - **Menus** use one label style (it was `titleMedium`, `bodyLarge`, `bodyMedium` or a raw colour, by screen); a destructive item keeps its red.
  - **Filter chips** (topic filters, Notifications' All/Unread, the users directory, profile activity, search) are Material 3 filter chips: 32dp with 8dp corners and a tick when selected, no longer a bolder label on the selected one. The row takes its height from the chips, so a larger text size no longer clips them, and the profile's pinned activity bar sizes itself the same way.
  - **Badges** (BANNED, DELETED) are 11sp `labelSmall`, Material's smallest size, instead of 10sp bold.
- `StyleBuilders.elevatedButtonStyle`, `textButtonStyle` and `extendedFilledButtonStyle` and the `paddingExtendedButton` / `radiusExtendedButton` tokens are removed. `DesignTokens.paddingInput` is 16dp all round (a 56dp field).

### Fixed
- **A post's Reply, Like, Bookmark and Accept buttons answer anywhere in their 48dp target.** Only the ~22dp icon took a tap: the shared `accessibleIconButton` wrapped it in a `GestureDetector` over a colourless `Container`, which hit-tests on the icon alone. It is now an `InkResponse`, which also shows the press. The message page's Quote and Like use the same helper and are fixed with it.
- **Notifications keeps its All | Unread filter when the list is empty or fails.** With Unread chosen and nothing unread, an early "All caught up!" branch returned without the filter bar, so there was no way back to All; the error state dropped it too. Both now sit under the bar, through `EmptyStateView`, with Retry on the error.
- **The topic and message pages' ↑ ↓ bar has its own space.** It floated over the list at 80% opacity, so posts showed through it and the last one could sit underneath. It is now a Material 3 bottom bar below the list, and the "2 / 7" position (the way into Jump to post) is a button with a full-size target instead of a small tappable label.
- **Another member's profile: Follow, Message and Chat are one size and wrap.** Message was a 56dp raised button beside 40dp outlined ones, in a row that could overflow a phone when all three showed.
- **Reply shows which topic it replies to.** The title was passed to the composer but never displayed.
- **Edit Post and Edit message keep their app bar while loading and on failure**, so there is always a way back, and a failed load offers Retry.
- **A quote that fails to load no longer locks the reply composer.** A barrier that could not be dismissed covered the whole screen; now a snackbar says the quote could not be loaded and the reply can be written without it.
- **A failed message reply's snackbar is readable in the light theme** (its text now uses `onErrorContainer`).
- **Messages no longer flash a ripple that does nothing when tapped.**
- **Tapping an uploaded image inserts it straight away.** The composer asked "Thumbnail or Full size?" and then ignored the answer; Discourse Markdown has no such distinction.
- **The bottom navigation shows its labels** (Home, Categories, Chat, Notifications, Profile). They were empty strings, so screen readers announced nothing, and three of the icons are speech bubbles.
- **A profile's Replies, Likes and Solved feeds say when they fail to load**, with Retry, instead of showing nothing.
- **The trust-level and notification-level sheets scroll** instead of overflowing at a larger text size or on a short phone.

## [1.0.32] - 2026-09-25

### Changed
- **A forum opened over a host's forum list no longer opens its drawer from the edge.** There the left edge means Back: iOS's swipe and Android's system gesture both take it, and on Android 13 and older a finger resting at the edge first opened the drawer instead. The drawer opens from ☰ only, so a swipe from the edge always goes back to the list.
- **In the single-forum app the edge swipe opens the drawer on Android with gesture navigation too.** Its forum home has nothing behind it, so the edge keeps opening the drawer, but the drawer's strip lay under Android's own Back strip, where every swipe went to Android (which closes the app from there). The strip now starts where the system's ends (`MediaQuery.systemGestureInsets`); a swipe from the very edge is still Android's Back. Elsewhere the inset is zero and nothing changes.

### Removed
- **The drawer's "Switch forum" row and `DiscourseHost.switchForum`.** A host's forum list is reached the way any previous page is, with Back or the edge swipe. A host that set the hook drops that line.

## [1.0.31] - 2026-09-24

### Fixed
- **Category logos and backgrounds show on forums Discourse hosts.** Uploads kept on S3 or a CDN come as protocol-relative URLs (`//cdck-file-uploads…/logo.png`), which were glued onto the forum's address as a path (`https://forum.asana.com//cdck…`, a 404), so the app drew an initial where the web shows the logo — on Asana, Product Announcements' rocket. One helper (`absoluteSiteUrl`) now resolves every upload and avatar URL the converters build. Covered by `packages/discourse_core/test/site_url_test.dart`; checked on the Pixel 4a in ABDA.

### Added
- **A category's dark-mode logo and its background image** (`uploaded_logo_dark`, `uploaded_background`, `uploaded_background_dark` from `/site.json`) are used on its page and in the category list when the forum has uploaded them.

### Changed
- **New Topic is a floating button** at the bottom right of a category page, in the forum's accent colour, instead of a button inside the category header that scrolled away with it (and a duplicate in the ⋮ menu). All floating buttons — New Message too — now take the forum's accent.

## [1.0.30] - 2026-09-24

### Added
- **The app wears the forum's own colours.** Its light and dark Discourse colour schemes (`/site.json`'s `default_light_color_scheme` / `default_dark_color_scheme`) become the app's theme: the forum's page and text colours, its accent on buttons, links and the selected filter, its `danger`, its `selected` behind chips and the bottom bar, and Material's greys mixed from its own page and text the way Discourse mixes `primary-low`. A colour that would not be legible is left to a scheme seeded from the forum's accent, and so is a mode the forum has no scheme for — a light-only forum still gets a dark mode in its accent, and a dark-only one (forum.obsidian.md, freeCodeCamp) a light one. Outside a forum (ABDA's forum list) the host keeps its own colours. Palettes are remembered on the device, so a forum opens in its colours at once; the forum's page wears them from its first frame. Checked on the Pixel 4a in ABDA: Let's Encrypt's own dark scheme, Asana's light scheme and the dark mode derived from it, Python's stock Light, and the forum list back in ABDA's colours. Covered by `packages/discourse_ui/test/forum_theme_test.dart`.
- **The like heart and "Solved" use the forum's `love` and `success` colours** (`ForumColors`, a theme extension also carrying `highlight`, `quaternary` and the header colours), instead of Material's error red and a fixed green.
- **Categories wear their own colours everywhere they are named** (`CategoryBadge`): a small mark in the category's colour — split with its parent's for a subcategory, or its emoji for an emoji-styled category — then its name, as Discourse badges it. On topic rows and the topic page (one shared `TopicTaxonomyChips` row now, where the two had drifted apart: tags open their topic list in both), search results (topics and posts), profile activity, the composer, the move-to-category picker, category hashtags inside posts, and the section headers of the category list. Tapping a badge opens the category. "Uncategorized" wears no badge, as on the web; a near-black category is lifted just enough to show on a dark page. Checked on the Pixel 4a against the local forum (square, emoji and subcategory badges). Covered by `packages/discourse_ui/test/category_badge_test.dart`.
- **A category page's header is a gradient in the category's colour**, the forum card's treatment (`ForumBrandStyle.forColor`), instead of the tinted pattern.
- `AppForumConfig.useForumColors` (default on) for a fork that wants its own brand over the forum's; `DiscourseSiteCapabilities.lightScheme` / `darkScheme` carry the full schemes.

### Fixed
- **A category opened from a link or a subscription has its colours.** A category reached from a link in a post opened with a blank header, and subscribed categories lost their colour after a reload (drawn in name-hashed colours beside the same categories in their real ones).
- **Search's post results no longer pass the topic's id as its category**, which the new badge would have shown as an unrelated category.

### Changed
- **The forum's identity card (the header on its home) and its drawer header are a gradient in the forum's colour** instead of our tinted pattern: its web header colour when that is branded (Docker's navy), otherwise its accent, deepened in dark mode so a bright accent does not light up a dark screen (`ForumBrandStyle`). Text takes the forum's header colour when it reads across the gradient, else white or black.
- **Its dark-mode card is no longer white.** A forum with no dark logo kept its light header colours in dark mode, so a black wordmark would not land on a dark strip — which left Asana's card white on a dark screen. The logo is now looked after instead (next item), and the card follows the mode.
- **A host can draw a forum that is not open in the same colours**: `ForumBrandStyle.forPalette(palette, brightness)` gives the card gradient and text colour from a `ForumPalette` without building a theme per forum (ABDA's forum list uses it for every card and icon tile).
- **A logo that would vanish on its card is helped** (`LogoTone`, `BrandImage.background`/`designedFor`). The forum's dark-mode logo is used on a dark card; one that still fades — measured per pixel against the card, compared with the forum's own header it was drawn for — is inverted in lightness with its hues kept when it is one-tone (Asana's black wordmark turns white, its coral dots stay coral), or shown untouched on a small backing of its own header colour when it has light and dark parts (Python's grey wordmark and yellow snake). Checked on the Pixel 4a in light and dark: Python, Let's Encrypt, Asana. Covered by `packages/discourse_ui/test/forum_brand_test.dart`.

## [1.0.29] - 2026-09-24

### Added
- **Appearance: System default, Light or Dark**, in the drawer's Account section (shown signed out too). The choice applies at once and is remembered. It was loadable all along (`theme_mode`), but the picker went with the XenForo-era settings page.
- **Web views follow the app's mode, not the phone's.** Forum pages (the sign-in grant, the Cloudflare challenge) get Discourse's own `forced_color_mode` cookie, which the server reads to pick the light or dark stylesheet, so they open in the right mode on first paint; other sites and native UI follow through the new `discourse_appearance` plugin (window style on iOS, `NSApp.appearance` on macOS, per-app night mode on Android 12+). Web views no longer flash white before their first frame in dark mode. Checked on the Pixel 4a (Android 13) with the phone in dark mode: in-app Light gave a light forum page, a light `prefers-color-scheme` page and a light status bar. iOS and macOS build; not yet checked on an iPhone. Covered by `packages/discourse_ui/test/appearance_test.dart` and `packages/discourse_appearance/test/`.
- `SettingsContext.setThemeMode`, `AppearanceSync`, `ThemedWebView`, and for host apps `AppearanceChoices` (the three choices, to embed in a host's own settings screen) and `DiscourseHost.showAppearanceSetting` (hides the drawer row; ABDA shows Appearance in its own Settings instead, since it applies to every forum).

### Changed
- `SettingsContext.themeMode` is now the same observable as `AppTheme.themeMode` instead of a second copy kept in step by hand.

## [1.0.28] - 2026-09-24

Links in posts open inside the app. Of the links into the same forum in 10,835 recent posts on 219 directory forums, about 70% were topics or posts, 13% categories (mostly the badge in a quote header), then users, tags and hashtags; each of those used to open the browser, lose the post number, or open with a blank title. Covered by `packages/discourse_core/test/discourse_link_test.dart`, `category_slug_lookup_test.dart` and `packages/discourse_ui/test/discourse_link_handler_test.dart`, and checked on the Pixel against meta.discourse.org.

### Changed
- **A link to this forum opens on the app's own screen**, from posts, messages, chat, link previews, the accepted answer and edit history alike (`DiscourseLinkHandler`, one handler where there were four): a topic at the post the link names; a category, titled with its name; a tag (also the `/tag/{name}/{id}` form newer forums write); a user, group or badge; a chat channel at its message; a search; the tag, user, group and badge lists; `/latest`, `/categories` and the forum itself back on the home's tabs; and `/my/…` pages for the signed-in reader. Uploads, raw posts, invites, sign-in and pages the app has no screen for (about, terms, admin) still go to the browser, as Discourse's own web client sends them to the server.
- **A link to another post of the topic on screen scrolls to it**, as the web does, instead of opening the topic again from its first post.
- **A link from one topic to another stacks**, so Back returns to the post it was tapped in.

### Fixed
- A same-forum link written with or without `www.`, or over http, was treated as another site.
- On a forum installed in a subfolder, the forum's own relative links (`/forum/t/…`, `/forum/uploads/…`) resolved to `/forum/forum/…`.
- Tapping a heading's anchor opened the forum's home in the browser.
- In a message, any link with an `@` in it (a `mailto:`, medium.com/@author) opened a user profile.
- **A push notification tapped while reading a topic opens its topic** instead of nothing. The topic on screen is replaced with `Get.off`, which, like `Get.to`, drops a page of the type already on top unless told not to — and replacing only happens when a topic is on top.
- A `/p/{id}` link opened its topic with the post id in place of the topic id, and the page's topic actions (subscribe, close, rename) used it; the topic is looked up first.

### Added
- `DiscourseLink` reads every Discourse route (`DiscourseLinkKind`: topic, post, category, tag, user, group, badge, chat, search, lists, `/my/`, server-side paths, pages), and `DiscourseLink.inForum(forumUrl, href)` reads a forum's own hrefs against its base path.
- `DiscourseSiteCapabilities.categoryIdForSlugs` finds a category from a hand-written `/c/{slug}` link.
- `SearchPage(initialQuery:)`; `DiscourseRouteNavigator.open(replaceTopic:)`; `DiscourseSiteController.homeRoute`, set by `SiteHomePage`, so a link can return to the forum's home in a host whose first route is not the forum.

### Removed
- `UrlUtils.handleUrlTapWithForumDetection` and its XenForo-era parser, and the unused `LinkPreviewCard`.

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

### Added
- **Delete your account in the app**, where the forum lets members do it (`can_delete_account`: Discourse Connect off and few enough posts). It is the website's Delete My Account, with the same confirmation and messages: the account and its posts are deleted (`DELETE /u/{username}.json`) and the app signs out. On forums that don't allow it, Delete account still points you to the staff.

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
