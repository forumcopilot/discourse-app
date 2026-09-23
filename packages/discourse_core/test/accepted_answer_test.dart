import 'package:discourse_core/src/data/post/discourse_accepted_answer.dart';
import 'package:flutter_test/flutter_test.dart';

/// discourse-solved has serialized the topic's solution two ways. Current
/// versions send a list (`accepted_answers`); reading only the older
/// `accepted_answer` object left the "Solved" panel under the first post
/// blank on 389 of 417 solved-enabled forums in the 2026-09-23 audit.
void main() {
  test('reads the older accepted_answer object', () {
    final answer = DiscourseAcceptedAnswer.fromTopicJson({
      'accepted_answer': {
        'post_number': 4,
        'username': 'alice',
        'name': 'Alice A.',
        'excerpt': '<p>Restart the service.</p>',
        'accepter_username': 'bob',
      },
    })!;

    expect(answer.postNumber, 4);
    expect(answer.solverDisplayName, 'Alice A.');
    expect(answer.excerptHtml, '<p>Restart the service.</p>');
    expect(answer.accepterUsername, 'bob');
  });

  test('reads the current accepted_answers list (first entry)', () {
    // The shape forums.almalinux.org sends: no name or accepter, the full
    // cooked answer instead of an excerpt.
    final answer = DiscourseAcceptedAnswer.fromTopicJson({
      'has_accepted_answer': true,
      'accepted_answers': [
        {
          'id': 16712,
          'username': 'label',
          'avatar_template': '/user_avatar/f.example/label/{size}/1949_2.png',
          'created_at': '2026-09-18T17:22:28.934Z',
          'cooked': '<p>The bootloader line is not required.</p>',
          'post_number': 2,
          'topic_id': 7625,
          'url': '/t/gpt-uefi/7625/2',
        },
        {'username': 'second', 'post_number': 9},
      ],
    })!;

    expect(answer.postNumber, 2);
    expect(answer.username, 'label');
    expect(answer.solverDisplayName, 'label');
    expect(answer.excerptHtml, '<p>The bootloader line is not required.</p>');
    expect(answer.avatarTemplate, contains('{size}'));
  });

  test('accepts numbers sent as strings', () {
    final answer = DiscourseAcceptedAnswer.fromTopicJson({
      'accepted_answers': [
        {'username': 'label', 'post_number': '2'},
      ],
    });

    expect(answer?.postNumber, 2);
  });

  test('no solution, or an unusable one, is null', () {
    expect(DiscourseAcceptedAnswer.fromTopicJson({}), isNull);
    expect(DiscourseAcceptedAnswer.fromTopicJson({'accepted_answers': []}), isNull);
    expect(
      DiscourseAcceptedAnswer.fromTopicJson({
        'accepted_answers': [
          {'username': '', 'post_number': 2},
        ],
      }),
      isNull,
    );
  });
}
