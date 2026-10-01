import 'dart:async';

import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../services/topic_tracking_service.dart';
import '../../utils/error_dialog.dart';
import '../../utils/error_message.dart';
import '../listitems/category_card.dart';
import '../widgets/empty_state_view.dart';

/// The forum's categories, as Home's Categories view shows them: a card per
/// category, or — where the forum lists a parent's subcategories as boxes —
/// the parent as a heading over its subcategories' own cards.
///
/// Like Home's topic lists, this holds the data and hands its rows to the
/// page's scroll view ([buildItems]); it draws nothing itself unless
/// [standalone], when it is a page's whole scrolling body.
class CategoriesList extends StatefulWidget {
  const CategoriesList({
    super.key,
    required this.siteContext,
    this.isActive = true,
    this.onChanged,
    this.standalone = false,
  });

  final SiteContext siteContext;
  final bool isActive;

  /// Called when the rows change, so the page hosting them rebuilds.
  final VoidCallback? onChanged;
  final bool standalone;

  @override
  CategoriesListState createState() => CategoriesListState();
}

class CategoriesListState extends State<CategoriesList> {
  List<FCForum>? _forums;
  String? _error;
  bool _loading = true;
  bool _retried = false;

  @override
  void initState() {
    super.initState();
    refreshList();
  }

  @override
  void didUpdateWidget(covariant CategoriesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The counts on the cards are kept fresh as the view comes back.
    if (widget.isActive && !oldWidget.isActive) {
      unawaited(TopicTrackingService.refresh(widget.siteContext,
          maxAge: const Duration(seconds: 10)));
    }
  }

  void _changed() {
    if (!mounted) return;
    setState(() {});
    widget.onChanged?.call();
  }

  Future<void> refreshList() async {
    // Each card's "3 new" / "2 unread".
    unawaited(TopicTrackingService.refresh(widget.siteContext,
        maxAge: const Duration(seconds: 10)));
    _loading = true;
    _error = null;
    _changed();
    try {
      final result =
          await SiteProxyFactory.getForumProxy().getForumAsync(true, '', true);
      if (!mounted) return;
      if (!result.result) {
        // No reason from the forum: the heading alone says it
        // (buildErrorWidget), so the hint stays empty.
        _error = (result.resultText?.isNotEmpty ?? false)
            ? result.resultText
            : '';
        _loading = false;
        _changed();
        // One quiet retry: a cold start's network is often not ready yet.
        if (!_retried) {
          _retried = true;
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted && _error != null) refreshList();
          });
        }
        return;
      }
      _retried = false;
      _forums = result.forums;
      _loading = false;
      _changed();
    } catch (e) {
      if (!mounted) return;
      _error = extractErrorMessage(e);
      _loading = false;
      _changed();
    }
  }

  bool get isLoading => _loading && _forums == null;

  Widget? buildErrorWidget() {
    if (_error == null || (_forums?.isNotEmpty ?? false)) return null;
    return EmptyStateView.error(
      icon: Icons.error_outline_rounded,
      message: AppLocalizations.of(context)!.couldNotLoadCategories,
      hint: _error!.isEmpty ? null : describeError(_error, context: context),
      onRetry: refreshList,
    );
  }

  Widget buildEmptyState() => EmptyStateView(
        icon: Icons.forum_outlined,
        message: AppLocalizations.of(context)!.noCategoriesToDisplay,
      );

  /// The rows, or an empty list while loading or when there are none.
  List<Widget> buildItems() {
    final forums = _forums;
    if (forums == null) return const [];
    final caps =
        DiscourseSiteCapabilities.forSite(widget.siteContext.site.pluginUrl);
    final items = <Widget>[const SizedBox(height: 4)];
    for (final forum in forums) {
      // Uncategorized appears only when something is filed there.
      if (caps.isUncategorized(forum.id) && forum.topicCount == 0) continue;
      final boxes = forum.childForums.isNotEmpty &&
          (caps.categoryStyleFor(forum.id)?.subcategoriesAsBoxes ?? false);
      items.add(boxes
          ? CategoryGroup(siteContext: widget.siteContext, forum: forum)
          : CategoryCard(siteContext: widget.siteContext, forum: forum));
    }
    // Room for the New topic button, so the last card scrolls clear of it.
    items.add(const SizedBox(height: 88));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.standalone) return const SizedBox.shrink();
    if (isLoading) return const Center(child: CircularProgressIndicator());
    final error = buildErrorWidget();
    final items = buildItems();
    return RefreshIndicator(
      onRefresh: refreshList,
      child: ListView(
        children: [
          if (error != null) error,
          if (error == null && items.length <= 2) buildEmptyState(),
          if (error == null && items.length > 2) ...items,
        ],
      ),
    );
  }
}
