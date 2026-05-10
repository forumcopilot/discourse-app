import 'package:discourse_core/discourse_core.dart'
    show DiscourseSubscriptionProxy;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';

import '../../theme/design_tokens.dart';

/// A bottom-sheet picker that mirrors Discourse's per-topic / per-category
/// notification-level dropdown. Supports the full 4-level enum:
///   * Watching (3)  — get notified for every reply
///   * Tracking (2)  — show in unread, no email
///   * Normal   (1)  — Discourse's default
///   * Muted    (0)  — hide entirely
///
/// For per-category sheets, [allowWatchingFirstPost] adds a fifth option
/// (level 4) which Discourse only honors at the category level.
class NotificationLevelSheet extends StatefulWidget {
  final int? initialLevel;
  final Future<bool> Function(int level) onLevelChanged;
  final bool allowWatchingFirstPost;
  final String title;

  const NotificationLevelSheet({
    super.key,
    required this.onLevelChanged,
    this.initialLevel,
    this.allowWatchingFirstPost = false,
    this.title = 'Notification level',
  });

  /// Convenience opener for a topic. Loads the current level on demand.
  static Future<void> showForTopic({
    required BuildContext context,
    required String topicId,
    int? currentLevel,
    VoidCallback? onChanged,
  }) async {
    final proxy = SiteProxyFactory.getSubscriptionProxy();
    if (proxy is! DiscourseSubscriptionProxy) return;
    final level = currentLevel ??
        (await proxy.getTopicNotificationLevelAsync(topicId)) ??
        DiscourseSubscriptionProxy.levelRegular;
    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return NotificationLevelSheet(
          initialLevel: level,
          title: 'Topic notification level',
          onLevelChanged: (newLevel) async {
            final ok = await proxy.setTopicNotificationLevelAsync(
                topicId, newLevel);
            if (ok && onChanged != null) onChanged();
            return ok;
          },
        );
      },
    );
  }

  /// Convenience opener for a category.
  static Future<void> showForCategory({
    required BuildContext context,
    required String categoryId,
    int? currentLevel,
    VoidCallback? onChanged,
  }) async {
    final proxy = SiteProxyFactory.getSubscriptionProxy();
    if (proxy is! DiscourseSubscriptionProxy) return;
    final level = currentLevel ??
        (await proxy.getCategoryNotificationLevelAsync(categoryId)) ??
        DiscourseSubscriptionProxy.levelRegular;
    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return NotificationLevelSheet(
          initialLevel: level,
          title: 'Category notification level',
          allowWatchingFirstPost: true,
          onLevelChanged: (newLevel) async {
            final ok = await proxy.setCategoryNotificationLevelAsync(
                categoryId, newLevel);
            if (ok && onChanged != null) onChanged();
            return ok;
          },
        );
      },
    );
  }

  @override
  State<NotificationLevelSheet> createState() => _NotificationLevelSheetState();
}

class _NotificationLevelSheetState extends State<NotificationLevelSheet> {
  late int _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected =
        widget.initialLevel ?? DiscourseSubscriptionProxy.levelRegular;
  }

  Future<void> _pick(int level) async {
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
      if (mounted) Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update notification level')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final entries = <_LevelEntry>[
      const _LevelEntry(
        level: DiscourseSubscriptionProxy.levelWatching,
        title: 'Watching',
        description: 'Notified of every new reply.',
        icon: Icons.notifications_active,
      ),
      if (widget.allowWatchingFirstPost)
        const _LevelEntry(
          level: DiscourseSubscriptionProxy.levelWatchingFirstPost,
          title: 'Watching First Post',
          description: 'Notified only for new topics in this category.',
          icon: Icons.fiber_new,
        ),
      const _LevelEntry(
        level: DiscourseSubscriptionProxy.levelTracking,
        title: 'Tracking',
        description: 'Shown in your unread list. No email.',
        icon: Icons.visibility,
      ),
      const _LevelEntry(
        level: DiscourseSubscriptionProxy.levelRegular,
        title: 'Normal',
        description: 'Notified only when @mentioned or directly replied to.',
        icon: Icons.notifications_none,
      ),
      const _LevelEntry(
        level: DiscourseSubscriptionProxy.levelMuted,
        title: 'Muted',
        description: 'No notifications, hidden from latest/unread.',
        icon: Icons.notifications_off,
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.spacingL,
                DesignTokens.spacingM,
                DesignTokens.spacingL,
                DesignTokens.spacingS,
              ),
              child: Text(
                widget.title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(height: 1),
            for (final entry in entries)
              ListTile(
                leading: Icon(
                  entry.icon,
                  color: _selected == entry.level
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  entry.title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: _selected == entry.level
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: _selected == entry.level
                        ? colorScheme.primary
                        : null,
                  ),
                ),
                subtitle: Text(
                  entry.description,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: _saving && _selected != entry.level
                    ? null
                    : (_selected == entry.level
                        ? Icon(Icons.check, color: colorScheme.primary)
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
  final int level;
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
