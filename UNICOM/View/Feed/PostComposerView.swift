//
//  PostComposerView.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI
import PhotosUI

struct PostComposerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @State private var postText = ""
    @State private var audience: PostAudience = .campus
    @State private var allowsComments = true
    @State private var department = "Select Department / Organization"

    @State private var pickedPhoto: PhotosPickerItem? = nil
    @State private var photoData: Data? = nil
    @State private var isPosting = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackdrop()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            AvatarView(url: appState.account.avatarURL, size: 44)
                            Text(appState.account.fullName)
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(.white)
                            Spacer()
                        }

                        TextField("What's on your mind?", text: $postText, axis: .vertical)
                            .foregroundStyle(.white)
                            .lineLimit(4...8)
                            .padding()
                            .glassCard()

                        if let photoData, let image = UIImage(data: photoData) {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                                Button {
                                    self.photoData = nil
                                    pickedPhoto = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.white, .black.opacity(0.6))
                                        .padding(8)
                                }
                            }
                        }

                        PhotosPicker(selection: $pickedPhoto, matching: .images) {
                            Label(photoData == nil ? "Add photo" : "Change photo", systemImage: "photo")
                                .foregroundStyle(.white.opacity(0.8))
                        }

                        Text("Post to:")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)

                        VStack(alignment: .leading, spacing: 12) {
                            audienceRow(.campus, subtitle: "Visible to student, faculty, and staff")
                            audienceRow(.social, subtitle: "Visible to students")

                            VStack(alignment: .leading, spacing: 6) {
                                audienceRow(.organization, subtitle: nil)
                                if audience == .organization {
                                    Menu(department) {
                                        ForEach(appState.organizations) { org in
                                            Button(org.name) { department = org.name }
                                        }
                                    }
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.7))
                                    .padding(.leading, 30)
                                }
                            }
                        }

                        Toggle(isOn: $allowsComments) {
                            Text("Allows comments")
                                .foregroundStyle(.white)
                        }
                        .tint(Color.appRed)

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(Color.appPink)
                        }

                        Button(action: post) {
                            PrimaryGlassButton(title: isPosting ? "Posting..." : "Post")
                        }
                        .disabled(isPosting)
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New post")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                    }
                }
            }
            .onChange(of: pickedPhoto) { _, item in
                guard let item else { return }
                Task { photoData = await item.loadJPEG(maxDimension: 1280) }
            }
        }
    }

    // MARK: - Actions
    func post() {
        let text = postText.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty && photoData == nil {
            errorMessage = "Write something or add a photo first."
            return
        }
        if audience == .organization && department == "Select Department / Organization" {
            errorMessage = "Please choose an organization."
            return
        }

        isPosting = true
        errorMessage = nil
        Task {
            do {
                try await appState.createPost(
                    body: text.isEmpty ? " " : text,
                    audience: audience,
                    organizationName: audience == .organization ? department : "",
                    allowsComments: allowsComments,
                    imageData: photoData
                )
                dismiss()
            } catch {
                errorMessage = "Couldn't publish your post. Try again."
                print("post:", error)
            }
            isPosting = false
        }
    }

    func audienceRow(_ option: PostAudience, subtitle: String?) -> some View {
        Button {
            audience = option
        } label: {
            HStack {
                Image(systemName: audience == option ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(audience == option ? Color.appRed : .white.opacity(0.5))
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.rawValue)
                        .foregroundStyle(.white)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    PostComposerView()
        .environmentObject(AppState())
}

