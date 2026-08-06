import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_attachment.dart';
import 'package:forumcopilot_sdk/models/entities/fc_forum.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post_vote.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post_reaction.dart';
import '../widgets/custom_bb_stylesheet.dart' show BBCodeCallbacks;
import '../widgets/rich_text_content.dart';
import '../widgets/reaction_chips_row.dart';
import '../widgets/reaction_picker_sheet.dart';
import '../widgets/reaction_users_sheet.dart';
import '../widgets/post_action_button.dart';
import '../widgets/post_vote_column.dart';
import '../widgets/link_preview_card.dart';
import '../widgets/video_card.dart';
import '../widgets/twitter_card.dart';
import '../../l10n/generated/app_localizations.dart';
import '../widgets/post_actions.dart';
import '../widgets/thread_poll_card.dart';
import '../../controllers/post_controller.dart';
import 'package:forumcopilot_sdk/models/entities/fc_poll.dart';
import '../../utils/bbcode_processor.dart';
import '../../utils/url_utils.dart';
import '../../utils/file_utils.dart';
import '../../theme/design_tokens.dart';
import '../../theme/style_builders.dart';
import 'post_list_item_header.dart';
import 'post_list_item_attachment.dart';
import 'post_list_item_social.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';
import '../user_profile_page.dart';
import '../forum_topics_page.dart';
import 'package:get/get.dart';
import 'package:forumcopilot_sdk/models/entities/fc_bookmark.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseBookmarkProxy, DiscourseBookmarkAutoDelete;
import '../widgets/bookmark_reminder_sheet.dart';
import '../../controllers/login_controller.dart';
import '../login_page.dart';
import '../post_page.dart';
import '../lists/posts_list.dart';
import '../../services/site_proxy_service.dart';

class _PostContentData {
  final String processedText;
  final List<String> limitedUrls;
  final List<String> limitedYoutubeUrls;
  final List<String> limitedTwitterUrls;
  final List<FCAttachment> attachments;
  final List<FCAttachment> filteredInlineAttachments;
  _PostContentData({
    required this.processedText,
    required this.limitedUrls,
    required this.limitedYoutubeUrls,
    required this.limitedTwitterUrls,
    required this.attachments,
    required this.filteredInlineAttachments,
  });
}

/// Callback class for post-related actions
class PostActions {
  /// Called when replying to a post
  final Future<void> Function(String postId)? onReply;

  /// Called when quoting a post
  final Future<void> Function(
      String postId, String authorName, String postText)? onQuote;

  /// Called when editing a post
  final Future<void> Function(String postId, String currentText)? onEdit;

  /// Called when deleting a post
  final Future<void> Function(String postId)? onDelete;

  /// Called when reporting a post
  final Future<void> Function(String postId)? onReport;

  /// Called when viewing a post's Discourse edit history
  final Future<void> Function(String postId)? onViewHistory;

  /// Called when toggling a post's Discourse wiki status
  /// (`wiki` = the desired new state)
  final Future<void> Function(String postId, bool wiki)? onToggleWiki;

  /// Called when viewing an image in the post
  final Function(String imageUrl, BuildContext context, String heroTag)?
      onShowImage;

  /// Called when the post needs to be refreshed
  final VoidCallback? onRefresh;

  /// Called when login is required for restricted attachments
  final Function(BuildContext context)? onLoginRequired;

  const PostActions({
    this.onReply,
    this.onQuote,
    this.onEdit,
    this.onDelete,
    this.onReport,
    this.onViewHistory,
    this.onToggleWiki,
    this.onShowImage,
    this.onRefresh,
    this.onLoginRequired,
  });
}

/// Widget para representar un ítem de la lista de foros
class PostListItem extends StatefulWidget {
  final SiteContext siteContext;
  final FCPost post;
  final String threadId;
  final String? forumId;
  final String topicTitle;
  final PostActions? actions;
  final void Function(String userId, String userName)? onAvatarTap;
  final PostController postController;
  final bool isHighlighted;

  /// Poll for the thread. When non-null and this is the first post, the poll card is shown above the body.
  final FCPoll? poll;

  /// Called after a successful vote to update the thread's poll in state.
  final void Function(FCPoll updatedPoll)? onVoteSuccess;

  /// Optional translated content to display instead of original post content.
  /// When provided, the post will show translated text with a visual indicator.
  final String? translatedContent;

  /// Whether translation is currently in progress for this thread.
  final bool isTranslating;

  const PostListItem({
    super.key,
    required this.siteContext,
    required this.post,
    required this.threadId,
    required this.topicTitle,
    required this.postController,
    this.forumId,
    this.actions,
    this.onAvatarTap,
    this.isHighlighted = false,
    this.poll,
    this.onVoteSuccess,
    this.translatedContent,
    this.isTranslating = false,
  });

  @override
  _PostListItemState createState() => _PostListItemState();
}

class _PostListItemState extends State<PostListItem> {
  // Local state for like + bookmark
  late bool _isLiked;
  late bool _isBookmarked;
  bool _bookmarkInFlight = false;
  late final PostController _postsController;
  late int _likeCount; // Add local state for like count
  late final PostActionsHandler _postActionsHandler;

  // discourse-reactions local copy. Mirrors widget.post.reactions at
  // parse time; mutated locally on toggle so the chips row updates
  // without a full thread refetch. Phase 5.36 — lifted from a
  // DiscoursePostProxy Expando sidecar to a proper FCPost field.
  late List<FCPostReaction> _reactions;

