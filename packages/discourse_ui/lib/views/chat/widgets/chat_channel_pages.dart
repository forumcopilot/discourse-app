import 'package:discourse_core/discourse_core.dart' show DiscourseChatProxy;
import 'package:flutter/foundation.dart';
import 'package:forumcopilot_sdk/models/entities/fc_chat_channel.dart';

import '../../../services/site_proxy_service.dart';

enum _Fetch { reload, more, refresh }

/// The forum's public channels (`GET /chat/api/channels`) a page at a time,
/// as the web's channel collection reads them: in the server's order, the
/// next page appended, and read again in place.
///
/// It outlives the widgets that show it, so pages the reader loaded stay
/// loaded when they open a channel and come back, join one, pull to
/// refresh, or switch to DMs and back; only a new owner (another account
/// or forum) starts over.
class ChatChannelPages extends ChangeNotifier {
  ChatChannelPages({this.status, this.filter = ''});

  /// Rows asked for per page.
  static const int pageSize = 25;

  /// The most rows the server returns at once
  /// (`Chat::ChannelFetcher::MAX_PUBLIC_CHANNEL_RESULTS`).
  static const int maxLimit = 100;

  /// `open`, `closed` or `archived`; null for every status.
  String? status;

  /// Part of a channel's name or slug (the server's `filter`).
  String filter;

  final List<FCChatChannel> _rows = [];

  /// Rows the server has given so far: the next page's offset. Not
  /// `_rows.length`, which a page repeating a row (an unordered listing can)
  /// leaves short.
  int _consumed = 0;
  List<FCChatChannel> _lastPage = const [];
  bool _loaded = false;
  bool _loading = false;
  bool _hasMore = false;
  String? _error;
  _Fetch? _failed;
  int _generation = 0;
  int _pages = 0;
  bool _disposed = false;

  /// The channels read so far, in the server's order. Never a direct
  /// message: those are not the forum's to browse.
  List<FCChatChannel> get channels => [
        for (final c in _rows)
          if (c.chatableType != 'DirectMessage') c
      ];

  /// The rows the last page brought (not a refresh).
  List<FCChatChannel> get lastPage => _lastPage;

  /// Counts the pages read (first and later; not refreshes), so a listener
  /// can tell a new page from any other change.
  int get pagesRead => _pages;

  bool get loaded => _loaded;
  bool get loading => _loading;
  bool get hasMore => _hasMore;

  /// Why the last request failed (empty when the server gave no reason);
  /// null when it did not.
  String? get error => _error;

  /// Reads the first page unless it has been read or is being read.
  void ensureLoaded() {
    if (_loaded || _loading) return;
    _fetch(_Fetch.reload, quiet: true);
  }

  /// Starts again from the first page (another search or status). What was
  /// shown goes at once: it answered another question.
  Future<void> reload() {
    _rows.clear();
    _consumed = 0;
    _hasMore = false;
    _loaded = false;
    _lastPage = const [];
    return _fetch(_Fetch.reload);
  }

  /// Reads the next page.
  Future<void> loadMore() async {
    if (_loading || !_hasMore) return;
    await _fetch(_Fetch.more);
  }

  /// Reads the channels already shown again, in one request up to the
  /// server's limit; rows beyond it are kept as they were.
  Future<void> refresh() => _fetch(_loaded ? _Fetch.refresh : _Fetch.reload);

  /// Repeats what failed: a failed refresh is read again, not appended to.
  Future<void> retry() => _fetch(_failed ?? _Fetch.reload);

  Future<void> _fetch(_Fetch kind, {bool quiet = false}) async {
    final proxy = SiteProxyService.getChatProxy();
    final generation = ++_generation;
    _loading = true;
    _error = null;
    if (!quiet) notifyListeners();
    if (proxy is! DiscourseChatProxy) {
      _settle(generation, error: '', failed: kind);
      return;
    }
    final offset = kind == _Fetch.more ? _consumed : 0;
    // A refresh asks for one more than it has, so a full answer means more
    // exist; asking for exactly as many came back "full" with nothing left,
    // and a dead Load more reappeared.
    final limit = kind == _Fetch.refresh
        ? (_consumed + 1).clamp(pageSize, maxLimit)
        : pageSize;
    final result = await proxy.browseChannelsAsync(
        filter: filter, status: status, offset: offset, limit: limit);
    if (_disposed || generation != _generation) return;
    if (!result.result) {
      _settle(generation, error: result.resultText ?? '', failed: kind);
      return;
    }
    final fresh = result.channels;
    final full = fresh.length >= limit;
    switch (kind) {
      case _Fetch.reload:
        _rows
          ..clear()
          ..addAll(fresh);
        _consumed = fresh.length;
        _hasMore = full;
      case _Fetch.more:
        final known = {for (final c in _rows) c.id};
        _rows.addAll(fresh.where((c) => !known.contains(c.id)));
        _consumed += fresh.length;
        _hasMore = full;
      case _Fetch.refresh:
        // More was loaded than one request returns: the rows past it stay.
        final beyond = _consumed > limit;
        final ids = {for (final c in fresh) c.id};
        final kept = beyond
            ? _rows.skip(limit).where((c) => !ids.contains(c.id)).toList()
            : const <FCChatChannel>[];
        _rows
          ..clear()
          ..addAll(fresh)
          ..addAll(kept);
        if (beyond) {
          _consumed = fresh.length + (_consumed - limit);
        } else {
          _consumed = fresh.length;
          _hasMore = full;
        }
    }
    if (kind != _Fetch.refresh) {
      _lastPage = fresh;
      _pages++;
    }
    _loaded = true;
    _settle(generation);
  }

  void _settle(int generation, {String? error, _Fetch? failed}) {
    if (_disposed || generation != _generation) return;
    _loading = false;
    _error = error;
    _failed = failed;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
