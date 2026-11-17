//
//  Post.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import Foundation

enum FeedTab: String, CaseIterable {
    case trending = "Trending"
    case campus = "Campus"
    case social = "Social"
}

enum PostAudience: String, CaseIterable {
    case campus = "Campus"
    case social = "Social"
    case organization = "Organization"
}

struct Post: Identifiable {
    var id = UUID()
    var authorId: UUID? = nil
    var authorName: String
    var authorRole: String
    var isVerified: Bool
    var timeAgo: String
    var body: String
    var likeCount: Int
    var commentCount: Int
    var isOfficial: Bool

    var audience: PostAudience = .campus
    var organizationName = ""
    var allowsComments = true
    var imageURL: String? = nil
    var avatarURL = ""
    var createdAt = Date()
    var myVote = 0

    // Sample posts bundled with the app (pictures come from the asset catalog, not Supabase).
    var isSample = false
    var sampleKey: String? = nil   // stable id for sample posts (their UUID changes every launch)
    var localImageName: String? = nil
    var localAvatarName: String? = nil

    init(authorName: String, authorRole: String, isVerified: Bool, timeAgo: String, body: String, likeCount: Int, commentCount: Int, isOfficial: Bool) {
        self.authorName = authorName
        self.authorRole = authorRole
        self.isVerified = isVerified
        self.timeAgo = timeAgo
        self.body = body
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.isOfficial = isOfficial
    }

    init() {
        self.init(authorName: "", authorRole: "", isVerified: false, timeAgo: "", body: "", likeCount: 0, commentCount: 0, isOfficial: false)
    }
}

struct Announcement: Identifiable {
    var id = UUID()
    var tag: String
    var title: String
    var subtitle: String
    var source: String
    var imageName: String?

    init(tag: String, title: String, subtitle: String, source: String = "", imageName: String? = nil) {
        self.tag = tag
        self.title = title
        self.subtitle = subtitle
        self.source = source
        self.imageName = imageName
    }
}

struct Comment: Identifiable {
    var id: UUID
    var authorName: String
    var avatarURL: String
    var body: String
    var timeAgo: String
}

// MARK: - Supabase rows

// Row from the `posts_feed` view
struct PostRow: Codable {
    var id: UUID
    var authorId: UUID
    var body: String
    var audience: String
    var organizationName: String
    var allowsComments: Bool
    var imageUrl: String?
    var createdAt: String
    var authorName: String
    var authorRole: String
    var avatarUrl: String
    var isOfficial: Bool
    var score: Int
    var commentCount: Int
    var myVote: Int

    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case body, audience
        case organizationName = "organization_name"
        case allowsComments = "allows_comments"
        case imageUrl = "image_url"
        case createdAt = "created_at"
        case authorName = "author_name"
        case authorRole = "author_role"
        case avatarUrl = "avatar_url"
        case isOfficial = "is_official"
        case score
        case commentCount = "comment_count"
        case myVote = "my_vote"
    }

    func toPost() -> Post {
        let date = Date.fromSupabase(createdAt) ?? Date()
        var post = Post(authorName: authorName, authorRole: authorRole, isVerified: isOfficial,
                        timeAgo: date.shortAgo, body: body, likeCount: score,
                        commentCount: commentCount, isOfficial: isOfficial)
        post.id = id
        post.authorId = authorId
        post.audience = PostAudience(rawValue: audience) ?? .campus
        post.organizationName = organizationName
        post.allowsComments = allowsComments
        post.imageURL = (imageUrl?.isEmpty == false) ? imageUrl : nil
        post.avatarURL = avatarUrl
        post.createdAt = date
        post.myVote = myVote
        return post
    }
}

struct PostInsert: Encodable {
    var body: String
    var audience: String
    var organizationName: String
    var allowsComments: Bool
    var imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case body, audience
        case organizationName = "organization_name"
        case allowsComments = "allows_comments"
        case imageUrl = "image_url"
    }
}

struct VoteUpsert: Encodable {
    var postId: UUID
    var value: Int

    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case value
    }
}

struct CommentRow: Codable {
    var id: UUID
    var postId: UUID
    var body: String
    var createdAt: String
    var authorName: String
    var avatarUrl: String

    enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case body
        case createdAt = "created_at"
        case authorName = "author_name"
        case avatarUrl = "avatar_url"
    }

    func toComment() -> Comment {
        Comment(id: id, authorName: authorName, avatarURL: avatarUrl, body: body,
                timeAgo: (Date.fromSupabase(createdAt) ?? Date()).shortAgo)
    }
}

struct CommentInsert: Encodable {
    var postId: UUID
    var body: String

    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case body
    }
}
