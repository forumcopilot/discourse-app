import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Staff tools and account requests (full review, batch 1).
void main() {
  test('review actions perform the server action, not the prefixed id',
      () async {
    final proxy = _Rec(_Moderation.new);
    proxy.answers['/review.json'] = {
      'reviewables': [
        {
          'id': 7,
          'type': 'ReviewableFlaggedPost',
          'status': 0,
          'version': 2,
          'bundled_action_ids': ['post-agree', 'post-disagree'],
        },
      ],
      'bundled_actions': [
        {'id': 'post-agree', 'action_ids': ['post-agree_and_keep']},
        {'id': 'post-disagree', 'action_ids': ['post-disagree']},
      ],
      // As ReviewableActionSerializer sends them.
      'actions': [
        {
          'id': 'post-agree_and_keep',
          'server_action': 'agree_and_keep',
          'label': 'Keep Post',
        },
        // No server_action: fall back to the id's last "-" part, as
        // Reviewable::Actions::Action#server_action does.
        {'id': 'post-disagree', 'label': 'No'},
      ],
    };
    final list = await proxy.target.getReviewablesAsync();
    final ids = [for (final a in list.reviewables.single.actions) a.id];
    expect(ids, ['agree_and_keep', 'disagree'],
        reason: 'the route only accepts [a-z_]+; "post-disagree" 404s');

    await proxy.target.performReviewableActionAsync(7, 'disagree', version: 2);
    expect(proxy.puts.last, '/review/7/perform/disagree.json');
  });

  test('a suspension ends on the picked date', () async {
    final proxy = _Rec(_Moderation.new);
    proxy.answers['/u/bob.json'] = {
      'user': {'id': 3, 'username': 'bob'},
    };
    final end = DateTime.utc(2026, 10, 1, 12);
    await proxy.target.banUserAsync(
        'bob', 'spam', end.millisecondsSinceEpoch ~/ 1000, 0, 0);
    expect(proxy.puts.last, '/admin/users/3/suspend.json');
    expect((proxy.lastBody as Map)['suspend_until'], end.toIso8601String(),
        reason: 'treated as seconds from now it lasted ~56 years');

    await proxy.target.banUserAsync('bob', 'spam', 0, 0, 0);
    expect((proxy.lastBody as Map)['suspend_until'],
        DateTime.utc(3000, 1, 1).toIso8601String());
  });

  test('a password reset is asked for by email', () async {
    final proxy = _Rec(_Account.new);
    proxy.answers['/u/alice/emails.json'] = {
      'email': 'alice@example.com',
      'secondary_emails': [],
    };
    final result = await proxy.target.updatePassword('', '');
    expect(result.result, isTrue);
    expect(proxy.posts.last, '/session/forgot_password.json');
    expect(proxy.lastBody, {'login': 'alice@example.com'},
        reason: 'with hide_email_address_taken a username gets a 400');

    proxy.answers.remove('/u/alice/emails.json');
    await proxy.target.updatePassword('', '');
    expect(proxy.lastBody, {'login': 'alice'});
  });

  test("groups page from Discourse's 0", () async {
    final proxy = _Rec(_Groups.new);
    proxy.answers['/groups.json'] = {
      'groups': [
        {'id': 1, 'name': 'a'},
      ],
      'total_rows_groups': 16,
    };
    final first = await proxy.target.getGroupsAsync();
    expect(proxy.queries.last, isEmpty);
    expect(first.total, 16);
    await proxy.target.getGroupsAsync(page: 2);
    expect(proxy.queries.last, {'page': '1'},
        reason: 'page 1 asked for the second page first');
  });
}

SiteContext _signedIn() {
  final ctx = SiteContext(
    siteType: 'discourse',
    site: Site(
      id: null,
      name: 'Test',
      url: 'https://forum.example',
      description: '',
      endpoint: null,
      baseUrl: 'https://forum.example',
      logoUrl: null,
      backgroundUrl: null,
      siteType: 'discourse',
    ),
  );
  ctx.setLoginData(FCLoginResult(
    result: true,
    resultText: '',
    user: FCUser(id: '2', username: 'alice'),
  ));
  return ctx;
}

/// Shared recording state for the proxy subclasses below.
class _Rec<T> {
  _Rec(T Function(_Rec<T>) make) {
    target = make(this);
  }
  late final T target;
  final Map<String, Map<String, dynamic>> answers = {};
  final List<Map<String, dynamic>> queries = [];
  final List<String> puts = [];
  final List<String> posts = [];
  Object? lastBody;

  Future<Map<String, dynamic>> get(String path, Map<String, dynamic>? q) async {
    queries.add({...?q});
    final a = answers[path];
    if (a == null) throw DiscourseApiException(
        statusCode: 404, method: 'GET', path: path, body: 'not found');
    return a;
  }

  Future<Map<String, dynamic>> put(String path, Object? body) async {
    puts.add(path);
    lastBody = body;
    return const {'reviewable_perform_result': {'success': 'OK'}};
  }

  Future<Map<String, dynamic>> post(String path, Object? body) async {
    posts.add(path);
    lastBody = body;
    return const {'success': 'OK'};
  }
}

class _Moderation extends DiscourseModerationProxy {
  _Moderation(this.rec) : super(_signedIn());
  final _Rec rec;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) =>
      rec.get(path, query);
  @override
  Future<Map<String, dynamic>> apiPut(String path,
          {Map<String, dynamic>? query, Object? body}) =>
      rec.put(path, body);
}

class _Account extends DiscourseAccountProxy {
  _Account(this.rec) : super(_signedIn());
  final _Rec rec;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) =>
      rec.get(path, query);
  @override
  Future<Map<String, dynamic>> apiPost(String path,
          {Map<String, dynamic>? query, Object? body}) =>
      rec.post(path, body);
}

class _Groups extends DiscourseGroupProxy {
  _Groups(this.rec) : super(_signedIn());
  final _Rec rec;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) =>
      rec.get(path, query);
}
