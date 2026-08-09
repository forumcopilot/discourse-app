import 'dart:convert';

import 'package:discourse_ui/utils/like_cooldown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/domain/site.dart';
import 'package:forumcopilot_sdk/network/fc_call_result.dart';

/// Builds a SiteContext whose last response is [result], which is where
/// `BaseDiscourseProxy` stashes every response and where LikeCooldown reads
/// the rate-limit details from.
SiteContext contextWithResponse(FCCallResult result) {
  final site = Site(
    id: null,
    name: 'test',
    url: 'https://example.invalid',
    description: '',
    endpoint: null,
    baseUrl: 'https://example.invalid',
    logoUrl: null,
    backgroundUrl: null,
    siteType: 'discourse',
  );
  return SiteContext(siteType: 'discourse', site: site)
    ..setLastCallResponse(result);
}

FCCallResult rateLimited({
  int? waitSeconds,
  String? retryAfter,
  int status = 429,
}) =>
    FCCallResult(
      statusCode: status,
      body: waitSeconds == null
          ? ''
          : jsonEncode({
              'errors': ['You’ve performed this action too many times.'],
              'error_type': 'rate_limit',
              'extras': {'wait_seconds': waitSeconds},
            }),
      headers: retryAfter == null ? const {} : {'retry-after': retryAfter},
      fcIsLogin: false,
    );

void main() {
  setUp(LikeCooldown.clear);

  test('records the wait from extras.wait_seconds', () {
    final ctx = contextWithResponse(rateLimited(waitSeconds: 42));
    final recorded = LikeCooldown.noteFromLastResponse(ctx, 'p1');
    expect(recorded, const Duration(seconds: 42));
    expect(LikeCooldown.isCoolingDown('p1'), isTrue);
    expect(LikeCooldown.secondsLeft('p1'), inInclusiveRange(41, 42));
  });

  test('falls back to the Retry-After header for a text/plain 429', () {
    final ctx = contextWithResponse(rateLimited(retryAfter: '15'));
    expect(LikeCooldown.noteFromLastResponse(ctx, 'p2'),
        const Duration(seconds: 15));
  });

  test('a non-429 failure records nothing', () {
    final ctx = contextWithResponse(rateLimited(waitSeconds: 30, status: 422));
    expect(LikeCooldown.noteFromLastResponse(ctx, 'p3'), isNull);
    expect(LikeCooldown.isCoolingDown('p3'), isFalse);
  });

  test('is scoped per post — one cooling post does not block another', () {
    final ctx = contextWithResponse(rateLimited(waitSeconds: 30));
    LikeCooldown.noteFromLastResponse(ctx, 'p4');
    expect(LikeCooldown.isCoolingDown('p4'), isTrue);
    expect(LikeCooldown.isCoolingDown('p5'), isFalse,
        reason: 'the server limit is per post, so the UI must be too');
  });

  test('an implausibly long wait is ignored rather than pinning the button',
      () {
    final ctx = contextWithResponse(rateLimited(waitSeconds: 60 * 60));
    expect(LikeCooldown.noteFromLastResponse(ctx, 'p6'), isNull);
    expect(LikeCooldown.isCoolingDown('p6'), isFalse);
  });

  test('expires on its own', () async {
    final ctx = contextWithResponse(rateLimited(retryAfter: '1'));
    LikeCooldown.noteFromLastResponse(ctx, 'p7');
    expect(LikeCooldown.isCoolingDown('p7'), isTrue);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    expect(LikeCooldown.isCoolingDown('p7'), isFalse);
    expect(LikeCooldown.secondsLeft('p7'), 0);
  });
}
