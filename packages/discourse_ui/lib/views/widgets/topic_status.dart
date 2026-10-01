import 'dart:math' as math;

import 'package:discourse_core/discourse_core.dart'
    show
        DiscourseSiteCapabilities,
        DiscourseTopicProxy,
        DiscourseTopicStatus;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_notification_level.dart';

import '../../l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import '../../theme/design_tokens.dart';
import '../../utils/snackbar_helper.dart';
import 'notification_level_sheet.dart';

/// Rebuilds with the topic's [DiscourseTopicStatus] whenever a load or an
/// action records a new one. The status is null until the topic has loaded
/// (and always off Discourse).
class TopicStatusBuilder extends StatelessWidget {
  const TopicStatusBuilder({
    super.key,
    required this.siteContext,
    required this.topicId,
    required this.builder,
  });

  final SiteContext siteContext;
  final String topicId;
  final Widget Function(BuildContext context, DiscourseTopicStatus? status)
      builder;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: DiscourseTopicStatus.changes,
        builder: (context, _, __) => builder(
            context,
            DiscourseTopicStatus.forTopic(siteContext.site.url, topicId)),
      );
}

/// One of the icons web's TopicStatus puts before a topic's title.
class _StatusIcon {
  const _StatusIcon(this.icon, this.help, {this.upsideDown = false, this.danger = false});
  final IconData icon;
  final String help;

  /// Web turns the thumbtack over for a pin the reader has cleared.
  final bool upsideDown;
  final bool danger;
}

List<_StatusIcon> _statusIcons(AppLocalizations l10n, DiscourseTopicStatus s) => [
      // Web's order: closed/archived, warning, pinned, unlisted.
      if (s.closed && s.archived)
        _StatusIcon(Icons.lock, l10n.topicStatusClosedArchivedHelp)
      else if (s.closed)
        _StatusIcon(Icons.lock, l10n.topicStatusClosedHelp)
      else if (s.archived)
        _StatusIcon(Icons.lock, l10n.topicStatusArchivedHelp),
      if (s.isWarning) _StatusIcon(Icons.mail, l10n.topicStatusWarningHelp),
      if (s.pinned)
        _StatusIcon(
            Icons.push_pin,
            s.pinnedGlobally
                ? l10n.topicStatusPinnedGloballyHelp
                : l10n.topicStatusPinnedHelp)
      else if (s.unpinned)
        _StatusIcon(Icons.push_pin_outlined, l10n.topicStatusUnpinnedHelp,
            upsideDown: true),
      if (!s.visible) _StatusIcon(Icons.visibility_off, l10n.topicStatusUnlistedHelp),
      // Not one of web's icons: there a deleted topic's posts turn red.
      if (s.deleted)
        _StatusIcon(Icons.delete, l10n.topicStatusDeletedHelp, danger: true),
    ];

