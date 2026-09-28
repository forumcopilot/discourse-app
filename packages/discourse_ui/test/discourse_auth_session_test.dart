import 'package:discourse_ui/services/discourse_auth_session.dart';
import 'package:discourse_ui/views/discourse_login_webview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sign-in (and sign-up) open in the system's browser sheet and come back
/// with Discourse's redirect to `discourse://auth_redirect`. Backing out is
/// not an error; a phone with no browser to open the sheet in gets the app's
/// own sign-in page instead.
void main() {
  const keyRequest = 'https://forum.example/user-api-key/new?nonce=n';
  bool isCallback(Uri uri) =>
      uri.scheme == 'discourse' && uri.host == 'auth_redirect';

  late BuildContext context;
  Future<void> pumpHost(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (c) {
        context = c;
        return const Scaffold(body: Text('Forum'));
      }),
    ));
  }

  tearDown(() => DiscourseAuthSession.debugAuthenticate = null);

  testWidgets('opens the key request and returns the forum\'s redirect',
      (tester) async {
    await pumpHost(tester);
    String? opened;
    String? scheme;
    DiscourseAuthSession.debugAuthenticate = (url, callbackScheme) async {
      opened = url;
      scheme = callbackScheme;
      return 'discourse://auth_redirect?payload=abc';
    };

    final result = await DiscourseAuthSession.authorize(context,
        url: keyRequest, isCallback: isCallback, title: 'Sign in');

    expect(opened, keyRequest);
    expect(scheme, 'discourse');
    expect(result?.queryParameters['payload'], 'abc');
  });

  testWidgets('backing out of the sheet is null, not an error',
      (tester) async {
    await pumpHost(tester);
    DiscourseAuthSession.debugAuthenticate = (_, __) async =>
        throw PlatformException(code: 'CANCELED', message: 'User canceled');

    final result = await DiscourseAuthSession.authorize(context,
        url: keyRequest, isCallback: isCallback, title: 'Sign in');
    expect(result, isNull);
    expect(find.byType(DiscourseLoginWebViewPage), findsNothing);
  });

  testWidgets('a redirect somewhere else is not taken for the answer',
      (tester) async {
    await pumpHost(tester);
    DiscourseAuthSession.debugAuthenticate =
        (_, __) async => 'discourse://elsewhere?payload=abc';

    final result = await DiscourseAuthSession.authorize(context,
        url: keyRequest, isCallback: isCallback, title: 'Sign in');
    expect(result, isNull);
  });

  testWidgets('with no browser to open the sheet in, the in-app page opens',
      (tester) async {
    await pumpHost(tester);
    DiscourseAuthSession.debugAuthenticate = (_, __) async =>
        throw PlatformException(code: 'NO_BROWSER', message: 'none');

    // The page is a web view, which a test cannot run; that it is pushed,
    // at the key request, is the point.
    Route<dynamic>? pushed;
    final navigator = Navigator.of(context);
    DiscourseAuthSession.authorize(context,
        url: keyRequest, isCallback: isCallback, title: 'Sign in');
    await tester.pump();
    navigator.popUntil((route) {
      pushed ??= route;
      return true;
    });
    expect(pushed, isA<MaterialPageRoute<Uri?>>());
    final page = (pushed! as MaterialPageRoute<Uri?>).builder(context)
        as DiscourseLoginWebViewPage;
    expect(page.url, keyRequest);
    expect(page.title, 'Sign in');
  });
}
