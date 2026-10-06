# Push notifications: status and decision

**Decision (2026-09-08, revised 2026-09-10): push ships as two optional
client paths, both off by default; the servers are out of scope for this
repo.** 1.0 did not wait for either.

## Why two paths

Discourse only pushes to a URL the forum **owner** has added to
`allowed_user_api_push_urls`. That is the relay path below, and it is the
right one for a forum whose owner runs (or subscribes to) the app. On a
forum nobody has configured — every forum a multi-forum host opens by
address — nothing would ever arrive. The notifications grant covers that
case with nothing from the forum's admins: the user themselves grants a
second User API Key, scoped to `notifications` alone, and a backend polls
their notifications with it.

## Path 1 — relay (`AppForumConfig.pushApiBaseUrl`)

With it set, the User API Key handshake requests the `push` scope and
registers a static `push_url` (`<pushApiBaseUrl>/discourse/push`).
Discourse then POSTs every notification for that key to the relay, tagged
with the handshake `client_id`. The app sends the same `client_id` to the
relay's `/devices/register` together with its FCM token, so the relay can
map one to the other. `DiscourseSiteContextExtension.userApiPushEnabled`
records whether the grant really included push; the notification settings
page tells a user whose key predates the grant to sign in again (a key's
scopes are immutable).

What a forum admin must do: add the exact `push_url` to
`allowed_user_api_push_urls` (Discourse substring-matches, so use a static
URL); keep `push` in `allow_user_api_key_scopes`; verify the relay checks
`push_api_secret_key` from the payload before trusting it. Existing logins
predate the grant and must sign in again.

## Path 2 — notifications grant (`AppForumConfig.notificationsApiBaseUrl`)

With it set, the sign-in flow ends on `EnableNotificationsPage`, which
asks the OS for notification permission (there, not at launch — the user
has just read what the alerts are for) and then runs a second handshake:
`notifications` scope only (four routes: `notifications#index`, `#totals`,
`#mark_read`, `message_bus`), its own client id (`<install>:notify<random>`; legacy grants use `<install>:notify`), and
the backend's `push_url` (`AppForumConfig.notificationsPushUrl`,
`<base>/discourse/push`). The push_url does nothing until a forum's admin
allowlists it — Discourse checks `allowed_user_api_push_urls` when it sends,
and counts the `notifications` scope as push-capable — but a key's push_url
can never be added later, so every grant carries it from the start.

The key is never persisted on the device; it goes to the backend via
`NotificationKeyService`, keyed on the forum URL and the client id. Every
call carries the phone's installation (`NotificationInstallation`: an id and
secret generated on first use, sent as `Authorization: Bearer <id>:<secret>`),
so only this phone can revoke its grants or change their Do Not Disturb.
`PUT /installation` reports the FCM token, the OS permission, app version and
locale for all of the phone's grants at once — at launch, on token rotation,
on every resume — and nothing is reported before the phone's first grant.
The forum's Do Not Disturb (read from the current-user payload and the DND
setting) goes to `PUT /discourse/notification-key/dnd`. A completed grant is
remembered per forum, so signing in again does not ask again; sign-out
revokes and forgets it, and Settings → Notifications turns it on or off
later. When the backend reports `reachable: false` (something in front of
the forum refuses it), the grant page says notifications may not arrive.

The reference backend is abda-push (betterdiscourse.app): it polls
`/notifications.json?filter=unread` (that branch writes nothing — no seen
pointer, no read marks) every 10 minutes, every 3 for half an hour after
news, and pushes one notification per Discourse notification. Discourse
rate-limits per key (20/min, 2880/day) and per IP (200/min across a hosting
cluster), which is what the 10-minute pace is sized against.

What it delivers has to be a payload the app can act on. The contract is
`DiscourseNotificationRoute` in `discourse_ui`, and its tests are the
specification:

