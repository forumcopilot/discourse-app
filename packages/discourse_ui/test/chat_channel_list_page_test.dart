import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/views/chat/chat_channel_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// The Chat tab loads its channels as soon as it is built. Signed out, that
/// first load read `AppLocalizations.of(context)` while `initState()` was
/// still running, which Flutter's debug build rejects ("…was called before
/// ChatChannelListPageState.initState() completed") — seen on forum.aousd.org,
/// where chat is on, every time the home screen opened.
void main() {
  SiteContext signedOut() => SiteContext(
        siteType: 'discourse',
        site: Site(
          id: null,
          name: 'Example',
          url: 'https://forum.example',
          description: 'chat channel list test',
          endpoint: null,
          baseUrl: 'https://forum.example',
          logoUrl: null,
          backgroundUrl: null,
          siteType: 'discourse',
        ),
      );

  for (final embedded in [true, false]) {
    testWidgets(
        'opens signed out without an initState error'
        '${embedded ? ' (home-screen tab)' : ' (own route)'}', (tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ChatChannelListPage(
            siteContext: signedOut(),
            embedded: embedded,
          ),
        ),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      // Signed out, the tab asks the reader to sign in.
      expect(find.text('Sign in to use chat'), findsOneWidget);
    });
  }
}
