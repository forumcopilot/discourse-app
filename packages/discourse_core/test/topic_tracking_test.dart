import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// The viewer's read state, as Discourse's web client decides it (topic
/// review, 2026-09-28): a title steps back only when read to the end; new
/// is never opened in the new-topic window; unread is a tracked topic with
/// posts after the reader's place. The shapes are ListableTopicSerializer,
/// TopicTrackingStateItemSerializer and TopicTrackingState's messages.
void main() {
  late SiteContext ctx;
  late DiscourseTopicTracking tracking;

  setUp(() {
    DiscourseTopicTracking.clearAll();
    ctx = _signedIn();
    tracking = DiscourseTopicTracking.forSite(ctx);
  });

  Map<String, dynamic> listTopic(int id,
          {int? lastRead,
          int highest = 5,
          int? level,
          bool unseen = false,
          int category = 4}) =>
      {
        'id': id,
        'highest_post_number': highest,
        if (lastRead != null) 'last_read_post_number': lastRead,
        if (level != null) 'notification_level': level,
        'unseen': unseen,
        'category_id': category,
        'archetype': 'regular',
      };

  group('a row', () {
    test('is read only when read to the end', () {
      tracking.recordTopicJson(listTopic(1, lastRead: 5, level: 1));
      tracking.recordTopicJson(listTopic(2));
      tracking.recordTopicJson(listTopic(3, lastRead: 2, level: 1));
      expect(tracking.stateOf('1')!.isRead, isTrue);
      expect(tracking.stateOf('2')!.isRead, isFalse,
          reason: 'never opened, older than the new-topic window');
      expect(tracking.stateOf('3')!.isRead, isFalse,
          reason: 'new replies in a topic the viewer does not track');
      expect(tracking.stateOf('2')!.isNew, isFalse);
      expect(tracking.stateOf('3')!.unreadCount, 0,
          reason: 'lib/unread.rb counts nothing below Tracking');
    });

    test('is new when unseen, unread when tracked with posts after', () {
      tracking.recordTopicJson(listTopic(1, unseen: true, highest: 1));
      tracking.recordTopicJson(listTopic(2, lastRead: 4, highest: 7, level: 2));
      expect(tracking.stateOf('1')!.isNew, isTrue);
      expect(tracking.stateOf('2')!.unreadCount, 3);
    });

    test('a deleted last post still reads as read', () {
      tracking.recordTopicJson(listTopic(1, lastRead: 6, highest: 5, level: 2));
      expect(tracking.stateOf('1')!.isRead, isTrue);
    });

    test('a PM never opened is new whatever its age', () {
      tracking.recordTopicJson(
          {...listTopic(9, highest: 3), 'archetype': 'private_message'});
      expect(tracking.stateOf('9')!.isNew, isTrue);
    });
  });

  group('reading', () {
    test('a reported post moves the row at once', () {
      tracking.recordTopicJson(listTopic(1, unseen: true, highest: 3));
      tracking.recordRead('1', 1);
      expect(tracking.stateOf('1')!.isNew, isFalse);
      expect(tracking.stateOf('1')!.isRead, isFalse);
      tracking.recordRead('1', 3);
      expect(tracking.stateOf('1')!.isRead, isTrue);
    });

    test('a payload fetched before the read cannot undo it', () {
      tracking.recordTopicJson(listTopic(1, lastRead: 2, highest: 6, level: 2));
      tracking.recordRead('1', 6);
      tracking.recordTopicJson(listTopic(1, lastRead: 2, highest: 6, level: 2));
      expect(tracking.stateOf('1')!.isRead, isTrue);
    });

    test('a new reply makes a read topic unread again', () {
      tracking.recordTopicJson(listTopic(1, lastRead: 6, highest: 6, level: 2));
      tracking.recordTopicJson(listTopic(1, lastRead: 6, highest: 8, level: 2));
      expect(tracking.stateOf('1')!.unreadCount, 2);
    });

    test('the topic view carries no unseen and keeps what the list said', () {
      tracking.recordTopicJson(listTopic(1, unseen: true, highest: 2));
      tracking.recordTopicJson({
        'id': 1,
        'highest_post_number': 2,
        'details': {'notification_level': 1},
      });
      expect(tracking.stateOf('1')!.isNew, isTrue);
      expect(tracking.stateOf('1')!.notificationLevel, 1);
    });
  });

  group('counts', () {
    List<Map<String, dynamic>> report() => [
          {
            'topic_id': 1,
            'highest_post_number': 1,
            'last_read_post_number': null,
            'category_id': 4,
            'notification_level': null,
            'created_in_new_period': true,
          },
          {
            'topic_id': 2,
            'highest_post_number': 9,
            'last_read_post_number': 5,
            'category_id': 7,
            'notification_level': 3,
            'created_in_new_period': false,
          },
          {
            'topic_id': 3,
            'highest_post_number': 1,
            'last_read_post_number': null,
            'category_id': 7,
            'notification_level': 1,
            'created_in_new_period': true,
          },
        ];

    test('are unknown until the report has loaded', () {
      tracking.recordTopicJson(listTopic(1, unseen: true));
      expect(tracking.counts(), isNull);
    });

    test('follow web: new, unread, and nothing below Tracking', () {
      tracking.replaceReport(report());
      expect(tracking.counts(), (newTopics: 1, unreadTopics: 1),
          reason: 'topic 3 has a Normal level: web does not count it new');
      expect(tracking.counts(categoryIds: {7}),
          (newTopics: 0, unreadTopics: 1));
    });

    test('drop as the viewer reads and dismisses', () {
      tracking.replaceReport(report());
      tracking.recordRead('2', 9);
      expect(tracking.counts(), (newTopics: 1, unreadTopics: 0));
      tracking.applyDismissedNew(['1']);
      expect(tracking.counts(), (newTopics: 0, unreadTopics: 0));
    });

    test('a category takes its subcategories', () {
      DiscourseSiteCapabilities.store(ctx.site.pluginUrl, {
        'top_menu_items': ['latest'],
        'categories': [
          {'id': 4},
          {'id': 7, 'parent_category_id': 4},
          {'id': 8, 'parent_category_id': 7},
          {'id': 9},
        ],
      });
      expect(DiscourseSiteCapabilities.forSite(ctx.site.pluginUrl)
          .categoryWithDescendants(4), {4, 7, 8});
    });
  });

  group('live messages', () {
    test('read on another device', () {
      tracking.recordTopicJson(listTopic(1, lastRead: 2, highest: 6, level: 2));
      tracking.applyBusMessage({
        'message_type': 'read',
        'topic_id': 1,
        'payload': {
          'last_read_post_number': 6,
          'highest_post_number': 6,
          'notification_level': 2,
        },
      });
      expect(tracking.stateOf('1')!.isRead, isTrue);
    });

    test('a reply in a tracked topic', () {
      tracking.replaceReport(const []);
      tracking.recordTopicJson(listTopic(1, lastRead: 6, highest: 6, level: 2));
      tracking.applyBusMessage({
        'message_type': 'unread',
        'topic_id': 1,
        'payload': {'highest_post_number': 7, 'category_id': 4},
      });
      expect(tracking.stateOf('1')!.unreadCount, 1);
      expect(tracking.counts(), (newTopics: 0, unreadTopics: 1));
    });

    test('dismissed elsewhere', () {
      tracking.recordTopicJson(listTopic(1, unseen: true));
      tracking.recordTopicJson(listTopic(2, lastRead: 1, highest: 4, level: 2));
      tracking.applyBusMessage({
        'message_type': 'dismiss_new',
        'payload': {
          'topic_ids': [1],
        },
      });
      tracking.applyBusMessage({
        'message_type': 'dismiss_new_posts',
        'payload': {
          'topic_ids': [2],
        },
      });
      expect(tracking.stateOf('1')!.isNew, isFalse);
      expect(tracking.stateOf('2')!.isRead, isTrue);
    });
  });

  test('a different user starts empty', () {
    tracking.recordTopicJson(listTopic(1, lastRead: 5));
    ctx.setLoginData(FCLoginResult(
        result: true, resultText: '', user: FCUser(id: '3', username: 'bob')));
    expect(DiscourseTopicTracking.forSite(ctx).stateOf('1'), isNull);
  });

  test('rows notify their listeners once per burst', () async {
    var calls = 0;
    tracking.addListener(() => calls++);
    for (var i = 0; i < 30; i++) {
      tracking.recordTopicJson(listTopic(i));
    }
    await Future<void>.delayed(Duration.zero);
    expect(calls, 1);
  });

  group('requests', () {
    late _Recorder rec;
    setUp(() => rec = _Recorder());

    test('the report is the signed-in user\'s', () async {
      rec.nextGet = {
        '_value': [
          {
            'topic_id': 5,
            'highest_post_number': 1,
            'last_read_post_number': null,
            'category_id': 4,
            'created_in_new_period': true,
          },
        ],
      };
      final loaded = await _Topic(rec, ctx).loadTopicTrackingStateAsync();
      expect(loaded, isTrue);
      expect(rec.last, ('GET', '/u/alice/topic-tracking-state.json'));
      expect(tracking.counts(), (newTopics: 1, unreadTopics: 0));
    });

    test('dismiss new names new topics, and a category takes its children',
        () async {
      tracking.recordTopicJson(listTopic(5, unseen: true));
      rec.nextPut = {
        'topic_ids': [5],
      };
      final r = await _Topic(rec, ctx).dismissNewAsync(categoryId: 4);
      expect(r.result, isTrue);
      expect(rec.last, ('PUT', '/topics/reset-new'));
      expect(rec.body, {
        'dismiss_topics': true,
        'category_id': 4,
        'include_subcategories': true,
      });
      expect(tracking.stateOf('5')!.isNew, isFalse);
    });

    test('dismiss unread marks replies read, or stops tracking', () async {
      tracking.recordTopicJson(listTopic(5, lastRead: 1, highest: 4, level: 2));
      tracking.recordTopicJson(listTopic(6, lastRead: 1, highest: 4, level: 2));
      rec.nextPut = {
        'topic_ids': [5],
      };
      await _Topic(rec, ctx).dismissUnreadAsync();
      expect(rec.body, {
        'filter': 'unread',
        'operation': {'type': 'dismiss_posts'},
      });
      expect(tracking.stateOf('5')!.isRead, isTrue);

      rec.nextPut = {
        'topic_ids': [6],
      };
      await _Topic(rec, ctx).dismissUnreadAsync(stopTracking: true);
      expect(rec.body, {
        'filter': 'unread',
        'operation': {
          'type': 'change_notification_level',
          'notification_level_id': 1,
        },
      });
      expect(tracking.stateOf('6')!.unreadCount, 0);
      expect(tracking.stateOf('6')!.isRead, isFalse,
          reason: 'untracked keeps its read place, as on web');
    });

    test('list payloads record, a guest records nothing', () async {
      rec.nextGet = {
        'topic_list': {
          'topics': [listTopic(7, lastRead: 5, level: 1)],
        },
      };
      await _Topic(rec, ctx).getLatestTopicAsync(0, 29);
      expect(tracking.stateOf('7')!.isRead, isTrue);

      final guest = _guest();
      await _Topic(rec, guest).getLatestTopicAsync(0, 29);
      expect(DiscourseTopicTracking.forSite(guest).stateOf('7'), isNull);
    });
  });
}

