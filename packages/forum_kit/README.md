# forum_kit

Platform-neutral UI shared by discourse-app and flarum-app: theme, shared widgets, caches,
logging and utilities. It must never import discourse_core, discourse_notifications or
discourse_ui (CI checks this); platform specifics come in through hooks the host fills.

Files moved here from discourse_ui keep their path under `lib/`, and discourse_ui re-exports
each one from its old location, so `package:discourse_ui/...` imports keep working.
