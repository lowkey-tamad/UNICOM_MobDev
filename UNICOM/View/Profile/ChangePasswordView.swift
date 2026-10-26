//
//  ChangePasswordView.swift
//  EucomCampusFeed
//

import SwiftUI

struct ChangePasswordView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    // MARK: - State
    @State private var current = ""
    @State private var newPassword = ""
    @State private var confirm = ""
    @State private var showCurrent = false
    @State private var showNew = false
    @State private var showConfirm = false
    @State private var errorMessage: String? = nil
    @State private var showSuccess = false

    var body: some View {
        ZStack {
            AppBackdrop()

            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "arrow.left")
                                .foregroundStyle(.white)
                        }
                        Text("Change Password")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    VStack(spacing: 14) {
                        PasswordRow(title: "Current Password", text: $current, isVisible: $showCurrent)
                        PasswordRow(title: "New Password", text: $newPassword, isVisible: $showNew)
                        PasswordRow(title: "Confirm New Password", text: $confirm, isVisible: $showConfirm)

                        Text("Use at least 8 characters.")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(Color.appPink)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal)

                    Button(action: save) {
                        PrimaryGlassButton(title: "Update Password")
                    }
                    .padding(.horizontal)
                }
            }
        }
        .toolbar(.hidden)
        .alert("Password Updated", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your password has been changed.")
        }
    }

    // MARK: - Actions
    func save() {
        if current.isEmpty || newPassword.isEmpty || confirm.isEmpty {
            errorMessage = "Please fill in all fields."
        } else if newPassword.count < 8 {
            errorMessage = "New password must be at least 8 characters."
        } else if newPassword == current {
            errorMessage = "New password must be different from the current one."
        } else if newPassword != confirm {
            errorMessage = "Passwords do not match."
        } else {
            errorMessage = nil
            Task {
                do {
                    try await appState.changePassword(current: current, new: newPassword)
                    showSuccess = true
                } catch {
                    errorMessage = "Current password is incorrect."
                }
            }
        }
    }
}

// MARK: - Row
struct PasswordRow: View {
    let title: String
    @Binding var text: String
    @Binding var isVisible: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))

            HStack {
                Group {
                    if isVisible {
                        TextField(title, text: $text)
                    } else {
                        SecureField(title, text: $text)
                    }
                }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(.white)

                Button {
                    isVisible.toggle()
                } label: {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding()
            .glassCard(cornerRadius: 14)
        }
    }
}

#Preview {
    NavigationStack {
        ChangePasswordView()
            .environmentObject(AppState())
    }
}
