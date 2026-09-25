import 'package:flutter/material.dart';

import 'widgets/themed_web_view.dart';

/// Full-screen in-app web view for opening URLs (e.g. link forum external links).
class InAppWebViewPage extends StatelessWidget {
  final String url;
  final String title;

  const InAppWebViewPage({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ThemedWebView(url: url),
    );
  }
}
