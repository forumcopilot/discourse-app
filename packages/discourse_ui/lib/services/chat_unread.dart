import 'package:flutter/foundation.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

/// What the Chat tab's badge shows: how many things want the reader now
/// (mentions in channels, unread direct messages), and whether anything at
/// all is unread. As Discourse's chat footer counts them.
@immutable
class ChatUnreadState {
  const ChatUnreadState({this.urgent = 0, this.any = false});

  final int urgent;
  final bool any;

  @override
  bool operator ==(Object other) =>
      other is ChatUnreadState && other.urgent == urgent && other.any == any;

  @override
  int get hashCode => Object.hash(urgent, any);
}

/// The chat list publishes its counts here, per forum, and the bottom bar's
/// Chat tab listens. The Chat tab had no badge at all while Messages had
/// one, so a mention in chat went unnoticed until the tab was opened.
class ChatUnread {
  ChatUnread._();

  static final Map<String, ValueNotifier<ChatUnreadState>> _bySite = {};

  static ValueNotifier<ChatUnreadState> of(SiteContext context) =>
      _bySite.putIfAbsent(context.site.url, () => ValueNotifier(const ChatUnreadState()));

  static void set(SiteContext context, ChatUnreadState state) => of(context).value = state;

  @visibleForTesting
  static void clear() => _bySite.clear();
}
