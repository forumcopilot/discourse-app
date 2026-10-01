import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/logging/app_logger.dart';
import '../../theme/design_tokens.dart';
import '../../utils/discourse_color.dart';
import '../../utils/discourse_icons.dart';
import '../../utils/file_picker_utils.dart';
import '../widgets/cached_redirect_image.dart';
import '../widgets/sheet_title.dart';

/// A group's flair, as Discourse draws it on a person's picture: the
/// group's icon (or uploaded image) on the group's colour.
///
/// [flairUrl] is what the server sends as `flair_url`: a Font Awesome name
/// ("far-face-smile") or an image URL. The icon is the nearest Material
/// one; a name with no match keeps the colour with a generic mark, never
/// nothing, so a chosen flair always shows.
class UserFlairBadge extends StatelessWidget {
  const UserFlairBadge({
    super.key,
    required this.flairUrl,
    this.bgHex,
    this.fgHex,
    this.size = 24,
    this.ringColor,
    this.semanticLabel,
  });

  final String flairUrl;
  final String? bgHex;
  final String? fgHex;
  final double size;

  /// A ring in the colour behind it, where it sits over a picture's edge.
  final Color? ringColor;
  final String? semanticLabel;

  bool get _isImage => flairUrl.contains('/');

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bg = (bgHex == null ? null : parseDiscourseHex(bgHex!)) ??
        (_isImage ? Colors.transparent : colorScheme.secondaryContainer);
    final fg = (fgHex == null ? null : parseDiscourseHex(fgHex!)) ??
        (bgHex == null
            ? colorScheme.onSecondaryContainer
            : (ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
                ? Colors.white
                : Colors.black87));
    final ring = ringColor == null ? 0.0 : 2.0;
    final inner = size - ring * 2;
    final Widget mark = _isImage
        ? ClipOval(
            child: CachedRedirectImage(
              imageUrl: flairUrl,
              width: inner,
              height: inner,
              fit: BoxFit.cover,
            ),
          )
        : Icon(
            materialIconForDiscourseIcon(flairUrl) ?? Icons.shield_outlined,
            size: inner * 0.62,
            color: fg,
          );
    return Semantics(
      label: semanticLabel,
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: ringColor == null
              ? null
              : Border.all(color: ringColor!, width: ring),
        ),
        alignment: Alignment.center,
        child: mark,
      ),
    );
  }
}

/// A photo picked for the profile: its bytes and file extension.
typedef PickedPhoto = ({Uint8List bytes, String extension});

/// Picks a photo from [source] (the camera or the library), or a file on
/// desktop, scaled so its longer side is at most [maxSide]. Null when the
/// reader cancelled.
Future<PickedPhoto?> pickProfilePhoto(
  ImageSource source, {
  double maxSide = 1024,
}) async {
  XFile? image;
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    image = await FilePickerUtils.pickImage(imageQuality: ImageQuality.high);
  } else {
    image = await ImagePicker().pickImage(
      source: source,
      maxWidth: maxSide,
      maxHeight: maxSide,
      imageQuality: 85,
    );
  }
  if (image == null) return null;
  final name = image.name.toLowerCase();
  final dot = name.lastIndexOf('.');
  final ext = dot < 0 ? 'jpg' : name.substring(dot + 1);
  return (bytes: await image.readAsBytes(), extension: ext.isEmpty ? 'jpg' : ext);
}

/// The session keeps the reader's picture (the drawer and headers read
/// it), so it is refreshed from the server after the picture changes.
Future<void> refreshSessionAvatar(SiteContext siteContext) async {
  final username = siteContext.currentUsername;
  if (username == null) return;
  try {
    final info =
        await SiteProxyFactory.getUserProxy().getUserInfoAsync(username, null);
    siteContext.loginDataOutput?.user?.iconUrl = info.iconUrl ?? '';
    await siteContext.saveToDevice();
  } catch (e) {
    AppLogger.debug('refreshSessionAvatar failed: $e');
  }
}

/// Opens a bottom sheet with the app's sheet chrome: the theme's drag
/// handle, [title] as every sheet names itself, an optional explanation,
/// then [children], scrolling when they are taller than the screen allows.
Future<T?> showProfileSheet<T>({
  required BuildContext context,
  required String title,
  String? subtitle,
  required List<Widget> Function(BuildContext sheetContext) children,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final textTheme = Theme.of(sheetContext).textTheme;
      final colorScheme = Theme.of(sheetContext).colorScheme;
      return SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: DesignTokens.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetTitle(title),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL, 0,
                      DesignTokens.spacingL, DesignTokens.spacingS),
                  child: Text(subtitle,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant)),
                ),
              ...children(sheetContext),
            ],
          ),
        ),
      );
    },
  );
}