/// The topic's status icons as inline spans, to lead its title the way web's
/// `<h1>` does: a lock when closed or archived, a thumbtack when pinned
/// (upside down once the reader has unpinned it), an eye struck through
/// when unlisted. A tap shows what each one means, Discourse's own help
/// text, which also labels it for screen readers.
List<InlineSpan> topicStatusSpans(
    BuildContext context, DiscourseTopicStatus? status, {required double size}) {
  if (status == null) return const [];
  final l10n = AppLocalizations.of(context)!;
  final colorScheme = Theme.of(context).colorScheme;
  return [
    for (final s in _statusIcons(l10n, status))
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(end: DesignTokens.spacingXS),
          child: Tooltip(
            message: s.help,
            triggerMode: TooltipTriggerMode.tap,
            showDuration: const Duration(seconds: 4),
            child: Semantics(
              label: s.help,
              child: Transform.rotate(
                angle: s.upsideDown ? math.pi : 0,
                child: Icon(s.icon,
                    size: size,
                    color: s.danger ? colorScheme.error : colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        ),
      ),
  ];
}

/// What web's TopicTimerInfo says under the last post: when the topic will
/// close, open, be published, deleted or bumped. Null when there is no
/// timer, or nothing left to announce.
String? topicTimerNotice(
  AppLocalizations l10n,
  DiscourseTopicStatus status, {
  required DateTime now,
  String? categoryName,
}) {
  final timer = status.timer;
  if (timer == null) return null;
  final executeAt = timer.executeAt;
  final type = timer.statusType == 'silent_close' ? 'close' : timer.statusType;
  final deleteReplies = type == 'delete_replies';
  if (!deleteReplies &&
      !timer.basedOnLastPost &&
      (executeAt == null || executeAt.isBefore(now))) {
    return null;
  }
  if (executeAt == null) return null;
  // A close timer on a closed topic (or open on an open one) already ran.
  if ((type == 'close' && status.closed) || (type == 'open' && !status.closed)) {
    return null;
  }
  final timeLeft = _humanizeIn(l10n, executeAt.difference(now));
  final duration = _humanize(l10n, Duration(minutes: timer.durationMinutes ?? 0));
  return switch (type) {
    'close' when timer.basedOnLastPost => l10n.topicTimerAutoCloseAfterLastPost(duration),
    'close' => l10n.topicTimerAutoClose(timeLeft),
    'open' => l10n.topicTimerAutoOpen(timeLeft),
    'delete' when timer.basedOnLastPost => l10n.topicTimerAutoDeleteAfterLastPost(duration),
    'delete' => l10n.topicTimerAutoDelete(timeLeft),
    'bump' => l10n.topicTimerAutoBump(timeLeft),
    'delete_replies' => l10n.topicTimerAutoDeleteReplies(duration),
    'publish_to_category' when categoryName != null =>
      l10n.topicTimerAutoPublish(categoryName, timeLeft),
    _ => null,
  };
}

/// "3 days", rounded the way web's moment.humanize reads: minutes under an
/// hour, hours under a day, then days.
String _humanize(AppLocalizations l10n, Duration d) {
  final minutes = math.max(1, (d.inSeconds / 60).round());
  if (minutes < 60) return l10n.durationMinutes(minutes);
  final hours = (minutes / 60).round();
  if (hours < 24) return l10n.durationHours(hours);
  return l10n.durationDays((hours / 24).round());
}

/// "in 3 days".
String _humanizeIn(AppLocalizations l10n, Duration d) {
  final minutes = math.max(1, (d.inSeconds / 60).round());
  if (minutes < 60) return l10n.timeLeftMinutes(minutes);
  final hours = (minutes / 60).round();
  if (hours < 24) return l10n.timeLeftHours(hours);
  return l10n.timeLeftDays((hours / 24).round());
}

/// Why the reader is at their notification level (web's
/// TopicNotificationsButton reason, `topic.notifications.reasons`): the
/// level and reason pair picks the sentence, falling back to the level's
/// own when Discourse has none for the pair.
String notificationReasonText(AppLocalizations l10n, int level, int? reason) =>
    switch ((level, reason)) {
      (3, 10) => l10n.notificationReasonWatchingTag,
      (3, 6) => l10n.notificationReasonWatchingCategory,
      (3, 5) => l10n.notificationReasonWatchingAuto,
      (3, 1) => l10n.notificationReasonWatchingCreated,
      (3, _) => l10n.notificationReasonWatching,
      (2, 8) => l10n.notificationReasonTrackingCategory,
      (2, 4) => l10n.notificationReasonTrackingReplied,
      (2, 2) => l10n.notificationReasonTracking,
      (2, _) => l10n.notificationReasonTrackingRead,
      (0, 7) => l10n.notificationReasonMutedCategory,
      (0, _) => l10n.notificationReasonMuted,
      _ => l10n.notificationReasonNormal,
    };

/// A notification level's name and icon, as web's tracking button shows
/// them (`d-watching`, `d-tracking`, `d-regular`, `d-muted`).
(String, IconData) notificationLevelLabel(AppLocalizations l10n, int level) =>
    switch (level) {
      3 => (l10n.notificationLevelWatching, Icons.notifications_active),
      2 => (l10n.notificationLevelTracking, Icons.notifications),
      0 => (l10n.notificationLevelMuted, Icons.notifications_off),
      _ => (l10n.notificationLevelNormal, Icons.notifications_none),
    };

/// The end of a topic, as web closes it under the last post: the topic
/// timer and slow-mode notices, then the reader's Pinned / Unpinned choice
/// and their notification level, each with the sentence that explains it
/// (web's PinnedButton and TopicNotificationsButton with their reasons).
/// Draws nothing when none of it applies.
class TopicFooter extends StatelessWidget {
  const TopicFooter({
    super.key,
    required this.siteContext,
    required this.topicId,
    required this.status,
    this.showTopBand = true,
    this.now,
  });

  final SiteContext siteContext;
  final String topicId;
  final DiscourseTopicStatus status;

  /// Opens with the section gap; off under the opening post, which already
  /// ends with one.
  final bool showTopBand;

  /// For tests; the clock otherwise.
  final DateTime? now;

  /// Whether a footer for [status] would show anything, so the list can
  /// drop the rule it would otherwise draw under the last post.
  static bool hasContent(
          BuildContext context, SiteContext siteContext, DiscourseTopicStatus status) =>
      _Parts.of(context, siteContext, status, DateTime.now()).isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final parts = _Parts.of(context, siteContext, status, now ?? DateTime.now());
    if (!parts.isNotEmpty) return const SizedBox.shrink();
    final (timer, slowMode, showPin, showLevel) =
        (parts.timer, parts.slowMode, parts.showPin, parts.showLevel);

    Widget notice(IconData icon, String text) => Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingS),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: DesignTokens.iconSizeM, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: DesignTokens.spacingM),
              Expanded(
                child: Text(text,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant)),
              ),
            ],
          ),
        );

    final (levelName, levelIcon) =
        notificationLevelLabel(l10n, status.notificationLevel);
    final pinTitle = status.pinned
        ? (status.pinnedGlobally
            ? l10n.topicStatusPinnedGloballyTitle
            : l10n.topicStatusPinnedTitle)
        : l10n.topicStatusUnpinnedTitle;
    final pinHelp = status.pinned
        ? (status.pinnedGlobally
            ? l10n.topicStatusPinnedGloballyHelp
            : l10n.topicStatusPinnedHelp)
        : l10n.topicStatusUnpinnedHelp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The section gap that also opens the suggested topics: the
        // stream ends here.
        if (showTopBand)
          ColoredBox(
            color: colorScheme.surfaceContainer,
            child: const SizedBox(height: DesignTokens.spacingS),
          ),
        const SizedBox(height: DesignTokens.spacingS),
        if (timer != null) notice(Icons.schedule, timer),
        if (slowMode != null) notice(Icons.hourglass_empty, slowMode),
        if (showPin)
          _ChoiceRow(
            key: const ValueKey('topic-footer-pinned'),
            icon: Transform.rotate(
              angle: status.pinned ? 0 : math.pi,
              child: Icon(status.pinned ? Icons.push_pin : Icons.push_pin_outlined),
            ),
            title: pinTitle,
            reason: pinHelp,
            onTap: () => showPinnedOptions(context,
                siteContext: siteContext, topicId: topicId, status: status),
          ),
        if (showLevel)
          _ChoiceRow(
            key: const ValueKey('topic-footer-notifications'),
            icon: Icon(levelIcon),
            title: levelName,
            reason: notificationReasonText(
                l10n, status.notificationLevel, status.notificationsReasonId),
            onTap: () => NotificationLevelSheet.showForTopic(
              context: context,
              topicId: topicId,
              isMessage: status.isMessage,
              currentLevel: FCNotificationLevel.fromInt(status.notificationLevel),
            ),
          ),
        const SizedBox(height: DesignTokens.spacingS),
      ],
    );
  }
}

