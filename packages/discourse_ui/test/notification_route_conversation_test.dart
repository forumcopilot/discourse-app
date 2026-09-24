import 'package:discourse_ui/services/notification_route.dart';
import 'package:flutter_test/flutter_test.dart';

/// A message push opens the message screen (full review, batch 2).
void main() {
  Map<String, dynamic> payload(Map<String, String> extra) => {
        'type': 'discourse_notification',
        'site_id': '0',
        'site_url': 'https://forum.example',
        ...extra,
      };

  test('a personal message or an invite to one opens the conversation', () {
    for (final type in ['6', '7']) {
      final route = DiscourseNotificationRoute.from(payload({
        'topic_id': '85',
        'post_number': '3',
        'content_id': '371',
        'notification_type': type,
      }));
      expect(route.kind, NotificationRouteKind.conversation,
          reason: 'type $type used to land in the topic reader');
      expect(route.topicId, '85');
      expect(route.postId, '371');
    }
  });

  test('other notifications still open the topic at the post', () {
    final route = DiscourseNotificationRoute.from(payload({
      'topic_id': '88',
      'post_number': '4',
      'content_id': '4321',
      'notification_type': '2',
    }));
    expect(route.kind, NotificationRouteKind.post);
  });
}
