import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';
import '../profile/profile_common.dart';
import '../profile/profile_pickers.dart';
import 'full_screen_image_viewer.dart';
import 'user_avatar.dart';

/// The signed-in reader's avatar with a camera badge to change it — the
/// Profile tab's header.
///
/// Tapping the picture opens it full screen; the badge picks a photo (camera
/// or library on phones, a file on desktop), uploads it and refreshes the
/// avatar stored with the session, then calls [onChanged]. The badge opens
/// the profile picture sheet, which offers what the forum allows.
class EditableProfileAvatar extends StatefulWidget {
  const EditableProfileAvatar({
    super.key,
    required this.siteContext,
    required this.username,
    this.avatarUrl,
    this.radius = 32,
    this.onChanged,
  });

  final SiteContext siteContext;
  final String username;
  final String? avatarUrl;
  final double radius;
  final VoidCallback? onChanged;

  @override
  State<EditableProfileAvatar> createState() => _EditableProfileAvatarState();
}

class _EditableProfileAvatarState extends State<EditableProfileAvatar> {
  bool _uploading = false;

  /// The profile picture sheet: a new photo, the letter avatar, the
  /// Gravatar, an earlier upload or one of the forum's own pictures —
  /// whichever the forum allows. The session's copy of the picture (the
  /// drawer and headers read it) is refreshed after a change.
  Future<void> _change() async {
    final changed = await changeProfilePicture(
      context: context,
      siteContext: widget.siteContext,
      onUploading: (busy) {
        if (mounted) setState(() => _uploading = busy);
      },
    );
    if (!changed) return;
    await refreshSessionAvatar(widget.siteContext);
    if (mounted) widget.onChanged?.call();
  }

  void _viewFull() {
    final url = widget.avatarUrl;
    if (url == null || url.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FullScreenImageViewer(
        imageUrls: [url],
        initialIndex: 0,
        heroTag: 'profile_picture_${widget.username}',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = widget.radius * 2;
    return SizedBox(
      width: size + 8,
      height: size + 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: GestureDetector(
              onTap: _viewFull,
              child: UserAvatar(
                username: widget.username,
                iconUrl: widget.avatarUrl,
                radius: widget.radius,
              ),
            ),
          ),
          if (_uploading)
            Positioned(
              left: 0,
              top: 0,
              width: size,
              height: size,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: DesignTokens.iconSizeL,
                  height: DesignTokens.iconSizeL,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          // A 28dp badge in a 44dp target: the padding around it takes
            // the tap too, so it is not a fingertip-sized hunt.
            Positioned(
              right: -8,
              bottom: -8,
              child: Semantics(
                button: true,
                label: AppLocalizations.of(context)!.changeProfilePicture,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _uploading ? null : _change,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.surface, width: 2),
                      ),
                      child: Icon(Icons.photo_camera_outlined,
                          size: DesignTokens.iconSizeS,
                          color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
