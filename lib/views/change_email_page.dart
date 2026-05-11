import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';

import '../theme/design_tokens.dart';
import 'widgets/simple_list_app_bar.dart';

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
        Navigator.of(context).pop(true);
      } else {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.resultText?.isNotEmpty == true
                  ? result.resultText!
                  : "Couldn't request email change",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: SimpleListAppBar(
        title: 'Change email',
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? SizedBox(
                    width: DesignTokens.iconSizeS,
                    height: DesignTokens.iconSizeS,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : Text(
                    'Send',
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
              Text(
                'We’ll send a confirmation link to your new email. '
                'The change takes effect when you click it.',
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
                  labelText: 'New email',
                  hintText: 'you@example.com',
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusS),
                  ),
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return 'Enter an email address';
                  // Permissive email regex — Discourse re-validates
                  // server-side and would reject anything bad; we
                  // just want to catch obvious typos.
                  if (!v.contains('@') || !v.contains('.')) {
                    return 'That doesn’t look like an email';
                  }
                  if (v.contains(' ')) return 'No spaces in emails';
                  return null;
                },
              ),
              const SizedBox(height: DesignTokens.spacingXL),
              Text(
                'For added security, Discourse may require you to '
                'confirm via the link in the email. Check your spam '
                'folder if you don’t see it.',
                style: textTheme.bodySmall?.copyWith(
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
