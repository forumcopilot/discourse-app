import 'package:discourse_core/discourse_core.dart' show DiscourseLink;
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
  group('fromLink — links name the same destinations', () {
    DiscourseNotificationRoute? route(String url) =>
        DiscourseNotificationRoute.fromLink(DiscourseLink.parse(url)!);

    test('a topic link opens the topic', () {
      final r = route('https://forum.example/t/some-topic/88')!;
      expect(r.kind, NotificationRouteKind.topicPage);
      expect(r.topicId, '88');
      expect(r.postNumber, isNull);
      expect(r.page, 1);
      expect(r.siteUrl, 'https://forum.example');
    });

    test('a post number opens its page, and names the post', () {
      final r = route('https://forum.example/t/some-topic/88/45')!;
      expect(r.kind, NotificationRouteKind.topicPage);
      expect(r.topicId, '88');
      expect(r.postNumber, 45);
      expect(r.page, 3, reason: '20 posts a page: 41–60 is page 3');
    });

    test('slugless and subfolder links', () {
      expect(route('https://forum.example/t/88/2')!.postNumber, 2);
      final sub = route('https://example.com/forum/t/x/88/2')!;
      expect(sub.topicId, '88');
      expect(sub.siteUrl, 'https://example.com/forum');
    });

    test('a post short link opens that post; the topic is looked up', () {
      final r = route('https://forum.example/p/1234')!;
      expect(r.kind, NotificationRouteKind.post);
      expect(r.postId, '1234');
      expect(r.topicId, isNull);
    });

    test('a link to the forum, a category or a user opens the forum', () {
      expect(route('https://forum.example'), isNull);
      expect(route('https://forum.example/c/help/4'), isNull);
      expect(route('https://forum.example/u/alice'), isNull);
    });
  });
}
