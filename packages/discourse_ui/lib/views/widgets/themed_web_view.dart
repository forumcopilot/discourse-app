import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../services/appearance_sync.dart';

/// An [InAppWebView] that opens in the app's light/dark mode.
///
/// Waits for [AppearanceSync.prepare] — the forum's `forced_color_mode`
/// cookie — before loading, so a Discourse page renders in the right mode
/// on first paint. Until the page paints, the theme's surface covers the
/// view: a web view is white before its first frame, which flashed in
/// dark mode.
class ThemedWebView extends StatefulWidget {
  final String url;
  final InAppWebViewSettings? initialSettings;
  final Future<NavigationActionPolicy?> Function(
    InAppWebViewController controller,
    NavigationAction action,
  )? shouldOverrideUrlLoading;

  /// Back (the system's, and Android's gesture) goes to the previous web
  /// page while there is one, as in a browser, and leaves the page only
  /// from the first. In sign-in, Back from Create account or Forgot
  /// password used to abandon sign-in altogether.
  final bool backGoesThroughHistory;

  const ThemedWebView({
    super.key,
    required this.url,
    this.initialSettings,
    this.shouldOverrideUrlLoading,
    this.backGoesThroughHistory = false,
  });

  @override
  State<ThemedWebView> createState() => _ThemedWebViewState();
}

class _ThemedWebViewState extends State<ThemedWebView> {
  late final Future<void> _ready;
  bool _painted = false;
  Timer? _fallback;
  InAppWebViewController? _web;
  bool _canGoBack = false;

  Future<void> _historyChanged(InAppWebViewController controller) async {
    final canGoBack = await controller.canGoBack();
    if (mounted && canGoBack != _canGoBack) {
      setState(() => _canGoBack = canGoBack);
    }
  }

  @override
  void initState() {
    super.initState();
    _ready = AppearanceSync.prepare(widget.url);
    // Never strand the reader behind the cover if no paint callback
    // arrives (a slow challenge page, a platform that skips one).
    _ready.then((_) {
      if (mounted) _fallback = Timer(const Duration(seconds: 8), _reveal);
    });
  }

  @override
  void dispose() {
    _fallback?.cancel();
    super.dispose();
  }

  void _reveal() {
    _fallback?.cancel();
    if (!_painted && mounted) setState(() => _painted = true);
  }

  @override
  Widget build(BuildContext context) {
    final cover = ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: const Center(child: CircularProgressIndicator()),
    );
    final view = FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) return cover;
        return Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: widget.initialSettings,
              shouldOverrideUrlLoading: widget.shouldOverrideUrlLoading,
              onPageCommitVisible: (_, __) => _reveal(),
              onLoadStop: (_, __) => _reveal(),
              onReceivedError: (_, __, ___) => _reveal(),
              onWebViewCreated: (controller) => _web = controller,
              onUpdateVisitedHistory: widget.backGoesThroughHistory
                  ? (controller, _, __) => _historyChanged(controller)
                  : null,
            ),
            if (!_painted) Positioned.fill(child: IgnorePointer(child: cover)),
          ],
        );
      },
    );
    if (!widget.backGoesThroughHistory) return view;
    return PopScope(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _web?.goBack();
      },
      child: view,
    );
  }
}
