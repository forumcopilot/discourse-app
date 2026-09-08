# Push notifications: status and decision

**Decision (2026-09-08): push ships as an optional feature, off by default,
with the client side complete and the relay out of scope for this repo.**
1.0 does not wait for a relay.

## What is in the app

With `AppForumConfig.pushApiBaseUrl` set, the User API Key handshake
requests the `push` scope and registers a static `push_url`
(`<pushApiBaseUrl>/discourse/push`). Discourse then POSTs every
notification for that key to the relay, tagged with the handshake
`client_id`. The app sends the same `client_id` to the relay's
`/devices/register` together with its FCM token, so the relay can map one
to the other. `DiscourseSiteContextExtension.userApiPushEnabled` records
whether the grant really included push; the notification settings page
tells a user whose key predates the grant to sign in again (a key's
scopes are immutable).

With `pushApiBaseUrl` empty (the default) none of this runs and no
Firebase project is needed; the committed `.example` config files exist
only so the native builds compile.

## What is not in this repo

A relay that accepts Discourse's POST at `/discourse/push` and forwards
it to FCM/APNs by `client_id`. It is a small service, but it holds push
credentials and receives unauthenticated traffic from the forum, so it
belongs in its own deployable, not in a client template. Forum Copilot
runs one for its hosted customers; a fork can run its own against the
contract on `AppForumConfig.discoursePushUrl`.

## What a forum admin must do to enable it

1. Add the exact `push_url` to the `allowed_user_api_push_urls` site
   setting (Discourse substring-matches, so use a static URL).
2. Keep `push` in `allow_user_api_key_scopes`.
3. Verify the relay checks `push_api_secret_key` from the payload before
   trusting it.

Existing logins predate the grant and must sign in again.

## Why not wait

Nothing else in the app depends on it, the setting defaults to off, the
README lists it as not yet implemented, and the code paths are
byte-identical to pre-push behaviour when it is off (checked in the
`app_forum_config_push_test`). Shipping 1.0 with push optional is honest;
holding 1.0 for a server nobody has to run is not.
