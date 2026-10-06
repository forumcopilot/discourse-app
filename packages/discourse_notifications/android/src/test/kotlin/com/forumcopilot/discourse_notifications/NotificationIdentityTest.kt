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
    @Test fun forumIdentityIsHostPortAndSubfolderCase() {
        val canonical = NotificationIdentity.forum("https://FORUM.example:443/Sub/")
        assertEquals("forum.example/Sub", canonical)
        // The relay files both schemes of one host under one forum.
        assertEquals(canonical, NotificationIdentity.forum("http://forum.example/Sub"))
        assertEquals(canonical, NotificationIdentity.forum("http://forum.example:80/Sub"))
        for (url in listOf("https://forum.example:444/Sub", "https://forum.example/sub", "https://forum.example/Other")) assertNotEquals(canonical, NotificationIdentity.forum(url))
        for (url in listOf(null, "bad", "ftp://forum.example", "https://u@forum.example", "https://forum.example/?x=1")) assertNull(NotificationIdentity.forum(url))
    }
    @Test fun hostsJavaUriWillNotParseStillHaveAnIdentity() {
        // An underscore or a non-ASCII host used to leave URI.host null, and
        // setAccount then threw into sign-in and sign-out.
        assertEquals("my_forum.example.com", NotificationIdentity.forum("https://my_forum.example.com"))
        assertEquals("my_forum.example.com:8443/x", NotificationIdentity.forum("https://My_Forum.example.com:8443/x/"))
        val unicode = NotificationIdentity.forum("https://fórum.example/sub")
        assertEquals("xn--frum-qqa.example/sub", unicode)
        assertEquals(unicode, NotificationIdentity.forum("https://xn--frum-qqa.example/sub"))
    }
}
