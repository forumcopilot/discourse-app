import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import '../../../../theme/design_tokens.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/empty_state_view.dart';
import 'package:discourse_ui/utils/app_navigation.dart';

class EditConversationPage extends StatefulWidget {
  final SiteContext siteContext;
  final String conversationId;

  /// Whether the viewer may open or close the message (Discourse's
  /// `can_close_topic`: staff, trust level 4, category moderators). Everyone
  /// else only edits the title.
  final bool canClose;

  const EditConversationPage({
    super.key,
    required this.siteContext,
    required this.conversationId,
    this.canClose = false,
  });

  @override
  State<EditConversationPage> createState() => _EditConversationPageState();
}

class _EditConversationPageState extends State<EditConversationPage> {
  late final TextEditingController _titleController;
  bool? _conversationOpen;

  /// The open state as loaded, so a save only sends a status change the
  /// user actually made.
  bool? _initialOpen;
  bool _isSubmitting = false;
  bool _hasChanges = false;
  bool _controllerInitialized = false;

  // Cache the future to prevent FutureBuilder from recreating it on every build
  late final Future<FCRawConversationResult> _rawConversationFuture;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _titleController.addListener(_onFieldChanged);
    // Cache the future so it doesn't recreate on every build
    _rawConversationFuture = SiteProxyFactory.getPrivateConversationProxy().getRawConversationAsync(widget.conversationId);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFieldChanged);
    _titleController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<bool> _handleSubmit() async {
    if (_titleController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.titleCannotBeEmpty ?? 'Title cannot be empty'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return false;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      final result = await SiteProxyFactory.getPrivateConversationProxy().saveRawConversationAsync(
        widget.conversationId,
        conversationTitle: _titleController.text.trim(),
        // Every save used to send the open state, so for anyone who cannot
        // close messages the title saved and then PUT /t/{id}/status failed
        // with a permission error. Only a change made by someone allowed to
        // make it is sent now.
        conversationOpen: widget.canClose && _conversationOpen != _initialOpen
            ? _conversationOpen
            : null,
      );

      if (!result.result) {
        final errorMessage = result.resultText?.trim();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage ?? AppLocalizations.of(context)?.failedToSaveConversation ?? 'Failed to save message'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return false;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.conversationUpdatedSuccessfully ?? 'Message updated successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        context.popOwnRoute(true); // Return true to indicate success
      }

      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.error(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.editConversation2,
        ),
        actions: [
          // A labelled button, as MessageComposePage's: it was an unlabelled
          // save icon in the same colour as Back.
          Padding(
            padding: const EdgeInsetsDirectional.only(end: DesignTokens.spacingS),
            child: FilledButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AppLocalizations.of(context)!.save),
            ),
          ),
        ],
      ),
      body: FutureBuilder<FCRawConversationResult>(
        future: _rawConversationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return EmptyStateView(
              icon: Icons.error_outline,
              message: AppLocalizations.of(context)!.failedToLoadMessage2,
              hint: snapshot.error.toString(),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)?.goBack ?? 'Go Back'),
                ),
              ],
            );
          }

          if (!snapshot.hasData || !snapshot.data!.result) {
            return EmptyStateView(
              icon: Icons.error_outline,
              message: AppLocalizations.of(context)!.cannotEditThisConversation,
              hint: snapshot.data?.resultText ?? 'Unknown error',
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)?.goBack ?? 'Go Back'),
                ),
              ],
            );
          }

          final data = snapshot.data!;

          // Initialize fields if not already set (defer controller update to avoid setState during build)
          if (!_controllerInitialized) {
            _controllerInitialized = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && data.conversationTitle != null && _titleController.text.isEmpty) {
                _titleController.removeListener(_onFieldChanged);
                _titleController.text = data.conversationTitle!;
                _titleController.addListener(_onFieldChanged);
              }
            });
          }
          if (_conversationOpen == null) {
            _conversationOpen = data.conversationOpen ?? true;
            _initialOpen = _conversationOpen;
          }

          return SingleChildScrollView(
            padding: DesignTokens.paddingL,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title field: the theme's outlined field with its label in
                // it, as MessageComposePage's.
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.title,
                    hintText: AppLocalizations.of(context)?.enterConversationTitle ?? 'Enter message title',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: DesignTokens.spacingL),

                // Options section: only the open/closed switch, for those
                // who may use it.
                if (widget.canClose)
                  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.options,
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: DesignTokens.fontWeightMedium,
                      ),
                    ),
                    SizedBox(height: DesignTokens.spacingS),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: DesignTokens.opacityLow),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                      ),
                      child: Column(
                        children: [
                          // Open for replies: the list tile's own title and
                          // subtitle styles.
                          SwitchListTile(
                            title: Text(AppLocalizations.of(context)!.conversationOpen),
                            subtitle: Text(
                              _conversationOpen == true
                                  ? AppLocalizations.of(context)!.messageOpenForReplies
                                  : AppLocalizations.of(context)!.messageClosedForReplies,
                            ),
                            value: _conversationOpen ?? true,
                            onChanged: (value) {
                              setState(() {
                                _conversationOpen = value;
                                _hasChanges = true;
                              });
                            },
                            activeThumbColor: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
