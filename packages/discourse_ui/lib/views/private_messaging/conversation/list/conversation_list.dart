import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_private_conversation_proxy.dart';
import 'package:discourse_core/discourse_core.dart' show DiscoursePrivateConversationProxy;
import 'package:forumcopilot_sdk/models/results/fc_private_conversation_result.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:discourse_ui/views/widgets/not_signed_in_view.dart';
import '../../../../theme/design_tokens.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../pages/conversation_page.dart';
import 'conversation_list_item.dart';

class ConversationList extends StatefulWidget {
  final SiteContext siteContext;

  /// Show the viewer's archived messages (Discourse's Archive list) instead
  /// of the inbox. Inbox and sent never include archived messages.
  final bool archived;

  const ConversationList({
    super.key,
    required this.siteContext,
    this.archived = false,
  });

  @override
  ConversationListState createState() => ConversationListState();
}

class ConversationListState extends State<ConversationList> with AutomaticKeepAliveClientMixin {
  List<FCConversationSummary>? _conversations;
  String? _error;
  bool _isLoading = true;
  bool _hasLoaded = false;

  // Add authentication state tracking
  bool _wasLoggedIn = false;
  String? _lastLoadedUsername;
  late final VoidCallback _authStateListener;

  // Pagination state
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  final int _itemsPerPage = 20;
  final ScrollController _scrollController = ScrollController();

  // Cold-start: the persisted User API Key is restored before the user
  // record (/session/current.json) is hydrated, so the username the PM
  // listing endpoints need may not be available yet. Instead of issuing a
  // doomed request (which would render as an empty inbox), stay in the
  // loading state and retry until the username arrives.
  int _usernameRetryCount = 0;
  bool _usernameRetryScheduled = false;
  static const int _maxUsernameRetries = 10;
  
  // Track last logged values to reduce debug noise
  int? _lastLoggedConversationsCount;
  bool? _lastLoggedIsLoading;
  bool? _lastLoggedHasLoaded;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _wasLoggedIn = widget.siteContext.isLoggedIn;
    _lastLoadedUsername = widget.siteContext.loginDataOutput?.user?.username;

    _scrollController.addListener(_onScroll);

    // Listen to login state changes
    _authStateListener = () {
      final isLoggedInStatus = widget.siteContext.isLoggedIn;
      final currentUsername = widget.siteContext.loginDataOutput?.user?.username;

      AppLogger.debug('🔔 [CONVERSATION_LIST] Auth state listener triggered');
      AppLogger.debug('   - isLoggedInStatus: $isLoggedInStatus');
      AppLogger.debug('   - currentUsername: $currentUsername');
      AppLogger.debug('   - _wasLoggedIn: $_wasLoggedIn');
      AppLogger.debug('   - _lastLoadedUsername: $_lastLoadedUsername');

      if (isLoggedInStatus) {
        if (!_wasLoggedIn || _lastLoadedUsername != currentUsername) {
          AppLogger.debug('📋 [CONVERSATION_LIST] Auth state changed - resetting and reloading');
          _hasLoaded = false;
          _wasLoggedIn = isLoggedInStatus;
          _lastLoadedUsername = currentUsername;
          if (mounted) {
            loadConversations();
          }
        }
      } else if (!isLoggedInStatus && _wasLoggedIn) {
        AppLogger.debug('📋 [CONVERSATION_LIST] User logged out - clearing data');
        _hasLoaded = false;
        _wasLoggedIn = false;
        _lastLoadedUsername = null;
        if (mounted) {
          setState(() {
            _conversations = null;
            _isLoading = false;
            _error = null;
          });
        }
      }
    };

