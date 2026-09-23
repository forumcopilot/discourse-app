import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The SDK sends the platform WebView's own User-Agent. A hard-coded
/// "Chrome/131" string got the app a Cloudflare 403 on
/// community.home-assistant.io and a "Browser Update Required" page on
/// forum.codefloe.com, both of which accept the phone's real WebView string.
void main() {
  late Future<String> Function() originalRead;
  late bool Function() originalHas;
  late Duration originalDelay;
  var reads = 0;

  setUp(() {
    originalRead = WebViewUserAgent.readPlatform;
    originalHas = WebViewUserAgent.hasSystemWebView;
    originalDelay = WebViewUserAgent.refreshDelay;
    WebViewUserAgent.hasSystemWebView = () => true;
    WebViewUserAgent.refreshDelay = const Duration(milliseconds: 10);
    reads = 0;
  });

  tearDown(() {
    WebViewUserAgent.readPlatform = originalRead;
    WebViewUserAgent.hasSystemWebView = originalHas;
    WebViewUserAgent.refreshDelay = originalDelay;
  });

  void platformSays(String ua) => WebViewUserAgent.readPlatform = () async {
        reads++;
        return ua;
      };

  test('first launch reads the WebView and remembers it', () async {
    SharedPreferences.setMockInitialValues({});
    platformSays('Mozilla/5.0 (Linux; Android 13; Pixel 4a; wv) Chrome/151.0.7922.199');

    expect(await WebViewUserAgent.resolve(), contains('Chrome/151'));
    expect(reads, 1);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('fc_webview_user_agent'), contains('Chrome/151'));
  });

  test('later launches use the stored value at once and refresh it for next time', () async {
    SharedPreferences.setMockInitialValues({'fc_webview_user_agent': 'old WebView/150'});
    platformSays('new WebView/152');

    // This session keeps the stored value: no mid-session User-Agent change.
    expect(await WebViewUserAgent.resolve(), 'old WebView/150');

    await Future<void>.delayed(const Duration(milliseconds: 50));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('fc_webview_user_agent'), 'new WebView/152');
  });

  test('no WebView to ask, or it fails: null, so the SDK falls back', () async {
    SharedPreferences.setMockInitialValues({});
    WebViewUserAgent.readPlatform = () async => throw UnimplementedError();
    expect(await WebViewUserAgent.resolve(), isNull);

    WebViewUserAgent.hasSystemWebView = () => false;
    platformSays('never read');
    expect(await WebViewUserAgent.resolve(), isNull);
    expect(reads, 0);
  });
}
