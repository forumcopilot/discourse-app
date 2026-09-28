import 'package:flutter/material.dart';
import 'package:discourse_ui/views/widgets/adaptive_app_bar_title.dart';

abstract class BaseForumAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BaseForumAppBar({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: AdaptiveAppBarTitle(title),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
      ),
      actions: buildActions(context),
    );
  }

  List<Widget> buildActions(BuildContext context);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
