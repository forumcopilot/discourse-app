import 'dart:async';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The New and Unread counts on the messages page, per inbox, as the web's
/// pm-topic-tracking-state counts them; and a group's filtered lists.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const site = 'https://pm.example';
  setUp(() {
    DiscourseMessageTracking.clear();
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  Map<String, dynamic> row(int id,
          {int? lastRead, int highest = 3, int? level, List<int> groups = const [], bool seen = false}) =>
      {
        'topic_id': id,
        'last_read_post_number': lastRead,
        'highest_post_number': highest,
        'notification_level': level,
        'group_ids': groups,
        if (seen) 'is_seen': true,
      };

  test('new and unread, in the personal inbox and a group inbox', () {
    final t = DiscourseMessageTracking.forSite(site)
      ..replaceReport([
        row(1), // new, personal
        row(2, level: 0), // muted: not new
        row(3, lastRead: 1, level: 2), // unread, personal
        row(4, lastRead: 3, level: 3), // read to the end
        row(5, lastRead: 1, level: 1), // regular: no unread count
        row(6, groups: [41]), // new, in the group
        row(7, lastRead: 2, level: 3, groups: [41]), // unread, in the group
        row(8, groups: [99]), // a group the reader is not in: personal
      ]);
    expect(t.count(unread: false, myGroupIds: {41}), 2);
    expect(t.count(unread: true, myGroupIds: {41}), 1);
    expect(t.count(unread: false, groupId: 41, myGroupIds: {41}), 1);
    expect(t.count(unread: true, groupId: 41, myGroupIds: {41}), 1);
  });

  test("live: someone else's new message counts, the reader's own does not, and reading clears", () {
    final t = DiscourseMessageTracking.forSite(site)..replaceReport(const []);
    final mine = t.apply({
      'topic_id': 10,
      'message_type': 'new_topic',
      'payload': {'last_read_post_number': null, 'highest_post_number': 1, 'group_ids': [], 'created_by_user_id': 2},
    }, myUserId: 2);
    expect(mine, isNull);
    expect(t.count(unread: false), 0);
    final theirs = t.apply({
      'topic_id': 11,
      'message_type': 'new_topic',
      'payload': {'last_read_post_number': null, 'highest_post_number': 1, 'group_ids': [], 'created_by_user_id': 7},
    }, myUserId: 2);
    expect(theirs, 'new_topic');
    expect(t.count(unread: false), 1);
    t.apply({
      'topic_id': 11,
      'message_type': 'read',
      'payload': {'last_read_post_number': 1, 'highest_post_number': 1, 'notification_level': 3},
    }, myUserId: 2);
    expect(t.count(unread: false), 0);
    expect(
        t.apply({
          'topic_id': 11,
          'message_type': 'unread',
          'payload': {'last_read_post_number': 1, 'highest_post_number': 2, 'notification_level': 3, 'group_ids': []},
        }, myUserId: 2),
        'unread');
    expect(t.count(unread: true), 1);
  });

  test("the report loads from the reader's tracking state", () async {
    final p = _Recording(site);
    expect(await p.loadMessageTrackingAsync(), isTrue);
    expect(p.paths.single, '/u/alice/private-message-topic-tracking-state.json');
    expect(DiscourseMessageTracking.forSite(site).count(unread: false), 1);
  });

  for (final change in ['signing out', 'signing in as someone else']) {
    test('$change forgets the counts until the next report', () async {
      final p = _Recording(site);
      await p.siteContext
          .setUserApiCredentials(userApiKey: 'alice', userApiClientId: 'c');
      expect(await p.loadMessageTrackingAsync(), isTrue);
      final tracking = DiscourseMessageTracking.forSite(site);
      expect(tracking.count(unread: false), 1);
      final heard = tracking.revision.value;
      if (change == 'signing out') {
        await p.siteContext.clearUserApiCredentials();
      } else {
        await p.siteContext
            .setUserApiCredentials(userApiKey: 'bob', userApiClientId: 'c');
      }
      expect(tracking.isLoaded, isFalse);
      expect(tracking.count(unread: false), 0);
      expect(tracking.revision.value, greaterThan(heard),
          reason: 'a list showing "New (1)" redraws without it');
    });
  }

  test("a report that arrives after the sign-in changed is not the next account's",
      () async {
    final p = _Recording(site);
    await p.siteContext
        .setUserApiCredentials(userApiKey: 'alice', userApiClientId: 'c');
    p.gate = Completer<void>();
    final load = p.loadMessageTrackingAsync();
    await p.siteContext
        .setUserApiCredentials(userApiKey: 'bob', userApiClientId: 'c');
    p.gate!.complete();
    expect(await load, isFalse);
    expect(DiscourseMessageTracking.forSite(site).isLoaded, isFalse);
    expect(DiscourseMessageTracking.forSite(site).count(unread: false), 0);
  });

  test("a group's New, Unread and Archive are its own lists", () async {
    final p = _Recording(site);
    await p.getMessageListAsync(DiscourseMessageList.group('team', filter: 'new'), 0, 19);
    await p.getMessageListAsync(DiscourseMessageList.group('team'), 0, 19);
    expect(p.paths, [
      '/topics/private-messages-group/alice/team/new.json',
      '/topics/private-messages-group/alice/team.json',
    ]);
    expect(DiscourseMessageList.group('team', filter: 'archive').isArchive, isTrue);
    expect(DiscourseMessageList.group('team', filter: 'unread').filter, 'unread');
    expect(DiscourseMessageList.group('team').filter, 'inbox');
    expect(DiscourseMessageList.sent.filter, 'sent');
  });
}

class _Recording extends DiscoursePrivateConversationProxy {
  _Recording(String url)
      : super(SiteContext(
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
        )..setLoginData(FCLoginResult(result: true, resultText: '', user: FCUser(id: '2', username: 'alice'))));

  final List<String> paths = [];
  Completer<void>? gate;

  @override
  Future<Map<String, dynamic>> apiGet(String path, {Map<String, dynamic>? query}) async {
    paths.add(path);
    await gate?.future;
    if (path.endsWith('private-message-topic-tracking-state.json')) {
      return {
        '_value': [
          {'topic_id': 1, 'last_read_post_number': null, 'highest_post_number': 1, 'group_ids': []},
        ],
      };
    }
    return const {'topic_list': {'topics': []}};
  }
}
