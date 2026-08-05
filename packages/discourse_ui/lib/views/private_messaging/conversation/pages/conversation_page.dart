import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/results/fc_private_conversation_result.dart';
import 'package:forumcopilot_sdk/models/entities/fc_like.dart';
import '../appbars/conversation_app_bar.dart';
import 'reply_conversation_page.dart';
import 'edit_conversation_page.dart';
import 'edit_conversation_message_page.dart';
import '../widgets/conversation_item.dart';
import '../widgets/conversation_header_widget.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import '../../../../theme/design_tokens.dart';
import '../../../../theme/style_builders.dart';
import '../../../../utils/accessibility_helpers.dart';
import 'package:get/get.dart';
import 'package:discourse_ui/controllers/login_controller.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';
import '../../../login_page.dart';

class ConversationPage extends StatefulWidget {
  final SiteContext siteContext;
  final String conversationId;
  final String subject;
  final VoidCallback? onMarkUnread;
  final int? initialStartNum;
  final String? anchorMessageId; // Message ID to navigate to and highlight

  const ConversationPage({
    Key? key,
    required this.siteContext,
    required this.conversationId,
    required this.subject,
    this.onMarkUnread,
    this.initialStartNum,
    this.anchorMessageId,
  }) : super(key: key);

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  FCConversationResult? _conversation;
  String? _error;
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  int _currentVisibleMessageIndex = 0;
  bool _showClosedBanner = true;
  bool _isLoadingMore = false;
  bool _hasMoreMessages = true;
  int _currentStartNum = 0;
  int _currentLastNum = 0; // Track the end of loaded range for proper pagination
  // Set when a newer-window fetch added zero new messages; guards the tail
  // auto-load so we never re-request the same window endlessly. Reset on any
  // fresh (non-merge) load.
  bool _newerFetchStalled = false;
  final int _pageSize = 20;
  String? _highlightedMessageId; // ID of message to highlight
  Timer? _highlightTimer; // Timer to clear highlight after a few seconds

  @override
  void initState() {
    super.initState();
    _attemptAutoLoginAndLoad();
    _scrollController.addListener(_onScroll);
  }

