import 'dart:io';

import 'package:discourse_ui/core/logging/app_logger.dart';
import 'package:discourse_ui/utils/file_picker_utils.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';
import 'full_screen_image_viewer.dart';
import 'user_avatar.dart';

/// The signed-in reader's avatar with a camera badge to change it — the
/// Profile tab's header.
///
/// Tapping the picture opens it full screen; the badge picks a photo (camera
/// or library on phones, a file on desktop), uploads it and refreshes the
/// avatar stored with the session, then calls [onChanged]. The badge shows
/// only where the forum lets this reader upload an avatar.
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
  File? _picked;
  bool _uploading = false;

  bool get _canUpload =>
      widget.siteContext.loginDataOutput?.canUploadAvatar ?? false;

  Future<void> _change() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    XFile? image;
    try {
      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        image = await FilePickerUtils.pickImage(imageQuality: ImageQuality.high);
      } else {
        // Camera or library. An avatar is shown small, so unlike a post's
        // images it is scaled and recompressed on the way.
        final source = await showModalBottomSheet<ImageSource>(
          context: context,
          builder: (sheet) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(l10n.takePhoto),
                  onTap: () => Navigator.pop(sheet, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(l10n.uploadImage),
                  onTap: () => Navigator.pop(sheet, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
        if (source == null) return;
        image = await ImagePicker().pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
      }
      if (image == null || !mounted) return;
      setState(() {
        _picked = File(image!.path);
        _uploading = true;
      });
      final result = await SiteProxyFactory.getAttachmentProxy()
          .uploadAvatarAsync('jpg', await image.readAsBytes());
      if (result.result != true) throw Exception(result.resultText);
      await _refreshSessionAvatar();
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _picked = null;
      });
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.avatarUploadedSuccessfully)));
      widget.onChanged?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _picked = null;
      });
      messenger.showSnackBar(SnackBar(content: Text(l10n.failedToPickImage2(e))));
    }
  }

  /// The session keeps the reader's avatar URL (the drawer and headers
  /// read it), so it is refreshed from the server after an upload.
  Future<void> _refreshSessionAvatar() async {
    try {
      final info = await SiteProxyFactory.getUserProxy()
          .getUserInfoAsync(widget.username, null);
      widget.siteContext.loginDataOutput?.user?.iconUrl = info.iconUrl ?? '';
      await widget.siteContext.saveToDevice();
    } catch (e) {
      AppLogger.debug('EditableProfileAvatar: refresh after upload failed: $e');
    }
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
              child: _picked != null
                  ? ClipOval(
                      child: Image.file(_picked!,
                          width: size, height: size, fit: BoxFit.cover),
                    )
                  : UserAvatar(
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
          if (_canUpload)
            // A 28dp badge in a 44dp target: the padding around it takes
            // the tap too, so it is not a fingertip-sized hunt.
            Positioned(
              right: -8,
              bottom: -8,
              child: Semantics(
                button: true,
                label: AppLocalizations.of(context)!.uploadImage,
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
