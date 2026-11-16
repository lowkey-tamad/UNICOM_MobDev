//
//  ProfileView.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSettings = false
    @State private var pickedPhoto: PhotosPickerItem? = nil
    @State private var isUploading = false

    var myPosts: [Post] {
        appState.allPosts.filter { $0.authorId == appState.userId }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackdrop()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Profile")
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            Spacer()
                            Button {
                                showSettings = true
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        VStack(spacing: 14) {
                            PhotosPicker(selection: $pickedPhoto, matching: .images) {
                                ZStack(alignment: .bottomTrailing) {
                                    AvatarView(url: appState.account.avatarURL, size: 90)
                                    Image(systemName: isUploading ? "hourglass" : "camera.fill")
                                        .foregroundStyle(.white)
                                        .padding(6)
                                        .glassTint(.appRed, in: Circle())
                                }
                            }

                            VStack(spacing: 2) {
                                Text(appState.account.fullName)
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                Text("\(appState.account.role) | \(appState.account.studentId)")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.6))
                            }

                            VStack(alignment: .leading, spacing: 14) {
                                Text("Personal Details")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .padding(.top, 6)

                                detailRow(icon: "building.columns.fill",
                                          text: appState.account.department,
                                          empty: "No department set")
                                detailRow(icon: appState.account.isEmployee ? "briefcase.fill" : "graduationcap.fill",
                                          text: appState.account.yearLevel,
                                          empty: appState.account.isEmployee ? "No position set" : "No course and year set")
                                detailRow(icon: "person.3.fill",
                                          text: appState.account.organizationName,
                                          empty: "No Organization")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .glassCard()
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("All post")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)

                            if myPosts.isEmpty {
                                Text("You haven't posted yet.")
                                    .font(.system(.footnote, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.6))
                            }

                            ForEach(myPosts) { post in
                                PostCardView(
                                    post: post,
                                    onVote: { appState.vote(on: post, value: $0) },
                                    onDelete: { Task { await appState.deletePost(post) } }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 90)
                }
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
            .toolbar(.hidden)
            .onChange(of: pickedPhoto) { _, item in
                guard let item else { return }
                Task {
                    isUploading = true
                    if let data = await item.loadJPEG(maxDimension: 512) {
                        try? await appState.uploadAvatar(data)
                    }
                    isUploading = false
                    pickedPhoto = nil
                }
            }
        }
    }

    func detailRow(icon: String, text: String, empty: String) -> some View {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        return HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.white.opacity(0.65))
                .frame(width: 20)
            Text(trimmed.isEmpty ? empty : trimmed)
                .font(.system(.footnote, design: .rounded))
                .fontWeight(.regular)
                .foregroundStyle(.white.opacity(trimmed.isEmpty ? 0.5 : 0.85))
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}
