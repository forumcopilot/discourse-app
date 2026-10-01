import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:discourse_ui/views/widgets/cached_redirect_image.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/forum_media.dart';
import 'forum_image.dart';

class FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String heroTag;

  /// The forum's media rules: its secure uploads are fetched with the
  /// signed-in user's key, as they are in the post.
  final ForumMediaAuth? auth;

  const FullScreenImageViewer({
    Key? key,
    required this.imageUrls,
    this.initialIndex = 0,
    required this.heroTag,
    this.auth,
  }) : super(key: key);

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  bool _isSaving = false;
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  Future<void> _saveImage() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });
    // Looked up before the awaits below.
    final l10n = AppLocalizations.of(context)!;

    try {
      final imageUrl = widget.imageUrls[_currentIndex];

      // Request write permission only when saving
      bool hasPermission = false;
      try {
        if (Platform.isAndroid) {
          final deviceInfoPlugin = DeviceInfoPlugin();
          final deviceInfo = await deviceInfoPlugin.androidInfo;
          final sdkInt = deviceInfo.version.sdkInt;
          // For Android 10+ (API 29+), no permission needed for saving to Pictures directory
          hasPermission = sdkInt < 29 ? await Permission.storage.request().isGranted : true;
        } else if (Platform.isIOS) {
          // Only request permission to add photos, not to read them
          hasPermission = await Permission.photosAddOnly.request().isGranted;
        } else if (Platform.isMacOS) {
          // On macOS, try to request permission, but if plugin isn't available, proceed anyway
          // macOS will handle permissions through system dialogs if needed
          try {
            hasPermission = await Permission.photosAddOnly.request().isGranted;
          } catch (e) {
            // If permission handler fails on macOS, proceed anyway - system will prompt if needed
            hasPermission = true;
          }
        } else {
          hasPermission = true; // For other platforms like web, windows, linux
        }
      } catch (e) {
        // If permission check fails entirely, proceed anyway
        // The save operation itself may succeed or provide better error messages
        hasPermission = true;
      }

      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.permissionDeniedToSaveImage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
              ),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      final Uint8List bytes;
      final auth = widget.auth;
      if (auth != null && auth.mustAuthenticate(imageUrl)) {
        // A secure upload: fetched with the key, as it was shown.
        final response = await ForumMedia.getBytes(auth, imageUrl);
        final data = response.data;
        if (response.statusCode != 200 || data == null || data.isEmpty) {
          throw Exception('HTTP ${response.statusCode}');
        }
        bytes = data is Uint8List ? data : Uint8List.fromList(data);
      } else {
        // Get cached image file directly - much faster than resolving image provider
        final imageData = await ImageLoader.fetchImageFile(imageUrl);

        if (!await imageData.file.exists()) {
          throw Exception(l10n.imageFileNotFound);
        }

        bytes = await imageData.file.readAsBytes();
      }

      // Save image to gallery
      final fileName = "image_${DateTime.now().millisecondsSinceEpoch}";
      final result = await SaverGallery.saveImage(
        bytes,
        quality: 100,
        fileName: fileName,
        androidRelativePath: "Pictures", // Save to standard Pictures folder
        skipIfExists: false,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.isSuccess 
                ? l10n.imageSavedToGallery
                : l10n.failedToSaveImage(
                    result.errorMessage ?? l10n.unknownErrorFallback),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: result.isSuccess
                        ? Theme.of(context).colorScheme.onInverseSurface
                        : Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
            backgroundColor: result.isSuccess
                ? Theme.of(context).colorScheme.inverseSurface
                : Theme.of(context).colorScheme.errorContainer,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.failedToSaveImage(e.toString()),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
              ),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              duration: const Duration(seconds: 3),
            ),
          );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // The position among the post's images, not the image's URL (which
      // was the title, in 14sp); the theme's title size and icon sizes.
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: widget.imageUrls.length > 1
            ? Text('${_currentIndex + 1} / ${widget.imageUrls.length}')
            : null,
        actions: [
          IconButton(
            icon: Icon(_isSaving ? Icons.downloading : Icons.download),
            onPressed: _isSaving ? null : _saveImage,
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
                Navigator.of(context).pop();
              }
            },
            child: PhotoView(
              imageProvider: widget.auth?.mustAuthenticate(widget.imageUrls[index]) == true
                  ? forumImage(widget.imageUrls[index], widget.auth)
                  : CachedRedirectNetworkImageProvider(widget.imageUrls[index]),
              heroAttributes: index == widget.initialIndex ? PhotoViewHeroAttributes(tag: widget.heroTag) : null,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              loadingBuilder: (context, event) => Center(
                child: SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    value: event == null || event.expectedTotalBytes == null ? null : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
