//
//  MainFeedView.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI

struct MainFeedView: View {
    @EnvironmentObject var appState: AppState
    @Namespace private var tabNamespace
    @State private var searchText = ""
    @State private var selectedTab = FeedTab.trending.rawValue
    @State private var showComposer = false
    @State private var showNotifications = false
    @State private var showFilter = false
    @State private var filter = PostFilter()

    var shownPosts: [Post] { filter.apply(currentPosts) }

    var currentPosts: [Post] {
        switch selectedTab {
        case FeedTab.campus.rawValue: return appState.campusFeed
        case FeedTab.social.rawValue: return appState.socialFeed
        default: return appState.allFeed
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackdrop()

                VStack(spacing: 16) {
                    TopBarView(searchText: $searchText, onAdd: { showComposer = true }, onNotification: { showNotifications = true })

                    HStack {
                        PillTabBar(titles: FeedTab.allCases.map(\.rawValue), icons: ["flame.fill", "graduationcap.fill", "person.2.fill"], selected: $selectedTab, namespace: tabNamespace)

                        Button {
                            showFilter = true
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal)

                    if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        SearchResultsView(query: searchText)
                    } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            HappeningNowView(items: appState.happeningNow)
                                .padding(.horizontal)

                            VStack(spacing: 12) {
                                if shownPosts.isEmpty {
                                    Text(filter.isApplied ? "No posts match this filter." : "No posts yet. Tap + to share something!")
                                        .font(.system(.footnote, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.6))
                                        .padding(.top, 30)
                                }

                                ForEach(shownPosts) { post in
                                    PostCardView(
                                        post: post,
                                        onVote: { appState.vote(on: post, value: $0) },
                                        onHide: { appState.hidePost(post) },
                                        onDelete: post.authorId == appState.userId
                                            ? { Task { await appState.deletePost(post) } }
                                            : nil
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                    }
                    .refreshable {
                        await appState.loadPosts()
                        await appState.loadNotifications()
                    }
                    }
                }
            }
            .navigationDestination(isPresented: $showNotifications) {
                NotificationView()
            }
            .sheet(isPresented: $showComposer) {
                PostComposerView()
            }
            .sheet(isPresented: $showFilter) {
                FilterSheetView(filter: $filter)
                    .presentationDetents([.medium])
            }
            .toolbar(.hidden)
        }
    }
}

#Preview {
    MainFeedView()
        .environmentObject(AppState())
}
