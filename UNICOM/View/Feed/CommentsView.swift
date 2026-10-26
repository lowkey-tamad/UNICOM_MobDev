//
//  CommentsView.swift
//  UNICOM
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

struct CommentsView: View {
    let post: Post
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var comments: [Comment] = []
    @State private var draft = ""
    @State private var isLoading = true
    @State private var errorMessage: String? = nil

    var body: some View {
        ZStack {
            AppBackdrop()

            VStack(spacing: 0) {
                HStack {
                    Text("Comments")
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

                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                        } else if comments.isEmpty {
                            Text(post.allowsComments ? "No comments yet. Be the first!" : "Comments are turned off for this post.")
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                                .frame(maxWidth: .infinity)
                                .padding(.top, 20)
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
            }
        }
        .task {
            comments = await appState.loadComments(for: post.id)
            isLoading = false
        }
    }

    func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        draft = ""
        Task {
            do {
                try await appState.addComment(to: post.id, body: text)
                comments = await appState.loadComments(for: post.id)
                errorMessage = nil
            } catch {
                draft = text
                errorMessage = "Couldn't post your comment."
            }
        }
    }
}


