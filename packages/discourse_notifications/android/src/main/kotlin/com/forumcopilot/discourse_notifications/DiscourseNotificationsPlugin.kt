package com.forumcopilot.discourse_notifications

import android.app.Notification
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import org.json.JSONObject
import java.security.SecureRandom

/** All MethodChannel calls run on the platform main thread, across engines.
 * Persist before returning; logout and display cannot pass each other in the
 * gap between an asynchronous Dart identity check and NotificationManager.
 */
class DiscourseNotificationsPlugin : FlutterPlugin, MethodChannel.MethodCallHandler,
    ActivityAware, PluginRegistry.NewIntentListener {
    private lateinit var context: Context
    private lateinit var channel: MethodChannel
    private var activityBinding: ActivityPluginBinding? = null
    private var pendingTap: Map<String, String>? = null
    private var listening = false
    private val prefs get() = context.getSharedPreferences("discourse_notifications", Context.MODE_PRIVATE)
    private val manager get() = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "com.forumcopilot/notifications")
        channel.setMethodCallHandler(this)
    }
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "configure" -> {
                    val icon = call.argument<String>("icon") ?: ""
                    require(iconId(icon) != 0) { "Notification icon does not exist" }
                    val editor = prefs.edit().putString("icon", icon)
                    val accounts = call.argument<Map<String, String>>("accounts") ?: emptyMap()
                    for ((raw, user) in accounts) {
                        val forum = NotificationIdentity.forum(raw) ?: continue
                        if (!prefs.contains("account:$forum")) {
                            editor.putString("account:$forum", NotificationIdentity.user(user) ?: "")
                        }
                    }
                    // One-time migration: older FCM/local entries contain no
                    // reliable forum ownership. Clear those before opting in.
                    if (!prefs.getBoolean("migrated", false)) {
                        for (entry in manager.activeNotifications) {
                            if (entry.tag?.startsWith(TAG_PREFIX) != true) manager.cancel(entry.tag, entry.id)
                        }
                        editor.putBoolean("migrated", true)
                    }
                    check(editor.commit()) { "Could not persist notification configuration" }
                    result.success(null)
                }
                "setAccount" -> {
                    val forum = NotificationIdentity.forum(call.argument("forum"))
                        ?: throw IllegalArgumentException("Invalid forum")
                    val user = NotificationIdentity.user(call.argument("userId")) ?: ""
                    check(prefs.edit().putString("account:$forum", user).commit()) {
                        "Could not persist notification account"
                    }
                    val keep = tag(forum, user)
                    for (entry in manager.activeNotifications) {
                        if (entry.tag?.startsWith("$TAG_PREFIX$forum|") == true && entry.tag != keep) {
                            manager.cancel(entry.tag, entry.id)
                        }
                    }
                    result.success(null)
                }
                "show" -> result.success(show(call.arguments as? Map<*, *> ?: emptyMap<String, String>()))
                "takeTap" -> {
                    listening = true
                    result.success(pendingTap)
                    pendingTap = null
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("notification_error", e.message, null)
        }
    }

    private fun iconId(name: String): Int {
        val parts = name.removePrefix("@").split('/')
        return context.resources.getIdentifier(parts.last(), if (parts.size > 1) parts.first() else "drawable", context.packageName)
    }
    private fun tag(forum: String, user: String) = "$TAG_PREFIX$forum|$user"
    private fun show(raw: Map<*, *>): Boolean {
        val data = raw.entries.associate { it.key.toString() to it.value.toString() }
        if (data["delivery_mode"] != "account_guarded_v1") return false
        val forum = NotificationIdentity.forum(data["site_url"]) ?: return false
        val user = NotificationIdentity.user(data["recipient_user_id"]) ?: return false
        if (!NotificationIdentity.permits(prefs.getString("account:$forum", null), user)) return false
        val icon = iconId(prefs.getString("icon", "") ?: "")
        if (icon == 0) return false
        // A channel this build doesn't have (an older app, a new group on the
        // relay) falls back to the default one rather than dropping the push.
        var channelId = data["channel_id"] ?: DEFAULT_CHANNEL
        if (Build.VERSION.SDK_INT >= 26 && manager.getNotificationChannel(channelId) == null) {
            channelId = DEFAULT_CHANNEL
            if (manager.getNotificationChannel(channelId) == null) return false
        }
        val notificationId = NotificationIdentity.messageKey(data) ?: return false
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName) ?: return false
        intent.action = ACTION
        intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        intent.data = Uri.Builder().scheme("discourse-notification").authority("open")
            .appendPath(forum).appendPath(user).appendPath(notificationId).build()
        intent.putExtra(PAYLOAD, JSONObject(data).toString())
        // The launcher activity is exported: only an intent carrying this
        // app-private token opens a notification route.
        intent.putExtra(TOKEN, tapToken())
        val pending = PendingIntent.getActivity(context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val builder = if (Build.VERSION.SDK_INT >= 26) Notification.Builder(context, channelId)
            else Notification.Builder(context)
        builder.setSmallIcon(icon).setContentTitle(data["title"])
            .setContentText(data["body"])
            .setStyle(Notification.BigTextStyle().bigText(data["body"]))
            .setAutoCancel(true).setContentIntent(pending).setGroup(tag(forum, user))
        accentColor()?.let { builder.setColor(it) }
        data["notification_count"]?.toIntOrNull()?.takeIf { it > 0 }?.let { builder.setNumber(it) }
        manager.notify(tag(forum, user), notificationId.hashCode(), builder.build())
        return true
    }

    /** Random, created once, kept in this app's private preferences. */
    private fun tapToken(): String {
        prefs.getString("tap_token", null)?.let { return it }
        val bytes = ByteArray(16).also { SecureRandom().nextBytes(it) }
        val token = bytes.joinToString("") { "%02x".format(it) }
        prefs.edit().putString("tap_token", token).commit()
        return token
    }

    private fun accentColor(): Int? {
        val id = context.resources.getIdentifier("default_notification_color", "color", context.packageName)
        if (id == 0) return null
        return try {
            if (Build.VERSION.SDK_INT >= 23) context.getColor(id) else context.resources.getColor(id)
        } catch (_: Exception) { null }
    }

    private fun consume(intent: Intent?): Map<String, String>? {
        if (intent?.action != ACTION) return null
        val payload = intent.getStringExtra(PAYLOAD) ?: return null
        val token = intent.getStringExtra(TOKEN)
        intent.removeExtra(PAYLOAD)
        intent.removeExtra(TOKEN)
        // Reopening from Recents after the process died re-delivers the
        // original intent: that is not a new tap.
        if ((intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY) != 0) return null
        if (token == null || token != prefs.getString("tap_token", null)) return null
        return try {
            val json = JSONObject(payload)
            json.keys().asSequence().associateWith { json.getString(it) }
        } catch (_: Exception) { null }
    }
    override fun onNewIntent(intent: Intent): Boolean {
        val data = consume(intent) ?: return false
        if (listening) channel.invokeMethod("tap", data) else pendingTap = data
        return true
    }
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        binding.addOnNewIntentListener(this)
        consume(binding.activity.intent)?.let { pendingTap = it }
    }
    override fun onDetachedFromActivity() {
        activityBinding?.removeOnNewIntentListener(this)
        activityBinding = null
    }
    override fun onDetachedFromActivityForConfigChanges() = onDetachedFromActivity()
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = onAttachedToActivity(binding)
    companion object {
        private const val TAG_PREFIX = "discourse-account:"
        private const val ACTION = "com.forumcopilot.NOTIFICATION_OPEN"
        private const val PAYLOAD = "discourse_notification_payload"
        private const val TOKEN = "discourse_notification_token"
        private const val DEFAULT_CHANNEL = "forum_copilot_channel"
    }
}
