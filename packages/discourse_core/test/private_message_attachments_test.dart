import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// A PM's uploads only become part of the message once their `upload://`
/// refs are written into raw. The composer uploads first and hands the refs
/// over; the private-message calls used to post the text alone.
///
/// Found on an iPhone 17 against meta.discourse.org (2026-09-22): a reply to
/// a PM with an image uploaded without error, and the post's raw was just
/// the text.
void main() {
  late _CapturingPmProxy proxy;

  setUp(() {
    DiscourseUploadMetadata.reset();
    DiscourseUploadMetadata.remember(
      'upload://photo.jpeg',
      const DiscourseUploadMetadata(
        fileName: 'photo.jpeg',
        fileSize: 1000,
        width: 800,
        height: 600,
      ),
    );
    proxy = _CapturingPmProxy();
  });

  test('a reply carries its uploads', () async {
    final r = await proxy.replyConversationAsync(
        '401970', 'Thanks', ['upload://photo.jpeg'], null);
    expect(r.result, isTrue);
    expect(proxy.lastBody!['raw'], 'Thanks\n\n![photo|800x600](upload://photo.jpeg)');
    expect(proxy.lastBody!.containsKey('archetype'), isFalse,
        reason: 'a reply must not restate the archetype');
  });

  test('a new message carries its uploads', () async {
    await proxy.newConversationAsync(['someone'], 'Hi', 'Look',
        attachmentIds: ['upload://photo.jpeg']);
    expect(proxy.lastBody!['raw'], 'Look\n\n![photo|800x600](upload://photo.jpeg)');
  });

  test('an edit carries newly added uploads', () async {
    await proxy.saveRawMessageAsync('5', 'Edited',
        attachmentIds: ['upload://photo.jpeg']);
    final post = proxy.lastBody!['post'] as Map;
    expect(post['raw'], 'Edited\n\n![photo|800x600](upload://photo.jpeg)');
  });

  test('an upload already placed inline is not appended again', () async {
    await proxy.replyConversationAsync(
        '1', 'See ![x](upload://photo.jpeg) here', ['upload://photo.jpeg'], null);
    expect(proxy.lastBody!['raw'], 'See ![x](upload://photo.jpeg) here');
  });
}

/// Records the body of the last write instead of sending it.
class _CapturingPmProxy extends DiscoursePrivateConversationProxy {
  _CapturingPmProxy()
      : super(SiteContext(
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
        ));

  Map<String, dynamic>? lastBody;

  @override
  Future<Map<String, dynamic>> apiPost(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    lastBody = (body as Map).cast<String, dynamic>();
    return {'id': 1, 'topic_id': 1};
  }

  @override
  Future<Map<String, dynamic>> apiPut(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    lastBody = (body as Map).cast<String, dynamic>();
    return {'raw': ((body['post'] as Map?)?['raw'])};
  }
}
