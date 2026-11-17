//
//  UserProfileView.swift
//  EucomCampusFeed
//
//  Another person's profile: their details and posts. No settings or edit buttons.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var profile: ProfileTarget
    @State private var fetchedPosts: [Post] = []
    @State private var isLoading = false

    init(target: ProfileTarget) {
        _profile = State(initialValue: target)
    }

    // Live copies so likes update right away; sample authors show their built-in posts.
    private var posts: [Post] {
        if profile.userId == nil {
            return appState.samplePosts.filter { $0.authorName == profile.name }
        }
        return fetchedPosts.map { post in
            appState.allPosts.first { $0.id == post.id } ?? post
        }
    }

    var body: some View {
        ZStack {
            AppBackdrop()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                    }
                    Text("Profile")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)

                ScrollView {
                    VStack(spacing: 16) {
                        header

                        Text("All post")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if isLoading {
                            ProgressView().tint(.white)
                        } else if posts.isEmpty {
                            Text("No posts yet.")
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.top, 10)
                        }

                        ForEach(posts) { post in
                            PostCardView(
                                post: post,
                                allowsProfileTap: false,
                                onVote: { appState.vote(on: post, value: $0) }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .task { await load() }
    }

    private var header: some View {
        VStack(spacing: 8) {
            AvatarView(url: profile.avatarURL, size: 88, assetName: profile.localAvatar)

            Text(profile.name)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(.white)

            if !profile.role.isEmpty {
                Text(profile.role)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Personal Details")
                    .font(.system(.footnote, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                detailRow(icon: "building.columns.fill", text: profile.department, empty: "No department set")
                detailRow(icon: "graduationcap.fill", text: profile.yearLevel, empty: "No course and year / position set")
                detailRow(icon: "person.3.fill", text: profile.organizationName, empty: "No Organization")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
        }
        .padding()
        .glassCard()
    }

    private func detailRow(icon: String, text: String, empty: String) -> some View {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        return HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.white.opacity(0.65))
                .frame(width: 20)
            Text(trimmed.isEmpty ? empty : trimmed)
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(.white.opacity(trimmed.isEmpty ? 0.5 : 0.85))
        }
    }

    private func load() async {
        guard let userId = profile.userId else { return }
        isLoading = true
        if let details = await appState.fetchPublicProfile(userId) {
            profile.name = details.fullName
            profile.role = details.role
            profile.department = details.department
            profile.yearLevel = details.yearLevel
            profile.organizationName = details.organizationName ?? ""
            profile.avatarURL = details.avatarUrl
        }
        fetchedPosts = await appState.fetchPosts(by: userId)
        isLoading = false
    }
}
