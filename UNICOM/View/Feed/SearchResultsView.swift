//
//  SearchResultsView.swift
//  EucomCampusFeed
//

import SwiftUI

struct SearchResultsView: View {
    @EnvironmentObject var appState: AppState
    let query: String
    @State private var people: [PublicProfile] = []

    private var trimmed: String { query.trimmingCharacters(in: .whitespacesAndNewlines) }

    private var matchingPosts: [Post] {
        guard !trimmed.isEmpty else { return [] }
        return (appState.samplePosts + appState.visiblePosts).filter {
            $0.body.localizedCaseInsensitiveContains(trimmed)
                || $0.authorName.localizedCaseInsensitiveContains(trimmed)
                || $0.organizationName.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                sectionTitle("People")
                if people.isEmpty {
                    emptyText("No people found.")
                }
                ForEach(people) { person in
                    Button {
                        appState.openProfile(ProfileTarget(profile: person))
                    } label: {
                    HStack(spacing: 12) {
                        AvatarView(url: person.avatarUrl, size: 40)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(person.fullName)
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.semibold)
                            Text([person.role, person.department].filter { !$0.isEmpty }.joined(separator: " · "))
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        Spacer()
                    }
                    .foregroundStyle(.white)
                    .padding()
                    .glassCard(cornerRadius: 16)
                    }
                    .buttonStyle(.plain)
                }

                sectionTitle("Posts")
                if matchingPosts.isEmpty {
                    emptyText("No posts found.")
                }
                ForEach(matchingPosts) { post in
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
            .padding(.bottom, 20)
        }
        // Restarts (and cancels the previous run) whenever the text changes, which debounces the request.
        .task(id: trimmed) {
            try? await Task.sleep(for: .milliseconds(300))
            if Task.isCancelled { return }
            people = await appState.searchProfiles(trimmed)
        }
    }

    func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(.headline, design: .rounded))
            .foregroundStyle(.white)
    }

    func emptyText(_ text: String) -> some View {
        Text(text)
            .font(.system(.footnote, design: .rounded))
            .foregroundStyle(.white.opacity(0.6))
    }
}
