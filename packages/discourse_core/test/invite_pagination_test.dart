import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

void main() {
  for (final filter in ['pending', 'expired', 'redeemed']) {
    test('$filter uses row offsets and its own total', () async {
      final proxy = _Invites();
      proxy.response = {
        'invites': [
          {'id': 1},
          {'id': 2}
        ],
        'counts': {'pending': 99, 'expired': 99, 'redeemed': 99, filter: 5},
      };
      final first = await proxy.getMyInvitesAsync(filter: filter);
      expect(proxy.path, '/u/alice/invited.json');
      expect(proxy.query, {'filter': filter, 'offset': 0});
      expect(first.nextOffset, 2);
      final second = await proxy.getMyInvitesAsync(filter: filter, offset: 2);
      expect(proxy.query, {'filter': filter, 'offset': 2});
      expect(second.nextOffset, 4);
      proxy.response['invites'] = [
        {'id': 5}
      ];
      final last = await proxy.getMyInvitesAsync(filter: filter, offset: 4);
      expect(last.invites.single.id, 5);
      expect(last.nextOffset, isNull);
    });
  }

  test('empty page terminates even with an outdated total', () async {
    final proxy = _Invites()
      ..response = {
        'invites': [],
        'counts': {'pending': 100},
      };
    expect((await proxy.getMyInvitesAsync(offset: 10)).nextOffset, isNull);
  });

  test('missing counts allow another page instead of truncating results',
      () async {
    final proxy = _Invites()
      ..response = {
        'invites': [
          {'id': 8}
        ]
      };
    expect((await proxy.getMyInvitesAsync(offset: 7)).nextOffset, 8);
    proxy.response = {'invites': []};
    expect((await proxy.getMyInvitesAsync(offset: 8)).nextOffset, isNull);
  });

  test('next offset counts server rows even when a malformed row is skipped',
      () async {
    final proxy = _Invites()
      ..response = {
        'invites': [
          null,
          {'id': 8}
        ],
        'counts': {'pending': 10},
      };
    final result = await proxy.getMyInvitesAsync(offset: 4);
    expect(result.invites.single.id, 8);
    expect(result.nextOffset, 6);
  });
}

class _Invites extends DiscourseInviteProxy {
  _Invites()
      : super(SiteContext(
          siteType: 'discourse',
          site: Site(
              id: null,
              name: 'Test',
              url: 'https://forum.example',
              baseUrl: 'https://forum.example',
              description: '',
              endpoint: null,
              logoUrl: null,
              backgroundUrl: null,
              siteType: 'discourse'),
        )..setLoginData(FCLoginResult(
            result: true,
            resultText: '',
            user: FCUser(id: '2', username: 'alice'))));
  Map<String, dynamic> response = {};
  String? path;
  Map<String, dynamic>? query;

  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    this.path = path;
    this.query = query;
    return response;
  }
}
