import 'package:discourse_core/discourse_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';
import '../../utils/app_navigation.dart';
import '../../utils/error_message.dart';
import '../../utils/local_dates.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/time_utils.dart';
import '../chat/chat_channel_view.dart';
import '../edit_profile_page.dart';
import '../private_messaging/conversation/pages/new_conversation_page.dart';
import '../search_page.dart';
import '../user_profile_page.dart';
import '../widgets/cached_redirect_image.dart';
import '../widgets/reaction_glyph.dart';
import '../widgets/rich_text_content.dart';
import '../widgets/user_avatar.dart';
import 'profile_common.dart';
import 'status_sheet.dart';

/// The user card: a quick look at someone that stays over the page being
/// read, as web's card does — opened by tapping a person's picture or name
/// on a post, in the member directory, an @mention or chat. Profile (or the
/// picture, or the name) opens their full profile.
///
/// [topicId] is the topic it was opened from: Discourse then says how many
/// posts they have in it, and the card offers to show only those.
Future<void> showUserCard(
  BuildContext context, {
  required SiteContext siteContext,
  required String username,
  int? topicId,
  String? avatarUrl,
  DiscourseProfileProxy? proxy,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    clipBehavior: Clip.antiAlias,
    builder: (_) => UserCardSheet(
      siteContext: siteContext,
      username: username,
      topicId: topicId,
      avatarUrl: avatarUrl,
      proxy: proxy,
    ),
  );
}

class UserCardSheet extends StatefulWidget {
  const UserCardSheet({
    super.key,
    required this.siteContext,
    required this.username,
    this.topicId,
    this.avatarUrl,
    this.proxy,
  });

  final SiteContext siteContext;
  final String username;
  final int? topicId;

  /// The picture the caller already shows, for the first frame.
  final String? avatarUrl;
  final DiscourseProfileProxy? proxy;

  @override
  State<UserCardSheet> createState() => _UserCardSheetState();
}

class _UserCardSheetState extends State<UserCardSheet> {
  late final DiscourseProfileProxy _proxy =
      widget.proxy ?? DiscourseProfileProxy(widget.siteContext);
  DiscourseUserCard? _card;
  Object? _error;
  bool _startingChat = false;

  static const double _imageHeight = 104;
  static const double _bandHeight = 72;
  static const double _avatarRadius = 36;
  static const double _ring = 4;

  bool get _isSelf =>
      widget.username.toLowerCase() ==
      (widget.siteContext.currentUsername ?? '').toLowerCase();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final card =
          await _proxy.loadCard(widget.username, topicId: widget.topicId);
      if (mounted) setState(() => _card = card);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  String? get _avatar {
    final template = _card?.avatarTemplate;
    return DiscourseEditableProfile.avatarUrl(
            widget.siteContext.site.url, template, 240) ??
        widget.avatarUrl;
  }

  /// Leaves the card for another page: the card closes first, so Back
  /// from that page returns to what was being read.
  void _go(Widget page, {bool form = false}) {
    final navigator = Navigator.of(context);
    navigator.pop();
    final route = form
        ? FormPageRoute<void>(builder: (_) => page)
        : AppNavigation.route<void>(page);
    navigator.push(route);
  }

  void _openProfile() => _go(UserProfilePage(
        siteContext: widget.siteContext,
        userName: widget.username,
        profilePictureUrl: _avatar,
      ));

  void _openTopicPosts() {
    final topicId = widget.topicId;
    if (topicId == null) return;
    _go(SearchPage(
      siteContext: widget.siteContext,
      initialQuery: 'topic:$topicId @${widget.username} order:oldest',
    ));
  }

  Future<void> _message() async {
    final navigator = Navigator.of(context);
    final rootContext = navigator.context;
    navigator.pop();
    await NewConversationPage.open(
      rootContext,
      siteContext: widget.siteContext,
      initialRecipient: widget.username,
      initialRecipientIconUrl: _avatar,
    );
  }

