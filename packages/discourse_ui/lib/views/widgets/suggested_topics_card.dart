import 'package:discourse_core/discourse_core.dart'
    show
        DiscourseMessageDetails,
        DiscourseMoreTopics,
        DiscourseSiteCapabilities,
        DiscourseTopicProxy;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../services/discourse_link_handler.dart';
import '../../theme/design_tokens.dart';
import '../forum_topics_page.dart';
import '../listitems/topic_list_item.dart';
import '../post_page.dart';
import 'category_badge.dart';

/// What to read next, under a topic's last post: Discourse's suggested
/// topics and, where the forum has them (discourse-ai), its related ones —
/// the web's `more-topics` footer.
///
/// * Set off from the posts by the same band that closes the opening post,
///   so a band on the topic page always means "a new section starts".
/// * With both lists, the heading is a Related | Suggested choice, as web's
///   pills; the choice is remembered for the session.
/// * The rows are the topic lists' own ([TopicListItem]), so a suggested
///   topic reads as it does in Latest: last poster, category and tags,
///   counts, unread state.
/// * Ends as web's "browse more" line does: more from this topic's
///   category, or the latest topics (a message: the inbox).
///
/// Both lists come from the topic load that opened the page — see
/// [DiscourseMoreTopics]; nothing is fetched again.
class SuggestedTopicsCard extends StatefulWidget {
  final SiteContext siteContext;
  final String topicId;

  /// The topic's category, for "More in …". Empty when unknown.
  final String categoryId;

  /// The band above the section. Off when the opening post is also the
  /// last, as it already ends with one.
  final bool showTopBand;

  const SuggestedTopicsCard({
    super.key,
    required this.siteContext,
    required this.topicId,
    this.categoryId = '',
    this.showTopBand = true,
  });

  @override
  State<SuggestedTopicsCard> createState() => _SuggestedTopicsCardState();
}

enum _MoreList { related, suggested }

class _SuggestedTopicsCardState extends State<SuggestedTopicsCard> {
  /// The reader's pick between the two lists, for the session (web keeps
  /// it in its key-value store).
  static _MoreList? _preferred;

  DiscourseMoreTopics? _more;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant SuggestedTopicsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topicId != widget.topicId) _load();
  }

  Future<void> _load() async {
    DiscourseTopicProxy? proxy;
    try {
      final p = SiteProxyFactory.getTopicProxy();
      if (p is DiscourseTopicProxy) proxy = p;
    } catch (_) {
      // No forum registered: nothing to suggest.
    }
    if (proxy == null) {
      setState(() => _more = const DiscourseMoreTopics());
      return;
    }
    final more = await proxy.getMoreTopicsAsync(widget.topicId);
    if (!mounted) return;
    setState(() => _more = more);
  }

  bool get _isMessage => DiscourseMessageDetails.isMessage(widget.topicId);

  void _open(FCTopic topic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostPage(
          siteContext: widget.siteContext,
          topicId: topic.id,
          title: topic.title,
          forumId: topic.forumId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final more = _more;
    // Nothing while loading: the lists are already in memory, and a
    // spinner at the end of the page would flash for a frame.
    if (more == null || more.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final both = more.related.isNotEmpty && more.suggested.isNotEmpty;
    final list = both
        ? (_preferred ?? _MoreList.related)
        : (more.related.isNotEmpty ? _MoreList.related : _MoreList.suggested);
    final topics = list == _MoreList.related ? more.related : more.suggested;
    String title(_MoreList l) => switch ((l, _isMessage)) {
          (_MoreList.related, false) => l10n.relatedTopics,
          (_MoreList.related, true) => l10n.relatedMessages,
          (_MoreList.suggested, false) => l10n.suggestedTopics,
          (_MoreList.suggested, true) => l10n.suggestedMessages,
        };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showTopBand)
          ColoredBox(
            color: colorScheme.surfaceContainer,
            child: const SizedBox(height: DesignTokens.spacingS),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
              DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingXS),
          child: both
              ? Wrap(
                  spacing: DesignTokens.spacingS,
                  runSpacing: DesignTokens.spacingS,
                  children: [
                    for (final l in _MoreList.values)
                      ChoiceChip(
                        label: Text(title(l)),
                        selected: l == list,
                        onSelected: (_) => setState(() => _preferred = l),
                      ),
                  ],
                )
              : Semantics(
                  header: true,
                  child: Text(
                    title(list),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: DesignTokens.fontWeightMedium,
                        ),
                  ),
                ),
        ),
        // Each row draws its own inset rule, as in every topic list.
        for (final topic in topics)
          TopicListItem(
            key: ValueKey('more-${list.name}-${topic.id}'),
            siteContext: widget.siteContext,
            topic: topic,
            // A message's suggestions are other messages: no categories,
            // as web hides them there.
            showCategory: !_isMessage,
            onTap: () => _open(topic),
          ),
        _browseMore(context),
      ],
    );
  }

  /// Web's "Want to read more? Browse other topics in {category} or view
  /// latest topics" — as the two places it names.
  Widget _browseMore(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final forumUrl = widget.siteContext.site.url;
    void follow(String path) =>
        DiscourseLinkHandler.open(context, widget.siteContext, '$forumUrl$path');

    final buttons = <Widget>[];
    if (_isMessage) {
      buttons.add(OutlinedButton.icon(
        onPressed: () => follow('/my/messages'),
        icon: const Icon(Icons.mail_outline, size: DesignTokens.iconSizeS),
        label: Text(l10n.messages),
      ));
    } else {
      final categoryId = widget.categoryId;
      if (categoryId.isNotEmpty &&
          CategoryBadge.shows(widget.siteContext, categoryId)) {
        final caps =
            DiscourseSiteCapabilities.forSite(widget.siteContext.site.pluginUrl);
        final style = caps.categoryStyleFor(categoryId);
        final parentId = style?.parentId;
        buttons.add(FilledButton.tonalIcon(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ForumTopicsPage(
              siteContext: widget.siteContext,
              forum: categoryForum(widget.siteContext, categoryId),
            ),
          )),
          icon: CategoryMark(
            style: style,
            parent: parentId == null ? null : caps.categoryStyleFor('$parentId'),
          ),
          label: Text(l10n.moreInCategory(style?.name ?? '')),
        ));
      }
      buttons.add(OutlinedButton(
        onPressed: () => follow('/latest'),
        child: Text(l10n.latestTopics),
      ));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
          DesignTokens.spacingS, DesignTokens.spacingL, DesignTokens.spacingL),
      child: Wrap(
        spacing: DesignTokens.spacingS,
        runSpacing: DesignTokens.spacingS,
        children: buttons,
      ),
    );
  }
}
