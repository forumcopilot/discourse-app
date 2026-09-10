import 'package:discourse_ui/services/notification_route.dart';
import 'package:flutter_test/flutter_test.dart';

/// The payloads here are the shapes `abda-push`'s NotificationPayload emits
/// for real Discourse notification types, with every value a string — which
/// is how FCM delivers a data payload.
void main() {
  Map<String, dynamic> payload(Map<String, String> extra) => {
        'type': 'discourse_notification',
        'site_id': '0',
        'site_url': 'https://forum.example',
        ...extra,
      };

  group('handles', () {
    test('claims only the payloads the notifications backend sends', () {
      expect(DiscourseNotificationRoute.handles(payload({})), isTrue);
      // The plugin's shape stays with the plugin path.
      expect(
        DiscourseNotificationRoute.handles(
            {'content_type': 'post', 'content_id': '1', 'site_id': '7'}),
        isFalse,
      );
      expect(DiscourseNotificationRoute.handles({}), isFalse);
    });
  });

  group('a reply, mention, quote, like or message', () {
    test('opens the topic centred on the post it names', () {
      final route = DiscourseNotificationRoute.from(payload({
        'topic_id': '88',
        'post_number': '4',
        'content_id': '4321',
        'notification_type': '2',
      }));
      expect(route.kind, NotificationRouteKind.post);
      expect(route.topicId, '88');
      expect(route.postId, '4321');
      expect(route.postNumber, 4);
      expect(route.siteUrl, 'https://forum.example');
    });

    test('prefers the post id over the post number when both are present', () {
      final route = DiscourseNotificationRoute.from(
          payload({'topic_id': '88', 'post_number': '45', 'content_id': '99'}));
      expect(route.kind, NotificationRouteKind.post);
      expect(route.page, isNull);
    });
  });

  group('a notification with a position but no post id', () {
    test('opens the page holding that post', () {
      final route = DiscourseNotificationRoute.from(
          payload({'topic_id': '88', 'post_number': '45'}));
      expect(route.kind, NotificationRouteKind.topicPage);
      expect(route.topicId, '88');
      expect(route.postNumber, 45);
      // 20 posts a page: 45 is the fifth post of page three.
      expect(route.page, 3);
    });

    test('post numbers on a page boundary do not slip to the next page', () {
      int? pageFor(String n) => DiscourseNotificationRoute.from(
          payload({'topic_id': '5', 'post_number': n})).page;
      expect(pageFor('1'), 1);
      expect(pageFor('20'), 1);
      expect(pageFor('21'), 2);
      expect(pageFor('40'), 2);
      expect(pageFor('41'), 3);
    });

    test('a topic with no position at all still beats the notification list',
        () {
      final route =
          DiscourseNotificationRoute.from(payload({'topic_id': '88'}));
      expect(route.kind, NotificationRouteKind.topicPage);
      expect(route.page, 1);
    });
  });

  group('a notification with nowhere to go', () {
    test('a badge lands on the notification list', () {
      final route = DiscourseNotificationRoute.from(
          payload({'notification_type': '12', 'action': 'You earned a badge'}));
      expect(route.kind, NotificationRouteKind.notificationsTab);
      expect(route.topicId, isNull);
      // Still knows which forum, so the right one is opened.
      expect(route.siteUrl, 'https://forum.example');
    });

    test('a post id without its topic is not enough to open anything', () {
      final route =
          DiscourseNotificationRoute.from(payload({'content_id': '4321'}));
      expect(route.kind, NotificationRouteKind.notificationsTab);
    });
  });

  group('values as they actually arrive', () {
    test('numbers survive being sent as ints, floats or float-ish strings', () {
      final asInts = DiscourseNotificationRoute.from({
        'type': 'discourse_notification',
        'topic_id': 88,
        'content_id': 4321,
        'post_number': 4,
      });
      expect(asInts.topicId, '88');
      expect(asInts.postId, '4321');
      expect(asInts.postNumber, 4);

      final asFloatText = DiscourseNotificationRoute.from(
          payload({'topic_id': '88.0', 'post_number': '45.0'}));
      expect(asFloatText.topicId, '88');
      expect(asFloatText.page, 3);
    });

    test('blank and unparseable values are treated as absent, not as zero', () {
      final route = DiscourseNotificationRoute.from(payload(
          {'topic_id': '', 'post_number': 'null', 'content_id': 'null'}));
      expect(route.kind, NotificationRouteKind.notificationsTab);

      final zeroPosition = DiscourseNotificationRoute.from(
          payload({'topic_id': '88', 'post_number': '0'}));
      expect(zeroPosition.kind, NotificationRouteKind.topicPage);
      expect(zeroPosition.page, 1,
          reason: 'post 0 does not exist; open the top');
    });

    test('a missing site_url is not fatal — the app resolves the forum', () {
      final route = DiscourseNotificationRoute.from(
          {'type': 'discourse_notification', 'topic_id': '3'});
      expect(route.siteUrl, isNull);
      expect(route.kind, NotificationRouteKind.topicPage);
    });
  });
}
