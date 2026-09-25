# discourse_appearance

Carries the app's light/dark choice below Flutter. `MaterialApp.themeMode`
only recolours what Flutter draws; web views (`prefers-color-scheme`),
share sheets and other system UI follow the platform's appearance. This
plugin forces that appearance to match the in-app setting:

| Platform | Mechanism |
|---|---|
| iOS | `overrideUserInterfaceStyle` on every window |
| macOS | `NSApp.appearance` |
| Android 12+ | `UiModeManager.setApplicationNightMode` (persisted per app by Android) |
| Android < 12, web, Windows, Linux | no-op — the platform keeps following the system |

```dart
await DiscourseAppearance.apply(ThemeMode.dark);
```

`discourse_ui` calls this whenever the Appearance setting changes and once
at startup, so host apps get it by depending on `discourse_ui`.
