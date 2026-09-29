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

  group('every type opens its own screen', () {
    test('a chat DM opens its channel at the message', () {
      final route = DiscourseNotificationRoute.from(payload({
        'notification_type': '30',
        'chat_channel_id': '5',
        'chat_message_id': '112',
        'bus_message_id': '4',
        'url': 'https://forum.example/chat/c/-/5/112',
      }));
      expect(route.kind, NotificationRouteKind.chat);
      expect(route.chatChannelId, 5);
      expect(route.chatMessageId, 112);
      expect(route.notificationId, isNull, reason: 'a chat message has no notification row');
    });

    test('a watched thread opens its channel, not a message outside the timeline', () {
      final route = DiscourseNotificationRoute.from(payload({
        'notification_id': '600',
        'notification_type': '40',
        'chat_channel_id': '3',
        'chat_thread_id': '42',
        'chat_message_id': '900',
      }));
      expect(route.kind, NotificationRouteKind.chat);
      expect(route.chatChannelId, 3);
      expect(route.chatMessageId, isNull);
      expect(route.notificationId, 600);
    });

    test('a chat bookmark is found from its link', () {
      final route = DiscourseNotificationRoute.from(payload({
        'notification_type': '24',
        'url': 'https://forum.example/chat/c/general/2/9',
      }));
      expect([route.kind, route.chatChannelId, route.chatMessageId],
          [NotificationRouteKind.chat, 2, 9]);
    });

    test('a badge opens its sheet', () {
      final route = DiscourseNotificationRoute.from(payload({
        'notification_id': '7',
        'notification_type': '12',
        'badge_id': '3',
        'badge_slug': 'nice-post',
      }));
      expect([route.kind, route.badgeId, route.notificationId],
          [NotificationRouteKind.badge, 3, 7]);
    });

    test('a group message summary opens that group\'s inbox', () {
      final route = DiscourseNotificationRoute.from(payload({
        'notification_type': '16',
        'group_name': 'support',
      }));
      expect([route.kind, route.groupName], [NotificationRouteKind.groupInbox, 'support']);
    });

    test('membership accepted or requested opens the group', () {
      for (final type in ['22', '23']) {
        final route = DiscourseNotificationRoute.from(
            payload({'notification_type': type, 'group_name': 'team'}));
        expect([route.kind, route.groupName], [NotificationRouteKind.group, 'team']);
      }
    });

    test('an invitee, a follower, or likes across posts open the person', () {
      for (final type in ['8', '800', '19', '39']) {
        final route = DiscourseNotificationRoute.from(
            payload({'notification_type': type, 'username': 'jane'}));
        expect([route.kind, route.username], [NotificationRouteKind.profile, 'jane'],
            reason: 'type $type');
      }
    });

    test('a topic still wins over everything but chat', () {
      final route = DiscourseNotificationRoute.from(payload({
        'notification_type': '25',
        'topic_id': '9',
        'post_number': '2',
        'username': 'jane',
      }));
      expect(route.kind, NotificationRouteKind.topicPage);
    });

    test('an admin notice lands on the notification list, carrying its id', () {
      final route = DiscourseNotificationRoute.from(
          payload({'notification_type': '38', 'notification_id': '55'}));
      expect([route.kind, route.notificationId],
          [NotificationRouteKind.notificationsTab, 55]);
    });
  });
}
