//
//  NotificationItem.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import Foundation

enum NotificationCategory: String, CaseIterable {
    case all = "All"
    case announcement = "Announcement"
    case social = "Social"
    case organization = "Organization"
}

struct NotificationItem: Identifiable {
    var id = UUID()
    var icon: String
    var title: String
    var subtitle: String
    var timeAgo: String
    var category: NotificationCategory
    var isRead = true
    var kind = ""
    var postId: UUID? = nil   // the post a reaction / comment / announcement is about
}

// MARK: - Supabase rows

// Row from the `notifications` table
struct NotificationRow: Codable {
    var id: UUID
    var kind: String
    var title: String
    var subtitle: String
    var isRead: Bool
    var createdAt: String
    var postId: UUID?

    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case id, kind, title, subtitle
        case isRead = "is_read"
        case createdAt = "created_at"
    }

    func toItem() -> NotificationItem {
        let meta: (String, NotificationCategory)
        switch kind {
        case "announcement": meta = ("megaphone.fill", .announcement)
        case "organization": meta = ("building.2.fill", .organization)
        case "message": meta = ("envelope.fill", .social)
        case "comment": meta = ("bubble.left.fill", .social)
        default: meta = ("heart.fill", .social)
        }
        return NotificationItem(id: id, icon: meta.0, title: title, subtitle: subtitle,
                                timeAgo: (Date.fromSupabase(createdAt) ?? Date()).shortAgo,
                                category: meta.1, isRead: isRead, kind: kind, postId: postId)
    }
}