  // discourse-post-voting local copy. Null when voting isn't enabled
  // on this topic, in which case the vote column is hidden.
  FCPostVote? _vote;

  @override
  void initState() {
    super.initState();
    _postsController = widget.postController;
    _postActionsHandler =
        PostActionsHandler(_postsController, widget.siteContext);
    // Set the default refresh callback for attachment login prompts
    _postActionsHandler.setDefaultRefreshCallback(widget.actions?.onRefresh);
    _isLiked = widget.post.isLiked;
    // `likesInfo` is intentionally empty (the proxy no longer pads it
    // with placeholder actors) — `likeCount` is the count of record.
    _likeCount = widget.post.likeCount;
    _isBookmarked = widget.post.bookmarked;
    _reactions = List.of(widget.post.reactions, growable: false);
    _vote = widget.post.vote;
  }

  @override
  void didUpdateWidget(PostListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keyed items survive a refresh, so the state copied in initState goes
    // stale when the parent hands us a fresh FCPost. Re-sync whenever the
    // post instance changes (same-instance rebuilds keep local mutations).
    if (!identical(oldWidget.post, widget.post)) {
      _isLiked = widget.post.isLiked;
      _likeCount = widget.post.likeCount;
      // Don't clobber an in-flight optimistic bookmark toggle.
      if (!_bookmarkInFlight) {
        _isBookmarked = widget.post.bookmarked;
      }
      _reactions = List.of(widget.post.reactions, growable: false);
      _vote = widget.post.vote;
    }
  }

  /// Checks if a URL is a mention link (link text starts with @ and has no spaces)
  bool _isMentionUrl(String? linkText) {
    if (linkText == null || linkText.isEmpty) return false;
    final trimmed = linkText.trim();
    // Check if it starts with @ and has no spaces
    return trimmed.startsWith('@') && !trimmed.contains(' ');
  }

  /// Returns the username when [url] is a same-forum `/u/{username}` (or
  /// `/users/{username}`) profile link — i.e. a genuine Discourse mention
  /// target. Returns null for everything else (mailto:, external hosts like
  /// medium.com/@author, deeper user sub-paths, ...).
  String? _mentionUsernameFromUrl(String url) {
    try {
      final uri = Uri.parse(url.trim());
      if (uri.scheme.isNotEmpty &&
          uri.scheme != 'http' &&
          uri.scheme != 'https') {
        return null; // mailto:, tel:, ...
      }
      if (uri.hasAuthority) {
        final forumHost = Uri.parse(widget.siteContext.site.url).host;
        if (uri.host != forumHost) return null;
      }
      final match =
          RegExp(r'^/u(?:sers)?/([^/?#]+)/?$').firstMatch(uri.path);
      return match?.group(1);
    } catch (_) {
      return null;
    }
  }

