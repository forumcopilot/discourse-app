package com.forumcopilot.discourse_appearance

import android.app.UiModeManager
import android.content.Context
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Forces the app's night mode to the in-app light/dark choice.
 *
 * `UiModeManager.setApplicationNightMode` (API 31) is the only per-app
 * switch Android has. It flips the app's `uiMode` configuration, which
 * the WebView reads for `prefers-color-scheme` and system UI reads for
 * its own colours. Android persists it, so the next cold start (launch
 * screen included) already matches. Below API 31 this is a no-op and
 * the app keeps following the system.
 */
class DiscourseAppearancePlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "com.forumcopilot/discourse_appearance")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method != "setMode") {
            result.notImplemented()
            return
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            result.success(null)
            return
        }
        val nightMode = when (call.arguments as? String) {
            "light" -> UiModeManager.MODE_NIGHT_NO
            "dark" -> UiModeManager.MODE_NIGHT_YES
            // MODE_NIGHT_AUTO is "follow the system" for the per-app setting.
            else -> UiModeManager.MODE_NIGHT_AUTO
        }
        val uiModeManager = context.getSystemService(Context.UI_MODE_SERVICE) as? UiModeManager
        uiModeManager?.setApplicationNightMode(nightMode)
        result.success(null)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
