package com.forumcopilot.discourse_notifications

import java.net.IDN
import java.net.URI

/** Forum identity as the relay keys it: host, port and subfolder (whose case
 * is significant). The scheme is not: the relay files http:// and https:// of
 * one host under one forum and echoes whichever was registered first, so a
 * strict scheme match silently dropped every push for that forum.
 */
internal object NotificationIdentity {
    fun forum(raw: String?): String? {
        try {
            val uri = URI(raw?.trim() ?: "")
            val scheme = uri.scheme?.lowercase()
            if (scheme !in listOf("http", "https") ||
                uri.rawUserInfo != null || uri.rawQuery != null || uri.rawFragment != null) return null
            // java.net.URI leaves host null for hosts it won't parse as a
            // server authority (an underscore, a non-ASCII name). Read those
            // from the raw authority instead of refusing the forum.
            var host = uri.host
            var port = uri.port
            if (host == null) {
                val authority = uri.rawAuthority ?: return null
                if ('@' in authority) return null
                val colon = authority.lastIndexOf(':')
                if (colon > 0 && colon < authority.length - 1 &&
                    authority.substring(colon + 1).all { it.isDigit() }) {
                    host = authority.substring(0, colon)
                    port = authority.substring(colon + 1).toInt()
                } else {
                    host = authority
                }
            }
            if (host.isNullOrBlank()) return null
            val ascii = IDN.toASCII(host, IDN.ALLOW_UNASSIGNED).lowercase()
            val defaultPort = if (scheme == "https") 443 else 80
            val portPart = if (port == -1 || port == defaultPort) "" else ":$port"
            return "$ascii$portPart${(uri.rawPath ?: "").trimEnd('/')}"
        } catch (_: Exception) {
            return null
        }
    }

    fun messageKey(data: Map<String, String>): String? {
        user(data["notification_id"])?.let { return "notification:$it" }
        user(data["bus_message_id"])?.let { return "bus:$it" }
        return null
    }

    fun user(raw: String?): String? = raw?.toLongOrNull()?.takeIf { it > 0 }?.toString()
    fun permits(active: String?, recipient: String?): Boolean =
        user(recipient)?.let { it == user(active) } ?: false
}
