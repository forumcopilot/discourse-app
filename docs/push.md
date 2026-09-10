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
`#mark_read`, `message_bus`), its own client id (`<install>:notify`), no
`push_url`. The key is never persisted on the device; it goes to the
backend via `NotificationKeyService`, keyed on the forum URL and the client
id, together with the FCM token, which is re-sent whenever it becomes
known or rotates. A completed grant is remembered per forum, so signing in
again does not ask again; sign-out revokes and forgets it, and Settings →
Notifications turns it on or off later.

The backend has to serve three routes under the base URL — the bodies are
on `NotificationKeyService` — and run a poller: read
`/notifications.json?filter=unread` with the stored key (that branch never
bumps the user's seen pointer), deliver everything above a per-key
high-water mark, advance the mark only for what was delivered. Discourse
rate-limits per key (20/min, 2880/day), so one poll a minute per user is
safe. What it delivers must be a payload the app can act on: see
`NotificationService._navigateFromNotification` for the fields it reads.

## What is not in this repo

Either server. A relay accepts unauthenticated POSTs from the forum and
holds push credentials; a poller holds users' forum keys. Both belong in
their own deployable, not in a client template. Forum Copilot runs them
for its hosted customers; a fork can run its own against the contracts
above.

## Why not wait

Nothing else in the app depends on either path, both default to off, and
the code paths are byte-identical to pre-push behaviour when they are
(checked in `app_forum_config_push_test` and
`notifications_api_base_url_test`). Shipping with push optional is honest;
holding a release for a server nobody has to run is not.
