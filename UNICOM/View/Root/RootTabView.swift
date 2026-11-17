//
//  RootTabView.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI

struct RootTabView: View {
    @EnvironmentObject var appState: AppState

    // "9+" above 9, hidden when there is nothing unread.
    var unreadBadge: Text? {
        let count = appState.unreadMessages
        if count <= 0 { return nil }
        return Text(count > 9 ? "9+" : "\(count)")
    }

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            Tab("Home", systemImage: "house.fill", value: AppTab.home) {
                MainFeedView()
            }
            Tab("Organization", systemImage: "person.3.fill", value: AppTab.organization) {
                OrganizationFeedView()
            }
            Tab("Message", systemImage: "bubble.left.and.bubble.right.fill", value: AppTab.message) {
                MessagesListView()
            }
            .badge(unreadBadge)
            Tab("Profile", systemImage: "person.crop.circle.fill", value: AppTab.profile) {
                ProfileView()
            }
        }
        .tint(.appRed)
        .fullScreenCover(item: $appState.viewedProfile) { target in
            UserProfileView(target: target)
        }
        .sheet(item: $appState.postRoute) { route in
            PostDetailView(postId: route.id)
        }
    }
}

#Preview {
    RootTabView()
        .environmentObject(AppState())
}

