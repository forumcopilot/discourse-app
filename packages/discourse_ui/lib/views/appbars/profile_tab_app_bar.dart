import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../utils/url_utils.dart';
import '../../l10n/kit_strings.dart';

class ProfileTabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoggedIn;
  final SiteContext siteContext;
  const ProfileTabAppBar({
    required this.siteContext,
    this.isLoggedIn = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final username = siteContext.loginDataOutput?.user?.username;
    return AppBar(
      title: Text(l10n.profile),
      actions: [
        // Your profile's address on the forum, to send someone. Sign out
        // is a row on the tab now, not an icon beside the title.
        if (isLoggedIn && username != null && username.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: l10n.kit.share,
            onPressed: () => UrlUtils.shareUrl(
                '${siteContext.site.url.replaceAll(RegExp(r'/+$'), '')}'
                '/u/${Uri.encodeComponent(username)}'),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
