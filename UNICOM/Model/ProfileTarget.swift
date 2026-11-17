//
//  ProfileTarget.swift
//  EucomCampusFeed
//

import Foundation

// Whose profile to show on the "other user" profile screen.
// `userId` is nil for the built-in sample authors, who have no account.
struct ProfileTarget: Identifiable {
    var id = UUID()
    var userId: UUID?
    var name: String
    var role: String
    var department = ""
    var yearLevel = ""
    var organizationName = ""
    var avatarURL = ""
    var localAvatar: String? = nil

    init(post: Post) {
        userId = post.authorId
        name = post.authorName
        role = post.authorRole
        organizationName = post.organizationName
        avatarURL = post.avatarURL
        localAvatar = post.localAvatarName
    }

    init(profile: PublicProfile) {
        userId = profile.id
        name = profile.fullName
        role = profile.role
        department = profile.department
        yearLevel = profile.yearLevel
        organizationName = profile.organizationName ?? ""
        avatarURL = profile.avatarUrl
    }

    init(conversation: Conversation) {
        userId = conversation.otherUserId
        name = conversation.name
        role = ""
        avatarURL = conversation.avatarURL
    }
}
