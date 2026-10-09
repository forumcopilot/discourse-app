import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/utils/app_navigation.dart';
import 'package:discourse_ui/views/widgets/message_compose_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/domain/site.dart';

/// Selecting text in the composer, on a phone-sized screen.
///
/// A long-press after Back had put the keyboard away selected from the
/// word to the end of the post: Flutter brings the keyboard back for the
/// long-press, the page scrolled the selection above it while the finger
/// was still down, and the selection ran on to the words now under the
/// finger. And a selection could not be dismissed by tapping the empty
/// page under a short post: nothing there took the tap.
void main() {
  const post = '[quote="Michael_Sandler, post:2, topic:414258"]\n'
      'I am happy to share how I have implemented it in my Flutter wrapper '
      "app for my Discourse forum. I haven't done Apple yet, only Android.\n"
      '[/quote]\n\n\n'
      'Hey Michael,\n\n'
      'Good work! You might want to take a look of ABDA, an open source '
      "mobile app for Discourse. It's just released on Android and will "
      'soon be on iOS.';

  late TextEditingController content;

  Future<void> open(WidgetTester tester) async {
    // A Pixel 10a: 1080 × 2424 at 2.625.
    tester.view.physicalSize = const Size(1080, 2424);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    content = TextEditingController();
    addTearDown(content.dispose);

    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: Text('Topic')),
    ));
    navigatorKey.currentState!.push(FormPageRoute(
      builder: (_) => MessageComposePage(
        siteContext: _site(),
        title: 'Reply',
        submitLabel: 'Reply',
        autoFocusContent: false,
        topicTitle: 'Discourse Mobile Push',
        initialContent: post,
        contentController: content,
        onSubmit: (_, __) async => false,
      ),
    ));
    await tester.pumpAndSettle();
  }

  EditableTextState editable(WidgetTester tester) =>
      tester.state<EditableTextState>(find.byType(EditableText));

  /// Where [word] is drawn, on screen.
  Offset wordOnScreen(WidgetTester tester, String word) {
    final render = editable(tester).renderEditable;
    final start = post.indexOf(word);
    final caret = render.getLocalRectForCaret(
        TextPosition(offset: start + word.length ~/ 2));
    return render.localToGlobal(caret.center);
  }

  String selected() => content.selection.textInside(content.text);

  testWidgets(
      'a long-press after the keyboard was put away selects one word',
      (tester) async {
    await open(tester);
    // In the text, with the keyboard down (as after Back).
    await tester.tapAt(wordOnScreen(tester, 'Hey'));
    await tester.pumpAndSettle();
    expect(editable(tester).widget.focusNode.hasFocus, isTrue);

    final finger = await tester.startGesture(
        wordOnScreen(tester, 'released'),
        kind: PointerDeviceKind.touch);
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    expect(selected(), 'released');

    // The long-press brings the keyboard back up under the finger.
    tester.view.viewInsets = const FakeViewPadding(bottom: 965);
    await tester.pump();
    await tester.pump();
    // A finger is never quite still.
    await finger.moveBy(const Offset(0, 1));
    await tester.pump();
    expect(selected(), 'released');

    await finger.up();
    await tester.pumpAndSettle();
    expect(selected(), 'released');
    // Once the finger is up, the selection is brought above the keyboard.
    final keyboardTop = (tester.view.physicalSize.height - 965) /
        tester.view.devicePixelRatio;
    expect(wordOnScreen(tester, 'released').dy, lessThan(keyboardTop));
  });

  testWidgets('a tap on the empty page under a short post leaves the text',
      (tester) async {
    await open(tester);
    await tester.tapAt(wordOnScreen(tester, 'Hey'));
    await tester.pumpAndSettle();
    content.selection = TextSelection(
        baseOffset: post.indexOf('Good'),
        extentOffset: post.indexOf('soon'));
    await tester.pump();
    expect(editable(tester).widget.focusNode.hasFocus, isTrue);

    final field = tester.getRect(find.byType(TextField));
    final page = tester.getRect(find.byType(Scaffold).last);
    // The post is short: there is page to spare under the field.
    expect(page.bottom - field.bottom, greaterThan(200));
    await tester.tapAt(Offset(field.center.dx, field.bottom + 100));
    await tester.pumpAndSettle();

    expect(editable(tester).widget.focusNode.hasFocus, isFalse);
  });
}

SiteContext _site() => SiteContext(
      siteType: 'discourse',
      site: Site(
        id: null,
        name: 'Test',
        url: 'https://forum.example',
        description: '',
        endpoint: null,
        baseUrl: 'https://forum.example',
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'discourse',
      ),
    );
