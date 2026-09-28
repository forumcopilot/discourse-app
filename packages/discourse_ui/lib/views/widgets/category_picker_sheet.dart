import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

import '../../l10n/generated/app_localizations.dart';
import 'category_tile_mark.dart';
import 'sheet_title.dart';

/// Asks which category a new topic goes in, listing the categories the
/// reader may start topics in (subcategories under their parents), each
/// with its own mark. Returns the chosen category, or null.
Future<FCForum?> pickCategoryForNewTopic(
    BuildContext context, SiteContext siteContext) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context)!;
  final result =
      await SiteProxyFactory.getForumProxy().getForumAsync(false, '', false);
  if (!context.mounted) return null;
  // Parents first, their subcategories indented under them; only where
  // the reader may post (a parent they can't post in still heads its
  // subcategories).
  List<(FCForum, int)> flatten(FCForum f, int depth) {
    final children = [for (final c in f.childForums) ...flatten(c, depth + 1)];
    if (!f.canPost && children.isEmpty) return const [];
    return [(f, depth), ...children];
  }

  final rows = [for (final f in result.forums) ...flatten(f, 0)];
  if (!result.result || rows.isEmpty) {
    messenger.showSnackBar(
        SnackBar(content: Text(l10n.couldNotLoadCategories)));
    return null;
  }

  return showModalBottomSheet<FCForum>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetTitle(l10n.chooseCategory),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: rows.length,
              itemBuilder: (_, i) {
                final (forum, depth) = rows[i];
                return ListTile(
                  enabled: forum.canPost,
                  contentPadding: EdgeInsetsDirectional.only(
                      start: 16.0 + depth * 24, end: 16),
                  leading: CategoryTileMark.forId(siteContext, forum.id,
                      size: 24,
                      fallbackColorHex: forum.color,
                      fallbackLogoUrl: forum.logoUrl),
                  title: Text(forum.name),
                  onTap: () => Navigator.of(sheetContext).pop(forum),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
