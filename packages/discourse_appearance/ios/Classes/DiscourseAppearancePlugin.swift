import Flutter
import UIKit

/// Forces every window's interface style to the in-app light/dark choice,
/// so WKWebView's `prefers-color-scheme`, share sheets, pickers and alerts
/// match the Flutter UI instead of the phone's setting.
public class DiscourseAppearancePlugin: NSObject, FlutterPlugin {
  private var style: UIUserInterfaceStyle = .unspecified

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.forumcopilot/discourse_appearance",
      binaryMessenger: registrar.messenger())
    let instance = DiscourseAppearancePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    // A window created later (a new scene) picks up the current choice.
    NotificationCenter.default.addObserver(
      instance, selector: #selector(windowDidBecomeVisible(_:)),
      name: UIWindow.didBecomeVisibleNotification, object: nil)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "setMode" else {
      result(FlutterMethodNotImplemented)
      return
    }
    switch call.arguments as? String {
    case "light": style = .light
    case "dark": style = .dark
    default: style = .unspecified
    }
    for case let scene as UIWindowScene in UIApplication.shared.connectedScenes {
      for window in scene.windows {
        window.overrideUserInterfaceStyle = style
      }
    }
    result(nil)
  }

  @objc private func windowDidBecomeVisible(_ note: Notification) {
    (note.object as? UIWindow)?.overrideUserInterfaceStyle = style
  }
}
