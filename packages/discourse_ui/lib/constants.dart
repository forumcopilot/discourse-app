const String forumUrl = 'https://forum.example.com/forumcopilot.php';

// Icon Assets
class AppIcons {
  static const String defaultForumIcon = 'packages/discourse_ui/assets/forumcopiloticon_256.png';

  // Separate icons for different contexts
  static const String defaultHeaderIcon = 'packages/discourse_ui/assets/forumcopiloticon_256.png';
  static const String defaultSubForumIcon = 'packages/discourse_ui/assets/forumcopiloticon_256.png';

  // Single background pattern image - applies theme color programmatically
  static const String backgroundPattern = 'packages/discourse_ui/assets/forum_header_bg.png';

  // Helper method to get the background pattern asset
  // Note: Theme color is applied via ColorFilter in the widget, not via separate assets
  static String getBackgroundAsset(bool isDarkMode) {
    return backgroundPattern;
  }

  // Helper method to get the appropriate default icon based on context
  static String getDefaultIcon(String context) {
    switch (context) {
      case 'header':
        return defaultHeaderIcon;
      case 'subforum':
        return defaultSubForumIcon;
      default:
        return defaultForumIcon;
    }
  }
}
