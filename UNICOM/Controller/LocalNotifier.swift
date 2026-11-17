//
//  LocalNotifier.swift
//  UNICOM
//
//  Created by Mac-LAB on 10/27/26.
//
import Foundation
import UserNotifications

// Shows banners for new messages / notifications while the app is running.
// Each banner says what it is (Message, Reaction, Comment, Announcement) and,
// when tapped, sends the user to the matching screen.
final class LocalNotifier: NSObject, UNUserNotificationCenterDelegate {
    static let shared = LocalNotifier()

    // Set by AppState; called when the user taps a banner.
    var onRoute: (@MainActor (AppRoute) -> Void)?

    func requestPermission() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    static func label(for kind: String) -> String {
        switch kind {
        case "message": return "Message"
        case "reaction": return "Reaction"
        case "comment": return "Comment"
        case "announcement": return "Announcement"
        default: return "Notification"
        }
    }

    func show(title: String, body: String, kind: String, conversationId: UUID? = nil, postId: UUID? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = Self.label(for: kind)
        content.body = body
        content.sound = .default

        var info: [String: String] = ["kind": kind]
        if let conversationId { info["conversationId"] = conversationId.uuidString }
        if let postId { info["postId"] = postId.uuidString }
        content.userInfo = info

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }

    // Also show the banner when the app is open
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification,
                                            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }

    // The user tapped a banner
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            didReceive response: UNNotificationResponse,
                                            withCompletionHandler completionHandler: @escaping () -> Void) {
        let info = response.notification.request.content.userInfo
        let conversationId = (info["conversationId"] as? String).flatMap { UUID(uuidString: $0) }
        let postId = (info["postId"] as? String).flatMap { UUID(uuidString: $0) }

        Task { @MainActor in
            if let conversationId {
                LocalNotifier.shared.onRoute?(.conversation(conversationId))
            } else if let postId {
                LocalNotifier.shared.onRoute?(.post(postId))
            }
        }
        completionHandler()
    }
}
