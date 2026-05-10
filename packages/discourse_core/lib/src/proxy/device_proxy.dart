import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_device_proxy.dart';
import 'package:forumcopilot_sdk/models/results/fc_device_result.dart';
import '../base_discourse_proxy.dart';

/// Discourse implementation of [IFCDeviceProxy].
///
/// **Phase-3 stub.** Push notifications aren't wired on Discourse yet —
/// the real implementation will register the device's FCM token against
/// the User API Key's `push_url` (Discourse pushes to whatever URL is
/// registered there). All three methods currently report success with a
/// no-op so the push controller's bootstrap code in
/// `lib/controllers/push_notification_controller.dart` doesn't crash
/// when Firebase issues a token; the device just doesn't actually
/// receive pushes until the relay backend is wired.
class DiscourseDeviceProxy extends BaseDiscourseProxy
    implements IFCDeviceProxy {
  DiscourseDeviceProxy(SiteContext context) : super(context);

  @override
  Future<FCDeviceResult> registerDeviceAsync({
    required String deviceId,
    required String fcmToken,
    required String platform,
    required String source,
    String? appVersion,
  }) async {
    // TODO(phase-3): register the device with the push relay backend.
    // For now we accept the token silently so push initialisation in
    // main.dart can complete without surfacing a misleading error.
    return FCDeviceResult(
      result: true,
      resultText: 'Push registration deferred to Phase 3.',
      deviceId: deviceId,
    );
  }

  @override
  Future<FCDeviceResult> updateDeviceTokenAsync({
    required String deviceId,
    required String fcmToken,
  }) async {
    // TODO(phase-3): forward the new FCM token to the relay backend.
    return FCDeviceResult(
      result: true,
      resultText: 'Push token update deferred to Phase 3.',
      deviceId: deviceId,
    );
  }

  @override
  Future<FCDeviceResult> unregisterDeviceAsync(String deviceId) async {
    // TODO(phase-3): drop the device from the relay backend.
    return FCDeviceResult(
      result: true,
      resultText: 'Push unregister deferred to Phase 3.',
    );
  }
}