SiteContext _site(String url) => SiteContext(
      siteType: 'discourse',
      site: Site(
        id: null,
        name: 'Test',
        url: url,
        description: '',
        endpoint: null,
        baseUrl: url,
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'discourse',
      ),
    );

SiteContext _signedIn() {
  final ctx = _site('https://tracking.example');
  ctx.setLoginData(FCLoginResult(
    result: true,
    resultText: '',
    user: FCUser(id: '2', username: 'alice'),
  ));
  return ctx;
}

SiteContext _guest() => _site('https://guest.example');

class _Recorder {
  Map<String, dynamic> nextGet = const {};
  Map<String, dynamic> nextPut = const {};
  (String, String)? last;
  Object? body;

  Future<Map<String, dynamic>> get(String path) async {
    last = ('GET', path);
    return path == '/site.json' || path == '/categories.json'
        ? const {'categories': []}
        : nextGet;
  }

  Future<Map<String, dynamic>> put(String path, Object? b) async {
    last = ('PUT', path);
    body = b;
    return nextPut;
  }
}

class _Topic extends DiscourseTopicProxy {
  _Topic(this.rec, SiteContext ctx) : super(ctx);
  final _Recorder rec;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) =>
      rec.get(path);
  @override
  Future<Map<String, dynamic>> apiPut(String path,
          {Map<String, dynamic>? query, Object? body}) =>
      rec.put(path, body);
}
