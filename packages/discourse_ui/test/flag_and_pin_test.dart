import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/widgets/discourse_report_dialog.dart';
import 'package:discourse_ui/views/widgets/feature_topic_sheet.dart';
import 'package:discourse_ui/views/widgets/suspend_user_page.dart';
import 'package:discourse_ui/views/widgets/text_entry_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Web's flag modal, from the forum's own flag types, and web's "Pin
/// Topic…" sheet.
const _site = 'https://flags.example';

SiteContext _ctx() => SiteContext(
      siteType: 'fp-test',
      site: Site(
        id: null,
        name: 'Test',
        url: _site,
        description: '',
        endpoint: null,
        baseUrl: _site,
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'fp-test',
      ),
    );

final _siteJson = {
  'top_menu_items': ['latest'],
  'post_action_types': [
    {'id': 6, 'name_key': 'notify_user', 'name': 'Send @%{username} a message', 'description': 'I want to talk to this person directly and personally about their post.', 'is_flag': true, 'require_message': true, 'applies_to': ['Post'], 'enabled': true},
    {'id': 3, 'name_key': 'off_topic', 'name': 'Off-Topic', 'description': 'Not relevant to the discussion', 'is_flag': true, 'applies_to': ['Post'], 'enabled': true},
    {'id': 10, 'name_key': 'illegal', 'name': 'Illegal', 'description': 'This is illegal', 'is_flag': true, 'require_message': true, 'applies_to': ['Post'], 'enabled': true},
    {'id': 7, 'name_key': 'notify_moderators', 'name': 'Something Else', 'description': 'Requires staff attention for another reason', 'is_flag': true, 'require_message': true, 'applies_to': ['Post'], 'enabled': true},
  ],
};

