import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';

import '../theme/design_tokens.dart';
import 'widgets/simple_list_app_bar.dart';
import '../utils/error_message.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:discourse_ui/utils/app_navigation.dart';
import 'package:discourse_ui/views/widgets/discard_changes_scope.dart';

/// Phase 5.23 — change-email flow.
///
/// Discourse's `PUT /u/{username}/preferences/email.json` accepts a
/// single `email` param, then sends a verification link to the new
/// address — the change isn't live until the user clicks it from
/// their inbox. Rate-limited server-side (6/hr + 3/min).
///
/// Surfaced from Settings → Account → "Change email". Pops with
/// `true` on a successful request so the caller can show a confirm
/// snackbar in the settings list.
class ChangeEmailPage extends StatefulWidget {
  final SiteContext siteContext;

  const ChangeEmailPage({super.key, required this.siteContext});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    try {
      final proxy = SiteProxyFactory.getAccountProxy();
      // The proxy's `password` param is XF-shape cruft — Discourse's
      // email-change endpoint doesn't accept it. Pass empty string so
      // the IFC contract is satisfied.
      final result = await proxy.updateEmail(
        '',
        _emailController.text.trim(),
      );
      if (!mounted) return;
      if (result.result) {
        context.popOwnRoute(true);
      } else {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.resultText?.isNotEmpty == true
                  ? result.resultText!
                  : AppLocalizations.of(context)!.couldNotRequestEmailChange,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(describeError(e,
                fallback: AppLocalizations.of(context)!.accountRequestFailed,
                context: context))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return DiscardChangesScope(
      listenable: _emailController,
      hasChanges: () => _emailController.text.trim().isNotEmpty,
      isEdit: true,
      busy: _submitting,
      child: Scaffold(
      appBar: SimpleListAppBar(
        title: l10n.changeEmail,
        // The same labelled button every form ends its app bar with.
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: DesignTokens.spacingS),
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.send),
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
              Text(
                l10n.changeEmailExplanation,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: DesignTokens.spacingL),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                decoration: InputDecoration(
                  labelText: l10n.newEmailLabel,
                  hintText: 'you@example.com',
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return l10n.enterAnEmailAddress;
                  // Permissive email regex — Discourse re-validates
                  // server-side and would reject anything bad; we
                  // just want to catch obvious typos.
                  if (!v.contains('@') || !v.contains('.')) {
                    return l10n.emailLooksInvalid;
                  }
                  if (v.contains(' ')) return l10n.emailNoSpaces;
                  return null;
                },
              ),
              const SizedBox(height: DesignTokens.spacingXL),
              Text(
                l10n.changeEmailSecurityNote,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
