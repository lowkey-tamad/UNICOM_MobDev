//
//  TopBarView.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI

struct TopBarView: View {
    @EnvironmentObject var appState: AppState
    @Binding var searchText: String
    var onAdd: () -> Void
    var onNotification: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button {
                appState.selectedTab = .profile
            } label: {
                AvatarView(url: appState.account.avatarURL, size: 36)
            }
            .buttonStyle(.plain)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.6))
                TextField("Search people, group...", text: $searchText)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .glassCapsule()

            Button(action: onAdd) {
                Image(systemName: "plus")
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
            }
            .glassCard(cornerRadius: 12)

            Button(action: onNotification) {
                Image(systemName: "bell")
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
            }
            .glassCard(cornerRadius: 12)
            .overlay(alignment: .topTrailing) {
                if appState.unreadNotifications > 0 {
                    Circle()
                        .fill(Color.appRed)
                        .frame(width: 10, height: 10)
                        .offset(x: 2, y: -2)
                }
            }
        }
        .padding(.horizontal)
    }
}
