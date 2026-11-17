//
//  PostFilter.swift
//  EucomCampusFeed
//

import Foundation

// What the "Filter Post" sheet edits. Nothing changes until the user taps Apply (isApplied).
struct PostFilter: Equatable {
    enum Sort: String, CaseIterable {
        case latest = "Latest"
        case mostLike = "Most like"
        case mostComment = "Most comment"
    }

    enum Range: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case thisWeek = "This week"
        case thisMonth = "This month"
    }

    var sort: Sort = .latest
    var range: Range = .all
    var isApplied = false

    func apply(_ posts: [Post]) -> [Post] {
        guard isApplied else { return posts }
        let now = Date()
        let calendar = Calendar.current

        let inRange = posts.filter { post in
            switch range {
            case .all: return true
            case .today: return calendar.isDate(post.createdAt, inSameDayAs: now)
            case .thisWeek: return calendar.isDate(post.createdAt, equalTo: now, toGranularity: .weekOfYear)
            case .thisMonth: return calendar.isDate(post.createdAt, equalTo: now, toGranularity: .month)
            }
        }

        switch sort {
        case .latest:
            return inRange.sorted { $0.createdAt > $1.createdAt }
        case .mostLike:
            return inRange.sorted { ($0.likeCount, $0.createdAt) > ($1.likeCount, $1.createdAt) }
        case .mostComment:
            return inRange.sorted { ($0.commentCount, $0.createdAt) > ($1.commentCount, $1.createdAt) }
        }
    }
}
