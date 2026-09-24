import 'package:discourse_ui/controllers/post_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A loaded topic is published after the next frame — so that frame has to
/// be asked for. With static loading placeholders nothing else redraws, and
/// a topic whose posts arrived after the page-open animation stayed on its
/// placeholders until the reader touched the screen (topic 26, local forum).
void main() {
  testWidgets('publishing loaded posts asks for the frame it waits for',
      (tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse,
        reason: 'a still screen: nothing is drawing frames');

    var applied = false;
    final done = PostController.applyOnNextFrame(() => applied = true);

    expect(tester.binding.hasScheduledFrame, isTrue,
        reason: 'without a requested frame the posts are never shown');
    expect(applied, isFalse, reason: 'deferred past the current frame');
    await tester.pump();
    expect(applied, isTrue);
    await done;
  });
}