  void _attemptAutoLoginAndLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      if (!widget.siteContext.isLoggedIn) {
        if (!Get.isRegistered<DiscourseLoginController>()) {
          Get.put(DiscourseLoginController());
        }
        final loginController = Get.find<DiscourseLoginController>();
        final loginResult = await loginController.attemptAutomaticLogin(widget.siteContext);
        if (!mounted) return;
        if (!loginResult.success && loginResult.hadCredentials && Get.currentRoute != '/LoginPage') {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LoginPage(siteContext: widget.siteContext),
            ),
          );
        }
      }
      if (mounted) {
        _loadConversation();
      }
    });
  }

  Future<void> _onReplyPressed() async {
    if (_conversation != null) {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReplyConversationPage(
            siteContext: widget.siteContext,
            conversationId: widget.conversationId,
            subject: widget.subject,
            canUpload: _conversation?.canUpload,
          ),
        ),
      );

      // If reply was successful, refresh conversation and scroll to last message
      if (result == true) {
        await _refreshAndScrollToLast();
      }
    }
  }

  Future<void> _markAsUnread() async {
    try {
      final conversationProxy = SiteProxyFactory.getPrivateConversationProxy();
      final result = await conversationProxy.markConversationUnreadAsync(widget.conversationId);

      if (mounted) {
        if (result.result) {
          // Call the callback to update the conversation state in the list
          widget.onMarkUnread?.call();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)?.conversationMarkedAsUnread ?? 'Conversation marked as unread'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          // Pop back to the conversation list
          Navigator.pop(context);
        } else {
          // API call returned false - show error message
          final errorMessage =
              result.resultText?.isNotEmpty == true ? result.resultText! : AppLocalizations.of(context)?.failedToMarkConversationAsUnread('') ?? 'Failed to mark conversation as unread';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.failedToMarkConversationAsUnread(e.toString()) ?? 'Failed to mark conversation as unread: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _loadOlderMessages() async {
    if (_isLoadingMore || _conversation == null) return;

    if (_currentStartNum <= 1) {
      return;
    }

    await _loadConversation(loadMore: true, loadOlder: true);
  }

  /// Merges two message lists preserving order and dropping duplicate ids
  /// (page boundaries can overlap when the server re-centers a window).
  List<FCConversationMessage> _mergeMessages(
      List<FCConversationMessage> first, List<FCConversationMessage> second) {
    final seen = <String>{};
    final merged = <FCConversationMessage>[];
    for (final msg in [...first, ...second]) {
      if (seen.add(msg.messageId)) merged.add(msg);
    }
    return merged;
  }

  /// Derives the loaded window bounds from the positions the server
  /// actually returned rather than mirroring its paging formula. Falls
  /// back to the computed bounds when messages carry no position.
  void _updateWindowFromMessages(List<FCConversationMessage> loaded,
      {required int fallbackStart, required int fallbackLast}) {
    final positions =
        loaded.map((m) => m.messageNumber).whereType<int>().toList();
    if (positions.isNotEmpty) {
      _currentStartNum = positions.reduce(math.min);
      _currentLastNum = positions.reduce(math.max);
    } else {
      _currentStartNum = fallbackStart;
      _currentLastNum = fallbackLast;
    }
  }

  /// Fetches the missing newer window (post-frame) when the loaded window
  /// stops short of the end of the conversation. Needed because a list that
  /// is already clamped at max scroll extent emits no scroll notifications,
  /// so the scroll listener alone can never load the tail. Guarded by
  /// [_newerFetchStalled] so a server that returns nothing new stops the
  /// loop instead of re-requesting the same window forever.
  void _scheduleTailFillIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isLoading || _isLoadingMore || _newerFetchStalled) {
        return;
      }
      final conversation = _conversation;
      if (conversation == null) return;
      final totalMessages =
          conversation.totalMessageNum ?? conversation.messages.length;
      if (_currentLastNum < totalMessages) {
        _loadConversation(loadMore: true);
      }
    });
  }

  Future<void> _loadConversation({bool loadMore = false, bool loadOlder = false}) async {
    if (loadMore && (_isLoadingMore || !_hasMoreMessages)) {
      return;
    }

    try {
      if (!loadMore) {
        setState(() {
          _isLoading = true;
          _error = null;
          _currentStartNum = widget.initialStartNum ?? 0;
        });
      } else {
        setState(() {
          _isLoadingMore = true;
        });
      }

      final conversationProxy = SiteProxyFactory.getPrivateConversationProxy();
      FCConversationResult conversation;

      // If anchorMessageId is provided and this is the initial load, use getConversationByMessageAsync
      if (!loadMore && widget.anchorMessageId != null && widget.anchorMessageId!.isNotEmpty) {
        conversation = await conversationProxy.getConversationByMessageAsync(
          widget.anchorMessageId!,
          messagesPerRequest: _pageSize,
        );

        if (!conversation.result) {
          if (mounted) {
            setState(() {
              _error = conversation.resultText ?? 'Failed to load conversation';
              _isLoading = false;
            });
          }
          return;
        }

        if (mounted) {
          setState(() {
            _conversation = conversation;
            // Derive the loaded window from the positions the server
            // actually returned. Fall back to mirroring the server's
            // centering formula (startNum = max(1, position -
            // floor(messagesPerRequest / 2))) only when the messages
            // carry no positions.
            final position = conversation.position ?? 1;
            // Use floor() to match server calculation exactly (not ~/ which truncates)
            final estimatedStart = math.max(1, position - (_pageSize / 2).floor());
            _updateWindowFromMessages(
              conversation.messages,
              fallbackStart: estimatedStart,
              fallbackLast: estimatedStart + conversation.messages.length - 1,
            );

            // Check if there are more messages to load
            final totalMessages = conversation.totalMessageNum ?? conversation.messages.length;
            // There are more messages if:
            // 1. We have more messages before the current range (startNum > 1)
            // 2. We have more messages after the current range (lastNum < totalMessages)
            final hasOlderMessages = _currentStartNum > 1;
            final hasNewerMessages = _currentLastNum < totalMessages;
            _hasMoreMessages = hasOlderMessages || hasNewerMessages;
            _newerFetchStalled = false;

            _isLoading = false;

            // Scroll to the anchor message after loading
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients && mounted && _conversation != null) {
                _scrollToMessage(widget.anchorMessageId!, position: position);
              }
            });
          });
        }
      } else {
        // Normal conversation loading logic
        int startNum;
        int lastNum;
        // Explicit direction of a loadMore request; the server re-centers
        // windows, so inferring direction from the requested range vs the
        // bookkeeping is unreliable.
        bool requestedOlder = false;
        bool requestedNewer = false;

        // Always calculate the last page when initially loading (not loading more)
        // This ensures we always show the most recent messages, even if initialStartNum was provided
        if (!loadMore) {
          // First, get the total message count by loading a minimal page
          // Use conversationId from widget, or from already loaded conversation if available
          final conversationIdToUse = _conversation?.convId ?? widget.conversationId;

          final metadataConversation = await conversationProxy.getConversationAsync(
            conversationIdToUse,
            1, // 1-based: position 1 = first message
            1, // Load just the first message to get totalMessageNum
            false,
          );

          // Surface a failed metadata call instead of continuing with a
          // bogus totalMessages of 0 (which would produce a nonsense
          // startNum=1, lastNum=0 request).
          if (!metadataConversation.result) {
            if (mounted) {
              setState(() {
                _error = metadataConversation.resultText?.isNotEmpty == true
                    ? metadataConversation.resultText
                    : 'Failed to load conversation';
                _isLoading = false;
                _isLoadingMore = false;
              });
            }
            return;
          }

          final totalMessages = metadataConversation.totalMessageNum ?? metadataConversation.messages.length;

          // Request the tail window. The proxy treats startNum as a 0-based
          // offset and anchors the server's ~20-post chunk at startNum + 1,
          // so anchoring at the last message (totalMessages - 1 -> anchor
          // totalMessages) makes the server return the final chunk.
          // startNum = 0 means "first chunk", which already covers short
          // conversations.
          startNum = math.max(0, totalMessages - 1);
          lastNum = totalMessages;
        } else {
          // When loading more messages, determine if we're loading older or newer messages
          final totalMessages = _conversation?.totalMessageNum ?? _conversation?.messages.length ?? 0;

          if (loadOlder && _currentStartNum > 1) {
            // Explicitly loading older messages (button click)
            startNum = math.max(1, _currentStartNum - _pageSize);
            lastNum = _currentStartNum - 1; // End just before the current start
            requestedOlder = true;
          } else if (_currentLastNum < totalMessages && !_newerFetchStalled) {
            // Loading newer messages (after the loaded window). The proxy
            // treats startNum as a 0-based offset (anchor = startNum + 1),
            // so pass the highest loaded messageNumber to anchor the server
            // window at the first missing message.
            startNum = _currentLastNum;
            lastNum = math.min(totalMessages, _currentLastNum + _pageSize);
            requestedNewer = true;
          } else {
            // Nothing to load in either direction; don't re-request the
            // window we already have.
            setState(() {
              _isLoadingMore = false;
            });
            return;
          }
        }

        // Use conversationId from widget, or from already loaded conversation if available
        final conversationIdToUse = _conversation?.convId ?? widget.conversationId;

        conversation = await conversationProxy.getConversationAsync(
          conversationIdToUse,
          startNum,
          lastNum,
          false, // returnHtml - use BBCode instead of HTML
        );

        if (mounted) {
          setState(() {
            if (loadMore && _conversation != null) {
              // Use the direction the request was made with; the server
              // re-centers windows so the returned/requested range can't be
              // compared against the bookkeeping reliably.
              final isLoadingOlder = requestedOlder;
              final isLoadingNewer = requestedNewer;

              if (isLoadingOlder) {
                // Save current scroll position before prepending messages
                final previousScrollPosition = _scrollController.hasClients ? _scrollController.position.pixels : 0.0;

                // Prepend older messages to existing list (since we're loading
                // backwards), deduping by id in case the pages overlap
                final previousCount = _conversation!.messages.length;
                final mergedMessages = _mergeMessages(conversation.messages, _conversation!.messages);
                _conversation = FCConversationResult(
                  result: conversation.result,
                  resultText: conversation.resultText,
                  convId: conversation.convId,
                  subject: conversation.subject,
                  convTitle: conversation.convTitle,
                  messages: mergedMessages,
                  participants: conversation.participants,
                  participantCount: conversation.participantCount,
                  canReply: conversation.canReply,
                  canInvite: conversation.canInvite,
                  canEdit: conversation.canEdit,
                  canClose: conversation.canClose,
                  isClosed: conversation.isClosed,
                  totalMessageNum: conversation.totalMessageNum ?? _conversation!.totalMessageNum,
                  canUpload: conversation.canUpload,
                  position: conversation.position,
                );
                // Derive the loaded window from the returned positions
                // (falling back to the requested range when absent)
                _updateWindowFromMessages(
                  mergedMessages,
                  fallbackStart: startNum,
                  fallbackLast: _currentLastNum,
                );
                // Check if there are more older messages to load
                final hasOlderMessages = _currentStartNum > 1;
                final hasNewerMessages = _currentLastNum < (conversation.totalMessageNum ?? _conversation!.totalMessageNum ?? 0);
                _hasMoreMessages = hasOlderMessages || hasNewerMessages;

                // Maintain scroll position after prepending older messages
                // Estimate the height of newly loaded messages and adjust scroll
                final newMessageCount = mergedMessages.length - previousCount;
                if (_scrollController.hasClients && previousScrollPosition > 0 && newMessageCount > 0) {
                  // Estimate average message height (this is approximate)
                  // In a real scenario, you might want to measure actual heights
                  final estimatedMessageHeight = 100.0; // Approximate height per message
                  final estimatedNewContentHeight = newMessageCount * estimatedMessageHeight;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients && mounted) {
                      // Adjust scroll position to maintain visual position
                      final newScrollPosition = previousScrollPosition + estimatedNewContentHeight;
                      _scrollController.jumpTo(newScrollPosition.clamp(
                        0.0,
                        _scrollController.position.maxScrollExtent,
                      ));
                    }
                  });
                }
              } else if (isLoadingNewer) {
                // Append newer messages to existing list, deduping by id
                // in case the pages overlap
                final previousCount = _conversation!.messages.length;
                final mergedMessages = _mergeMessages(_conversation!.messages, conversation.messages);
                // Bail out of the tail-load loop when the fetch added zero
                // new messages, so we never re-request the same window
                // endlessly.
                _newerFetchStalled = mergedMessages.length == previousCount;
                _conversation = FCConversationResult(
                  result: conversation.result,
                  resultText: conversation.resultText,
                  convId: conversation.convId,
                  subject: conversation.subject,
                  convTitle: conversation.convTitle,
                  messages: mergedMessages,
                  participants: conversation.participants,
                  participantCount: conversation.participantCount,
                  canReply: conversation.canReply,
                  canInvite: conversation.canInvite,
                  canEdit: conversation.canEdit,
                  canClose: conversation.canClose,
                  isClosed: conversation.isClosed,
                  totalMessageNum: conversation.totalMessageNum ?? _conversation!.totalMessageNum,
                  canUpload: conversation.canUpload,
                  position: conversation.position,
                );
                // Derive the loaded window from the returned positions
                // (falling back to the requested range when absent)
                _updateWindowFromMessages(
                  mergedMessages,
                  fallbackStart: _currentStartNum,
                  fallbackLast: lastNum,
                );
                // Check if there are more newer messages to load
                final totalMessages = conversation.totalMessageNum ?? _conversation!.totalMessageNum ?? 0;
                final hasOlderMessages = _currentStartNum > 1;
                final hasNewerMessages = _currentLastNum < totalMessages;
                _hasMoreMessages = hasOlderMessages || hasNewerMessages;
              } else {
                // Requested window is neither older nor newer than what's
                // loaded (e.g. an overlapping/re-centered response). Keep
                // the current list and pagination state — replacing them
                // here would drop loaded messages and kill pagination.
                AppLogger.warning(
                    'ConversationPage: unexpected loadMore window startNum=$startNum '
                    'lastNum=$lastNum within [$_currentStartNum, $_currentLastNum]; '
                    'keeping current state');
              }
            } else {
              _conversation = conversation;
              // Derive the loaded window from the messageNumbers the server
              // actually returned — the server re-centers windows and does
              // NOT honor the requested range, so mirroring the request here
              // would corrupt all downstream pagination logic.
              final totalMessages = conversation.totalMessageNum ?? conversation.messages.length;
              _updateWindowFromMessages(
                conversation.messages,
                fallbackStart: math.max(1, totalMessages - conversation.messages.length + 1),
                fallbackLast: totalMessages,
              );
              _hasMoreMessages = _currentStartNum > 1 || _currentLastNum < totalMessages;
              _newerFetchStalled = false;

              // Always scroll to bottom when initially loading (since we always load the last page)
              if (!loadMore) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients && mounted) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
              }
            }
            _isLoading = false;
            _isLoadingMore = false;
          });

          // When the list is already clamped at max scroll extent no scroll
          // notifications fire, so the scroll listener can never trigger the
          // newer-window load. Explicitly follow up (post-frame) whenever the
          // loaded window still stops short of the end of the conversation.
          if (!loadMore || requestedNewer) {
            _scheduleTailFillIfNeeded();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  /// Highlights a message by ID and clears it after 3 seconds
  void _highlightMessage(String messageId) {
    if (!mounted) return;

    // Cancel any existing timer
    _highlightTimer?.cancel();

    // Set the highlighted message
    setState(() {
      _highlightedMessageId = messageId;
    });

    // Clear highlight after 3 seconds
    _highlightTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _highlightedMessageId = null;
        });
      }
    });
  }

  /// Scroll to a specific message by message ID
  /// [position] is the 1-based position of the message in the entire conversation (optional)
  void _scrollToMessage(String messageId, {int? position}) {
    if (_conversation == null || !_scrollController.hasClients) return;

    // Find the index of the message in the loaded list
    final messageIndex = _conversation!.list.indexWhere((msg) => msg.messageId == messageId);
    if (messageIndex == -1) {
      return;
    }

    // If we have the position field, use it to properly center the message
    // This is especially important when the message is in the middle of multiple pages
    if (position != null && _conversation!.totalMessageNum != null) {
      final loadedMessages = _conversation!.list.length;

      // Calculate where the target message is relative to the loaded range
      // position is 1-based in the entire conversation
      // _currentStartNum is 1-based start of loaded range
      final relativePosition = position - _currentStartNum;

      // If the message is in the loaded range, scroll to it proportionally
      if (relativePosition >= 0 && relativePosition < loadedMessages) {
        // Calculate scroll position: center the message in the viewport
        // Use the relative position within the loaded messages to calculate scroll
        final maxScroll = _scrollController.position.maxScrollExtent;
        if (maxScroll > 0) {
          // Calculate scroll position to center the message
          // We want the message to be roughly in the middle of the viewport
          final scrollRatio = relativePosition / loadedMessages;
          final targetScroll = maxScroll * scrollRatio;

          // Adjust to center: subtract half viewport height (approximate)
          // This ensures the message appears in the middle of the screen
          final viewportHeight = _scrollController.position.viewportDimension;
          final centeredScroll = (targetScroll - viewportHeight / 2).clamp(0.0, maxScroll);

          _scrollController.animateTo(
            centeredScroll,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      } else {
        // Fall back to proportional scrolling
        final maxScroll = _scrollController.position.maxScrollExtent;
        if (maxScroll > 0 && loadedMessages > 0) {
          final scrollPosition = maxScroll * (messageIndex / loadedMessages);
          _scrollController.animateTo(
            scrollPosition,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    } else {
      // Fallback: Calculate approximate scroll position without position field
      // This is approximate since we don't know exact heights, but should get us close
      final totalMessages = _conversation!.list.length;
      if (totalMessages > 0) {
        final scrollPosition = _scrollController.position.maxScrollExtent * (messageIndex / totalMessages);
        _scrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }

    // Highlight the message
    _highlightMessage(messageId);
  }

  /// Refresh the conversation and scroll to the last message, highlighting it
  Future<void> _refreshAndScrollToLast() async {
    try {
      // Reset highlight before loading
      setState(() {
        _highlightedMessageId = null;
      });

      // Fully refresh the conversation by calling _loadConversation
      // This will automatically load the last page and scroll to bottom
      await _loadConversation();

      if (mounted && _conversation != null && _conversation!.list.isNotEmpty) {
        // Highlight the last message (the one user just posted)
        final lastMessage = _conversation!.list.last;
        _highlightMessage(lastMessage.messageId);

        // Ensure we scroll to the very bottom after UI is rendered
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && mounted) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _closeConversation() async {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Close Conversation',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to close this conversation? This will prevent new replies from being posted.',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppLocalizations.of(context)?.cancel ?? 'Cancel',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Close',
              style: TextStyle(color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final conversationProxy = SiteProxyFactory.getPrivateConversationProxy();
      final result = await conversationProxy.closeConversationAsync(widget.conversationId);

      if (mounted) {
        if (result.result) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)?.conversationClosed ?? 'Conversation closed'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          // Refresh conversation to update state
          await _loadConversation();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.resultText ?? AppLocalizations.of(context)?.failedToCloseConversation('') ?? 'Failed to close conversation'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.failedToCloseConversation(e.toString()) ?? 'Failed to close conversation: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _uncloseConversation() async {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Open Conversation',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to open this conversation? This will allow new replies to be posted.',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppLocalizations.of(context)?.cancel ?? 'Cancel',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Open',
              style: TextStyle(color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final conversationProxy = SiteProxyFactory.getPrivateConversationProxy();
      final result = await conversationProxy.uncloseConversationAsync(widget.conversationId);

      if (mounted) {
        if (result.result) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)?.conversationOpened ?? 'Conversation opened'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          // Refresh conversation to update state
          await _loadConversation();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.resultText ?? 'Failed to open conversation'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.failedToOpenConversation(e.toString()) ?? 'Failed to open conversation: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _leaveConversation() async {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Leave Conversation',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to leave this conversation? This will hide it from your inbox.',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppLocalizations.of(context)?.cancel ?? 'Cancel',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Leave',
              style: TextStyle(color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final conversationProxy = SiteProxyFactory.getPrivateConversationProxy();
      await conversationProxy.leaveConversationAsync(widget.conversationId, 1); // 1 = soft leave
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.failedToLeaveConversation(e.toString()) ?? 'Failed to leave conversation: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ConversationAppBar(
        title: _conversation?.convTitle ?? widget.subject,
        siteContext: widget.siteContext,
        onLeave: _leaveConversation,
        onMarkUnread: _markAsUnread,
        participantCount: _conversation?.participantCount ?? 0,
        canEdit: _conversation?.canEdit ?? false,
        canClose: _conversation?.canClose ?? false,
        isClosed: _conversation?.isClosed ?? false,
        participants: _conversation?.participants,
        canInvite: _conversation?.canInvite ?? false,
        conversationId: widget.conversationId,
        onInviteSuccess: () => _loadConversation(),
        onClose: _conversation?.canClose == true && _conversation?.isClosed == false ? _closeConversation : null,
        onUnclose: _conversation?.canClose == true && _conversation?.isClosed == true ? _uncloseConversation : null,
        onEdit: _conversation?.canEdit == true && widget.siteContext.siteType == 'discourse' ? _editConversation : null,
      ),
      body: _buildBody(),
    );
  }

  Future<void> _editConversation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditConversationPage(
          siteContext: widget.siteContext,
          conversationId: widget.conversationId,
        ),
      ),
    );

    // Reload conversation if edit was successful
    if (result == true) {
      _loadConversation();
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading conversation: $_error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadConversation,
              child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
            ),
          ],
        ),
      );
    }

    if (_conversation == null) {
      return Center(
        child: Text(
          'Conversation not found',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return Column(
      children: [
        // Closed banner
        if ((_conversation?.isClosed ?? false) && _showClosedBanner)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.7),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: DesignTokens.opacityMediumLow),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This conversation is closed and no longer accepting replies',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      _showClosedBanner = false;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
        // Messages list
        Expanded(
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: _loadConversation,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Conversation header with overlapping avatars, title, and participant count
                      ConversationHeaderWidget(
                        title: _conversation!.convTitle ?? widget.subject,
                        participants: _conversation!.participants,
                        participantCount: _conversation!.participantCount ?? 0,
                        siteContext: widget.siteContext,
                        canInvite: _conversation!.canInvite ?? false,
                        conversationId: widget.conversationId,
                        onInviteSuccess: () => _loadConversation(),
                      ),
                      // Load Earlier Messages button
                      if (_currentStartNum > 1 && !_isLoadingMore)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: OutlinedButton.icon(
                            onPressed: () => _loadOlderMessages(),
                            icon: const Icon(Icons.arrow_upward),
                            label: Text(AppLocalizations.of(context)?.loadEarlierMessages ?? 'Load Earlier Messages'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            ),
                          ),
                        ),
                      // Loading indicator when loading older messages
                      if (_isLoadingMore && _currentStartNum > 1)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      // Header (first message) - only show if messages exist
                      if (_conversation!.list.isNotEmpty)
                        ConversationHeaderItem(
                          siteContext: widget.siteContext,
                          message: _conversation!.list[0],
                          subject: _conversation!.convTitle ?? '',
                          participants: _conversation!.participants,
                          onQuote: () => _onQuoteMessage(_conversation!.list[0]),
                          onLike: () => _onLikeMessage(_conversation!.list[0]),
                          onEdit: () => _onEditMessage(_conversation!.list[0]),
                          isHighlighted: _highlightedMessageId == _conversation!.list[0].messageId,
                          isClosed: _conversation!.isClosed ?? false,
                        ),
                      // Individual reply messages
                      if (_conversation!.list.length > 1)
                        ...List.generate(_conversation!.list.length - 1, (i) {
                          final msg = _conversation!.list[i + 1];
                          return ConversationItem(
                            siteContext: widget.siteContext,
                            message: msg,
                            isFirst: false,
                            isLast: i == _conversation!.list.length - 2,
                            onQuote: () => _onQuoteMessage(msg),
                            onLike: () => _onLikeMessage(msg),
                            onEdit: () => _onEditMessage(msg),
                            isHighlighted: _highlightedMessageId == msg.messageId,
                            isClosed: _conversation!.isClosed ?? false,
                          );
                        }),
                      // Show message if no messages found
                      if (_conversation!.list.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'No messages found',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ),
                      // Loading indicator for more messages
                      if (_isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      // End of conversation indicator
                      if (!_isLoadingMore && _conversation!.list.isNotEmpty)
                        Builder(
                          builder: (context) {
                            final totalMessages = _conversation!.totalMessageNum ?? _conversation!.list.length;
                            // Only claim the end has been reached when the
                            // highest actually-loaded messageNumber covers
                            // the conversation total (falling back to the
                            // derived window bound when messages carry no
                            // positions).
                            final highestLoaded = _conversation!.list
                                .map((m) => m.messageNumber)
                                .whereType<int>()
                                .fold<int>(0, math.max);
                            final isAtEnd = (highestLoaded > 0 ? highestLoaded : _currentLastNum) >= totalMessages;

                            if (isAtEnd) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(
                                  child: Text(
                                    'End of conversation',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      const SizedBox(height: 80), // for bottom bar spacing
                    ],
                  ),
                ),
              ),
              _buildBottomBar(context),
            ],
          ),
        ),
      ],
    );
  }

  void _onScroll() {
    if (_conversation == null) return;

    final position = _scrollController.position;
    final isNearBottom = position.pixels >= position.maxScrollExtent - 200;

    // Only auto-load newer messages when scrolling to the bottom
    // Older messages require manual button click
    if (_hasMoreMessages && !_isLoadingMore) {
      final totalMessages = _conversation!.totalMessageNum ?? _conversation!.messages.length;
      final hasNewerMessages = _currentLastNum < totalMessages && !_newerFetchStalled;

      if (isNearBottom && hasNewerMessages) {
        // Load newer messages when scrolling to the bottom
        _loadConversation(loadMore: true);
      }
    }

    if (position.maxScrollExtent > 0 && _conversation!.list.isNotEmpty) {
      // Calculate which message is currently most visible (local index in loaded list)
      final itemHeight = position.maxScrollExtent / _conversation!.list.length;
      final currentIndex = (position.pixels / itemHeight).round();
      final newIndex = currentIndex.clamp(0, _conversation!.list.length - 1);

      // Update the visible index (this is the local index, we'll convert to absolute when displaying)
      if (_currentVisibleMessageIndex != newIndex) {
        setState(() {
          _currentVisibleMessageIndex = newIndex;
        });
      }
    }
  }

  /// Get the absolute position (1-based) of the currently visible message
  int get _currentVisibleMessagePosition {
    if (_conversation == null || _conversation!.list.isEmpty) return 1;

    // If message has messageNumber, use it directly
    final visibleMessage = _conversation!.list[_currentVisibleMessageIndex.clamp(0, _conversation!.list.length - 1)];
    if (visibleMessage.messageNumber != null) {
      return visibleMessage.messageNumber!;
    }

    // Fallback: calculate from _currentStartNum (1-based) + local index
    return _currentStartNum + _currentVisibleMessageIndex;
  }

  /// Load first page of conversation and scroll to top
  Future<void> _jumpToFirstMessage() async {
    if (_conversation == null) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final conversationProxy = SiteProxyFactory.getPrivateConversationProxy();
      final conversationIdToUse = _conversation!.convId;

      // Load first page (messages 1 to pageSize)
      final startNum = 1;
      final lastNum = _pageSize;

      final conversation = await conversationProxy.getConversationAsync(
        conversationIdToUse,
        startNum,
        lastNum,
        false, // returnHtml - use BBCode instead of HTML
      );

      if (mounted) {
        setState(() {
          // Replace current conversation with first page (discard previous messages)
          _conversation = conversation;
          // Derive the loaded window from the returned messageNumbers (the
          // server re-centers windows and does not honor the request).
          _updateWindowFromMessages(
            conversation.messages,
            fallbackStart: startNum,
            fallbackLast: conversation.messages.length,
          );
          final totalMessages = conversation.totalMessageNum ?? conversation.messages.length;
          _hasMoreMessages = _currentStartNum > 1 || _currentLastNum < totalMessages;
          _newerFetchStalled = false;
          _isLoading = false;
        });

        // Scroll to top after loading
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && mounted) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Load last page of conversation and scroll to bottom
  Future<void> _jumpToLastMessage() async {
    if (_conversation == null) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final conversationProxy = SiteProxyFactory.getPrivateConversationProxy();
      final conversationIdToUse = _conversation!.convId;

      // First, get total message count
      final metadataConversation = await conversationProxy.getConversationAsync(
        conversationIdToUse,
        1, // 1-based: position 1 = first message
        1, // Load just the first message to get totalMessageNum
        false,
      );

      final totalMessages = metadataConversation.totalMessageNum ?? metadataConversation.messages.length;

      // Request the tail window. The proxy treats startNum as a 0-based
      // offset and anchors the server chunk at startNum + 1, so anchoring at
      // the last message (totalMessages - 1 -> anchor totalMessages) makes
      // the server return the final chunk. startNum = 0 means "first chunk",
      // which already covers short conversations.
      final startNum = math.max(0, totalMessages - 1);
      final lastNum = totalMessages;

      final conversation = await conversationProxy.getConversationAsync(
        conversationIdToUse,
        startNum,
        lastNum,
        false, // returnHtml - use BBCode instead of HTML
      );

      if (mounted) {
        setState(() {
          // Replace current conversation with last page (discard previous messages)
          _conversation = conversation;
          // Derive the loaded window from the returned messageNumbers (the
          // server re-centers windows and does not honor the request).
          _updateWindowFromMessages(
            conversation.messages,
            fallbackStart: math.max(1, totalMessages - conversation.messages.length + 1),
            fallbackLast: totalMessages,
          );
          final total = conversation.totalMessageNum ?? totalMessages;
          _hasMoreMessages = _currentStartNum > 1 || _currentLastNum < total;
          _newerFetchStalled = false;
          _isLoading = false;
        });

        // If the returned window somehow still stops short of the end,
        // fetch the missing tail.
        _scheduleTailFillIfNeeded();

        // Scroll to bottom after loading
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && mounted) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showJumpToMessageDialog(BuildContext context) {
    if (_conversation == null) return;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final totalMessages = _conversation!.totalMessageNum ?? _conversation!.list.length;
    int selectedMessagePosition = _currentVisibleMessagePosition;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                'Jump to Message',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$selectedMessagePosition',
                    style: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Slider(
                    value: selectedMessagePosition.toDouble(),
                    min: 1,
                    max: totalMessages.toDouble(),
                    divisions: math.max(0, totalMessages - 1),
                    label: '$selectedMessagePosition',
                    onChanged: (double value) {
                      setState(() {
                        selectedMessagePosition = value.toInt();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    AppLocalizations.of(context)?.cancel ?? 'Cancel',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _jumpToMessagePosition(selectedMessagePosition);
                  },
                  child: Text(
                    'Jump',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Jump to a specific message position (1-based) in the conversation
  Future<void> _jumpToMessagePosition(int targetPosition) async {
    if (_conversation == null) return;

    final totalMessages = _conversation!.totalMessageNum ?? _conversation!.list.length;

    // Clamp target position to valid range
    final clampedPosition = targetPosition.clamp(1, totalMessages);

    // Check if target message is already loaded
    final targetMessage = _conversation!.list.firstWhere(
      (msg) => msg.messageNumber == clampedPosition,
      orElse: () => _conversation!.list.first,
    );

    // Check if target is in currently loaded range
    final isInLoadedRange = clampedPosition >= _currentStartNum && clampedPosition <= _currentLastNum;

    if (isInLoadedRange && targetMessage.messageNumber == clampedPosition) {
      // Message is already loaded, just scroll to it
      final listIndex = _conversation!.list.indexWhere((msg) => msg.messageNumber == clampedPosition);
      if (listIndex >= 0) {
        // Calculate scroll position
        if (_scrollController.hasClients && _conversation!.list.isNotEmpty) {
          final itemHeight = _scrollController.position.maxScrollExtent / _conversation!.list.length;
          final targetOffset = listIndex * itemHeight;
          _scrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );

          // Update visible index
          setState(() {
            _currentVisibleMessageIndex = listIndex;
          });

          // Highlight the message
          _highlightMessage(targetMessage.messageId);
        }
        return;
      }
    }

    // Need to load the page containing the target message
    // Calculate which page contains the target position
    final messagesPerPage = _pageSize;
    final targetStartNum = math.max(1, clampedPosition - (messagesPerPage / 2).floor());
    final targetLastNum = math.min(totalMessages, targetStartNum + messagesPerPage - 1);

    // Load the conversation with the target range
    try {
      final conversationProxy = SiteProxyFactory.getPrivateConversationProxy();
      final conversation = await conversationProxy.getConversationAsync(
        widget.conversationId,
        targetStartNum,
        targetLastNum,
        false, // returnHtml - use BBCode instead of HTML
      );

      if (mounted) {
        setState(() {
          _conversation = conversation;
          // Derive the loaded window from the returned messageNumbers (the
          // server re-centers windows and does not honor the request).
          _updateWindowFromMessages(
            conversation.messages,
            fallbackStart: targetStartNum,
            fallbackLast: targetLastNum,
          );
          final totalMessages = conversation.totalMessageNum ?? conversation.messages.length;
          _hasMoreMessages = _currentStartNum > 1 || _currentLastNum < totalMessages;
          _newerFetchStalled = false;
        });

        // Find and scroll to the target message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && mounted && _conversation != null) {
            final targetMsg = _conversation!.list.firstWhere(
              (msg) => msg.messageNumber == clampedPosition,
              orElse: () => _conversation!.list.first,
            );

            if (targetMsg.messageNumber == clampedPosition) {
              final listIndex = _conversation!.list.indexWhere((msg) => msg.messageNumber == clampedPosition);
              if (listIndex >= 0) {
                final itemHeight = _scrollController.position.maxScrollExtent / _conversation!.list.length;
                final targetOffset = listIndex * itemHeight;
                _scrollController.animateTo(
                  targetOffset,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );

                setState(() {
                  _currentVisibleMessageIndex = listIndex;
                });

                // Highlight the message
                _highlightMessage(targetMsg.messageId);
              }
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.failedToJumpToMessage(e.toString()) ?? 'Failed to jump to message: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildBottomBar(BuildContext context) {
    if (_conversation == null) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingL,
              vertical: DesignTokens.spacingS,
            ),
            child: Row(
              children: [
                Semantics(
                  label: AppLocalizations.of(context)?.goToTop ?? 'Go to top',
                  hint: 'Jump to first message',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: _jumpToFirstMessage,
                    tooltip: AppLocalizations.of(context)?.goToTop ?? 'Go to top',
                  ),
                ),
                Semantics(
                  label: AppLocalizations.of(context)?.goToBottom ?? 'Go to bottom',
                  hint: 'Jump to last message',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_downward),
                    onPressed: _jumpToLastMessage,
                    tooltip: AppLocalizations.of(context)?.goToBottom ?? 'Go to bottom',
                  ),
                ),
                SizedBox(width: DesignTokens.spacingS),
                Semantics(
                  label: 'Message ${_currentVisibleMessagePosition} of ${_conversation!.totalMessageNum ?? _conversation!.list.length}',
                  hint: 'Tap to jump to a specific message',
                  button: true,
                  child: GestureDetector(
                    onTap: () {
                      _showJumpToMessageDialog(context);
                    },
                    child: Text(
                      '${_currentVisibleMessagePosition} / ${_conversation!.totalMessageNum ?? _conversation!.list.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                const Spacer(),
                if ((_conversation!.canReply ?? true) && !(_conversation!.isClosed ?? false))
                  Semantics(
                    label: AccessibilityHelpers.getReplyButtonLabel(context),
                    button: true,
                    child: FilledButton.icon(
                      onPressed: _onReplyPressed,
                      icon: const Icon(Icons.reply),
                      label: Text(AppLocalizations.of(context)?.reply ?? 'Reply'),
                      style: StyleBuilders.extendedFilledButtonStyle(
                        colorScheme: Theme.of(context).colorScheme,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onQuoteMessage(FCConversationMessage message) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReplyConversationPage(
          siteContext: widget.siteContext,
          conversationId: widget.conversationId,
          subject: widget.subject,
          quotedMessageId: message.messageId,
          canUpload: _conversation?.canUpload,
        ),
      ),
    );

    // If reply was successful, refresh conversation and scroll to last message
    if (result == true) {
      await _refreshAndScrollToLast();
    }
  }

  Future<void> _onEditMessage(FCConversationMessage message) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditConversationMessagePage(
          siteContext: widget.siteContext,
          messageId: message.messageId,
          conversationId: widget.conversationId,
        ),
      ),
    );

    // If edit was successful, refresh conversation
    if (result == true) {
      _loadConversation();
    }
  }

  Future<void> _onLikeMessage(FCConversationMessage message) async {
    if (!widget.siteContext.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.pleaseLoginToLikeMessages ?? 'Please login to like messages'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Optimistically update UI
    final wasLiked = message.isLiked;
    final oldLikeCount = message.likeCount;
    setState(() {
      message.isLiked = !wasLiked;
    });

    if (!wasLiked) {
      // Optimistically add like
      final currentUsername = widget.siteContext.currentUsername;
      if (currentUsername != null && !message.likesInfo.any((like) => like.username == currentUsername)) {
        message.likesInfo.add(FCLike(
          userId: widget.siteContext.currentUserId ?? '',
          username: currentUsername,
          avatarUrl: widget.siteContext.currentAvatarUrl ?? '',
          timestamp: DateTime.now(),
        ));
      }
    } else {
      // Optimistically remove like
      final currentUsername = widget.siteContext.currentUsername;
      if (currentUsername != null) {
        message.likesInfo.removeWhere((like) => like.username == currentUsername);
      }
    }
    setState(() {
      message.likeCount = message.likesInfo.length;
    });

    try {
      final socialProxy = SiteProxyFactory.getSocialProxy();

      if (wasLiked) {
        final result = await socialProxy.unlikePostAsync(message.messageId);
        if (result.result) {
          // Update UI with response data from server
          setState(() {
            message.isLiked = result.isLiked;
            message.likeCount = result.likeCount;

            // Update likesInfo based on server response
            final currentUsername = widget.siteContext.currentUsername;
            if (currentUsername != null && !result.isLiked) {
              // Remove current user from likesInfo
              message.likesInfo.removeWhere((like) => like.username == currentUsername);
            }

            // Ensure likeCount matches server response (server is source of truth)
            message.likeCount = result.likeCount;
          });
        } else {
          // API returned failure, revert optimistic update
          throw Exception(result.resultText ?? 'Failed to unlike message');
        }
      } else {
        final result = await socialProxy.likePostAsync(message.messageId);
        if (result.result) {
          // Update UI with response data from server
          setState(() {
            message.isLiked = result.isLiked;
            message.likeCount = result.likeCount;

            // Update likesInfo based on server response
            final currentUsername = widget.siteContext.currentUsername;
            if (currentUsername != null && result.isLiked) {
              // Add current user to likesInfo if not already there
              if (!message.likesInfo.any((like) => like.username == currentUsername)) {
                message.likesInfo.add(FCLike(
                  userId: widget.siteContext.currentUserId ?? '',
                  username: currentUsername,
                  avatarUrl: widget.siteContext.currentAvatarUrl ?? '',
                  timestamp: DateTime.now(),
                ));
              }
            }

            // Ensure likeCount matches server response (server is source of truth)
            message.likeCount = result.likeCount;
          });
        } else {
          // API returned failure, revert optimistic update
          throw Exception(result.resultText ?? 'Failed to like message');
        }
      }
    } catch (e) {
      // Revert UI if failed
      setState(() {
        message.isLiked = wasLiked;
        message.likeCount = oldLikeCount;

        if (wasLiked) {
          // Re-add like to likesInfo
          final currentUsername = widget.siteContext.currentUsername;
          if (currentUsername != null && !message.likesInfo.any((like) => like.username == currentUsername)) {
            message.likesInfo.add(FCLike(
              userId: widget.siteContext.currentUserId ?? '',
              username: currentUsername,
              avatarUrl: widget.siteContext.currentAvatarUrl ?? '',
              timestamp: DateTime.now(),
            ));
          }
        } else {
          // Remove like from likesInfo
          final currentUsername = widget.siteContext.currentUsername;
          if (currentUsername != null) {
            message.likesInfo.removeWhere((like) => like.username == currentUsername);
          }
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)
                    ?.failedToLikeOrUnlikeMessage(wasLiked ? (AppLocalizations.of(context)?.unlike ?? 'unlike') : (AppLocalizations.of(context)?.like ?? 'like'), e.toString()) ??
                'Failed to ${wasLiked ? 'unlike' : 'like'} message: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _highlightTimer?.cancel(); // Cancel timer on dispose
    super.dispose();
  }
}
