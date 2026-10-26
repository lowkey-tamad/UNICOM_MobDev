//
//  SettingsView.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var showEditProfile = false
    @State private var showChangePassword = false
    @State private var showAbout = false

    var body: some View {
        ZStack {
            AppBackdrop()

            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(.white)
                    }
                    Text("Settings")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)

                HStack(spacing: 12) {
                    AvatarView(url: appState.account.avatarURL, size: 50)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(appState.account.fullName)
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(.white)
                        Text("\(appState.account.role)   \(appState.account.studentId)")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    Spacer()
                }
                .padding()
                .glassCard()
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Account")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.horizontal)

                    settingsRow(icon: "person.crop.circle", title: "Edit Profile", subtitle: "Update your personal information") {
                        showEditProfile = true
                    }
                    settingsRow(icon: "lock.fill", title: "Change Password", subtitle: "Keep your account secure") {
                        showChangePassword = true
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Support & Other")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.horizontal)

                    settingsRow(icon: "lock.shield.fill", title: "About UNICOM", subtitle: "App version 1.0.0") {
                        showAbout = true
                    }
                }

                Spacer()

                Button {
                    Task { await appState.signOut() }
                } label: {
                    Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.appRed, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)
            }
        }
        .toolbar(.hidden)
        .navigationDestination(isPresented: $showEditProfile) {
            EditProfileView()
        }
        .navigationDestination(isPresented: $showChangePassword) {
            ChangePasswordView()
        }
        .navigationDestination(isPresented: $showAbout) {
            AboutView()
        }
    }

    func settingsRow(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(Color.appRed)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                    Text(subtitle)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.4))
            }
            .foregroundStyle(.white)
            .padding()
            .glassCard(cornerRadius: 14)
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppState())
    }
}