| field | meaning |
|---|---|
| `type` | `discourse_notification` — what marks the payload as this backend's |
| `site_url` | the forum, as the backend spells it; how a multi-forum app picks which of its forums to open. The backend keys forums without the scheme and echoes whichever was registered first, so the app matches host, port and subfolder, not the scheme (`NotificationForum.identity`, `NotificationIdentity` on Android) |
| `topic_id` | the topic to open, when the notification is about one |
| `post_number` | position within that topic; the app opens the page holding it |
| `content_id` | the post *id* where `/notifications.json` exposed one (`data.original_post_id`) — a better anchor than the post number, since Discourse resolves it exactly. Left out for a collapsed row ("3 replies"), which should open at the first unread `post_number` |
| `notification_type` | Discourse's type: with the fields below, what the tap opens (chat channel, badge sheet, group inbox, group, profile, notification list) |
| `chat_channel_id`, `chat_message_id`, `chat_thread_id` | a chat destination; a thread opens its channel (the app has no thread view) |
| `badge_id`, `group_name`, `username` | a badge (type 12), a group's inbox (16) or page (22, 23), a person (8, 19, 39, 800, spread reactions) |
| `url` | the page the web would open — a chat bookmark's only address |
| `notification_id` | marked read (with the reader's session) once opened; absent on chat messages, which have no row |
| `push_group` | `messages`, `replies`, `reactions` or `other`: the Android channel for a notification the app shows itself |

Chat DMs and messages in "always" channels have no Notification row; the
backend reads them from the message bus (`/chat/notification-alert/<uid>`)
and sends them with `notification_type` 30. The backend's pushes also carry
the phone's badge (unread across its forums) and name their group's Android
channel (`discourse_messages`, `discourse_replies`, `discourse_reactions`,
else `forum_copilot_channel`).

Per-type switches: `PUT /discourse/notification-key/groups` with
`muted_groups` (`NotificationKeyService.setMutedGroups`), per forum and
phone; what is muted is skipped, not saved for later.

Everything else is passed through for display. A payload naming no topic —
a badge, a bookmark reminder — is expected rather than an error: the app
opens its notification list. FCM data payloads are string-to-string, so
every number arrives as text.

## What is not in this repo

Either server. A relay accepts unauthenticated POSTs from the forum and
holds push credentials; a poller holds users' forum keys. Both belong in
their own deployable, not in a client template. abda-push is the poller
ABDA runs at betterdiscourse.app; a fork can run its own against the
contracts above.

## Why not wait

Nothing else in the app depends on either path, both default to off, and
the code paths are byte-identical to pre-push behaviour when they are
(checked in `app_forum_config_push_test` and
`notifications_api_base_url_test`). Shipping with push optional is honest;
holding a release for a server nobody has to run is not.


### Account switching

Logout persists a revocation outbox entry before clearing grant preferences.
Retries run at startup, on resume/token reports, and once a minute while active.
Each retired grant keeps its original forum and client ID; a new grant uses a
fresh ID, so delayed cleanup cannot revoke the new account's grant. A network
failure does not block logout. Cleanup remains pending until the relay confirms
it; notifications already queued by FCM may still be shown by the OS.

Push payloads must include `recipient_user_id` (the recipient's forum user ID,
not the actor's username), for notification rows and message-bus chat alerts.
The shared navigator checks the full forum URL and signed-in recipient before
opening a destination. Read marking and foreground display use the same check.
Older payloads without identity fail closed with an explanatory message; ordinary
shared links continue to work. Deploy the backend payload update before releasing
the app update. Live account switching and FCM delivery require device verification.

### Guarded Android display (account switches)

Android clients which use `AccountNotifications.handle` in **both** FCM message
handlers initialize `AccountNotifications` after creating notification channels.
Only then does `NotificationInstallation` advertise `account_guarded_v1`. The
backend sends title/body in data, with no notification block: Android must not
render private text before the recipient check.

`discourse_notifications` keeps a native, persistent forum → user map. Its
platform-thread methods serialize checking/display with account replacement and
tray cancellation across foreground/background Flutter engines. A signed-out
forum has a durable empty entry; startup snapshot migration cannot overwrite it.
Login and a new notification grant publish the new identity. Logout invalidates
it before backend cleanup, including offline logout. Other forums keep their
entries. Notification taps still pass through the existing route recipient guard.

Upgrading clears unowned legacy tray notifications once because those entries
have no reliable forum ownership. Already queued legacy FCM notification payloads
cannot be recalled. Older hosts which do not install both handlers must retain
legacy delivery; Apple delivery is unchanged. Android force-stop prevents FCM
execution until the user opens the app again.

Native identity tests: after a Flutter Android build bootstraps Gradle, run
`cd android && ./gradlew :discourse_notifications:testDebugUnitTest`.
