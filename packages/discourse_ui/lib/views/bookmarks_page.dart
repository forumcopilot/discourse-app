import 'dart:async';

import 'package:discourse_core/discourse_core.dart'
    show
        DiscourseBookmarkAutoDelete,
        DiscourseBookmarkDetails,
        DiscourseBookmarkProxy;
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_bookmark.dart';
import 'package:intl/intl.dart';

import '../core/logging/app_logger.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/app_l10n.dart';
import '../theme/design_tokens.dart';
import '../utils/emoji_shortcodes.dart';
import '../utils/error_message.dart';
import '../utils/time_utils.dart';
import 'lists/posts_list.dart';
import 'post_page.dart';
import 'widgets/activity_row.dart' show QuotedExcerpt;
import 'widgets/bookmark_reminder_sheet.dart';
import 'widgets/empty_state_view.dart';
import 'widgets/filter_chip_bar.dart';
import 'widgets/topic_taxonomy_chips.dart';
import 'widgets/user_avatar.dart';

/// The reader's bookmarks (`/u/{me}/bookmarks.json`), in the style of the
/// topic page and My posts.
///
/// * Search (the server's own, over labels and post text) and filters: All,
///   Reminders, Pinned. Pinned bookmarks lead the list under their own
///   heading, as web floats them.
/// * Each row: the topic, its category and tags, the reader's label (the
///   bookmark's name — sent with every bookmark and never shown before), a
///   reminder chip that says when ("Tomorrow, 8:00 AM", or "Due" once it
///   has fired, where it used to say "2h" or "due"), the saved post's
///   words quoted, and whose post, which one, and when it was saved.
/// * Swipe to remove, with Undo; the ⋮ menu edits the label and the
///   reminder and pins or unpins, as web's bookmark menu does.
class BookmarksPage extends StatefulWidget {
  final SiteContext siteContext;

  const BookmarksPage({super.key, required this.siteContext});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

enum _Filter { all, reminders, pinned }

class _BookmarksPageState extends State<BookmarksPage> {
  final List<FCBookmark> _entries = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;
  int _page = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  _Filter _filter = _Filter.all;

  /// Bumped on every fresh load, so a slow page for an older query does
  /// not land in the newer one.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final p = _scrollController.position;
    if (p.pixels >= p.maxScrollExtent - 400 && !_isLoading && _hasMore) {
      _load(reset: false);
    }
  }

  DiscourseBookmarkProxy? get _proxy {
    final proxy = SiteProxyService.getBookmarkProxy();
    return proxy is DiscourseBookmarkProxy ? proxy : null;
  }

