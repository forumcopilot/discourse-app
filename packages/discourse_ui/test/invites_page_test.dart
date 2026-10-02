import 'dart:async';

import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/views/invites_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

void main() {
  late _Invites proxy;
  setUp(() => proxy = _Invites());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: InvitesPage(siteContext: proxy.siteContext, proxy: proxy),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('load more appends rows, uses the offset and stops at the total',
      (tester) async {
    await pump(tester);
    expect(find.text('invite-1@example.com'), findsOneWidget);
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(proxy.calls, [('pending', 0), ('pending', 1)]);
    expect(find.text('invite-1@example.com'), findsOneWidget);
    expect(find.text('invite-2@example.com'), findsOneWidget);
    expect(find.text('Load more'), findsNothing);
  });

  testWidgets('later failure keeps rows and retries the same offset',
      (tester) async {
    await pump(tester);
    proxy.failMore = true;
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(find.text('invite-1@example.com'), findsOneWidget);
    final l10n = AppLocalizations.of(tester.element(find.byType(InvitesPage)))!;
    expect(find.text(l10n.errorForumDown), findsOneWidget);
    proxy.failMore = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(proxy.calls, [('pending', 0), ('pending', 1), ('pending', 1)]);
    expect(find.text('invite-2@example.com'), findsOneWidget);
  });

  testWidgets('switching filters ignores an outstanding older page',
      (tester) async {
    await pump(tester);
    final delayed = proxy.delayed = Completer<Map<String, dynamic>>();
    await tester.tap(find.text('Load more'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Expired (1)'));
    await tester.pumpAndSettle();
    expect(find.text('expired@example.com'), findsOneWidget);
    delayed.complete(_page('stale@example.com', 2));
    await tester.pumpAndSettle();
    expect(find.text('expired@example.com'), findsOneWidget);
    expect(find.text('stale@example.com'), findsNothing);
    expect(find.text('invite-1@example.com'), findsNothing);
    expect(proxy.calls.last, ('expired', 0));
  });

  testWidgets('refresh resets the offset and replaces loaded rows',
      (tester) async {
    await pump(tester);
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    final refresh =
        tester.widget<RefreshIndicator>(find.byType(RefreshIndicator));
    await refresh.onRefresh();
    await tester.pumpAndSettle();
    expect(proxy.calls.last, ('pending', 0));
    expect(find.text('invite-2@example.com'), findsNothing);
    expect(find.text('Load more'), findsOneWidget);
  });

  testWidgets('cannot send a duplicate next-page request while loading',
      (tester) async {
    await pump(tester);
    final delayed = proxy.delayed = Completer<Map<String, dynamic>>();
    await tester.tap(find.text('Load more'));
    await tester.tap(find.text('Load more'));
    await tester.pump();
    expect(proxy.calls, [('pending', 0), ('pending', 1)]);
    delayed.complete(_page('invite-2@example.com', 2));
    await tester.pumpAndSettle();
  });
}

Map<String, dynamic> _page(String email, int id) => {
      'invites': [
        {'id': id, 'email': email}
      ],
      'counts': {'pending': 2, 'expired': 1, 'redeemed': 0},
    };

class _Invites extends DiscourseInviteProxy {
  _Invites()
      : super(SiteContext(
          siteType: 'discourse',
          site: Site(
              id: null,
              name: 'Test',
              url: 'https://forum.example',
              baseUrl: 'https://forum.example',
              description: '',
              endpoint: null,
              logoUrl: null,
              backgroundUrl: null,
              siteType: 'discourse'),
        )..setLoginData(FCLoginResult(
            result: true,
            resultText: '',
            user: FCUser(id: '2', username: 'alice'))));

  final calls = <(String, int)>[];
  bool failMore = false;
  Completer<Map<String, dynamic>>? delayed;

  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    final filter = query!['filter'] as String;
    final offset = query['offset'] as int;
    calls.add((filter, offset));
    if (filter == 'expired') return _page('expired@example.com', 3);
    if (offset > 0) {
      if (failMore) {
        throw DiscourseApiException(
            statusCode: 503,
            method: 'GET',
            path: path,
            body: '{"errors":["Please try again later."]}');
      }
      if (delayed != null) return delayed!.future;
      return _page('invite-2@example.com', 2);
    }
    return _page('invite-1@example.com', 1);
  }
}
