import 'dart:async';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/controllers/site_controller.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/attachment_upload_service.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/edit_post_page.dart';
import 'package:discourse_ui/views/new_topic_page.dart';
import 'package:discourse_ui/views/private_messaging/conversation/pages/new_conversation_page.dart';
import 'package:discourse_ui/views/reply_page.dart';
import 'package:discourse_ui/views/widgets/message_compose_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  late SiteContext site;
  late _Factory factory;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    site = _site('first')
      ..setLoginData(FCLoginResult(
          result: true,
          resultText: '',
          canUploadAttachment: true,
          user: FCUser(id: '2', username: 'writer')));
    factory = _Factory();
    SiteProxyFactory.register('upload-test', factory);
    SiteProxyService.initialize(site);
    Get.put<DiscourseSiteController>(
        _SiteController()..currentSiteContext.value = site);
  });
  tearDown(() => Get.reset());

  Future<BuildContext> host(WidgetTester tester, [Widget? child]) async {
    late BuildContext context;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (value) {
        context = value;
        return child ?? const Scaffold();
      }),
    ));
    await tester.pumpAndSettle();
    return context;
  }

  Future<AttachmentUploadOutcome> upload(BuildContext context, XFile file) =>
      AttachmentUploadService.upload(
        context: context,
        file: file,
        uploadType: 'post',
        targetId: '4',
        groupId: '',
        currentAttachmentCount: 0,
      );
  for (final phase in ['reading', 'uploading']) {
    for (final transition in ['switch', 'logout', 'sign back in']) {
      testWidgets('$transition during $phase invalidates the upload',
          (tester) async {
        await site.setUserApiCredentials(
            userApiKey: 'first-key', userApiClientId: 'first-client');
        final context = await host(tester);
        final file = _DelayedFile();
        if (phase == 'uploading') {
          factory.pending = Completer<FCAttachmentUploadResult>();
        }
        final pending = upload(context, file);
        await file.started.future;
        if (phase == 'uploading') {
          file.bytes.complete(Uint8List.fromList([1]));
          await tester.pump();
          expect(factory.calls, hasLength(1));
        }
        if (transition == 'switch') {
          await site.setUserApiCredentials(
              userApiKey: 'second-key', userApiClientId: 'second-client');
        } else {
          await site.clearUserApiCredentials();
          if (transition == 'sign back in') {
            await site.setUserApiCredentials(
                userApiKey: 'first-key', userApiClientId: 'first-client');
          }
        }
        if (phase == 'reading') {
          file.bytes.complete(Uint8List.fromList([1]));
        } else {
          factory.pending!.complete(_success());
        }
        final result = await pending;
        expect(result.succeeded, isFalse);
        expect(result.cancelled, isFalse);
        expect(result.errorMessage,
            'Your sign-in changed during the upload. Reopen this screen before trying again.');
        expect(result.shortUrl, isNull);
        expect(factory.calls, hasLength(phase == 'reading' ? 0 : 1));
      });
    }
  }
  testWidgets('refreshing unchanged credentials permits the pending upload',
      (tester) async {
    await site.setUserApiCredentials(
        userApiKey: 'first-key', userApiClientId: 'first-client');
    final context = await host(tester);
    final file = _DelayedFile();
    final pending = upload(context, file);
    await file.started.future;
    await site.setUserApiCredentials(
        userApiKey: 'first-key', userApiClientId: 'first-client');
    file.bytes.complete(Uint8List.fromList([1]));
    expect((await pending).succeeded, isTrue);
    expect(factory.calls, hasLength(1));
  });
  testWidgets('unreadable file during validation returns a visible error',
      (tester) async {
    site.setUploadLimits(
        const DiscourseUploadLimits(authorizedExtensions: ['txt']));
    final context = await host(tester);
    final result = await upload(context, _UnreadableFile());
    expect(result.succeeded, isFalse);
    expect(result.cancelled, isFalse);
    expect(result.errorMessage, isNotEmpty);
    expect(factory.calls, isEmpty);
  });
  testWidgets(
      'changing forum during file read keeps the original upload destination',
      (tester) async {
    final context = await host(tester);
    final file = _DelayedFile();
    final pending = upload(context, file);
    await file.started.future;
    SiteProxyFactory.initialize(_site('second'));
    file.bytes.complete(Uint8List.fromList([1]));
    final result = await pending;
    expect(result.succeeded, isTrue);
    expect(factory.calls.single, same(site));
  });
  testWidgets('closing during file preparation does not start an upload',
      (tester) async {
    final context = await host(tester);
    final file = _DelayedFile();
    final pending = upload(context, file);
    await file.started.future;
    await tester.pumpWidget(const SizedBox());
    file.bytes.complete(Uint8List.fromList([1]));
    final result = await pending;
    expect(result.cancelled, isTrue);
    expect(factory.calls, isEmpty);
  });
  testWidgets('transport failure is reported without retrying the upload',
      (tester) async {
    final context = await host(tester);
    factory.failure = StateError('connection interrupted');
    final result = await upload(
        context, XFile.fromData(Uint8List.fromList([1]), name: 'a.txt'));
    expect(result.succeeded, isFalse);
    expect(result.errorMessage, contains('connection interrupted'));
    expect(factory.calls, hasLength(1));
  });
  testWidgets('a selected file disappearing before validation shows a notice',
      (tester) async {
    site.setUploadLimits(
        const DiscourseUploadLimits(authorizedExtensions: ['txt']));
    FilePicker.platform = _MissingFilePicker();
    var uploads = 0;
    await host(
        tester,
        MessageComposePage(
          siteContext: site,
          title: 'Compose',
          autoFocusContent: false,
          onSubmit: (_, __) async => true,
          onFileUpload: (_) async {
            uploads++;
            return 'upload://abc.txt';
          },
        ));
    await tester.runAsync(() async {
      await tester.tap(find.byTooltip('Attach file'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(uploads, 0);
    await tester.pumpWidget(const SizedBox());
  });
  for (final kind in ['topic', 'reply', 'message', 'edit']) {
    testWidgets('$kind ignores upload completion after closing',
        (tester) async {
      factory.pending = Completer<FCAttachmentUploadResult>();
      final Widget page = switch (kind) {
        'topic' =>
          NewTopicPage(siteContext: site, forumId: '4', forumName: 'General'),
        'reply' =>
          ReplyPage(siteContext: site, threadId: '42', topicTitle: 'Topic'),
        'message' =>
          NewConversationPage(siteContext: site, initialRecipient: 'alice'),
        _ => EditPostPage(siteContext: site, postId: '11', topicTitle: 'Topic'),
      };
      await host(tester, page);
      final composer =
          tester.widget<MessageComposePage>(find.byType(MessageComposePage));
      final pending = composer.onFileUpload!(
          XFile.fromData(Uint8List.fromList([1]), name: 'a.txt'));
      await tester.pump();
      expect(factory.calls, hasLength(1));
      await tester.pumpWidget(const SizedBox());
      factory.pending!.complete(_success());
      expect(await pending, isNull);
      expect(tester.takeException(), isNull);
    });
  }
}

class _SiteController extends DiscourseSiteController {
  // Tests supply the context directly; skip settings and loader startup.
  @override
  // ignore: must_call_super
  void onInit() {}
}

SiteContext _site(String name) => SiteContext(
    siteType: 'upload-test',
    site: Site(
        name: name,
        url: 'https://$name.example',
        baseUrl: 'https://$name.example',
        description: '',
        siteType: 'upload-test'));

class _DelayedFile extends XFile {
  _DelayedFile() : super('delayed.txt');
  @override
  Future<int> length() async => 1;
  final started = Completer<void>();
  final bytes = Completer<Uint8List>();
  @override
  Future<Uint8List> readAsBytes() {
    started.complete();
    return bytes.future;
  }
}

class _UnreadableFile extends XFile {
  _UnreadableFile() : super('unreadable.txt');
  @override
  Future<int> length() async => throw StateError('file is no longer available');
}

FCAttachmentUploadResult _success() => FCAttachmentUploadResult(
    result: true, attachmentId: '12', groupId: 'upload://abc.txt');

class _Factory implements SiteProxyFactory {
  final calls = <SiteContext>[];
  Completer<FCAttachmentUploadResult>? pending;
  Object? failure;
  @override
  IFCAttachmentProxy createAttachmentProxy(SiteContext context) =>
      _Uploads(context, this);
  @override
  IFCDraftProxy createDraftProxy(SiteContext context) => _Drafts();
  @override
  IFCPostProxy createPostProxy(SiteContext context) => _Posts();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Uploads implements IFCAttachmentProxy {
  _Uploads(this.context, this.factory);
  final SiteContext context;
  final _Factory factory;
  @override
  Future<FCAttachmentUploadResult> uploadAttachmentAsync(String type, String id,
      String groupId, String name, Uint8List bytes) async {
    factory.calls.add(context);
    if (factory.failure != null) throw factory.failure!;
    return factory.pending?.future ?? _success();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Drafts implements IFCDraftProxy {
  @override
  Future<FCLoadDraftResult> loadDraftAsync(String key) async =>
      FCLoadDraftResult(result: true);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Posts implements IFCPostProxy {
  @override
  Future<FCRawPostResult> getRawPostAsync(String id) async =>
      FCRawPostResult(result: true, postContent: 'Existing content');
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MissingFilePicker extends FilePicker with MockPlatformInterfaceMixin {
  @override
  Future<FilePickerResult?> pickFiles(
          {String? dialogTitle,
          String? initialDirectory,
          FileType type = FileType.any,
          List<String>? allowedExtensions,
          Function(FilePickerStatus)? onFileLoading,
          bool allowCompression = false,
          int compressionQuality = 0,
          bool allowMultiple = false,
          bool withData = false,
          bool withReadStream = false,
          bool lockParentWindow = false,
          bool readSequential = false}) async =>
      FilePickerResult([
        PlatformFile(
            path: '/nonexistent/upload-test/missing.txt',
            name: 'missing.txt',
            size: 1)
      ]);
}
