import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// The Markdown an upload turns into, checked against what Discourse web
/// produces in `frontend/discourse/app/lib/uploads.js`:
///
///   imageMarkdown       `![name|WxH](url)`
///   attachmentMarkdown  `[name|attachment](url) (size)`
///
/// Observed before this was fixed, against a local Discourse: a posted
/// `notes.txt` came out as `[file|attachment](upload://….txt)` and cooked
/// to `<a class="attachment">file</a>` — the link text every reader and
/// screen reader gets was the literal word "file".
void main() {
  setUp(DiscourseUploadMetadata.reset);

  test('an attachment carries its filename and size', () {
    DiscourseUploadMetadata.remember(
      'upload://abc.txt',
      const DiscourseUploadMetadata(fileName: 'notes.txt', fileSize: 117),
    );
    expect(
      discourseUploadMarkdown('upload://abc.txt'),
      '[notes.txt|attachment](upload://abc.txt) (117 Bytes)',
    );
  });

  test('an image carries its name without extension, plus dimensions', () {
    DiscourseUploadMetadata.remember(
      'upload://xyz.png',
      const DiscourseUploadMetadata(
        fileName: 'ok-photo.png',
        fileSize: 4766,
        width: 900,
        height: 600,
        thumbnailWidth: 690,
        thumbnailHeight: 460,
      ),
    );
    expect(
      discourseUploadMarkdown('upload://xyz.png'),
      '![ok-photo|690x460](upload://xyz.png)',
    );
  });

  test('falls back to full dimensions when no thumbnail size is given', () {
    DiscourseUploadMetadata.remember(
      'upload://d.jpg',
      const DiscourseUploadMetadata(
        fileName: 'shot.jpg',
        fileSize: 10,
        width: 300,
        height: 200,
      ),
    );
    expect(discourseUploadMarkdown('upload://d.jpg'),
        '![shot|300x200](upload://d.jpg)');
  });

  test('unknown upload still produces valid Markdown', () {
    // Metadata is process-lifetime, so a ref restored from a draft after
    // a restart has none. Better a generic label than broken Markdown.
    expect(discourseUploadMarkdown('upload://gone.png'),
        '![image](upload://gone.png)');
    expect(discourseUploadMarkdown('upload://gone.zip'),
        '[file|attachment](upload://gone.zip)');
  });

  test('sizes use the units Discourse prints', () {
    for (final (bytes, expected) in [
      (117, '117 Bytes'),
      (2048, '2.0 KB'),
      (5 * 1024 * 1024, '5.0 MB'),
    ]) {
      DiscourseUploadMetadata.remember(
        'upload://s.bin',
        DiscourseUploadMetadata(fileName: 'f.bin', fileSize: bytes),
      );
      expect(discourseUploadMarkdown('upload://s.bin'), endsWith('($expected)'));
    }
  });
}
