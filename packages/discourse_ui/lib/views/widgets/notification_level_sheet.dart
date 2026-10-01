import 'package:flutter/material.dart';
import 'package:discourse_core/discourse_core.dart' show DiscourseTagProxy;
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/models/entities/fc_notification_level.dart';

import '../../theme/design_tokens.dart';
import 'sheet_title.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:discourse_ui/utils/app_navigation.dart';

/// A bottom-sheet picker that mirrors Discourse's per-topic / per-category
/// / per-tag notification-level dropdown. Supports the full 4-level enum:
///   * Watching        — get notified for every reply
///   * Tracking        — show in unread, no email
///   * Normal          — Discourse's default
///   * Muted           — hide entirely
///
/// For per-category and per-tag sheets, [allowWatchingFirstPost] adds a
/// fifth option which Discourse only honors at those levels (topics have
/// no "first post" to watch).
/// What the levels are set on, which picks Discourse's description for
/// each (`topic.notifications`, the `_pm` variants, `category.notifications`,
/// `tagging.notifications`).
enum NotificationLevelTarget { topic, message, category, tag }

class NotificationLevelSheet extends StatefulWidget {
  final FCNotificationLevel? initialLevel;
  final Future<bool> Function(FCNotificationLevel level) onLevelChanged;
  final NotificationLevelTarget target;

  const NotificationLevelSheet({
    super.key,
    required this.onLevelChanged,
    this.initialLevel,
    this.target = NotificationLevelTarget.topic,
  });

  /// Watching First Post is a category and tag level; topics have no
  /// first post to watch for.
  bool get allowWatchingFirstPost =>
      target == NotificationLevelTarget.category ||
      target == NotificationLevelTarget.tag;

  /// Convenience opener for a topic (or a message, with [isMessage]). Loads
  /// the current level on demand.
  static Future<void> showForTopic({
    required BuildContext context,
    required String topicId,
    FCNotificationLevel? currentLevel,
    bool isMessage = false,
    VoidCallback? onChanged,
  }) async {
    final proxy = SiteProxyService.getSubscriptionProxy();
    FCNotificationLevel level =
        currentLevel ?? FCNotificationLevel.normal;
    if (currentLevel == null) {
      final result = await proxy.getTopicNotificationLevelAsync(topicId);
      level = result.level ?? FCNotificationLevel.normal;
    }
    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return NotificationLevelSheet(
          initialLevel: level,
          target: isMessage
              ? NotificationLevelTarget.message
              : NotificationLevelTarget.topic,
          onLevelChanged: (newLevel) async {
            final result =
                await proxy.setTopicNotificationLevelAsync(topicId, newLevel);
            if (result.result && onChanged != null) onChanged();
            return result.result;
          },
        );
      },
    );
  }

  /// Convenience opener for a category.
  static Future<void> showForCategory({
    required BuildContext context,
    required String categoryId,
    FCNotificationLevel? currentLevel,
    VoidCallback? onChanged,
  }) async {
    final proxy = SiteProxyService.getSubscriptionProxy();
    FCNotificationLevel level =
        currentLevel ?? FCNotificationLevel.normal;
    if (currentLevel == null) {
      final result =
          await proxy.getCategoryNotificationLevelAsync(categoryId);
      level = result.level ?? FCNotificationLevel.normal;
    }
    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return NotificationLevelSheet(
          initialLevel: level,
          target: NotificationLevelTarget.category,
          onLevelChanged: (newLevel) async {
            final result = await proxy.setCategoryNotificationLevelAsync(
                categoryId, newLevel);
            if (result.result && onChanged != null) onChanged();
            return result.result;
          },
        );
      },
    );
  }

  /// Convenience opener for a tag (Discourse-native tag watching/muting).
  ///
  /// Same pattern as [showForTopic] / [showForCategory], but backed by
  /// `DiscourseTagProxy` — a no-op when the registered tag proxy isn't the
  /// Discourse one. [onChanged] receives the newly-applied level so callers
  /// can update their bell icon without refetching.
  static Future<void> showForTag({
    required BuildContext context,
    required String tagName,
    FCNotificationLevel? currentLevel,
    void Function(FCNotificationLevel level)? onChanged,
  }) async {
    final tagProxy = SiteProxyService.getTagProxy();
    if (tagProxy is! DiscourseTagProxy) return;
    FCNotificationLevel level =
        currentLevel ?? FCNotificationLevel.normal;
    if (currentLevel == null) {
      final result = await tagProxy.getTagNotificationLevelAsync(tagName);
      if (result.result) level = result.level;
    }
    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return NotificationLevelSheet(
          initialLevel: level,
          target: NotificationLevelTarget.tag,
          onLevelChanged: (newLevel) async {
            final result =
                await tagProxy.setTagNotificationLevelAsync(tagName, newLevel);
            if (result.result && onChanged != null) onChanged(newLevel);
            return result.result;
          },
        );
      },
    );
  }

  @override
  State<NotificationLevelSheet> createState() => _NotificationLevelSheetState();
}