  Future<void> _chat() async {
    if (_startingChat) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _startingChat = true);
    try {
      final proxy = SiteProxyFactory.getChatProxy() as DiscourseChatProxy;
      final result = await proxy
          .createDirectMessageChannelAsync([widget.username], upsert: true);
      if (!mounted) return;
      final channel = result.channel;
      if (!result.result || channel == null) {
        SnackbarHelper.showError(
            context,
            result.resultText?.isNotEmpty == true
                ? result.resultText!
                : l10n.chatCouldNotStartDm);
        return;
      }
      _go(Scaffold(
        appBar: AppBar(title: Text(widget.username)),
        body: ChatChannelView(
            siteContext: widget.siteContext, channelId: channel.id),
      ));
    } finally {
      if (mounted) setState(() => _startingChat = false);
    }
  }

  Future<void> _editStatus() async {
    final l10n = AppLocalizations.of(context)!;
    final changed = await showStatusSheet(
        context: context,
        siteContext: widget.siteContext,
        current: _card?.status);
    if (!changed || !mounted) return;
    SnackbarHelper.showInfo(context, l10n.statusUpdated);
    _load();
  }

  Future<void> _menu(String action) async {
    final l10n = AppLocalizations.of(context)!;
    final card = _card;
    if (card == null) return;
    try {
      switch (action) {
        case 'mute':
          await _proxy.setMuted(card.username, !card.muted);
          if (mounted) {
            SnackbarHelper.showInfo(context,
                card.muted ? l10n.userUnmuted(card.username) : l10n.userMuted(card.username));
          }
        case 'ignore':
          final result = await DiscourseUserProxy(widget.siteContext)
              .ignoreUserAsync(card.username, card.ignored ? 0 : 1);
          if (!result.result) throw Exception(result.resultText);
          if (mounted) {
            SnackbarHelper.showInfo(
                context,
                card.ignored
                    ? l10n.stoppedIgnoringUser(card.username)
                    : l10n.userIgnoredFor4Months(card.username));
          }
        case 'link':
          final base = widget.siteContext.site.url.replaceAll(RegExp(r'/$'), '');
          await Clipboard.setData(
              ClipboardData(text: '$base/u/${Uri.encodeComponent(card.username)}'));
          if (mounted) SnackbarHelper.showInfo(context, l10n.linkCopied);
          return;
      }
      _load();
    } catch (e) {
      if (mounted) SnackbarHelper.showError(context, describeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = _card;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: DesignTokens.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(context, card),
            if (card == null)
              _error == null
                  ? const Padding(
                      padding: EdgeInsets.all(DesignTokens.spacingXL),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(DesignTokens.spacingL),
                      child: Text(describeError(_error)),
                    )
            else
              ..._body(context, card),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, DiscourseUserCard? card) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final background = card?.cardBackgroundUrl;
    final band = background == null ? _bandHeight : _imageHeight;
    final avatarBox = (_avatarRadius + _ring) * 2;
    final onImage = background != null;
    return SizedBox(
      height: band + avatarBox / 2,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: band,
            child: background == null
                ? ColoredBox(color: colorScheme.surfaceContainerHigh)
                : CachedRedirectImage(
                    imageUrl: background,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        ColoredBox(color: colorScheme.surfaceContainerHigh),
                    errorWidget: (_, __, ___) =>
                        ColoredBox(color: colorScheme.surfaceContainerHigh),
                  ),
          ),
          // The sheet's handle, drawn over the image.
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: onImage
                      ? Colors.white.withValues(alpha: 0.85)
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          if (card != null && !_isSelf)
            PositionedDirectional(
              end: DesignTokens.spacingS,
              top: DesignTokens.spacingL,
              child: PopupMenuButton<String>(
                tooltip: l10n.moreOptions,
                style: onImage
                    ? IconButton.styleFrom(
                        backgroundColor:
                            colorScheme.surface.withValues(alpha: 0.9))
                    : null,
                onSelected: _menu,
                itemBuilder: (_) => [
                  if (card.canMute || card.muted)
                    PopupMenuItem(
                      value: 'mute',
                      child: ListTile(
                        leading: Icon(card.muted
                            ? Icons.volume_up_outlined
                            : Icons.volume_off_outlined),
                        title: Text(card.muted ? l10n.unmute : l10n.mute),
                      ),
                    ),
                  if (card.canIgnore || card.ignored)
                    PopupMenuItem(
                      value: 'ignore',
                      child: ListTile(
                        leading: Icon(card.ignored
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        title: Text(
                            card.ignored ? l10n.unignore : l10n.ignore),
                      ),
                    ),
                  PopupMenuItem(
                    value: 'link',
                    child: ListTile(
                      leading: const Icon(Icons.link),
                      title: Text(l10n.copyProfileLink),
                    ),
                  ),
                ],
              ),
            ),
          if (card != null && _isSelf && background != null)
            PositionedDirectional(
              end: DesignTokens.spacingS,
              top: DesignTokens.spacingL,
              child: FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.surface.withValues(alpha: 0.92),
                  foregroundColor: colorScheme.onSurface,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => _go(EditProfilePage(
                    siteContext: widget.siteContext,
                    userInfo: _selfInfo(card))),
                icon: const Icon(Icons.photo_camera_outlined,
                    size: DesignTokens.iconSizeSMedium),
                label: Text(l10n.change),
              ),
            ),
          PositionedDirectional(
            start: DesignTokens.spacingM - _ring,
            top: band - avatarBox / 2,
            child: Semantics(
              button: true,
              label: l10n.openProfileOf(widget.username),
              child: GestureDetector(
                onTap: _openProfile,
                child: Container(
                  padding: const EdgeInsets.all(_ring),
                  decoration: BoxDecoration(
                    color: Theme.of(context).bottomSheetTheme.backgroundColor ??
                        colorScheme.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      UserAvatar(
                        username: widget.username,
                        iconUrl: _avatar,
                        radius: _avatarRadius,
                      ),
                      if (card != null && card.hasFlair)
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: UserFlairBadge(
                            flairUrl: card.flairUrl!,
                            bgHex: card.flairBgColor,
                            fgHex: card.flairColor,
                            size: 26,
                            ringColor: colorScheme.surfaceContainerLow,
                            semanticLabel: card.flairName,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  FCUserInfoResult _selfInfo(DiscourseUserCard card) => FCUserInfoResult(
        result: true,
        id: '${card.id}',
        username: card.username,
        displayText: card.name,
        iconUrl: _avatar,
      );

  List<Widget> _body(BuildContext context, DiscourseUserCard card) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final muted =
        textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant);
    final locale = Localizations.localeOf(context).toString();
    final name = card.name?.trim() ?? '';
    final subline = [
      if (name.isNotEmpty) '@${card.username}',
      if (card.title != null) card.title!,
    ].join(' · ');
    final zone = timeZoneNamed(card.timezone);
    final status = card.status;

    Widget meta(IconData icon, String text, {VoidCallback? onTap}) {
      final row = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: DesignTokens.iconSizeS, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: DesignTokens.spacingXS),
          Flexible(
            child: Text(text,
                style: onTap == null
                    ? muted
                    : muted?.copyWith(color: colorScheme.primary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );
      return onTap == null ? row : InkWell(onTap: onTap, child: row);
    }

    final dates = [
      if (card.createdAt != null)
        l10n.profileJoined(DateFormat.yMMM(locale).format(card.createdAt!.toLocal())),
      if (card.lastPostedAt != null)
        l10n.cardPosted(formatTimeAgo(card.lastPostedAt!, context)),
      if (card.lastSeenAt != null)
        l10n.profileSeen(formatTimeAgo(card.lastSeenAt!, context)),
    ];
    final website = card.website;
    final postsHere = card.topicPostCount;

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
            DesignTokens.spacingS, DesignTokens.spacingL, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _openProfile,
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                      text: name.isNotEmpty ? name : card.username,
                      style: textTheme.titleLarge),
                  if (_isSelf)
                    TextSpan(text: '  ${l10n.youParenthetical}', style: muted),
                ]),
              ),
            ),
            if (subline.isNotEmpty) Text(subline, style: muted),
            if (card.profileHidden) ...[
              if (card.primaryGroupName != null)
                Text(l10n.memberOfGroup(card.primaryGroupName!), style: muted),
              const SizedBox(height: DesignTokens.spacingL),
              Container(
                padding: const EdgeInsets.all(DesignTokens.spacingM),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline,
                        size: DesignTokens.iconSizeM,
                        color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: DesignTokens.spacingM),
                    Expanded(
                      child: Text(l10n.profileIsPrivate(card.username),
                          style: textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            ] else ...[
              if (status != null && status.isActive)
                InkWell(
                  onTap: _isSelf ? _editStatus : null,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
                    child: Row(
                      children: [
                        if (status.emoji != null) ...[
                          ReactionGlyph(
                              reactionId: status.emoji!,
                              size: DesignTokens.iconSizeM,
                              siteContext: widget.siteContext),
                          const SizedBox(width: DesignTokens.spacingS),
                        ],
                        Expanded(
                            child: Text(status.description,
                                style: textTheme.bodyMedium)),
                        if (_isSelf)
                          Icon(Icons.edit_outlined,
                              size: DesignTokens.iconSizeS,
                              color: colorScheme.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
              if (card.bioExcerptHtml != null) ...[
                const SizedBox(height: DesignTokens.spacingXS),
                RichTextContent(
                  siteContext: widget.siteContext,
                  content: card.bioExcerptHtml!,
                  baseFontSize: textTheme.bodyMedium?.fontSize,
                ),
              ],
              const SizedBox(height: DesignTokens.spacingS),
              Wrap(
                spacing: DesignTokens.spacingM,
                runSpacing: DesignTokens.spacingXS,
                children: [
                  if (card.location != null)
                    meta(Icons.place_outlined, card.location!),
                  if (zone != null)
                    meta(
                        Icons.schedule,
                        l10n.profileLocalTime(DateFormat.jm(locale)
                            .format(tz.TZDateTime.now(zone)))),
                  for (final f in card.fields)
                    meta(Icons.info_outline, '${f.name}: ${f.value}'),
                  if (website != null)
                    meta(Icons.link, card.websiteName ?? website, onTap: () {
                      final uri = Uri.tryParse(
                          website.contains('://') ? website : 'https://$website');
                      if (uri != null) {
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    }),
                ],
              ),
              if (card.badges.isNotEmpty) ...[
                const SizedBox(height: DesignTokens.spacingM),
                Wrap(
                  spacing: DesignTokens.spacingS,
                  runSpacing: DesignTokens.spacingS,
                  children: [
                    for (final b in card.badges)
                      Chip(
                        avatar: Icon(Icons.military_tech,
                            color: _badgeColor(b.badgeTypeId, colorScheme)),
                        label: Text(b.name),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
              if (dates.isNotEmpty) ...[
                const SizedBox(height: DesignTokens.spacingM),
                Text(dates.join(' · '),
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ],
          ],
        ),
      ),
      if (widget.topicId != null && postsHere != null && postsHere > 0) ...[
        const Divider(
            height: DesignTokens.spacingXL,
            indent: DesignTokens.spacingL,
            endIndent: DesignTokens.spacingL),
        ListTile(
          leading: Icon(Icons.filter_list, color: colorScheme.primary),
          title: Text(
            _isSelf
                ? l10n.showOnlyYourPostsHere(postsHere)
                : l10n.showOnlyTheirPostsHere(
                    name.isNotEmpty ? name : card.username, postsHere),
            style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
          ),
          onTap: _openTopicPosts,
        ),
      ] else
        const SizedBox(height: DesignTokens.spacingM),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL),
        child: Row(
          children: _isSelf
              ? [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => _go(EditProfilePage(
                          siteContext: widget.siteContext,
                          userInfo: _selfInfo(card))),
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(l10n.editProfile),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacingS),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openProfile,
                      icon: const Icon(Icons.account_circle_outlined),
                      label: Text(l10n.viewProfile),
                    ),
                  ),
                ]
              : [
                  if (card.canSendPrivateMessage) ...[
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: _message,
                        icon: const Icon(Icons.mail_outline),
                        label: Text(l10n.sendMessage),
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacingS),
                  ],
                  if (card.canChat && !card.profileHidden) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _startingChat ? null : _chat,
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: Text(l10n.chatWithUser),
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacingS),
                  ],
                  if (!card.profileHidden)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openProfile,
                        icon: const Icon(Icons.account_circle_outlined),
                        label: Text(l10n.profile),
                      ),
                    ),
                ],
        ),
      ),
    ];
  }

  Color _badgeColor(int? type, ColorScheme scheme) => switch (type) {
        1 => const Color(0xFFB08A12),
        2 => const Color(0xFF76828E),
        3 => const Color(0xFFA0622D),
        _ => scheme.onSurfaceVariant,
      };
}
