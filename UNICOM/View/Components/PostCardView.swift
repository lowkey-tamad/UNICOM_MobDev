//
//  PostCardView.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI

struct PostCardView: View {
    var post: Post
    var allowsProfileTap = true
    var onVote: (Int) -> Void = { _ in }
    var onReport: () -> Void = {}
    var onHide: () -> Void = {}
    var onDelete: (() -> Void)? = nil

    @EnvironmentObject var appState: AppState
    @State private var showComments = false
    @State private var showImageViewer = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Button {
                    if allowsProfileTap { appState.openProfile(ProfileTarget(post: post)) }
                } label: {
                HStack(alignment: .top) {
                AvatarView(url: post.avatarURL, size: 36, assetName: post.localAvatarName)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(post.authorName)
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)

                        if post.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption2)
                                .foregroundStyle(Color.appRed)
                        }

                        if post.isOfficial {
                            Text("Official")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.appRed, in: Capsule())
                        }
                    }
                    Text("\(post.authorRole) · \(post.timeAgo)")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
                }
                }
                .buttonStyle(.plain)

                Spacer()

                Menu {
                    if let onDelete {
                        Button("Delete Post", systemImage: "trash", role: .destructive, action: onDelete)
                    } else {
                        Button("Report Post", systemImage: "flag", action: onReport)
                        Button("Hide Post", systemImage: "eye.slash", action: onHide)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.white.opacity(0.7))
                        .rotationEffect(.degrees(90))
                }
            }

            postText

            Group {
            if let localName = post.localImageName, UIImage(named: localName) != nil {
                Image(localName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else if let imageURL = post.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    case .failure:
                        EmptyView()
                    default:
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.white.opacity(0.08))
                            .frame(height: 220)
                            .overlay { ProgressView().tint(.white) }
                    }
                }
            }
            }
            .contentShape(Rectangle())
            .onTapGesture { showImageViewer = true }

            HStack(spacing: 20) {
                HStack(spacing: 10) {
                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                            onVote(1)
                        }
                    } label: {
                        Image(systemName: "arrow.up")
                            .fontWeight(post.myVote == 1 ? .bold : .regular)
                    }
                    .foregroundStyle(post.myVote == 1 ? Color.appRed : .white.opacity(0.6))

                    Text("\(post.likeCount)")
                        .foregroundStyle(.white.opacity(0.8))

                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                            onVote(-1)
                        }
                    } label: {
                        Image(systemName: "arrow.down")
                            .fontWeight(post.myVote == -1 ? .bold : .regular)
                    }
                    .foregroundStyle(post.myVote == -1 ? .blue : .white.opacity(0.6))
                }

                Button {
                    showComments = true
                } label: {
                    Label("\(post.commentCount)", systemImage: "bubble.right")
                }
            }
            .font(.system(.footnote, design: .rounded))
            .foregroundStyle(.white.opacity(0.6))
        }
        .padding()
        .glassCard()
        .sheet(isPresented: $showComments) {
            CommentsView(post: post)
        }
        .fullScreenCover(isPresented: $showImageViewer) {
            ImageViewerView(assetName: post.localImageName, url: post.imageURL.flatMap { URL(string: $0) })
        }
    }

    // Sample posts use "Title\nDetails": the first line is the headline, the rest is lighter text.
    @ViewBuilder
    var postText: some View {
        let lines = post.body.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: true)
        if post.isSample, lines.count == 2 {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(lines[0]))
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                Text(String(lines[1]))
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(post.body)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

