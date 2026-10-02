/// The forum's chat settings that change what the app offers, from the
/// client site settings (`/site/settings.json`), per forum.
class DiscourseChatSettings {
  const DiscourseChatSettings({
    this.maxDirectMessageUsers = 20,
    this.searchEnabled = true,
    this.threadsEnabled = false,
    this.pinnedMessages = false,
  });

  /// How many people besides the creator a group chat may have
  /// (`chat_max_direct_message_users`); staff are exempt.
  final int maxDirectMessageUsers;

  /// Chat search (`chat_search_enabled`).
  final bool searchEnabled;

  /// Some channel has threads on (`chat_threads_enabled`, set by Discourse
  /// itself): the reader's threads are worth listing.
  final bool threadsEnabled;

  /// Pinned messages (`chat_pinned_messages`).
  final bool pinnedMessages;

  static final Map<String, DiscourseChatSettings> _bySite = {};

  static String _key(String siteUrl) {
    var s = siteUrl.trim();
    while (s.endsWith('/')) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  static DiscourseChatSettings forSite(String siteUrl) => _bySite[_key(siteUrl)] ?? const DiscourseChatSettings();

  /// Reads them from the client settings.
  static void storeFromClientSettings(String siteUrl, Map<String, dynamic> settings) {
    int? asInt(Object? v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}');
    _bySite[_key(siteUrl)] = DiscourseChatSettings(
      maxDirectMessageUsers: asInt(settings['chat_max_direct_message_users']) ?? 20,
      searchEnabled: settings['chat_search_enabled'] != false,
      threadsEnabled: settings['chat_threads_enabled'] == true,
      pinnedMessages: settings['chat_pinned_messages'] == true,
    );
  }

  /// Only for tests.
  static void set(String siteUrl, DiscourseChatSettings settings) => _bySite[_key(siteUrl)] = settings;
  static void clear() => _bySite.clear();
}
