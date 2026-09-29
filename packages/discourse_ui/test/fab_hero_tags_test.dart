import 'dart:async';

import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/views/chat/chat_channel_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Home keeps all its tabs mounted, so the Chat tab's own "Start new DM"
/// button sits in Home's route beside Home's New Topic / New Message
/// button. Two floating buttons with the default hero tag in one route is
/// a framework error on every push and pop from that route.
void main() {
  const forum = 'https://forum.example';
  final ctx = SiteContext(
    siteType: 'fab-hero-test',
    site: Site(
      id: null,
      name: 'Test',
      url: forum,
      description: '',
      endpoint: null,
      baseUrl: forum,
      logoUrl: null,
      backgroundUrl: null,
      siteType: 'fab-hero-test',
    ),
  )..updateLoginStateFromHeader(true);

  setUp(() {
    SiteProxyFactory.register('fab-hero-test', _Factory());
    SiteProxyService.initialize(ctx);
  });

  testWidgets('the Chat tab\'s button beside a page\'s own: routes change cleanly',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: ChatChannelListPage(siteContext: ctx, embedded: true),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(),
                floatingActionButton:
                    FloatingActionButton(onPressed: () {}),
              ),
            )),
            child: const Icon(Icons.edit_outlined),
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(find.byType(FloatingActionButton), findsNWidgets(2),
        reason: 'the page\'s button and the Chat tab\'s');

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    Navigator.of(tester.element(find.byType(AppBar))).pop();
    // Past the transition (the channels' spinner never settles).
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    expect(find.byType(AppBar), findsNothing);
  });
}

class _Factory implements SiteProxyFactory {
  @override
  IFCChatProxy createChatProxy(SiteContext context) => _Chat();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Channels that are still loading: the button shows regardless.
class _Chat implements IFCChatProxy {
  @override
  Future<FCChatChannelListResult> getMyChannelsAsync() =>
      Completer<FCChatChannelListResult>().future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
