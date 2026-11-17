//
//  PostDetailView.swift
//  EucomCampusFeed
//
//  One post with its comments. Opened from a notification.
//

import SwiftUI

struct PostDetailView: View {
    let postId: UUID
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var fetched: Post? = nil
    @State private var comments: [Comment] = []
    @State private var draft = ""
    @State private var isLoading = true
    @State private var errorMessage: String? = nil

    // The live copy (so votes show right away), else what we fetched.
    private var post: Post? {
        if let live = appState.allPosts.first(where: { $0.id == postId }) { return live }
        if let live = appState.samplePosts.first(where: { $0.id == postId }) { return live }
        return fetched
    }

    var body: some View {
        ZStack {
            AppBackdrop()

            VStack(spacing: 0) {
                HStack {
                    Text("Post")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                    }
                }
                .padding()

                if let post {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            PostCardView(post: post, allowsProfileTap: false,
                                         onVote: { appState.vote(on: post, value: $0) })

                            Text("Comments")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)

                            if comments.isEmpty {
                                Text(post.allowsComments ? "No comments yet. Be the first!" : "Comments are turned off for this post.")
                                    .font(.system(.footnote, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.6))
                            }

                            ForEach(comments) { comment in
                                HStack(alignment: .top, spacing: 10) {
                                    AvatarView(url: comment.avatarURL, size: 32)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(comment.authorName) · \(comment.timeAgo)")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundStyle(.white.opacity(0.6))
                                        Text(comment.body)
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundStyle(.white)
                                    }
                                    Spacer()
                                }
                                .padding(12)
                                .glassCard(cornerRadius: 14)
                            }
                        }
                        .padding(.horizontal)
                    }

                    if post.allowsComments {
                        if let errorMessage {
                            Text(errorMessage)
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(Color.appPink)
                        }
                        HStack(spacing: 10) {
                            TextField("Write a comment...", text: $draft)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .glassCapsule()
                            Button(action: send) {
                                Image(systemName: "paperplane.fill")
                                    .foregroundStyle(.white)
                                    .frame(width: 36, height: 36)
                                    .background(Color.appRed, in: Circle())
                            }
                        }
                        .padding()
                    }
                } else if isLoading {
                    Spacer()
                    ProgressView().tint(.white)
                    Spacer()
                } else {
                    Spacer()
                    Text("This post is no longer available.")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                }
            }
        }
        .task {
            fetched = await appState.fetchPost(postId)
            comments = await appState.loadComments(for: postId)
            isLoading = false
        }
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        draft = ""
        Task {
            do {
                try await appState.addComment(to: postId, body: text)
                comments = await appState.loadComments(for: postId)
                errorMessage = nil
            } catch {
                errorMessage = "Could not post your comment."
            }
        }
    }
}
