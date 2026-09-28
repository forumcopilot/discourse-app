import 'package:discourse_core/discourse_core.dart' show DiscourseTopicTracking;
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/widgets.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

/// Keeps the topic rows under it current from the forum's live messages —
/// a topic read on another device, a reply in a topic you track — as
/// Discourse's web client does (`DiscourseTopicTracking.watchLive`).
///
/// Each watch costs a long-poll on the forum's message bus, which counts
/// against the User API Key's request budget, so this watches only while
/// it is [active], on screen (not under another page: [TickerMode]) and the
/// app is in the foreground. Coming back re-reads nothing by itself: the
/// lists refresh their counts when they reappear.
class TopicTrackingLive extends StatefulWidget {
  const TopicTrackingLive({
    super.key,
    required this.siteContext,
    required this.active,
    required this.child,
  });

  final SiteContext siteContext;
  final bool active;
  final Widget child;

  @override
  State<TopicTrackingLive> createState() => _TopicTrackingLiveState();
}

class _TopicTrackingLiveState extends State<TopicTrackingLive>
    with WidgetsBindingObserver {
  void Function()? _stop;
  ValueListenable<bool>? _onScreen;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final state = WidgetsBinding.instance.lifecycleState;
    _foreground = state == null || state == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final onScreen = TickerMode.getNotifier(context);
    if (onScreen != _onScreen) {
      _onScreen?.removeListener(_update);
      _onScreen = onScreen..addListener(_update);
    }
    _update();
  }

  @override
  void didUpdateWidget(covariant TopicTrackingLive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.siteContext != widget.siteContext) _unwatch();
    _update();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _update();
  }

  void _update() {
    final want = widget.active &&
        widget.siteContext.isLoggedIn &&
        _foreground &&
        (_onScreen?.value ?? true);
    if (want && _stop == null) {
      _stop = DiscourseTopicTracking.forSite(widget.siteContext)
          .watchLive(widget.siteContext);
    } else if (!want) {
      _unwatch();
    }
  }

  void _unwatch() {
    _stop?.call();
    _stop = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _onScreen?.removeListener(_update);
    _unwatch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