/// What a [TopicFooter] shows for a status.
class _Parts {
  const _Parts(this.timer, this.slowMode, this.showPin, this.showLevel);

  factory _Parts.of(BuildContext context, SiteContext siteContext,
      DiscourseTopicStatus status, DateTime now) {
    final l10n = AppLocalizations.of(context)!;
    final signedIn = siteContext.isLoggedIn;
    final timerCategoryId = status.timer?.categoryId;
    return _Parts(
      topicTimerNotice(
        l10n,
        status,
        now: now,
        categoryName: timerCategoryId == null
            ? null
            : DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl)
                .categoryNameFor('$timerCategoryId'),
      ),
      status.slowModeSeconds > 0
          ? l10n.slowModeNotice(
              _humanize(l10n, Duration(seconds: status.slowModeSeconds)))
          : null,
      // Web hides the pin choice on a deleted topic, and from guests.
      signedIn && status.isPinnedByStaff && !status.deleted,
      signedIn,
    );
  }

  final String? timer;
  final String? slowMode;
  final bool showPin;
  final bool showLevel;

  bool get isNotEmpty =>
      timer != null || slowMode != null || showPin || showLevel;
}

/// A footer choice: what it is now, why, and a tap to change it — web's
/// dropdown button with its reason beside it, laid out for a phone.
class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    super.key,
    required this.icon,
    required this.title,
    required this.reason,
    required this.onTap,
  });

  final Widget icon;
  final String title;
  final String reason;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: icon,
        title: Text(title),
        subtitle: Text(reason),
        trailing: const Icon(Icons.arrow_drop_down),
        onTap: onTap,
      );
}

/// Web's PinnedOptions: keep the topic pinned at the top for this reader,
/// or list it in regular order for them alone (PUT /t/{id}/clear-pin,
/// /re-pin). Nobody else's view changes.
Future<void> showPinnedOptions(
  BuildContext context, {
  required SiteContext siteContext,
  required String topicId,
  required DiscourseTopicStatus status,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final choice = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            key: const ValueKey('pinned-option-pinned'),
            selected: status.pinned,
            leading: const Icon(Icons.push_pin),
            title: Text(status.pinnedGlobally
                ? l10n.topicStatusPinnedGloballyTitle
                : l10n.topicStatusPinnedTitle),
            subtitle: Text(status.pinnedGlobally
                ? l10n.topicStatusPinnedGloballyHelp
                : l10n.topicStatusPinnedHelp),
            trailing: status.pinned ? const Icon(Icons.check) : null,
            onTap: () => Navigator.of(sheetContext).pop(true),
          ),
          ListTile(
            key: const ValueKey('pinned-option-unpinned'),
            selected: !status.pinned,
            leading: Transform.rotate(
                angle: math.pi, child: const Icon(Icons.push_pin_outlined)),
            title: Text(l10n.topicStatusUnpinnedTitle),
            subtitle: Text(l10n.topicStatusUnpinnedHelp),
            trailing: !status.pinned ? const Icon(Icons.check) : null,
            onTap: () => Navigator.of(sheetContext).pop(false),
          ),
        ],
      ),
    ),
  );
  if (choice == null || choice == status.pinned || !context.mounted) return;
  final proxy = SiteProxyFactory.getTopicProxy();
  if (proxy is! DiscourseTopicProxy) return;
  final error = await proxy.setPinnedForMeAsync(topicId, pinned: choice);
  if (error != null && context.mounted) {
    SnackbarHelper.showError(context, l10n.topicActionFailed(error));
  }
}
