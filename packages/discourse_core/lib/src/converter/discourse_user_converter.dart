import 'package:forumcopilot_sdk/models/entities/fc_user.dart';
import '../data/user/user.dart';

/// Converter for mapping DiscourseUser to FCUser
class DiscourseUserConverter {
  /// Convert a single DiscourseUser to FCUser
  static FCUser toFCUser(DiscourseUser discourseUser) {
    return FCUser(
      id: discourseUser.userId.toString(),
      username: discourseUser.username,
      loginName: discourseUser.username,
      email: discourseUser.email,
      userType: discourseUser.userTitle,
      iconUrl: _getAvatarUrl(discourseUser),
      postCount: discourseUser.messageCount ?? 0,
      registrationTime: discourseUser.registerDate != null ? DateTime.fromMillisecondsSinceEpoch(discourseUser.registerDate! * 1000) : null,
      lastActivityTime: discourseUser.lastActivity != null ? DateTime.fromMillisecondsSinceEpoch(discourseUser.lastActivity! * 1000) : null,
      isOnline: discourseUser.isOnline,
      acceptsPM: discourseUser.canConverse ?? false,
      canSendPM: discourseUser.canConverse ?? false,
      canPM: discourseUser.canConverse ?? false,
      isFollowing: discourseUser.isFollowed ?? false,
      isFollowingMe: false, // Not available in API
      acceptsFollowers: false, // Not available in API
      followingCount: 0, // Not available in API
      followerCount: 0, // Not available in API
      displayText: discourseUser.userTitle,
      customFields: _getCustomFields(discourseUser),
      canBan: discourseUser.canBan ?? false,
      isBanned: discourseUser.isBanned ?? false,
      isIgnored: discourseUser.isIgnored ?? false,
      userGroups: _getUserGroups(discourseUser),
      canModerate: discourseUser.isModerator ?? false,
      canSearch: false, // Not available in API
    );
  }

  /// Convert a list of DiscourseUser to FCUser list
  static List<FCUser> toFCUserList(List<DiscourseUser> discourseUsers) {
    return discourseUsers.map((user) => toFCUser(user)).toList();
  }

  /// Get avatar URL from DiscourseUser
  static String? _getAvatarUrl(DiscourseUser user) {
    // Try different avatar URL sources
    if (user.avatarUrls != null && user.avatarUrls!.isNotEmpty) {
      // Get the largest avatar available
      final urls = user.avatarUrls!;
      if (urls.containsKey('l')) return urls['l'];
      if (urls.containsKey('m')) return urls['m'];
      if (urls.containsKey('s')) return urls['s'];
      // Return first available URL
      return urls.values.first;
    }

    // Fallback to direct avatar URL
    return user.avatarUrl;
  }

  /// Get user groups list from DiscourseUser
  static List<String> _getUserGroups(DiscourseUser user) {
    final groups = <String>[];

    // Add primary group if available
    if (user.userGroupId != null) {
      groups.add('Group ${user.userGroupId}');
    }

    // Add secondary groups if available
    if (user.secondaryGroupIds != null && user.secondaryGroupIds!.isNotEmpty) {
      groups.addAll(user.secondaryGroupIds!.map((id) => 'Group $id'));
    }

    // Add user title as a group
    if (user.userTitle != null && user.userTitle!.isNotEmpty) {
      groups.add(user.userTitle!);
    }

    return groups;
  }

  /// Extract custom fields from DiscourseUser
  static List<FCUserCustomField> _getCustomFields(DiscourseUser user) {
    final customFields = <FCUserCustomField>[];

    // Add profile fields as custom fields
    if (user.location != null) {
      customFields.add(FCUserCustomField(name: 'location', value: user.location!));
    }
    if (user.website != null) {
      customFields.add(FCUserCustomField(name: 'website', value: user.website!));
    }
    if (user.about != null) {
      customFields.add(FCUserCustomField(name: 'about', value: user.about!));
    }

    return customFields;
  }
}