  _PostContentData _extractPostContentData() {
    // Use translated content if available, otherwise use original
    final originalText = widget.translatedContent ?? widget.post.content;
    String processedText = BBCodeProcessor.processText(originalText,
            siteContext: widget.siteContext)
        .trimRight();
    final urls = <String>{};
    final youtubeUrls = <String>{};
    final twitterUrls = <String>{};
    final inlineTwitterUrls = <String>{};
    final inlineYoutubeUrls = <String>{};

    // First, extract URLs from the original text before processing
    final originalPlainUrls = BBCodeProcessor.findPlainUrls(originalText);
    for (final match in originalPlainUrls) {
      final url = originalText.substring(match.start, match.end);
      if (url.toLowerCase().startsWith('mailto:')) continue;
      if (BBCodeProcessor.isYoutubeUrl(url)) {
        youtubeUrls.add(url);
      } else if (BBCodeProcessor.isTwitterUrl(url)) {
        twitterUrls.add(url);
      } else {
        urls.add(url);
      }
    }

    // Then extract from BBCode tags in processed text
    // Inline YouTube
    final youtubeTagRegex =
        RegExp(r'\[youtube\](.*?)\[/youtube\]', caseSensitive: false);
    for (final match in youtubeTagRegex.allMatches(processedText)) {
      final url = match.group(1)!;
      inlineYoutubeUrls.add(url);
      // Remove from youtubeUrls if it's there (to avoid duplicates)
      youtubeUrls.remove(url);
    }
    // Inline Twitter
    final twitterTagRegex =
        RegExp(r'\[twitter\](.*?)\[/twitter\]', caseSensitive: false);
    for (final match in twitterTagRegex.allMatches(processedText)) {
      final url = match.group(1)!;
      inlineTwitterUrls.add(url);
      // Remove from twitterUrls if it's there (to avoid duplicates)
      twitterUrls.remove(url);
    }
    // [url] tags
    final bbCodeRegex =
        RegExp(r'\[url(?:=([^\]]+))?\](.*?)\[/url\]', caseSensitive: false);
    for (final match in bbCodeRegex.allMatches(processedText)) {
      final url = match.group(1) ?? match.group(2)!;
      final linkText = match.group(2); // The visible text inside [url]...[/url]

      // Skip mention URLs (link text starts with @ and has no spaces)
      if (_isMentionUrl(linkText)) {
        AppLogger.debug(
            'PostListItem: Skipping mention URL from preview: url=$url, linkText=$linkText');
        continue;
      }

      if (url.toLowerCase().startsWith('mailto:')) continue;
      if (match.group(1) != null && match.group(1) != match.group(2)) continue;
      if (inlineYoutubeUrls.contains(url) || inlineTwitterUrls.contains(url))
        continue;
      if (BBCodeProcessor.isYoutubeUrl(url)) {
        youtubeUrls.add(url);
      } else if (BBCodeProcessor.isTwitterUrl(url)) {
        twitterUrls.add(url);
      } else {
        urls.add(url);
      }
    }

    // Inline attachments
    final inlineAttachmentResult =
        BBCodeProcessor.replaceInlineAttachmentUrlsAndFilter(
      processedText,
      widget.post.inlineAttachments,
    );
    processedText = inlineAttachmentResult.text;
    final filteredInlineAttachments =
        inlineAttachmentResult.remainingInlineAttachments;
    // Limit
    final limitedUrls = urls.take(10).toList();
    final limitedYoutubeUrls = youtubeUrls.take(10).toList();
    final limitedTwitterUrls = twitterUrls.take(10).toList();
    // Filter out attachments that are already displayed inline
    // The isInline flag is set by the backend to indicate the attachment is embedded inline in the post content
    final nonInlineAttachments = widget.post.attachments.where((att) {
      // Check if attachment has isInline property - now directly accessible from the model
      final isInline = att.isInline ?? false;
      // Return true if NOT inline (i.e., should be shown in attachment list)
      return !isInline;
    }).toList();

    return _PostContentData(
      processedText: processedText,
      limitedUrls: limitedUrls,
      limitedYoutubeUrls: limitedYoutubeUrls,
      limitedTwitterUrls: limitedTwitterUrls,
      attachments: nonInlineAttachments,
      filteredInlineAttachments: filteredInlineAttachments,
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    return PostListItemHeader(
      siteContext: widget.siteContext,
      post: widget.post,
      onAvatarTap: widget.onAvatarTap,
      onMenuSelected: _onMenuSelected,
      buildPopupMenuItems: _buildPopupMenuItems,
      context: context,
      postActionsHandler: _postActionsHandler,
      onRefresh: widget.actions?.onRefresh,
    );
  }

  Widget _buildPostContent(BuildContext context, _PostContentData data,
      ColorScheme colorScheme, TextTheme textTheme) {
    final callbacks = BBCodeCallbacks(
      onUrlTap: (url) {
        AppLogger.debug('BBCode URL tapped: $url');
        // Only treat the link as a mention when it is a genuine same-forum
        // /u/{username} profile URL. (A bare `@(\w+)` match on the whole URL
        // would hijack mailto: links, medium.com/@author, etc. Mention-class
        // anchors are already routed to onMentionTap by RichTextContent.)
        final mentionUsername = _mentionUsernameFromUrl(url);
        if (mentionUsername != null && mentionUsername.isNotEmpty) {
          AppLogger.debug(
              'PostListItem: same-forum profile link, username: $mentionUsername');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfilePage(
                siteContext: widget.siteContext,
                userName: mentionUsername,
              ),
            ),
          );
          return;
        }
        final cleanUrl = url.trim().replaceAll('"', '');
        final site = widget.siteContext.site;
        final forumUrl = site.pluginUrl;
        final forumType = widget.siteContext.ConfigData.forumType;
        UrlUtils.handleUrlTapWithForumDetection(
          widget.siteContext,
          cleanUrl,
          context,
          forumUrl: forumUrl,
          forumType: forumType,
          onForumNavigation: (topicId, postId, forumId) {
            Future.microtask(() async {
              if (!mounted) return;
              if (!widget.siteContext.isLoggedIn) {
                if (!Get.isRegistered<DiscourseLoginController>()) {
                  Get.put(DiscourseLoginController());
                }
                final loginController = Get.find<DiscourseLoginController>();
                final loginResult = await loginController
                    .attemptAutomaticLogin(widget.siteContext);
                if (!loginResult.success &&
                    loginResult.hadCredentials &&
                    Get.currentRoute != '/LoginPage') {
                  await Get.to(
                      () => LoginPage(siteContext: widget.siteContext));
                }
                if (!widget.siteContext.isLoggedIn) {
                  AppLogger.debug(
                      'PostListItem: proceeding to thread as guest after login screen');
                }
              }
              if (postId != null) {
                final String effectiveTopicId =
                    topicId.isNotEmpty ? topicId : postId;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostPage(
                      siteContext: widget.siteContext,
                      topicId: effectiveTopicId,
                      title: '',
                      mode: PostsListMode.thread_by_post,
                      anchorPostId: postId,
                      forumId: forumId,
                    ),
                  ),
                );
              } else if (topicId.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostPage(
                      siteContext: widget.siteContext,
                      topicId: topicId,
                      title: '',
                      mode: PostsListMode.normal,
                      forumId: forumId,
                    ),
                  ),
                );
              } else if (forumId != null && forumId.isNotEmpty) {
                // Category link (Discourse /c/{slug}/{id}) — open the
                // category's topic list. ForumTopicsPage only needs the id.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForumTopicsPage(
                      siteContext: widget.siteContext,
                      forum: FCForum(id: forumId, name: ''),
                    ),
                  ),
                );
              }
            });
          },
        );
      },
      onImageTap: (String imageUrl, BuildContext context, String heroTag) {
        if (widget.actions?.onShowImage != null) {
          widget.actions!.onShowImage!(imageUrl, context, heroTag);
        } else {
          AppLogger.debug('No onShowImage action defined');
        }
      },
      onMentionTap: (username) {
        AppLogger.debug('BBCode Mention tapped: $username');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfilePage(
              siteContext: widget.siteContext,
              userName: username,
            ),
          ),
        );
      },
    );
    // Check if attachments/images are the last items - if so, reduce bottom padding
    // to avoid excessive white space between images and social buttons
    // Attachments and filteredInlineAttachments always come last (after text, videos, links)
    final bool hasAttachments = data.attachments.isNotEmpty ||
        data.filteredInlineAttachments.isNotEmpty;
    // Check if attachments are all images (using same logic as PostListItemAttachment)
    final bool allAttachmentsAreImages = hasAttachments &&
        (data.attachments.isEmpty ||
            data.attachments.every((att) => isImageFile(att.filename))) &&
        (data.filteredInlineAttachments.isEmpty ||
            data.filteredInlineAttachments
                .every((att) => isImageFile(att.filename)));
    // Reduce bottom padding when images are the last items since PostListItemSocial
    // already adds spacingM (12px) before the social buttons
    final double bottomPadding = allAttachmentsAreImages
        ? DesignTokens.spacingM
        : DesignTokens.spacingXL;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          DesignTokens.spacingL, 0.0, DesignTokens.spacingL, bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // discourse-post-voting vertical arrows. Only renders on
          // posts in Q&A-style topics where the plugin populated
          // post_voting_* fields on the JSON.
          if (_vote != null) ...[
            Padding(
              padding: EdgeInsets.only(bottom: DesignTokens.spacingS),
              child: Align(
                alignment: Alignment.centerLeft,
                child: PostVoteColumn(
                  postId: widget.post.id,
                  vote: _vote!,
                  isLoggedIn: widget.siteContext.isLoggedIn,
                  onVoteChanged: (next) {
                    setState(() {
                      _vote = next;
                      widget.post.vote = next;
                    });
                  },
                ),
              ),
            ),
          ],
          // Discourse "solved" banner: shown on the post that was
          // marked as the accepted answer for this topic.
          if (widget.post.isSolution) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingS,
                vertical: DesignTokens.spacingXS,
              ),
              margin: EdgeInsets.only(bottom: DesignTokens.spacingS),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.45),
                  width: 0.75,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade700,
                    size: DesignTokens.iconSizeS,
                  ),
                  const SizedBox(width: DesignTokens.spacingXS),
                  Text(
                    'Solution',
                    style: textTheme.labelMedium?.copyWith(
                      color: Colors.green.shade800,
                      fontWeight: DesignTokens.fontWeightBold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Show topic title for the first post (topic starter)
          if (widget.post.postNumber == 1 && widget.topicTitle.isNotEmpty) ...[
            Text(
              widget.topicTitle,
              style: StyleBuilders.titleTextStyle(
                colorScheme: colorScheme,
                textTheme: textTheme,
                fontSize: DesignTokens.fontSizeTopicTitle,
                fontWeight: DesignTokens.fontWeightBold,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingM),
          ],
          // Poll card (first post only): below the title, above body. onVoteSuccess updates
          // the thread's poll in PostController so the UI reflects the new vote without reloading.
          if (widget.post.postNumber == 1 &&
              widget.poll != null &&
              widget.onVoteSuccess != null) ...[
            ThreadPollCard(
              poll: widget.poll!,
              topicId: widget.threadId,
              siteContext: widget.siteContext,
              onVoteSuccess: widget.onVoteSuccess!,
            ),
            const SizedBox(height: DesignTokens.spacingM),
          ],
          // Translation indicator badge - show "Translating..." or "Translated"
          if (widget.isTranslating || widget.translatedContent != null) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingS,
                vertical: DesignTokens.spacingXS / 2,
              ),
              margin: EdgeInsets.only(bottom: DesignTokens.spacingS),
              decoration: BoxDecoration(
                color: widget.isTranslating && widget.translatedContent == null
                    ? colorScheme.secondaryContainer.withValues(alpha: 0.5)
                    : colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isTranslating &&
                      widget.translatedContent == null) ...[
                    SizedBox(
                      width: DesignTokens.iconSizeXS,
                      height: DesignTokens.iconSizeXS,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.translate_rounded,
                      size: DesignTokens.iconSizeXS,
                      color: colorScheme.primary,
                    ),
                  ],
                  const SizedBox(width: DesignTokens.spacingXS),
                  Text(
                    widget.isTranslating && widget.translatedContent == null
                        ? (AppLocalizations.of(context)?.translating ??
                            'Translating...')
                        : (AppLocalizations.of(context)?.translated ??
                            'Translated'),
                    style: textTheme.labelSmall?.copyWith(
                      color: widget.isTranslating &&
                              widget.translatedContent == null
                          ? colorScheme.secondary
                          : colorScheme.primary,
                      fontWeight: DesignTokens.fontWeightMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Discourse posts arrive as server-rendered HTML in the
          // `cooked` field, so we render it directly with flutter_html
          // via RichTextContent — the BBCode pipeline is XF-only.
          RichTextContent(
            siteContext: widget.siteContext,
            content: widget.translatedContent ?? widget.post.content,
            callbacks: callbacks,
          ),
          // Reaction chips — the single like/reaction surface. On
          // plugin-less forums the proxy synthesizes one heart entry
          // here, so a plain like renders as a chip too. Tap toggles,
          // long-press lists the real reactors, trailing "+" opens the
          // full picker. Hidden only in the zero state, where the
          // heart button in the action row takes over.
          if (_reactions.isNotEmpty)
            ReactionChipsRow(
              reactions: _reactions,
              onTap: _toggleReaction,
              onLongPress: _showReactionUsers,
              onAddReaction: widget.siteContext.isLoggedIn
                  ? _openReactionPicker
                  : null,
            ),
          if (data.limitedYoutubeUrls.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spacingM),
            StyleBuilders.divider(colorScheme: colorScheme),
            const SizedBox(height: DesignTokens.spacingS),
            ...data.limitedYoutubeUrls.map((url) => VideoCard(url: url)),
          ],
          if (data.limitedTwitterUrls.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spacingM),
            StyleBuilders.divider(colorScheme: colorScheme),
            const SizedBox(height: DesignTokens.spacingS),
            ...data.limitedTwitterUrls.map((url) => TwitterCard(url: url)),
          ],
          if (data.limitedUrls.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spacingM),
            StyleBuilders.divider(colorScheme: colorScheme),
            const SizedBox(height: DesignTokens.spacingS),
            ...data.limitedUrls
                .where((url) =>
                    !BBCodeProcessor.isEmail(url) &&
                    !BBCodeProcessor.isYoutubeUrl(url) &&
                    !BBCodeProcessor.isTwitterUrl(url) &&
                    !UrlUtils.isSameDomain(widget.siteContext, url))
                .map((url) =>
                    LinkPreviewCard(url: url, siteContext: widget.siteContext)),
          ],
          if (data.attachments.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spacingS),
            PostListItemAttachment(
              attachments: data.attachments,
              actions: widget.actions,
              context: context,
              isInline: false,
              title: AppLocalizations.of(context)?.attachments ?? 'Attachments',
            ),
          ],
          if (data.filteredInlineAttachments.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spacingS),
            PostListItemAttachment(
              attachments: data.filteredInlineAttachments,
              actions: widget.actions,
              context: context,
            ),
          ],
          PostListItemSocial(
            post: widget.post,
            isLiked: _isLiked,
            likeCount: _likeCount,
            isLoggedIn: widget.siteContext.isLoggedIn,
            onLike: _handleLikeAction,
            onLongPressLike: _openReactionPicker,
            isBookmarked: _isBookmarked,
            onBookmark: _handleBookmarkAction,
            // Long-press opens the Discourse bookmark-reminder sheet
            // (create with reminder / edit reminder / remove).
            onLongPressBookmark: _handleBookmarkLongPress,
            // Phase 5.31 — discourse-solved accept/unaccept. Gated
            // inside PostListItemSocial on `post.canAcceptAnswer` or
            // `post.isSolution` so the button only renders when
            // meaningful.
            onToggleAcceptAnswer: _handleToggleAcceptAnswer,
            trailing: (widget.siteContext.isLoggedIn &&
                    (_postsController.threadDataOutput.value?.topic.canReply ??
                        false))
                ? _buildReplyButtonWithMenu(context, colorScheme, textTheme)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDivider(ColorScheme colorScheme) {
    return StyleBuilders.divider(
      colorScheme: colorScheme,
      opacity: DesignTokens.opacityLow,
      thickness: 2.0,
      height: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final data = _extractPostContentData();

    // Determine background color based on highlight state
    // Use a more visible highlight color
    final backgroundColor = widget.isHighlighted
        ? colorScheme.primaryContainer.withValues(alpha: 0.4)
        : colorScheme.surface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      color: backgroundColor,
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHeader(context),
            _buildPostContent(context, data, colorScheme, textTheme),
            _buildBottomDivider(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyButtonWithMenu(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    // Phase 5.29 — Reply uses the same PostActionButton recipe as
    // Like and Bookmark so all three buttons share the 48×48 touch
    // target + 22px icon + `opacityMediumLow` inactive tint. Tap
    // opens the Reply / Reply-with-Quote chooser dialog; there's no
    // active state.
    return PostActionButton(
      icon: Icons.reply_rounded,
      semanticLabel:
          AppLocalizations.of(context)?.reply ?? 'Reply',
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              ),
              title: Text(
                AppLocalizations.of(context)?.replyOptions ?? 'Reply Options',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading:
                        Icon(Icons.reply_rounded, color: colorScheme.primary),
                    title: Text(
                      AppLocalizations.of(context)?.reply ?? 'Reply',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _handleReply();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.format_quote_rounded,
                        color: colorScheme.primary),
                    title: Text(
                      AppLocalizations.of(context)?.replyWithQuote ??
                          'Reply with Quote',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _handleQuote();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Handles menu item selection for the post header
  void _onMenuSelected(String value) {
    switch (value) {
      case 'edit':
        _handleEdit();
        break;
      case 'delete':
        _handleDelete();
        break;
      case 'report':
        _handleReport();
        break;
      case 'history':
        _handleViewHistory();
        break;
      case 'make_wiki':
        _handleToggleWiki(true);
        break;
      case 'remove_wiki':
        _handleToggleWiki(false);
        break;
      default:
        break;
    }
  }

  // Builds the popup menu items for the post header
  List<PopupMenuEntry<String>> _buildPopupMenuItems(BuildContext context) {
    final items = <PopupMenuEntry<String>>[];
    if (widget.siteContext.isLoggedIn && widget.post.canEdit) {
      items.add(
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit,
                  size: DesignTokens.iconSizeM,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: DesignTokens.spacingM),
              Text(AppLocalizations.of(context)?.edit ?? 'Edit'),
            ],
          ),
        ),
      );
    }
    if (widget.siteContext.isLoggedIn && widget.post.canDelete) {
      items.add(
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete,
                  size: DesignTokens.iconSizeM,
                  color: Theme.of(context).colorScheme.error),
              const SizedBox(width: DesignTokens.spacingM),
              Text(AppLocalizations.of(context)?.delete ?? 'Delete'),
            ],
          ),
        ),
      );
    }
    if (widget.post.canReport) {
      items.add(
        PopupMenuItem<String>(
          value: 'report',
          child: Row(
            children: [
              Icon(Icons.flag,
                  size: DesignTokens.iconSizeM,
                  color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: DesignTokens.spacingM),
              Text(AppLocalizations.of(context)?.report ?? 'Report'),
            ],
          ),
        ),
      );
    }
    // Discourse wiki toggle — a single direction-aware item driven by
    // FCPost.isWiki (the server still rejects non-staff/TL3 with a
    // clean message).
    if (widget.siteContext.isLoggedIn &&
        widget.post.canEdit &&
        widget.actions?.onToggleWiki != null) {
      final isWiki = widget.post.isWiki;
      items.add(
        PopupMenuItem<String>(
          value: isWiki ? 'remove_wiki' : 'make_wiki',
          child: Row(
            children: [
              Icon(isWiki ? Icons.edit_off : Icons.edit_note,
                  size: DesignTokens.iconSizeM,
                  color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: DesignTokens.spacingM),
              Text(isWiki ? 'Remove wiki' : 'Make wiki'),
            ],
          ),
        ),
      );
    }
    // Edit history — only for posts that were actually edited
    // (FCPost.editVersion > 1; Discourse's `version` starts at 1 and
    // bumps on each public revision).
    if (widget.actions?.onViewHistory != null &&
        (widget.post.editVersion ?? 1) > 1) {
      items.add(
        PopupMenuItem<String>(
          value: 'history',
          child: Row(
            children: [
              Icon(Icons.history,
                  size: DesignTokens.iconSizeM,
                  color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: DesignTokens.spacingM),
              const Text('Edit history'),
            ],
          ),
        ),
      );
    }
    return items;
  }

  void _handleQuote() async {
    if (widget.actions?.onQuote != null) {
      AppLogger.debug('Post Quote action: ${widget.post.id}');
      await widget.actions!.onQuote!(
          widget.post.id, widget.post.authorName, widget.post.content);
    }
  }

  void _handleReply() async {
    AppLogger.debug('Post Reply action: ${widget.post.id}');
    if (widget.actions?.onReply != null) {
      await widget.actions!.onReply!(widget.post.id);
    }
  }

  void _handleEdit() async {
    AppLogger.debug('Post Edit action: ${widget.post.id}');
    if (widget.actions?.onEdit != null) {
      await widget.actions!.onEdit!(widget.post.id, widget.post.content);
    }
  }

  void _handleDelete() async {
    AppLogger.debug('Post Delete action: ${widget.post.id}');
    if (widget.actions?.onDelete != null) {
      await widget.actions!.onDelete!(widget.post.id);
    }
  }

  void _handleReport() async {
    AppLogger.debug('Post Report action: ${widget.post.id}');
    if (widget.actions?.onReport != null) {
      await widget.actions!.onReport!(widget.post.id);
    }
  }

  void _handleViewHistory() async {
    AppLogger.debug('Post View History action: ${widget.post.id}');
    if (widget.actions?.onViewHistory != null) {
      await widget.actions!.onViewHistory!(widget.post.id);
    }
  }

  void _handleToggleWiki(bool wiki) async {
    AppLogger.debug('Post Toggle Wiki action: ${widget.post.id} → $wiki');
    if (widget.actions?.onToggleWiki != null) {
      await widget.actions!.onToggleWiki!(widget.post.id, wiki);
    }
  }

  Future<void> _handleLikeAction() async {
    await _postActionsHandler.handleLike(
      context: context,
      siteContext: widget.siteContext,
      post: widget.post,
      onRefresh: widget.actions?.onRefresh ?? () {},
      setIsLiked: (val) => setState(() => _isLiked = val),
      setLikeCount: (val) => setState(() => _likeCount = val),
      isLiked: _isLiked,
    );
    // A like IS the heart reaction on Discourse (the plugin folds plain
    // likes into `heart`, and the proxy synthesizes the same chip on
    // plugin-less forums). Mirror the new count into the chips row so
    // the zero-state heart button hands off to a chip immediately
    // instead of waiting for a thread refetch.
    _syncHeartChipFromLike();
  }

  /// Toggle bookmark on the current post via IFCBookmarkProxy
  /// (Phase 5.33 — was a DiscoursePostProxy sidecar pre-lift).
  /// Optimistically flips state; reverts on failure.
  void _handleBookmarkAction() async {
    if (_bookmarkInFlight) return;
    final wasBookmarked = _isBookmarked;
    setState(() {
      _isBookmarked = !wasBookmarked;
      _bookmarkInFlight = true;
    });
    final proxy = SiteProxyService.getBookmarkProxy();
    bool ok;
    String? errText;
    try {
      if (wasBookmarked) {
        final result = await proxy.removePostBookmarkAsync(widget.post.id);
        ok = result.result;
        errText = result.resultText;
      } else {
        final result = await proxy.addPostBookmarkAsync(widget.post.id);
        ok = result.result;
        errText = result.resultText;
      }
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    setState(() {
      if (!ok) {
        // Revert on failure.
        _isBookmarked = wasBookmarked;
      } else {
        // Mirror the new value back onto the FCPost so reopening
        // the thread continues to reflect the latest state.
        widget.post.bookmarked = _isBookmarked;
      }
      _bookmarkInFlight = false;
    });
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errText?.isNotEmpty == true
              ? errText!
              : (wasBookmarked
                  ? 'Failed to remove bookmark'
                  : 'Failed to bookmark post')),
        ),
      );
    }
  }

  /// Long-press on the bookmark button: Discourse-native bookmark
  /// reminders. Not bookmarked → "Bookmark with reminder" preset sheet
  /// (create). Already bookmarked → chooser between editing the
  /// reminder and removing the bookmark. Quick tap keeps the plain
  /// toggle in [_handleBookmarkAction].
  Future<void> _handleBookmarkLongPress() async {
    if (!widget.siteContext.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to bookmark')),
      );
      return;
    }
    if (_bookmarkInFlight) return;
    final proxy = SiteProxyService.getBookmarkProxy();
    if (proxy is! DiscourseBookmarkProxy) {
      // Reminders are Discourse-only; fall back to the plain toggle.
      _handleBookmarkAction();
      return;
    }
    if (!_isBookmarked) {
      final choice = await BookmarkReminderSheet.show(context);
      if (choice == null || !mounted) return;
      await _createBookmarkWithReminder(proxy, choice.reminderAt);
      return;
    }
    // Already bookmarked: offer edit-reminder / remove.
    final colorScheme = Theme.of(context).colorScheme;
    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusL)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.alarm, color: colorScheme.primary),
              title: const Text('Edit reminder'),
              onTap: () => Navigator.pop(sheetContext, 'edit'),
            ),
            ListTile(
              leading: Icon(Icons.bookmark_remove_outlined,
                  color: colorScheme.error),
              title: const Text('Remove bookmark'),
              onTap: () => Navigator.pop(sheetContext, 'remove'),
            ),
            const SizedBox(height: DesignTokens.spacingS),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'remove') {
      _handleBookmarkAction(); // existing optimistic un-bookmark path
    } else if (action == 'edit') {
      await _editBookmarkReminder(proxy);
    }
  }

  /// Create the bookmark with an optional reminder. Same optimistic
  /// flip + in-flight guard + revert-on-failure shape as
  /// [_handleBookmarkAction].
  Future<void> _createBookmarkWithReminder(
      DiscourseBookmarkProxy proxy, DateTime? reminderAt) async {
    if (_bookmarkInFlight) return;
    final postId = int.tryParse(widget.post.id);
    if (postId == null) return;
    setState(() {
      _isBookmarked = true;
      _bookmarkInFlight = true;
    });
    bool ok;
    String? errText;
    try {
      final result = await proxy.createBookmarkAsync(
        postId: postId,
        reminderAt: reminderAt,
        // Discourse's default for reminder bookmarks: keep the
        // bookmark, clear reminder_at once the reminder fires.
        autoDeletePreference:
            reminderAt != null ? DiscourseBookmarkAutoDelete.clearReminder : null,
      );
      ok = result.result;
      errText = result.resultText;
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    setState(() {
      if (!ok) {
        _isBookmarked = false; // revert
      } else {
        widget.post.bookmarked = true;
      }
      _bookmarkInFlight = false;
    });
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errText?.isNotEmpty == true
              ? errText!
              : 'Failed to bookmark post'),
        ),
      );
    }
  }

  /// Edit the reminder on an existing bookmark. FCPost only carries the
  /// `bookmarked` flag, so resolve the bookmark row (id + current
  /// reminder/note) from the user's bookmark list first. The update
  /// endpoint overwrites rather than patches, so the existing note is
  /// passed back through untouched.
  Future<void> _editBookmarkReminder(DiscourseBookmarkProxy proxy) async {
    final messenger = ScaffoldMessenger.of(context);
    final entry = await _findBookmarkEntry(proxy);
    if (!mounted) return;
    if (entry == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not find this bookmark')),
      );
      return;
    }
    final choice = await BookmarkReminderSheet.show(
      context,
      title: 'Edit reminder',
      currentReminderAt: entry.reminderAt,
    );
    if (choice == null || !mounted) return;
    final result = await proxy.updateBookmarkAsync(
      entry.id,
      reminderAt: choice.reminderAt, // omitting clears — intended for "No reminder"
      name: entry.name, // overwrite semantics: resend the note
      autoDeletePreference: choice.reminderAt != null
          ? DiscourseBookmarkAutoDelete.clearReminder
          : null,
    );
    if (!mounted) return;
    if (!result.result) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.resultText?.isNotEmpty == true
              ? result.resultText!
              : 'Failed to update reminder'),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(choice.reminderAt != null
              ? 'Reminder set'
              : 'Reminder cleared'),
        ),
      );
    }
  }

  /// Scan the user's bookmark list for this post's bookmark row.
  /// Page-capped like DiscourseBookmarkProxy.removePostBookmarkAsync's
  /// lookup so a huge list can't loop forever.
  Future<FCBookmark?> _findBookmarkEntry(
      DiscourseBookmarkProxy proxy) async {
    final postId = int.tryParse(widget.post.id);
    if (postId == null) return null;
    const maxPages = 25;
    for (var page = 0; page < maxPages; page++) {
      final result = await proxy.getBookmarksWithRemindersAsync(page: page);
      if (!result.result || result.entries.isEmpty) return null;
      for (final entry in result.entries) {
        if (entry.bookmarkableType == 'Post' &&
            entry.bookmarkableId == postId) {
          return entry;
        }
      }
      if (!result.hasMore) return null;
    }
    return null;
  }

  /// Phase 5.31 — toggle the topic's accepted-answer state for this
  /// post. Routes through `IFCPostProxy.acceptAnswerAsync` /
  /// `unacceptAnswerAsync` (the SDK-aligned interface — no
  /// Discourse-only sidecar). Optimistic flip with revert on
  /// failure; surfaces the proxy's `resultText` in a snackbar so
  /// the "plugin not installed" case reads clearly.
  Future<void> _handleToggleAcceptAnswer() async {
    if (!widget.siteContext.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to mark answers')),
      );
      return;
    }
    final wasSolution = widget.post.isSolution;
    setState(() {
      widget.post.isSolution = !wasSolution;
    });
    final messenger = ScaffoldMessenger.of(context);
    final proxy = SiteProxyService.getPostProxy();
    try {
      final result = wasSolution
          ? await proxy.unacceptAnswerAsync(widget.post.id)
          : await proxy.acceptAnswerAsync(widget.post.id);
      if (!mounted) return;
      if (!result.result) {
        setState(() {
          widget.post.isSolution = wasSolution;
        });
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              result.resultText?.isNotEmpty == true
                  ? result.resultText!
                  : (wasSolution
                      ? 'Failed to unmark answer'
                      : 'Failed to mark answer'),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        widget.post.isSolution = wasSolution;
      });
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  /// Toggle a specific reaction by id (called from the chips row when
  /// the user taps an existing chip). When [reactionId] is the
  /// viewer's current reaction, the server removes it; otherwise it
  /// becomes the viewer's reaction (replacing any previous one).
  Future<void> _toggleReaction(String reactionId) async {
    if (!widget.siteContext.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to react')),
      );
      return;
    }
    final result = await SiteProxyService.getPostProxy()
        .toggleReactionAsync(widget.post.id, reactionId);
    if (!mounted) return;
    if (!result.result) {
      // Forums without discourse-reactions have no custom-reactions
      // route, but they still have likes — and the `heart` chip there
      // is the synthesized like chip. Toggle it through the like path.
      if (reactionId == 'heart') {
        await _handleLikeAction();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.resultText?.isNotEmpty == true
              ? result.resultText!
              : 'Could not update reaction.'),
        ),
      );
      return;
    }
    setState(() {
      _reactions = result.reactions;
      widget.post.reactions = result.reactions;
      // Keep the like state/count (used by the zero-state heart button
      // and its a11y label) consistent with the heart chip.
      final heart = result.reactions
          .where((r) => r.id == 'heart')
          .fold<int>(0, (sum, r) => sum + r.count);
      _likeCount = heart;
      widget.post.likeCount = heart;
      _isLiked = result.reactions.any((r) => r.id == 'heart' && r.viewerReacted);
      widget.post.isLiked = _isLiked;
    });
  }

  /// Rebuild the synthesized `heart` chip after a like/unlike so the
  /// chips row and the zero-state heart button never disagree. Only
  /// touches the heart entry; other emoji chips are left alone.
  void _syncHeartChipFromLike() {
    if (!mounted) return;
    final others =
        _reactions.where((r) => r.id != 'heart').toList(growable: true);
    final next = <FCPostReaction>[
      if (_likeCount > 0)
        FCPostReaction(
          id: 'heart',
          count: _likeCount,
          viewerReacted: _isLiked,
          canUndo: _isLiked,
        ),
      ...others,
    ];
    setState(() {
      _reactions = next;
      widget.post.reactions = next;
    });
  }

  /// Long-press on a reaction chip: list the users behind that count,
  /// fetched live from the server (never from `post.likesInfo`).
  void _showReactionUsers(String reactionId) {
    ReactionUsersSheet.show(
      context: context,
      siteContext: widget.siteContext,
      postId: widget.post.id,
      reactionId: reactionId.isEmpty ? null : reactionId,
    );
  }

  /// Open the full reaction picker. Reachable from the trailing "+"
  /// chip when reactions exist, and from a long-press on the like
  /// button in the zero state, so users can pick any of the forum's
  /// enabled emojis, not just the ones already showing.
  Future<void> _openReactionPicker() async {
    if (!widget.siteContext.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to react')),
      );
      return;
    }
    final current = _reactions
        .firstWhere(
          (r) => r.viewerReacted,
          orElse: () => FCPostReaction(id: '', count: 0),
        )
        .id;
    final updated = await ReactionPickerSheet.show(
      context: context,
      postId: widget.post.id,
      currentReactionId: current.isEmpty ? null : current,
    );
    if (updated == null || !mounted) return;
    setState(() {
      _reactions = updated;
      widget.post.reactions = updated;
    });
  }
}
