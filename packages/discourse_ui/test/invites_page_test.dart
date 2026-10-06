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

  testWidgets('refresh keeps the rows on screen until the first page answers',
      (tester) async {
    await pump(tester);
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    final first = proxy.delayedFirst = Completer<Map<String, dynamic>>();
    final refresh =
        tester.widget<RefreshIndicator>(find.byType(RefreshIndicator));
    final refreshed = refresh.onRefresh();
    await tester.pump();
    // No full-screen spinner over an emptied list while it reloads.
    expect(find.text('invite-1@example.com'), findsOneWidget);
    expect(find.text('invite-2@example.com'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    first.complete(_page('invite-1@example.com', 1));
    await refreshed;
    await tester.pumpAndSettle();
    // The first page then stands for the list, and Load more goes on from it.
    expect(proxy.calls.last, ('pending', 0));
    expect(find.text('invite-2@example.com'), findsNothing);
    expect(find.text('Load more'), findsOneWidget);
  });

  testWidgets('a failed refresh keeps the rows and says why', (tester) async {
    await pump(tester);
    proxy.failFirst = true;
    final refresh =
        tester.widget<RefreshIndicator>(find.byType(RefreshIndicator));
    await refresh.onRefresh();
    await tester.pump();
    final l10n = AppLocalizations.of(tester.element(find.byType(InvitesPage)))!;
    expect(find.text('invite-1@example.com'), findsOneWidget);
    expect(find.descendant(of: find.byType(SnackBar), matching: find.text(l10n.errorForumDown)),
        findsOneWidget);
  });

  testWidgets('revoking removes the row in place; the next page starts a row '
      'earlier', (tester) async {
    proxy.pending.add(('invite-3@example.com', 3));
    await pump(tester);
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(find.text('Pending (3)'), findsOneWidget);
    final calls = [...proxy.calls];
    await tester.tap(find.descendant(
        of: find.widgetWithText(ListTile, 'invite-1@example.com'),
        matching: find.byIcon(Icons.delete_outline)));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Revoke'));
    await tester.pump();
    // No reload: no spinner, and the rows already loaded stay.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pumpAndSettle();
    expect(proxy.deleted, [1]);
    expect(proxy.calls, calls);
    expect(find.text('invite-1@example.com'), findsNothing);
    expect(find.text('invite-2@example.com'), findsOneWidget);
    expect(find.text('Pending (2)'), findsOneWidget);
    // Invite 3 moved up to offset 1 on the server: asking from 2 skipped it.
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(proxy.calls.last, ('pending', 1));
    expect(find.text('invite-3@example.com'), findsOneWidget);
    expect(find.text('Load more'), findsNothing);
  });

  testWidgets('a row that comes round again on the next page is listed once',
      (tester) async {
    await pump(tester);
    // Someone invites from the web meanwhile: everything moves down a row.
    proxy.pending.insert(0, ('invite-0@example.com', 9));
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(proxy.calls.last, ('pending', 1));
    expect(find.text('invite-1@example.com'), findsOneWidget);
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(find.text('invite-1@example.com'), findsOneWidget);
    expect(find.text('invite-2@example.com'), findsOneWidget);
  });

  testWidgets('a new invite link goes on top without reloading the list',
      (tester) async {
    await pump(tester);
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    final calls = [...proxy.calls];
    await tester.tap(find.text('New invite link'));
    await tester.pumpAndSettle();
    // The link sheet: close it.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(proxy.calls, calls);
    expect(find.text('https://forum.example/invites/new'), findsOneWidget);
    expect(find.text('invite-2@example.com'), findsOneWidget);
    expect(find.text('Pending (3)'), findsOneWidget);
    final rows = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((t) => (t.title as Text).data)
        .toList();
    expect(rows.first, 'https://forum.example/invites/new');
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

Map<String, dynamic> _page(String email, int id, {int pending = 2}) => {
      'invites': [
        {'id': id, 'email': email, 'can_delete_invite': true}
      ],
      'counts': {'pending': pending, 'expired': 1, 'redeemed': 0},
    };

/// A forum's pending invites, one per page, newest first.
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

  final pending = <(String, int)>[
    ('invite-1@example.com', 1),
    ('invite-2@example.com', 2),
  ];
  final calls = <(String, int)>[];
  final deleted = <int>[];
  bool failMore = false;
  bool failFirst = false;
  Completer<Map<String, dynamic>>? delayed;
  Completer<Map<String, dynamic>>? delayedFirst;

  DiscourseApiException _down(String path) => DiscourseApiException(
      statusCode: 503,
      method: 'GET',
      path: path,
      body: '{"errors":["Please try again later."]}');

  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    if (path == '/site/settings.json') return const {};
    final filter = query!['filter'] as String;
    final offset = query['offset'] as int;
    calls.add((filter, offset));
    if (filter == 'expired') return _page('expired@example.com', 3);
    if (offset > 0) {
      if (failMore) throw _down(path);
      if (delayed != null) return delayed!.future;
    } else {
      if (failFirst) throw _down(path);
      final first = delayedFirst;
      if (first != null) {
        delayedFirst = null;
        return first.future;
      }
    }
    final rows = pending.skip(offset).take(1).toList();
    return {
      'invites': [
        for (final (email, id) in rows)
          {'id': id, 'email': email, 'can_delete_invite': true}
      ],
      'counts': {'pending': pending.length, 'expired': 1, 'redeemed': 0},
    };
  }

  @override
  Future<Map<String, dynamic>> apiPost(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    pending.insert(0, ('', 50));
    return {
      'id': 50,
      'link': 'https://forum.example/invites/new',
      'can_delete_invite': true,
    };
  }

  @override
  Future<Map<String, dynamic>> apiDelete(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    final id = int.parse(query!['id'] as String);
    deleted.add(id);
    pending.removeWhere((r) => r.$2 == id);
    return const {};
  }
}
