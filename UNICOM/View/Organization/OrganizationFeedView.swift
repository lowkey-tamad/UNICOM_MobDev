//
//  OrganizationFeedView.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI

struct OrganizationFeedView: View {
    @EnvironmentObject var appState: AppState
    @Namespace private var namespace
    @State private var searchText = ""
    @State private var selectedTab = "All"
    @State private var showComposer = false
    @State private var showNotifications = false
    @State private var showFilter = false
    @State private var filter = PostFilter()
    @State private var showAllFeatured = false

    var filteredOrganizations: [StudentOrganization] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return appState.organizations.filter { org in
            (selectedTab == "All" || org.type.contains(selectedTab))
                && (query.isEmpty || org.name.localizedCaseInsensitiveContains(query)
                    || org.shortName.localizedCaseInsensitiveContains(query))
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackdrop()

                VStack(spacing: 16) {
                    TopBarView(searchText: $searchText, onAdd: { showComposer = true }, onNotification: { showNotifications = true })

                    HStack {
                        Text("Organization Feed")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.horizontal)

                    HStack {
                        PillTabBar(titles: ["All", "University", "Department"], selected: $selectedTab, namespace: namespace)
                        Button {
                            showFilter = true
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            FeaturedOrganizationPanel(organizations: filteredOrganizations) {
                                showAllFeatured = true
                            }
                            .padding(.horizontal)

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Latest Updates")
                                    .font(.system(.headline, design: .rounded))
                                    .foregroundStyle(.white)

                                VStack(spacing: 12) {
                                    let updates = filter.apply(appState.organizationSamplePosts)
                                    if updates.isEmpty {
                                        Text("No posts match this filter.")
                                            .font(.system(.footnote, design: .rounded))
                                            .foregroundStyle(.white.opacity(0.6))
                                            .padding(.top, 20)
                                    }
                                    ForEach(updates) { post in
                                        PostCardView(post: post, onVote: { appState.vote(on: post, value: $0) })
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationDestination(isPresented: $showNotifications) {
                NotificationView()
            }
            .navigationDestination(isPresented: $showAllFeatured) {
                FeaturedOrganizationListView()
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
    OrganizationFeedView()
        .environmentObject(AppState())
}