  Future<void> _load({required bool reset}) async {
    final generation = reset ? ++_generation : _generation;
    if (reset) {
      _page = 0;
      _hasMore = true;
      _error = null;
    }
    setState(() => _isLoading = true);
    try {
      final proxy = _proxy;
      if (proxy == null) {
        setState(() {
          // appL10n: the first load runs from initState, before this
          // State may look anything up through its context.
          _error = appL10n().bookmarksUnavailable;
          _isLoading = false;
          _hasMore = false;
        });
        return;
      }
      final result = await proxy.getBookmarksWithRemindersAsync(
          page: _page, query: _search.text);
      if (!mounted || generation != _generation) return;
      if (!result.result) {
        setState(() {
          if (reset) _entries.clear();
          _error = result.resultText?.isNotEmpty == true
              ? result.resultText
              : AppLocalizations.of(context)!.failedToLoadBookmarks;
          _isLoading = false;
          _hasMore = false;
        });
        return;
      }
      setState(() {
        if (reset) _entries.clear();
        _entries.addAll(result.entries);
        _hasMore = result.hasMore;
        if (result.entries.isNotEmpty) _page++;
        _isLoading = false;
      });
      _fillFilter();
    } catch (e, st) {
      AppLogger.error('BookmarksPage load failed', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _error = describeError(e);
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  /// Reminders and Pinned filter what is loaded; while they show only a
  /// few and more pages exist, load on, so a filter does not look empty
  /// because its matches are further down.
  void _fillFilter() {
    if (_filter == _Filter.all || !_hasMore || _isLoading) return;
    if (_visible.length >= 10) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isLoading && _hasMore) _load(reset: false);
    });
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) _load(reset: true);
    });
    setState(() {});
  }

  List<FCBookmark> get _visible => switch (_filter) {
        _Filter.all => _entries,
        _Filter.reminders => _entries.where((b) => b.reminderAt != null).toList(),
        _Filter.pinned => _entries.where((b) => b.pinned).toList(),
      };

  Future<void> _refresh() => _load(reset: true);

  /// Removes at once and deletes when the Undo snackbar closes without an
  /// Undo — a removed bookmark comes back exactly, with its label and
  /// reminder, rather than being recreated.
  void _remove(FCBookmark entry) {
    final index = _entries.indexOf(entry);
    if (index < 0) return;
    setState(() => _entries.removeAt(index));
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    messenger.hideCurrentSnackBar();
    // Timed, not persistent: since Flutter 3.38 a snackbar with an action
    // stays up until tapped, and the delete waits for it to close.
    final controller = messenger.showSnackBar(SnackBar(
      content: Text(l10n.bookmarkRemoved),
      action: SnackBarAction(label: l10n.undo, onPressed: () {}),
      persist: false,
      duration: const Duration(seconds: 5),
    ));
    controller.closed.then((reason) async {
      if (reason == SnackBarClosedReason.action) {
        if (mounted) {
          setState(() => _entries.insert(index.clamp(0, _entries.length), entry));
        }
        return;
      }
      final result = await SiteProxyService.getBookmarkProxy()
          .removeBookmarkByIdAsync(entry.id);
      if (!mounted || result.result) return;
      setState(() => _entries.insert(index.clamp(0, _entries.length), entry));
      messenger.showSnackBar(SnackBar(
        content: Text(result.resultText?.isNotEmpty == true
            ? result.resultText!
            : l10n.failedToRemoveBookmark),
      ));
    });
  }

  Future<void> _editReminder(FCBookmark entry) async {
    final l10n = AppLocalizations.of(context)!;
    final choice = await BookmarkReminderSheet.show(
      context,
      title: entry.reminderAt != null ? l10n.editReminder : l10n.addReminder,
      currentReminderAt: entry.reminderAt,
    );
    if (choice == null || !mounted) return;
    await _update(entry, reminderAt: choice.reminderAt, name: entry.name);
  }

  Future<void> _editLabel(FCBookmark entry) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: entry.name ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text((entry.name ?? '').isEmpty
            ? l10n.addBookmarkLabel
            : l10n.editBookmarkLabel),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 100,
          decoration: InputDecoration(hintText: l10n.bookmarkLabelHint),
          onSubmitted: (v) => Navigator.of(dialog).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || !mounted) return;
    await _update(entry, reminderAt: entry.reminderAt, name: name.trim());
  }

  /// The endpoint overwrites, so the label and reminder not being changed
  /// are sent back as they are.
  Future<void> _update(FCBookmark entry,
      {DateTime? reminderAt, String? name}) async {
    final proxy = _proxy;
    if (proxy == null) return;
    final result = await proxy.updateBookmarkAsync(
      entry.id,
      reminderAt: reminderAt,
      name: name,
      autoDeletePreference: reminderAt != null
          ? DiscourseBookmarkAutoDelete.clearReminder
          : null,
    );
    if (!mounted) return;
    if (result.result) {
      setState(() {
        entry.reminderAt = reminderAt;
        entry.name = (name?.isEmpty ?? true) ? null : name;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.resultText?.isNotEmpty == true
            ? result.resultText!
            : AppLocalizations.of(context)!.failedToUpdateBookmark),
      ));
    }
  }

  Future<void> _togglePin(FCBookmark entry) async {
    final proxy = _proxy;
    if (proxy == null) return;
    final result = await proxy.toggleBookmarkPinAsync(entry.id);
    if (!mounted) return;
    if (!result.result) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.resultText?.isNotEmpty == true
            ? result.resultText!
            : AppLocalizations.of(context)!.failedToUpdateBookmark),
      ));
      return;
    }
    setState(() {
      entry.pinned = !entry.pinned;
      // Pinned first, as the server orders them; otherwise as they were.
      final pinned = _entries.where((b) => b.pinned).toList();
      final rest = _entries.where((b) => !b.pinned).toList();
      _entries
        ..clear()
        ..addAll(pinned)
        ..addAll(rest);
    });
  }

  void _open(FCBookmark b) {
    final tid = b.topicId;
    if (tid == null) return;
    final isPost = b.bookmarkableType == 'Post' && b.bookmarkableId != null;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostPage(
          siteContext: widget.siteContext,
          topicId: tid.toString(),
          title: b.title ?? '',
          mode: isPost ? PostsListMode.thread_by_post : PostsListMode.normal,
          anchorPostId: isPost ? b.bookmarkableId!.toString() : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookmarks)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
                    DesignTokens.spacingS, DesignTokens.spacingL, 0),
                child: TextField(
                  controller: _search,
                  onChanged: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.searchBookmarks,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: MaterialLocalizations.of(context)
                                .deleteButtonTooltip,
                            onPressed: () {
                              _search.clear();
                              _onSearchChanged('');
                            },
                          ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHigh,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            PinnedHeaderSliver(
              child: Material(
                color: colorScheme.surface,
                child: FilterChipBar(
                  options: [
                    FilterChipOption(label: l10n.all),
                    FilterChipOption(
                        label: l10n.bookmarksFilterReminders,
                        icon: Icons.alarm),
                    FilterChipOption(
                        label: l10n.pinned, icon: Icons.push_pin_outlined),
                  ],
                  selectedIndex: _filter.index,
                  onSelected: (i) {
                    setState(() => _filter = _Filter.values[i]);
                    _fillFilter();
                  },
                ),
              ),
            ),
            ..._content(context, l10n),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final visible = _visible;
    if (visible.isEmpty && _isLoading) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (visible.isEmpty && _error != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateView.error(
              message: _error!, onRetry: () => _load(reset: true)),
        ),
      ];
    }
    if (visible.isEmpty) {
      final searching = _search.text.trim().isNotEmpty || _filter != _Filter.all;
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: searching
              ? EmptyStateView(
                  icon: Icons.search_off, message: l10n.bookmarksNoMatch)
              : EmptyStateView(
                  icon: Icons.bookmark_border,
                  message: l10n.bookmarksEmpty,
                  hint: l10n.bookmarksEmptyHint,
                ),
        ),
      ];
    }

    // Pinned lead under their own heading, then a band, then the rest.
    final pinnedCount =
        _filter == _Filter.all ? visible.where((b) => b.pinned).length : 0;
    final grouped = pinnedCount > 0 && pinnedCount < visible.length;
    final rows = <Object>[
      if (grouped) _Heading(l10n.pinned),
      for (var i = 0; i < visible.length; i++) ...[
        if (grouped && i == pinnedCount) const _Band(),
        visible[i],
      ],
    ];
    return [
      SliverList.builder(
        itemCount: rows.length,
        itemBuilder: (context, i) {
          final row = rows[i];
          if (row is _Heading) return row;
          if (row is _Band) return row;
          final entry = row as FCBookmark;
          final next = i + 1 < rows.length ? rows[i + 1] : null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BookmarkTile(
                key: ValueKey('bookmark-${entry.id}'),
                siteContext: widget.siteContext,
                bookmark: entry,
                onTap: () => _open(entry),
                onEditLabel: () => _editLabel(entry),
                onEditReminder: () => _editReminder(entry),
                onClearReminder: entry.reminderAt != null
                    ? () => _update(entry, reminderAt: null, name: entry.name)
                    : null,
                onTogglePin: () => _togglePin(entry),
                onRemove: () => _remove(entry),
              ),
              if (next is FCBookmark)
                Divider(
                  height: 1,
                  indent: 72,
                  color: colorScheme.outlineVariant,
                ),
            ],
          );
        },
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingL),
          child: _hasMore && _isLoading
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink(),
        ),
      ),
    ];
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
            DesignTokens.spacingM, DesignTokens.spacingL, 0),
        child: Semantics(
          header: true,
          child: Row(
            children: [
              Icon(Icons.push_pin_outlined,
                  size: DesignTokens.iconSizeS,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: DesignTokens.spacingXS),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
}

/// The band the topic page sets between sections.
class _Band extends StatelessWidget {
  const _Band();

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: const SizedBox(height: DesignTokens.spacingS, width: double.infinity),
      );
}

class _BookmarkTile extends StatelessWidget {
  final SiteContext siteContext;
  final FCBookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onEditLabel;
  final VoidCallback onEditReminder;
  final VoidCallback? onClearReminder;
  final VoidCallback onTogglePin;
  final VoidCallback onRemove;

  const _BookmarkTile({
    super.key,
    required this.siteContext,
    required this.bookmark,
    required this.onTap,
    required this.onEditLabel,
    required this.onEditReminder,
    this.onClearReminder,
    required this.onTogglePin,
    required this.onRemove,
  });

  /// When the reminder fires, in words: "Today, 8:00 PM", "Tomorrow, …",
  /// a weekday within the week, else the date; "Due · …" once it has
  /// fired and not been cleared.
  static String reminderLabel(
      BuildContext context, AppLocalizations l10n, DateTime at) {
    final locale = Localizations.localeOf(context).toString();
    final local = at.toLocal();
    final now = DateTime.now();
    final time = DateFormat.jm(locale).format(local);
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    final days = day.difference(today).inDays;
    if (local.isBefore(now)) {
      final when = days == 0
          ? time
          : '${DateFormat.E(locale).format(local)} $time';
      return l10n.reminderDue(when);
    }
    if (days == 0) return l10n.reminderToday(time);
    if (days == 1) return l10n.reminderTomorrow(time);
    if (days < 7) return '${DateFormat.EEEE(locale).format(local)}, $time';
    return '${DateFormat.MMMd(locale).format(local)}, $time';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final username = bookmark.username ?? '';
    final title = (bookmark.title?.isNotEmpty ?? false)
        ? withEmojiShortcodes(bookmark.title!)
        : '—';
    final details =
        DiscourseBookmarkDetails.forBookmark(siteContext.site.url, bookmark.id);
    final label = (bookmark.name ?? '').trim();
    final reminder = bookmark.reminderAt;
    final due = reminder != null && reminder.isBefore(DateTime.now());
    final isPost = bookmark.bookmarkableType == 'Post';
    final meta = [
      if (!isPost)
        l10n.bookmarkWholeTopic
      else ...[
        if (username.isNotEmpty) '@$username',
        if ((bookmark.postNumber ?? 0) > 1)
          l10n.bookmarkPostNumber(bookmark.postNumber!),
      ],
      if (bookmark.createdAt != null)
        l10n.bookmarkSaved(formatTimeAgo(bookmark.createdAt!, context)),
    ].join(' · ');

    Widget chip(IconData icon, String text, Color bg, Color fg) => Container(
          padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingS, vertical: 2),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(DesignTokens.radiusS),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: DesignTokens.iconSizeXS + 2, color: fg),
              const SizedBox(width: DesignTokens.spacingXS),
              Flexible(
                child: Text(text,
                    style: textTheme.labelMedium?.copyWith(color: fg),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        );

    return Dismissible(
      key: ValueKey('dismiss-${bookmark.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        color: colorScheme.errorContainer,
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingXL),
        child: Icon(Icons.bookmark_remove_outlined,
            color: colorScheme.onErrorContainer),
      ),
      child: Material(
        color: colorScheme.surface,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
                DesignTokens.spacingM, DesignTokens.spacingXS, DesignTokens.spacingM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserAvatar(
                  username: username,
                  iconUrl: bookmark.avatarUrl,
                  radius: DesignTokens.avatarRadiusM,
                ),
                const SizedBox(width: DesignTokens.spacingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((details?.categoryId != null) ||
                          (details?.tags.isNotEmpty ?? false))
                        TopicTaxonomyChips(
                          siteContext: siteContext,
                          categoryId: details?.categoryId?.toString() ?? '',
                          tags: details?.tags ?? const [],
                          maxTags: 3,
                          padding: const EdgeInsets.only(
                              top: DesignTokens.spacingXS),
                        ),
                      if (label.isNotEmpty || reminder != null)
                        Padding(
                          padding:
                              const EdgeInsets.only(top: DesignTokens.spacingS),
                          child: Wrap(
                            spacing: DesignTokens.spacingS,
                            runSpacing: DesignTokens.spacingXS,
                            children: [
                              if (label.isNotEmpty)
                                chip(Icons.label_outline, label,
                                    colorScheme.tertiaryContainer,
                                    colorScheme.onTertiaryContainer),
                              if (reminder != null)
                                chip(
                                  Icons.alarm,
                                  reminderLabel(context, l10n, reminder),
                                  due
                                      ? colorScheme.errorContainer
                                      : colorScheme.secondaryContainer,
                                  due
                                      ? colorScheme.onErrorContainer
                                      : colorScheme.onSecondaryContainer,
                                ),
                            ],
                          ),
                        ),
                      if ((bookmark.excerpt ?? '').trim().isNotEmpty)
                        QuotedExcerpt(text: bookmark.excerpt!.trim(), maxLines: 2),
                      if (meta.isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsets.only(top: DesignTokens.spacingS),
                          child: Text(
                            meta,
                            style: textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert,
                          color: colorScheme.onSurfaceVariant),
                      tooltip: MaterialLocalizations.of(context)
                          .showMenuTooltip,
                      onSelected: (value) {
                        switch (value) {
                          case 'label':
                            onEditLabel();
                          case 'reminder':
                            onEditReminder();
                          case 'clear_reminder':
                            onClearReminder?.call();
                          case 'pin':
                            onTogglePin();
                          case 'remove':
                            onRemove();
                        }
                      },
                      itemBuilder: (context) => [
                        _item('label', Icons.label_outline,
                            label.isEmpty ? l10n.addBookmarkLabel : l10n.editBookmarkLabel,
                            colorScheme.onSurfaceVariant),
                        _item('reminder', Icons.alarm,
                            reminder != null ? l10n.editReminder : l10n.addReminder,
                            colorScheme.onSurfaceVariant),
                        if (onClearReminder != null)
                          _item('clear_reminder', Icons.alarm_off,
                              l10n.clearReminder, colorScheme.onSurfaceVariant),
                        _item(
                            'pin',
                            bookmark.pinned
                                ? Icons.push_pin
                                : Icons.push_pin_outlined,
                            bookmark.pinned ? l10n.unpinBookmark : l10n.pinBookmark,
                            colorScheme.onSurfaceVariant),
                        _item('remove', Icons.bookmark_remove_outlined,
                            l10n.removeBookmark, colorScheme.error),
                      ],
                    ),
                    if (bookmark.pinned)
                      Icon(Icons.push_pin,
                          size: DesignTokens.iconSizeS,
                          color: colorScheme.primary,
                          semanticLabel: l10n.pinned),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _item(
          String value, IconData icon, String text, Color color) =>
      PopupMenuItem<String>(
        value: value,
        child: Row(children: [
          Icon(icon, color: color),
          const SizedBox(width: DesignTokens.spacingM),
          Text(text),
        ]),
      );
}
