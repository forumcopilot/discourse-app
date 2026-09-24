import 'package:discourse_ui/views/widgets/profile_view.dart';
import 'package:flutter_test/flutter_test.dart';

/// The profile shows a website the way Discourse's does (website_name),
/// while the full address is kept for editing and opening.
void main() {
  test('host without www, plus the path', () {
    expect(websiteDisplayName('https://www.example.com/blog'), 'example.com/blog');
    expect(websiteDisplayName('http://example.com/'), 'example.com');
    expect(websiteDisplayName('example.com'), 'example.com');
  });
}
