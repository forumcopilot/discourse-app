import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';

import '../theme/design_tokens.dart';
import 'widgets/simple_list_app_bar.dart';

/// Phase 5.22 — inline profile editing.
///
/// Backed by `DiscourseAccountProxy.updateProfile`, which PUTs to
/// `/u/{username}.json` with the four user-editable fields Discourse's
/// `UserUpdater` recognises top-level: `name`, `bio_raw`, `location`,
/// `website`. The proxy method forwards keys verbatim — unknown keys
/// are silently dropped server-side, so the surface stays small and
/// future fields can be added without an SDK change.
///
/// Returns `true` from `Navigator.pop` on a successful save so the
/// caller (ProfileTab) can re-fetch user info and refresh the section.
class EditProfilePage extends StatefulWidget {
  final SiteContext siteContext;
  final FCUserInfoResult userInfo;

  const EditProfilePage({
    super.key,
    required this.siteContext,
    required this.userInfo,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Name editing intentionally omitted in 5.22: Discourse's
  // `user.name` field doesn't make it through the FCUser converter
  // (which writes the user's title into `displayText` instead), so
  // we can't seed the field with the existing value. Surfacing
  // Name editing properly will need an SDK conversion fix first;
  // for now, the web prefs link in Settings handles it.
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;
  late final TextEditingController _websiteController;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.userInfo.bio ?? '');
    _locationController = TextEditingController(
      text: widget.userInfo.location ?? '',
    );
    _websiteController = TextEditingController(
      text: widget.userInfo.website ?? '',
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final payload = <String, dynamic>{
      // Discourse `UserUpdater` accepts these as top-level params on
      // `PUT /u/{username}.json` — see field whitelist in
      // `app/services/user_updater.rb`. `bio_raw` writes to
      // `user_profile.bio_raw`; `location` / `website` live there
      // too.
      'bio_raw': _bioController.text.trim(),
      'location': _locationController.text.trim(),
      'website': _websiteController.text.trim(),
    };

    try {
      final proxy = SiteProxyFactory.getAccountProxy();
      final result = await proxy.updateProfile(
        widget.userInfo.id,
        payload,
      );
      if (!mounted) return;
      if (result.result) {
        // Pop with `true` so the caller reloads the user info — the
        // PUT response doesn't include the full updated profile, so
        // a re-fetch is the cleanest way to surface the new values.
        Navigator.of(context).pop(true);
      } else {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.resultText?.isNotEmpty == true
                  ? result.resultText!
                  : "Couldn't save profile",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: SimpleListAppBar(
        title: 'Edit profile',
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? SizedBox(
                    width: DesignTokens.iconSizeS,
                    height: DesignTokens.iconSizeS,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: DesignTokens.fontWeightSemiBold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spacingL),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Field(
                controller: _bioController,
                label: 'About me',
                hint: 'A short bio shown on your profile',
                maxLines: 6,
                minLines: 3,
                maxLength: 3000,
              ),
              const SizedBox(height: DesignTokens.spacingL),
              _Field(
                controller: _locationController,
                label: 'Location',
                hint: 'City, country, or anywhere',
                maxLength: 100,
              ),
              const SizedBox(height: DesignTokens.spacingL),
              _Field(
                controller: _websiteController,
                label: 'Website',
                hint: 'https://example.com',
                keyboardType: TextInputType.url,
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  // Discourse server-side `format_url()` is permissive
                  // (adds https:// if missing) but we still reject
                  // obvious bad input to save a round trip.
                  final v = value.trim();
                  if (v.contains(' ')) return 'No spaces in URLs';
                  return null;
                },
              ),
              const SizedBox(height: DesignTokens.spacingXL),
              Text(
                'Display name, email, password, and other account '
                'settings are managed under Account → Manage account '
                'on web. Your avatar can be changed by tapping the '
                'camera badge on your photo.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: DesignTokens.spacingXS, bottom: DesignTokens.spacingXS),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: DesignTokens.fontWeightSemiBold,
                ),
          ),
        ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            ),
            // Hide the maxLength counter on short fields — it adds
            // visual noise for one-line inputs but is useful on the
            // bio field where users care about the limit.
            counterText:
                (maxLines ?? 1) == 1 || maxLength == null ? '' : null,
          ),
        ),
      ],
    );
  }
}