class _NotificationLevelSheetState extends State<NotificationLevelSheet> {
  late FCNotificationLevel _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLevel ?? FCNotificationLevel.normal;
  }

  Future<void> _pick(FCNotificationLevel level) async {
    if (_saving) return;
    setState(() => _saving = true);
    final ok = await widget.onLevelChanged(level);
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (ok) _selected = level;
    });
    if (ok) {
      // Small delay so the user sees the new selection tick before the
      // sheet dismisses.
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) context.popOwnRoute();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.failedToUpdateNotificationLevel)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Discourse's names and descriptions; the icons are web's bells
    // (`d-watching`, `d-tracking`, `d-regular`, `d-muted`).
    final (watching, tracking, normal, muted) = switch (widget.target) {
      NotificationLevelTarget.topic => (
          l10n.topicWatchingDescription,
          l10n.topicTrackingDescription,
          l10n.topicNormalDescription,
          l10n.topicMutedDescription,
        ),
      NotificationLevelTarget.message => (
          l10n.messageWatchingDescription,
          l10n.messageTrackingDescription,
          l10n.messageNormalDescription,
          l10n.messageMutedDescription,
        ),
      NotificationLevelTarget.category => (
          l10n.categoryWatchingDescription,
          l10n.categoryTrackingDescription,
          l10n.categoryNormalDescription,
          l10n.categoryMutedDescription,
        ),
      NotificationLevelTarget.tag => (
          l10n.tagWatchingDescription,
          l10n.tagTrackingDescription,
          l10n.tagNormalDescription,
          l10n.tagMutedDescription,
        ),
    };
    final entries = <_LevelEntry>[
      _LevelEntry(
        level: FCNotificationLevel.watching,
        title: l10n.notificationLevelWatching,
        description: watching,
        icon: Icons.notifications_active,
      ),
      if (widget.allowWatchingFirstPost)
        _LevelEntry(
          level: FCNotificationLevel.watchingFirstPost,
          title: l10n.notificationLevelWatchingFirstPost,
          description: widget.target == NotificationLevelTarget.tag
              ? l10n.tagWatchingFirstPostDescription
              : l10n.categoryWatchingFirstPostDescription,
          icon: Icons.fiber_new,
        ),
      _LevelEntry(
        level: FCNotificationLevel.tracking,
        title: l10n.notificationLevelTracking,
        description: tracking,
        icon: Icons.notifications,
      ),
      _LevelEntry(
        level: FCNotificationLevel.normal,
        title: l10n.notificationLevelNormal,
        description: normal,
        icon: Icons.notifications_none,
      ),
      _LevelEntry(
        level: FCNotificationLevel.muted,
        title: l10n.notificationLevelMuted,
        description: muted,
        icon: Icons.notifications_off,
      ),
    ];

    // Scrolls, and may grow past the default 9/16 of the screen: at a
    // larger text size or on a short phone the options no longer fit.
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: DesignTokens.spacingS),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetTitle(l10n.notifications),
            // The theme's selected row (primary icon and text) plus a
            // check, as the trust-level sheet does; the colours and weight
            // were set by hand here, and the descriptions were 12sp.
            for (final entry in entries)
              ListTile(
                selected: _selected == entry.level,
                leading: Icon(entry.icon),
                title: Text(entry.title),
                subtitle: Text(entry.description),
                trailing: _saving && _selected != entry.level
                    ? null
                    : (_selected == entry.level
                        ? const Icon(Icons.check)
                        : null),
                onTap: _saving ? null : () => _pick(entry.level),
              ),
          ],
        ),
      ),
    );
  }
}

class _LevelEntry {
  final FCNotificationLevel level;
  final String title;
  final String description;
  final IconData icon;
  const _LevelEntry({
    required this.level,
    required this.title,
    required this.description,
    required this.icon,
  });
}
