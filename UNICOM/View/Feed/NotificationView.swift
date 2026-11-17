//
//  NotificationView.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @Namespace private var namespace
    @State private var selectedCategory = NotificationCategory.all.rawValue

    var filteredNotifications: [NotificationItem] {
        if selectedCategory == NotificationCategory.all.rawValue {
            return appState.notifications
        }
        return appState.notifications.filter { $0.category.rawValue == selectedCategory }
    }

    // Close this screen first, then show what the notification is about.
    private func openNotification(_ item: NotificationItem) {
        dismiss()
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            appState.open(item)
        }
    }

    var body: some View {
        ZStack {
            AppBackdrop()

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(.white)
                    }
                    Text("Notification")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)

                PillTabBar(titles: NotificationCategory.allCases.map(\.rawValue), selected: $selectedCategory, namespace: namespace)
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(filteredNotifications) { item in
                            Button {
                                openNotification(item)
                            } label: {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: item.icon)
                                    .foregroundStyle(.white)
                                    .frame(width: 36, height: 36)
                                    .background(Color.appRed.opacity(0.4), in: Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(.system(.subheadline, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                    Text(item.subtitle)
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.6))
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 6) {
                                    Text(item.timeAgo)
                                        .font(.system(.caption2, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.5))
                                    if !item.isRead {
                                        Circle()
                                            .fill(Color.appRed)
                                            .frame(width: 8, height: 8)
                                    }
                                }
                            }
                            .padding()
                            .glassCard(cornerRadius: 16)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .toolbar(.hidden)
        .task {
            await appState.loadNotifications()
            try? await Task.sleep(for: .seconds(1.5))
            await appState.markNotificationsRead()
        }
    }
}

#Preview {
    NotificationView()
        .environmentObject(AppState())
}
