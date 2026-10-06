package com.forumcopilot.discourse_notifications

import java.net.URI

/** Full forum identity: schemes, ports and subfolder case are significant. */
internal object NotificationIdentity {
    fun forum(raw: String?): String? = try {
        val uri = URI(raw ?: "")
        val scheme = uri.scheme?.lowercase()
        val host = uri.host?.lowercase()
        if (scheme !in listOf("http", "https") || host.isNullOrBlank() ||
            uri.rawUserInfo != null || uri.rawQuery != null || uri.rawFragment != null) null
        else {
            val port = if (uri.port == -1 || (scheme == "https" && uri.port == 443) ||
                (scheme == "http" && uri.port == 80)) "" else ":${uri.port}"
            "$scheme://$host$port${(uri.rawPath ?: "").trimEnd('/')}"
        }
    } catch (_: Exception) { null }

    fun messageKey(data: Map<String, String>): String? {
        user(data["notification_id"])?.let { return "notification:$it" }
        user(data["bus_message_id"])?.let { return "bus:$it" }
        return null
    }

    fun user(raw: String?): String? = raw?.toLongOrNull()?.takeIf { it > 0 }?.toString()
    fun permits(active: String?, recipient: String?): Boolean =
        user(recipient)?.let { it == user(active) } ?: false
}
