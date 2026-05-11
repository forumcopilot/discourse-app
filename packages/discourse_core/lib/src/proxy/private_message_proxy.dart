import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_private_message_proxy.dart';
import 'package:forumcopilot_sdk/models/results/fc_private_message_result.dart';

import '../base_discourse_proxy.dart';

/// Phase 5.20e — dormant shim for the XF-shaped traditional PM
/// inbox/sent contract.
///
/// Discourse doesn't have a "PM inbox vs PM sent box, with a single
/// message per row" model. Every private message on Discourse is a
/// topic with `archetype: 'private_message'` and any number of posts
/// inside it — the right abstraction is a *conversation*. The app's
/// live PM UI uses `IFCPrivateConversationProxy` exclusively
/// (`DiscoursePrivateConversationProxy` against
/// `/topics/private-messages/{u}.json` and `/t/{id}.json`).
///
/// Earlier phases shipped a 433-LOC implementation of this proxy
/// that mapped the XF box-shaped contract onto Discourse's
/// topic-shaped reality. Every method worked, but **no UI ever
/// called any of them** — they were unreachable from Phase 0 onward.
/// The proxy's interface is still required by the SDK
/// (`SiteProxyFactory.getPrivateMessageProxy()` returns this type),
/// so we keep the class but stub each method to fail loudly with
/// guidance pointing at the conversation proxy. That way:
///
///   1. Anything that does happen to reach this proxy doesn't
///      silently render a half-broken XF-shape view of Discourse
///      PMs (which the old impl would have done, since
///      `markPmReadAsync` etc. were lossy).
///   2. The IFC contract stays satisfied so the typed factory
///      registry keeps compiling.
///   3. Future contributors get a clear pointer instead of
///      stumbling into a 433-LOC trap.
///
/// If a use case actually emerges for the traditional XF-shape, the
/// pre-5.20e implementation is recoverable from git history at
/// commit `83ca240`.
class DiscoursePrivateMessageProxy extends BaseDiscourseProxy
    implements IFCPrivateMessageProxy {
  DiscoursePrivateMessageProxy(SiteContext context) : super(context);

  static const String _redirect =
      'Use IFCPrivateConversationProxy on Discourse — '
      'discourseapp models PMs as conversations, not as XF-style '
      'inbox / sent boxes.';

  @override
  Future<FCBoxInfoResult> getBoxInfoAsync() async {
    return FCBoxInfoResult(
      result: false,
      resultText: _redirect,
      messageRoomCount: 0,
      list: const [],
    );
  }

  @override
  Future<FCBoxResult> getBoxAsync(
    String boxId,
    int startNum,
    int endNum,
  ) async {
    return FCBoxResult(
      result: false,
      resultText: _redirect,
      totalMessageNum: 0,
      list: const [],
    );
  }

  @override
  Future<FCMessageResult> getMessageAsync(
    String messageId,
    String boxId,
    bool returnHtml,
  ) async {
    return FCMessageResult(
      result: false,
      resultText: _redirect,
      msgId: messageId,
      subject: '',
      authorId: '',
      authorName: '',
      textBody: '',
      msgTime: '',
      isUnread: false,
    );
  }

  @override
  Future<FCCreateMessageResult> createMessageAsync(
    List<String> userName,
    String subject,
    String textBody,
    int? action,
    String? pmId,
    List<String>? attachmentIds,
    String? groupId,
  ) async {
    return FCCreateMessageResult(
      result: false,
      resultText: _redirect,
      msgId: '',
    );
  }

  @override
  Future<FCQuotePMResult> getQuotePmAsync(String messageId) async {
    return FCQuotePMResult(result: false, resultText: _redirect);
  }

  @override
  Future<FCDeleteMessageResult> deleteMessageAsync(
    String messageId,
    String boxId,
  ) async {
    return FCDeleteMessageResult(result: false, resultText: _redirect);
  }

  @override
  Future<FCMarkPMUnreadResult> markPmUnreadAsync(String messageId) async {
    return FCMarkPMUnreadResult(result: false, resultText: _redirect);
  }

  @override
  Future<FCMarkPMReadResult> markPmReadAsync(
    List<String> messageIds,
  ) async {
    return FCMarkPMReadResult(result: false, resultText: _redirect);
  }

  @override
  Future<FCReportPMResult> reportPmAsync(
    String msgId,
    String? reason,
  ) async {
    return FCReportPMResult(result: false, resultText: _redirect);
  }
}
