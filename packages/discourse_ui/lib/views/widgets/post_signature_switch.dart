import 'package:discourse_core/discourse_core.dart' show DiscoursePostSignature;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../settings_context.dart';

/// The member's switch for the host's "Sent from" line
/// (DiscourseHost.postSignature), for a host app's settings screen. Applies
/// to every forum at once. Shows nothing when the host installs no line.
class PostSignatureSwitch extends StatelessWidget {
  const PostSignatureSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final signature = DiscoursePostSignature.current;
    if (signature == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final settings = SettingsContext.instance;
    return Obx(() => SwitchListTile(
          title: Text(l10n.postSignatureTitle(signature.appName)),
          subtitle: Text(l10n.postSignatureDescription),
          value: settings.postSignature.value,
          onChanged: settings.setPostSignature,
        ));
  }
}
