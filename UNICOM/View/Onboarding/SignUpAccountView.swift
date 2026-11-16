//
//  SignUpAccountView.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI

struct SignUpAccountView: View {
    @EnvironmentObject var appState: AppState
    @State private var accountType: AccountType = .student
    @State private var fullName = ""
    @State private var schoolEmail = ""
    @State private var studentNumber = ""
    @State private var department = ""
    @State private var courseOrPosition = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreedToTerms = false
    @State private var errorMessage: String? = nil
    @State private var isLoading = false
    @State private var showTerms = false

    var body: some View {
        ZStack {
            AppBackdrop()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Button {
                            withAnimation { appState.stage = .login }
                        } label: {
                            Image(systemName: "arrow.left")
                                .foregroundStyle(.white)
                        }
                        Spacer()
                    }

                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Text("Join the University Community\nand stay connected.")
                            .font(.system(.footnote, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)

                    SignUpStepper(currentStep: 1)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Account Type")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)

                        HStack(spacing: 10) {
                            ForEach(AccountType.allCases, id: \.self) { type in
                                Button {
                                    accountType = type
                                } label: {
                                    VStack(spacing: 6) {
                                        Image(systemName: iconFor(type))
                                        Text(type.rawValue)
                                            .font(.system(.caption2, design: .rounded))
                                    }
                                    .foregroundStyle(accountType == type ? .white : .white.opacity(0.6))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(accountType == type ? Color.appRed : Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                                }
                            }
                        }

                        formField(icon: "person", placeholder: "Enter your full name...", text: $fullName)
                        formField(icon: "envelope", placeholder: "Enter your school email...", text: $schoolEmail)
                        formField(icon: accountType.idIcon, placeholder: accountType.idPlaceholder, text: $studentNumber)
                        departmentField
                        formField(icon: accountType.detailIcon, placeholder: accountType.detailPlaceholder, text: $courseOrPosition)
                        secureField(icon: "lock", placeholder: "Enter your password...", text: $password)
                        secureField(icon: "lock", placeholder: "Re-enter your password...", text: $confirmPassword)

                        HStack {
                            Button {
                                agreedToTerms.toggle()
                            } label: {
                                Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(agreedToTerms ? Color.appRed : .white.opacity(0.6))
                            }
                            Text(termsText)
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                                .tint(Color.appRed)
                                .environment(\.openURL, OpenURLAction { _ in
                                    showTerms = true
                                    return .handled
                                })
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(Color.appPink)
                        }

                        Button {
                            signUp()
                        } label: {
                            PrimaryGlassButton(title: isLoading ? "Please wait..." : "NEXT")
                        }
                        .disabled(isLoading)
                        .padding(.top, 6)

                        HStack(spacing: 4) {
                            Spacer()
                            Text("Already have an account?")
                                .foregroundStyle(.white.opacity(0.7))
                            Text("Login")
                                .foregroundStyle(Color.appRed)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .font(.system(.footnote, design: .rounded))
                        .onTapGesture {
                            withAnimation { appState.stage = .login }
                        }
                    }
                    .padding()
                    .glassCard()
                }
                .padding(.horizontal, 24)
            }
        }
        .onChange(of: accountType) { _, _ in
            // Employee-only departments and the other ID format must not carry over.
            studentNumber = ""
            department = ""
            courseOrPosition = ""
        }
        .sheet(isPresented: $showTerms) {
            TermsView()
        }
    }

    var termsText: AttributedString {
        var text = AttributedString("I agree to the Terms of Service and Privacy Policy")
        for phrase in ["Terms of Service", "Privacy Policy"] {
            if let range = text.range(of: phrase) {
                text[range].link = URL(string: "unicom://terms")
                text[range].foregroundColor = Color.appRed
            }
        }
        return text
    }

    var departmentField: some View {
        Menu {
            ForEach(Departments.list(for: accountType), id: \.self) { name in
                Button(name) { department = name }
            }
        } label: {
            HStack {
                Image(systemName: "building.columns")
                Text(department.isEmpty ? "Select your department..." : department)
                    .foregroundStyle(department.isEmpty ? .white.opacity(0.45) : .white)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .foregroundStyle(.white)
            .padding()
            .glassCard(cornerRadius: 14)
        }
    }

    func signUp() {
        let detail = courseOrPosition.trimmingCharacters(in: .whitespaces)
        if fullName.isEmpty || schoolEmail.isEmpty || studentNumber.isEmpty || detail.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields."
        } else if department.isEmpty {
            errorMessage = "Please select your department."
        } else if !schoolEmail.contains("@") {
            errorMessage = "Enter a valid school email."
        } else if password.count < 8 {
            errorMessage = "Password must be at least 8 characters."
        } else if password != confirmPassword {
            errorMessage = "Passwords do not match."
        } else if !agreedToTerms {
            errorMessage = "Please agree to the Terms of Service."
        } else {
            isLoading = true
            errorMessage = nil
            Task {
                do {
                    try await appState.signUp(
                        fullName: fullName, email: schoolEmail,
                        studentId: studentNumber, role: accountType.rawValue,
                        department: department, yearLevel: detail,
                        password: password
                    )
                    withAnimation { appState.stage = .signUpVerify }
                } catch {
                    errorMessage = error.localizedDescription
                }
                isLoading = false
            }
        }
    }

    func iconFor(_ type: AccountType) -> String {
        switch type {
        case .student: return "graduationcap.fill"
        case .employee: return "briefcase.fill"
        }
    }

    func formField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack {
            Image(systemName: icon)
            TextField(placeholder, text: text)
        }
        .foregroundStyle(.white)
        .padding()
        .glassCard(cornerRadius: 14)
    }

    func secureField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack {
            Image(systemName: icon)
            SecureField(placeholder, text: text)
        }
        .foregroundStyle(.white)
        .padding()
        .glassCard(cornerRadius: 14)
    }
}

#Preview {
    SignUpAccountView()
        .environmentObject(AppState())
}