Widget _app(void Function(BuildContext) onTap) => MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => onTap(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

void main() {
  late _Posts posts;
  setUp(() {
    posts = _Posts(_ctx());
    SiteProxyFactory.register('fp-test', _Factory(posts));
    SiteProxyFactory.initialize(_ctx());
    DiscourseSiteCapabilities.store(_site, _siteJson);
    DiscourseSiteCapabilities.storeClientSettings(
        _site, {'min_personal_message_post_length': 10});
  });

  Future<void> openFlag(WidgetTester tester, {bool ownPost = false}) async {
    await tester.pumpWidget(_app((context) => showDiscourseReportDialog(
        context, postId: '11', authorUsername: 'bob', ownPost: ownPost)));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('flagging', () {
    testWidgets("the forum's flags, Illegal included, and its author by name",
        (tester) async {
      await openFlag(tester);
      expect(find.text('Send @bob a message'), findsOneWidget);
      expect(find.text('Off-Topic'), findsOneWidget);
      expect(find.text('Illegal'), findsOneWidget);
      expect(find.text('Something Else'), findsOneWidget);
      expect(find.text('All flags are received by moderators and will be reviewed as soon as possible.'),
          findsOneWidget);
    });

    testWidgets('no message to yourself', (tester) async {
      await openFlag(tester, ownPost: true);
      expect(find.textContaining('Send @'), findsNothing);
      expect(find.text('Off-Topic'), findsOneWidget);
    });

    testWidgets('a flag without a message is filed as is', (tester) async {
      await openFlag(tester);
      await tester.tap(find.text('Off-Topic'));
      await tester.pump();
      expect(find.byKey(const ValueKey('flag-message')), findsNothing);
      await tester.tap(find.widgetWithText(FilledButton, 'Flag Post'));
      await tester.pumpAndSettle();
      expect(posts.posts.single, {'id': 11, 'post_action_type_id': 3});
      expect(find.text('Thanks for keeping our community civil!'), findsOneWidget);
    });

    testWidgets("Illegal needs the forum's minimum message and the confirmation",
        (tester) async {
      await openFlag(tester);
      await tester.tap(find.text('Illegal'));
      await tester.pump();
      FilledButton submit() =>
          tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Flag Post'));
      expect(submit().onPressed, isNull, reason: 'not confirmed yet');

      await tester.ensureVisible(find.byKey(const ValueKey('flag-confirm-illegal')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('flag-confirm-illegal')));
      await tester.enterText(find.byKey(const ValueKey('flag-message')), 'too short');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Flag Post'));
      await tester.pump();
      expect(find.text('enter at least 10 characters'), findsOneWidget);
      expect(posts.posts, isEmpty);

      await tester.enterText(
          find.byKey(const ValueKey('flag-message')), 'This copies a paid course.');
      await tester.tap(find.widgetWithText(FilledButton, 'Flag Post'));
      await tester.pumpAndSettle();
      expect(posts.posts.single, {
        'id': 11,
        'post_action_type_id': 10,
        'message': 'This copies a paid course.',
      });
    });

    testWidgets('a message to the author says Message and confirms it was sent',
        (tester) async {
      await openFlag(tester);
      await tester.tap(find.text('Send @bob a message'));
      await tester.pump();
      expect(find.text('Message for the user'), findsOneWidget);
      await tester.enterText(
          find.byKey(const ValueKey('flag-message')), 'Could you add a source?');
      await tester.tap(find.widgetWithText(FilledButton, 'Message'));
      await tester.pumpAndSettle();
      expect(posts.posts.single['post_action_type_id'], 6);
      expect(find.text('Your message has been sent.'), findsOneWidget);
    });
  });

  _fullScreenTests();

  group('Pin Topic…', () {
    Future<FeatureTopicChoice?> open(WidgetTester tester,
        {required bool canPinGlobally}) async {
      FeatureTopicChoice? choice;
      await tester.pumpWidget(_app((context) async {
        choice = await showFeatureTopicSheet(context,
            categoryName: 'General', canPinGlobally: canPinGlobally);
      }));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return choice;
    }

    testWidgets("in the topic's category; globally only for those who may",
        (tester) async {
      await open(tester, canPinGlobally: false);
      expect(find.text('Make this topic appear at the top of the General category until'),
          findsOneWidget);
      expect(find.byKey(const ValueKey('pin-globally')), findsNothing);
      expect(find.text('Users can unpin the topic individually for themselves.'),
          findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await open(tester, canPinGlobally: true);
      expect(find.text('Make this topic appear at the top of all topic lists until'),
          findsOneWidget);
    });

    testWidgets('an end date is required, as on web', (tester) async {
      await open(tester, canPinGlobally: false);
      await tester.tap(find.text('Pin Topic'));
      await tester.pump();
      expect(find.text('A date is required to pin this topic.'), findsOneWidget);
    });
  });
}

void _fullScreenTests() {
  group('long choices and text get the whole screen', () {
    testWidgets('flagging is a full-screen dialog, its action in the top bar',
        (tester) async {
      await tester.pumpWidget(_app((context) => showDiscourseReportDialog(
          context, postId: '11', authorUsername: 'bob')));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(CloseButton), findsOneWidget);
      expect(
          find.descendant(
              of: find.byType(AppBar), matching: find.byKey(const ValueKey('flag-submit'))),
          findsOneWidget);
    });

    testWidgets('Suspend User: how long and why on one page', (tester) async {
      SuspendUserChoice? choice;
      await tester.pumpWidget(_app((context) async {
        choice = await showSuspendUserPage(context);
      }));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Suspend forever'), findsOneWidget);
      await tester.tap(find.text('Too combative'));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('suspend-submit')));
      await tester.pumpAndSettle();
      expect(choice, (reason: 'Too combative', expires: 0));
    });

    testWidgets('a custom suspension reason must be written', (tester) async {
      // A phone's screen, so every reason is on it.
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.6;
      addTearDown(tester.view.reset);
      SuspendUserChoice? choice;
      await tester.pumpWidget(_app((context) async {
        choice = await showSuspendUserPage(context);
      }));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Custom…'));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('suspend-submit')));
      await tester.pump();
      expect(choice, isNull);
      await tester.enterText(
          find.byKey(const ValueKey('suspend-custom-reason')), 'Spamming DMs');
      await tester.tap(find.byKey(const ValueKey('suspend-submit')));
      await tester.pumpAndSettle();
      expect(choice?.reason, 'Spamming DMs');
    });

    testWidgets('a long message: the whole screen, sent from the top bar',
        (tester) async {
      String? text;
      await tester.pumpWidget(_app((context) async {
        text = await showTextEntryPage(context,
            title: 'Request to join', actionLabel: 'Send', requiredMessage: 'Required');
      }));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('text-entry-submit')));
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('text-entry-field')), '  Hello  ');
      await tester.tap(find.byKey(const ValueKey('text-entry-submit')));
      await tester.pumpAndSettle();
      expect(text, 'Hello');
    });
  });
}

class _Posts extends DiscoursePostProxy {
  _Posts(super.context);
  final posts = <Map<String, dynamic>>[];
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      _siteJson;
  @override
  Future<Map<String, dynamic>> apiPost(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    posts.add(Map<String, dynamic>.from(body as Map));
    return const {};
  }
}

class _Factory implements SiteProxyFactory {
  _Factory(this.posts);
  final _Posts posts;

  @override
  IFCPostProxy createPostProxy(SiteContext context) => posts;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
