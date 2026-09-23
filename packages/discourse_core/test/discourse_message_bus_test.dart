import 'dart:async';
import 'dart:convert';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// The MessageBus long-poll client that replaces chat's 4-second refetch.
void main() {
  late _HeldPolls server;
  late DiscourseMessageBus bus;

  setUp(() {
    server = _HeldPolls();
    bus = DiscourseMessageBus(
      _context(),
      client: server,
      minInterval: Duration.zero,
    );
  });

  tearDown(() => bus.close());

  test('delivers to the channel\'s listener and advances its last id',
      () async {
    final got = <Map<String, dynamic>>[];
    bus.subscribe('/chat/5', got.add, lastId: 10);
    await server.nextPoll;
    expect(server.polls.single['/chat/5'], 10);
    expect(server.polls.single['__seq'], 1);

    server.answer([
      {'channel': '/chat/5', 'message_id': 11, 'data': {'type': 'sent'}},
      {'channel': '/chat/9', 'message_id': 3, 'data': {'type': 'sent'}},
    ]);
    await server.nextPoll;
    expect(got.map((d) => d['type']), ['sent'],
        reason: 'only the subscribed channel');
    expect(server.polls.last['/chat/5'], 11, reason: 'resumes after 11');
  });

  test('a replayed id is not delivered twice', () async {
    final got = <Map<String, dynamic>>[];
    bus.subscribe('/chat/5', got.add, lastId: 10);
    await server.nextPoll;
    server.answer([
      {'channel': '/chat/5', 'message_id': 10, 'data': {'type': 'old'}},
      {'channel': '/chat/5', 'message_id': 12, 'data': {'type': 'new'}},
    ]);
    await server.nextPoll;
    expect(got.map((d) => d['type']), ['new']);
  });

  test('__status sets the starting point without delivering', () async {
    final got = <Map<String, dynamic>>[];
    bus.subscribe('/chat/5', got.add);
    await server.nextPoll;
    expect(server.polls.single['/chat/5'], -1);
    server.answer([
      {'channel': '/__status', 'message_id': 1, 'data': {'/chat/5': 42}},
    ]);
    await server.nextPoll;
    expect(got, isEmpty);
    expect(server.polls.last['/chat/5'], 42);
  });

  test('a new channel replaces the poll the server is holding', () async {
    bus.subscribe('/chat/5', (_) {}, lastId: 1);
    await server.nextPoll;
    bus.subscribe('/chat/7', (_) {}, lastId: 2);
    await server.nextPoll;
    expect(server.polls, hasLength(2));
    expect(server.polls.last.keys, containsAll(['/chat/5', '/chat/7']));
    expect(server.polls.last['__seq'], 2,
        reason: 'a higher __seq makes the server close the older poll');
  });

  test('another listener on a polled channel costs no request', () async {
    bus.subscribe('/chat/5', (_) {}, lastId: 1);
    await server.nextPoll;
    bus.subscribe('/chat/5', (_) {});
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(server.polls, hasLength(1));
  });

  test('a refused key stops the bus and says so', () async {
    bus.subscribe('/chat/5', (_) {}, lastId: 1);
    await server.nextPoll;
    server.answerStatus(403);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(bus.isUnavailable, isTrue);
    expect(server.polls, hasLength(1));
  });

  test('when the last listener leaves, polling stops', () async {
    final remove = bus.subscribe('/chat/5', (_) {}, lastId: 1);
    await server.nextPoll;
    remove();
    server.answer(const []);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(server.polls, hasLength(1));
  });
}

/// Holds each poll open until the test answers it, like a long-poll server.
class _HeldPolls extends DiscourseClient {
  final List<Map<String, dynamic>> polls = [];
  final List<Completer<FCCallResult>> _held = [];
  Completer<void> _arrived = Completer<void>();

  /// Completes when the next poll reaches the server.
  Future<void> get nextPoll async {
    await _arrived.future.timeout(const Duration(seconds: 2));
    _arrived = Completer<void>();
  }

  void answer(List<Object> messages) => _held.removeAt(0).complete(
      FCCallResult(statusCode: 200, body: jsonEncode(messages)));

  void answerStatus(int code) =>
      _held.removeAt(0).complete(FCCallResult(statusCode: code));

  @override
  Future<FCCallResult> post(
    SiteContext context,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    Map<String, String>? extraHeaders,
  }) {
    expect(path, startsWith('/message-bus/'));
    expect(extraHeaders?['Dont-Chunk'], 'true');
    polls.add((jsonDecode(body as String) as Map).cast<String, dynamic>());
    final c = Completer<FCCallResult>();
    _held.add(c);
    if (!_arrived.isCompleted) _arrived.complete();
    return c.future;
  }
}

SiteContext _context() => SiteContext(
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
