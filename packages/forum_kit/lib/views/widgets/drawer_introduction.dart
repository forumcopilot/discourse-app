import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the forum's drawer by itself, once per install, the first time a
/// forum is opened inside a host app (ABDA).
///
/// There the left edge means Back to the host's forum list, so the drawer,
/// which is the forum's map, opens only from its ☰ button, and a reader who
/// never taps it never sees the categories and tags it holds. Showing it
/// once, with a line on how to find it again ([SiteDrawer.introduction]),
/// teaches the button without giving the edge a second meaning.
///
/// It waits for the forum to have slid in and be on screen for a moment, and
/// gives way to the reader: if they are already touching the screen, or have
/// opened a page over the forum, it tries again with the next forum they
/// open. A reader who opens the drawer on their own has found it
/// ([markSeen]), and it never opens by itself.
///
/// Sits in the Scaffold's body, so it can open that Scaffold's drawer.
class DrawerIntroduction extends StatefulWidget {
  const DrawerIntroduction({
    super.key,
    required this.enabled,
    required this.onIntroduce,
    required this.child,
  });

  /// Whether this forum home is one to introduce the drawer on: pushed over
  /// a host's list. A root home (the single-forum app) opens its drawer from
  /// the edge, and needs no introduction.
  final bool enabled;

  /// Called just before the drawer opens, so it can show its introduction.
  final VoidCallback onIntroduce;

  final Widget child;

  /// How long the forum shows before its drawer slides out.
  @visibleForTesting
  static const delay = Duration(milliseconds: 700);

  @visibleForTesting
  static const prefsKey = 'forum_drawer_introduced';

  /// Records that the reader has seen the drawer, by themselves or through
  /// the introduction, so it is not opened for them again.
  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKey, true);
  }

  static Future<bool> _seen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefsKey) ?? false;
  }

  @override
  State<DrawerIntroduction> createState() => _DrawerIntroductionState();
}

class _DrawerIntroductionState extends State<DrawerIntroduction> {
  bool _started = false;
  bool _readerBusy = false;
  Timer? _timer;
  Animation<double>? _routeAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || !widget.enabled) return;
    _started = true;
    _whenRouteSettled();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    super.dispose();
  }

  /// The forum may still be sliding in: start counting once it is in place.
  void _whenRouteSettled() {
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.isCompleted) {
      _startTimer();
    } else {
      _routeAnimation = animation..addStatusListener(_onRouteStatus);
    }
  }

  void _onRouteStatus(AnimationStatus status) {
    if (!status.isCompleted) return;
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    _routeAnimation = null;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer(DrawerIntroduction.delay, _introduce);
  }

  Future<void> _introduce() async {
    if (!mounted || _readerBusy || !widget.enabled) return;
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
    if (await DrawerIntroduction._seen() || !mounted) return;
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold == null || !scaffold.hasDrawer || scaffold.isDrawerOpen) {
      return;
    }
    // Recorded first: shown once even if the app is closed while it is open.
    await DrawerIntroduction.markSeen();
    if (!mounted || _readerBusy) return;
    widget.onIntroduce();
    scaffold.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      // A reader already scrolling or tapping is not interrupted.
      onPointerDown: (_) => _readerBusy = true,
      child: widget.child,
    );
  }
}
