//
//  AppRoute.swift
//  EucomCampusFeed
//

import Foundation

// Where tapping a notification (pop-up banner or the Notification list) should take the user.
enum AppRoute: Equatable {
    case conversation(UUID)   // a new message -> that conversation
    case post(UUID)           // reaction, comment, announcement -> that post
}

// Used to show the post detail screen as a sheet.
struct PostRoute: Identifiable {
    var id: UUID
}
