//
//  Conversation.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import Foundation

struct ChatMessage: Identifiable {
    var id = UUID()
    var text: String
    var isSentByMe: Bool
    var timestamp: String
}

struct Conversation: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var lastMessage = ""
    var timestamp = ""
    var unreadCount = 0
    var isGroup = false
    var avatarURL = ""
    var otherUserId: UUID? = nil   // the other person in a direct chat (nil for groups)

    static func == (lhs: Conversation, rhs: Conversation) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Supabase rows

// Result of the `my_conversations()` function
struct ConversationRow: Codable {
    var conversationId: UUID
    var isGroup: Bool
    var name: String
    var avatarUrl: String
    var lastMessage: String
    var lastAt: String
    var unreadCount: Int
    var otherUserId: UUID?

    enum CodingKeys: String, CodingKey {
        case otherUserId = "other_user_id"
        case conversationId = "conversation_id"
        case isGroup = "is_group"
        case name
        case avatarUrl = "avatar_url"
        case lastMessage = "last_message"
        case lastAt = "last_at"
        case unreadCount = "unread_count"
    }

    func toConversation() -> Conversation {
        Conversation(id: conversationId, name: name, lastMessage: lastMessage,
                     timestamp: (Date.fromSupabase(lastAt) ?? Date()).chatLabel,
                     unreadCount: unreadCount, isGroup: isGroup, avatarURL: avatarUrl,
                     otherUserId: otherUserId)
    }
}

// Row from the `messages` table
struct MessageRow: Codable {
    var id: UUID
    var conversationId: UUID
    var senderId: UUID
    var body: String
    var createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case body
        case createdAt = "created_at"
    }

    func toChatMessage(me: UUID?) -> ChatMessage {
        let date = Date.fromSupabase(createdAt) ?? Date()
        return ChatMessage(id: id, text: body, isSentByMe: senderId == me,
                           timestamp: date.formatted(date: .omitted, time: .shortened))
    }
}

struct MessageInsert: Encodable {
    var conversationId: UUID
    var body: String

    enum CodingKeys: String, CodingKey {
        case conversationId = "conversation_id"
        case body
    }
}

