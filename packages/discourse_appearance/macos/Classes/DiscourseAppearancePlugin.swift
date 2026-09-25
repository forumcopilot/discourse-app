import Cocoa
import FlutterMacOS

/// Forces the app's appearance to the in-app light/dark choice, so
/// WKWebView's `prefers-color-scheme` and system panels match the
/// Flutter UI instead of the Mac's setting.
public class DiscourseAppearancePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.forumcopilot/discourse_appearance",
      binaryMessenger: registrar.messenger)
    let instance = DiscourseAppearancePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "setMode" else {
      result(FlutterMethodNotImplemented)
      return
    }
    switch call.arguments as? String {
    case "light": NSApp.appearance = NSAppearance(named: .aqua)
    case "dark": NSApp.appearance = NSAppearance(named: .darkAqua)
    default: NSApp.appearance = nil
    }
    result(nil)
  }
}
