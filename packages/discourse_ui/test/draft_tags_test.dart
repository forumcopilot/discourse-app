import 'package:discourse_ui/utils/draft_tags.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mixed tag payload keeps valid unique names in order', () {
    expect(
        draftTagNames([
          'design',
          {'id': 8, 'name': 'mobile'},
          {'name': 'design'},
          null,
          42,
          {'id': 9},
          {'name': false},
          ' ',
          {'name': ' music '},
        ]),
        ['design', 'mobile', 'music']);
  });

  test('an absent or malformed tag collection is empty', () {
    for (final value in [
      null,
      'design',
      {'name': 'design'}
    ]) {
      expect(draftTagNames(value), isEmpty);
    }
  });
}