    widget.siteContext.isLoggedInNotifier.addListener(_authStateListener);
  }

  /// Load now unless this list already has (or is about to). For a parent
  /// that shows the list itself, rather than relying on the visibility
  /// callback alone.
  void loadIfNeeded() {
    if (_initialLoadInFlight || !_shouldLoadConversations()) return;
    _initialLoadInFlight = true;
    loadConversations().whenComplete(() => _initialLoadInFlight = false);
  }

  /// Set while [loadIfNeeded] has a load running, so the visibility callback
  /// and an explicit request do not start two.
  bool _initialLoadInFlight = false;

  bool _shouldLoadConversations() {
    final currentUsername = widget.siteContext.loginDataOutput?.user?.username;

    if (!_hasLoaded && widget.siteContext.isLoggedIn) {
      return true;
    }

    if (_wasLoggedIn != widget.siteContext.isLoggedIn) {
      return true;
    }

    if (widget.siteContext.isLoggedIn && _lastLoadedUsername != currentUsername) {
      return true;
    }

    return false;
  }

  Future<void> loadConversations() async {
    final currentUsername = widget.siteContext.loginDataOutput?.user?.username;

    if (!widget.siteContext.isLoggedIn) {
      setState(() {
        _isLoading = false;
        _conversations = null;
        _error = null;
        _hasLoaded = false;
      });
      _wasLoggedIn = false;
      _lastLoadedUsername = null;
      return;
    }

    if (currentUsername == null || currentUsername.isEmpty) {
      // Logged in (User API Key restored) but the user record hasn't
      // hydrated yet — the PM endpoints are built from the username, so
      // requesting now can only fail. Keep the spinner and retry shortly.
      if (_usernameRetryCount < _maxUsernameRetries) {
        AppLogger.debug(
            '[ConversationList] Username not hydrated yet - deferring load (attempt ${_usernameRetryCount + 1}/$_maxUsernameRetries)');
        if (mounted) {
          setState(() {
            _isLoading = true;
            _error = null;
          });
        }
        if (!_usernameRetryScheduled) {
          _usernameRetryScheduled = true;
          _usernameRetryCount++;
          Future.delayed(const Duration(seconds: 2), () {
            _usernameRetryScheduled = false;
            if (mounted) loadConversations();
          });
        }
        return;
      }
      // Retries exhausted — fall through; the proxy returns result:false
      // and the error state below offers a manual Retry.
    } else {
      _usernameRetryCount = 0;
    }

    _wasLoggedIn = widget.siteContext.isLoggedIn;
    _lastLoadedUsername = currentUsername;

    AppLogger.debug('\n[ConversationList] Loading conversations');

    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 0;
        _hasMoreData = true;
      });

      await _loadConversations();

      _hasLoaded = true;
    } catch (e, stackTrace) {
      AppLogger.debug('[ConversationList] Error loading conversations:');
      AppLogger.debug('  Error: $e');
      AppLogger.debug('  Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// The inbox, or the archive — which only Discourse has, so it is reached
  /// on the Discourse proxy rather than through the shared interface.
  Future<FCConversationsResult> _fetch(
      IFCPrivateConversationProxy proxy, int startNum, int lastNum) {
    if (widget.archived && proxy is DiscoursePrivateConversationProxy) {
      return proxy.getArchivedConversationsAsync(startNum, lastNum);
    }
    return proxy.getConversationsAsync(startNum, lastNum);
  }

  Future<void> _loadConversations() async {
    final startNum = _currentPage * _itemsPerPage;
    final lastNum = startNum + _itemsPerPage - 1;
    AppLogger.debug('[ConversationList] Loading conversations (page $_currentPage, startNum: $startNum, lastNum: $lastNum)');
    final conversationProxy = SiteProxyFactory.getPrivateConversationProxy();

    final conversationsData = await _fetch(conversationProxy, startNum, lastNum);
    AppLogger.debug('[ConversationList] Conversations received: ${conversationsData.list.length} conversations');

    if (!conversationsData.result) {
      // A failed fetch must not render as an empty inbox — surface the
      // error state (with Retry) via loadConversations' catch instead.
      throw Exception(conversationsData.resultText?.isNotEmpty == true
          ? conversationsData.resultText
          : 'Failed to load messages');
    }

    if (mounted) {
      AppLogger.debug('   - Setting state with ${conversationsData.list.length} conversations');
      setState(() {
        if (_currentPage == 0) {
          _conversations = conversationsData.list;
        } else {
          _conversations = [...(_conversations ?? []), ...conversationsData.list];
        }
        _isLoading = false;
        _hasMoreData = conversationsData.list.length == _itemsPerPage;
      });
      AppLogger.debug('   - State updated: conversations=${_conversations?.length ?? "null"}, isLoading=$_isLoading');
    } else {
      AppLogger.debug('   - Widget not mounted, skipping setState');
    }
  }

  void resetAndLoadConversations() {
    _hasLoaded = false;
    _currentPage = 0;
    _hasMoreData = true;
    _isLoadingMore = false;
    loadConversations();
  }

  Future<void> _deleteConversation(String conversationId) async {
    try {
      final conversationProxy = SiteProxyFactory.getPrivateConversationProxy();
      await conversationProxy.leaveConversationAsync(conversationId, 1); // 1 = soft leave

      if (mounted) {
        setState(() {
          _conversations?.removeWhere((conversation) => conversation.conv_id == conversationId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.failedToLeaveConversation(e.toString()) ?? 'Failed to leave message: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _onConversationTap(FCConversationSummary conversation) async {
    // Use messageId if available to navigate directly to the appropriate message
    // Otherwise, calculate the last page to open at the most recent messages
    final pageSize = 20;
    int? lastPageStartNum;
    
    if (conversation.messageId != null && conversation.messageId!.isNotEmpty) {
      // messageId is available - will use getConversationByMessageAsync in ConversationPage
      // No need to calculate initialStartNum
    } else {
      // Fallback: calculate the last page
      final replyCount = int.tryParse(conversation.reply_count ?? '0') ?? 0;
      final totalMessages = replyCount + 1; // replies + first message
      lastPageStartNum = totalMessages > pageSize ? totalMessages - pageSize : 0;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationPage(
          siteContext: widget.siteContext,
          conversationId: conversation.conv_id ?? '',
          subject: conversation.subject ?? (AppLocalizations.of(context)?.noSubject ?? 'No subject'),
          initialStartNum: lastPageStartNum,
          anchorMessageId: conversation.messageId, // Use messageId to navigate to specific message
          onMarkUnread: () {
            final index = _conversations!.indexWhere((c) => c.conv_id == conversation.conv_id);
            if (index != -1) {
              setState(() {
                _conversations![index] = _conversations![index].copyWith(
                  newPost: true,
                );
              });
            }
          },
        ),
      ),
    );

    // Refresh the conversation list when returning from conversation page
    if (mounted) {
      AppLogger.debug('[ConversationList] Refreshing conversation list after returning from conversation');
      await loadConversations();
    }

    // If the conversation was left (result is true), remove it from the list
    if (result == true && mounted) {
      setState(() {
        _conversations?.removeWhere((c) => c.conv_id == conversation.conv_id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Only log when state meaningfully changes to reduce noise
    final currentConversationsCount = _conversations?.length;
    final currentIsLoading = _isLoading;
    final currentHasLoaded = _hasLoaded;
    if (_lastLoggedConversationsCount != currentConversationsCount || 
        _lastLoggedIsLoading != currentIsLoading || 
        _lastLoggedHasLoaded != currentHasLoaded) {
      AppLogger.debug('🏗️ [CONVERSATION_LIST] build() called');
      AppLogger.debug('   - isLoggedIn: ${widget.siteContext.isLoggedIn}');
      AppLogger.debug('   - conversations: ${currentConversationsCount ?? "null"}');
      AppLogger.debug('   - isLoading: $currentIsLoading');
      AppLogger.debug('   - hasLoaded: $currentHasLoaded');
      _lastLoggedConversationsCount = currentConversationsCount;
      _lastLoggedIsLoading = currentIsLoading;
      _lastLoggedHasLoaded = currentHasLoaded;
    }

    return VisibilityDetector(
      // Must be unique among live detectors: the inbox and archive lists are
      // both mounted (IndexedStack), and with one shared key the archive's
      // visibility was never reported, so it never loaded and spun forever.
      key: Key(widget.archived ? 'conversation_list_archive' : 'conversation_list'),
      onVisibilityChanged: (VisibilityInfo info) {
        final isVisible = info.visibleFraction > 0.5;

        // Only load conversations if they haven't been loaded yet (initial load)
        // Don't auto-refresh when returning from navigation - user can pull to refresh
        if (isVisible) loadIfNeeded();
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.siteContext.isLoggedInNotifier,
      builder: (context, isLoggedIn, child) {
        if (!isLoggedIn) {
          return NotSignedInView(
            siteContext: widget.siteContext,
            title: AppLocalizations.of(context)?.signInToViewMessages ?? 'Sign in to view messages',
            message: AppLocalizations.of(context)?.youNeedToBeSignedInToViewConversations ?? 'You need to be signed in to view your messages.',
            icon: Icons.mail_outline_rounded,
          );
        }

        return _buildConversationsContent(context);
      },
    );
  }

  Widget _buildConversationsContent(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)?.errorLoadingConversations(_error ?? 'Unknown error') ?? 'Error loading messages: $_error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: DesignTokens.spacingL),
            FilledButton(
              onPressed: loadConversations,
              child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
            ),
          ],
        ),
      );
    }

    if (_conversations == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_conversations!.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;
      return RefreshIndicator(
        onRefresh: loadConversations,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: DesignTokens.paddingScreen,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.archived ? Icons.archive_outlined : Icons.inbox_outlined,
                          size: 80,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: DesignTokens.spacingXL),
                        Text(
                          widget.archived
                              ? AppLocalizations.of(context)!.noArchivedMessages
                              : AppLocalizations.of(context)!.noConversations,
                          style: textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: DesignTokens.fontWeightBold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: DesignTokens.spacingS),
                        Text(
                          widget.archived
                              ? AppLocalizations.of(context)!.noArchivedMessagesHint
                              : AppLocalizations.of(context)!.noConversationsMessage,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadConversations,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: DesignTokens.paddingVerticalS,
        itemCount: _conversations!.length + 1,
        itemBuilder: (context, index) {
          if (index < _conversations!.length) {
            final conversation = _conversations![index];
            return ConversationListItem(
              conversation: conversation,
              onTap: () => _onConversationTap(conversation),
              onDelete: () => _deleteConversation(conversation.conv_id ?? ''),
            );
          } else {
            if (_hasMoreData) {
              return Padding(
                padding: DesignTokens.paddingS,
                child: const Center(child: CircularProgressIndicator()),
              );
            } else {
              return const SizedBox.shrink();
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    widget.siteContext.isLoggedInNotifier.removeListener(_authStateListener);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    try {
      await _loadMoreConversations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.errorLoadingMoreConversations(e.toString()) ?? 'Error loading more messages: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMoreConversations() async {
    AppLogger.debug('[ConversationList] Loading more conversations (page ${_currentPage + 1})');
    final conversationProxy = SiteProxyFactory.getPrivateConversationProxy();

    final nextPage = _currentPage + 1;
    final startNum = nextPage * _itemsPerPage;
    final lastNum = startNum + _itemsPerPage - 1;
    final conversationsData = await _fetch(conversationProxy, startNum, lastNum);
    AppLogger.debug('[ConversationList] More conversations received: ${conversationsData.list.length} conversations');

    if (!conversationsData.result) {
      // Surface the failure via _loadMoreData's snackbar instead of
      // silently ending pagination.
      throw Exception(conversationsData.resultText?.isNotEmpty == true
          ? conversationsData.resultText
          : 'Failed to load more conversations');
    }

    if (mounted) {
      setState(() {
        // Inbox and sent are paged separately and merged, so a message can
        // come back on more than one page; keep the first.
        final seen = {for (final c in _conversations!) c.conv_id};
        _conversations!.addAll(
            conversationsData.list.where((c) => seen.add(c.conv_id)));
        _currentPage = nextPage;
        _hasMoreData = conversationsData.list.length >= _itemsPerPage;
      });
    }
  }
}
