import 'package:discourse_ui/views/widgets/post_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The post action row (Reply, Like, Bookmark, Accept) promises a 48x48
/// target around a 22dp icon. The helper under it used a bare
/// GestureDetector over a colourless Container, so only the icon's own
/// pixels answered a tap.
void main() {
  Future<void> pump(WidgetTester tester,
      {VoidCallback? onTap, VoidCallback? onLongPress}) {
    return tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: PostActionButton(
            icon: Icons.favorite_border,
            semanticLabel: 'Like post',
            onTap: onTap,
            onLongPress: onLongPress,
          ),
        ),
      ),
    ));
  }

  testWidgets('the whole 48dp target takes the tap, not just the icon',
      (tester) async {
    var taps = 0;
    await pump(tester, onTap: () => taps++);

    final box = tester.getRect(find.byType(PostActionButton));
    expect(box.width, greaterThanOrEqualTo(48));
    expect(box.height, greaterThanOrEqualTo(48));

    // 3dp in from the corner: well outside the centred 22dp icon.
    await tester.tapAt(box.topLeft + const Offset(3, 3));
    expect(taps, 1);
    await tester.tapAt(box.bottomRight - const Offset(3, 3));
    expect(taps, 2);
  });

  testWidgets('long-press reaches the handler anywhere in the target',
      (tester) async {
    var taps = 0;
    var longPresses = 0;
    await pump(tester, onTap: () => taps++, onLongPress: () => longPresses++);

    final box = tester.getRect(find.byType(PostActionButton));
    await tester.longPressAt(box.topLeft + const Offset(3, 3));
    expect(longPresses, 1);
    expect(taps, 0);
  });
}
