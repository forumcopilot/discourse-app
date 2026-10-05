package com.forumcopilot.discourse_notifications
import org.junit.Assert.*
import org.junit.Test
class NotificationIdentityTest {
    @Test fun chatBusAndNotificationRowsHaveIndependentTrayIds() {
        assertEquals("notification:12", NotificationIdentity.messageKey(mapOf("notification_id" to "12")))
        assertEquals("bus:12", NotificationIdentity.messageKey(mapOf("bus_message_id" to "12")))
        assertNull(NotificationIdentity.messageKey(mapOf("notification_id" to "0")))
    }
    @Test fun requiresKnownMatchingPositiveRecipient() {
        assertTrue(NotificationIdentity.permits("4", "4"))
        for (recipient in listOf(null, "", "-1", "0", "1", "bad")) assertFalse(NotificationIdentity.permits("4", recipient))
        assertFalse(NotificationIdentity.permits(null, "4"))
        assertFalse(NotificationIdentity.permits("", "4"))
    }
    @Test fun fullForumIdentityIncludesSchemePortAndSubfolderCase() {
        val canonical = NotificationIdentity.forum("https://FORUM.example:443/Sub/")
        assertEquals("https://forum.example/Sub", canonical)
        for (url in listOf("http://forum.example/Sub", "https://forum.example:444/Sub", "https://forum.example/sub", "https://forum.example/Other")) assertNotEquals(canonical, NotificationIdentity.forum(url))
        for (url in listOf(null, "bad", "ftp://forum.example", "https://u@forum.example", "https://forum.example/?x=1")) assertNull(NotificationIdentity.forum(url))
    }
}
