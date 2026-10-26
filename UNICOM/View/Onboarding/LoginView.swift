//
//  LoginView.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 8/27/2026.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var errorMessage: String? = nil
    @State private var isLoading = false

    var body: some View {
        ZStack {
            AppBackdrop()

            VStack(alignment: .leading, spacing: 1) {
                Spacer().frame(height: 100)

                Text("Welcome")
                    .font(.system(size: 55))
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("to ")
                        .font(.system(size: 40))
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.regular)
                        .foregroundStyle(.white)

                    Text("UNICOM!")
                        .font(.system(size: 55))
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.black)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.red, Color.orange.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                Text("Login to continue to your University Community.")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.top, 4)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            VStack(alignment: .leading) {
                Text("Login")
                    .font(.system(size: 38))
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Text("Enter your credentials to enter your account.")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))

                Spacer().frame(height: 45)
                
                loginField(icon: "envelope") {
                    TextField("Enter your email...", text: $email)
                        .font(.system(.subheadline, design: .rounded))
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                }
                
                Spacer().frame(height: 20)

                loginField(icon: "lock") {
                    HStack {
                        if isPasswordVisible {
                            TextField("Enter your password...", text: $password)
                                .font(.system(.subheadline, design: .rounded))
                        } else {
                            SecureField("Enter your password...", text: $password)
                                .font(.system(.subheadline, design: .rounded))
                        }
                        Button {
                            isPasswordVisible.toggle()
                        } label: {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                }

                HStack {
                    Spacer()
                    Text("Forgot password?")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Color.appRed)
                }
                
                Spacer().frame(height: 25)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(Color.appPink)
                }

                Button {
                    login()
                } label: {
                    PrimaryGlassButton(title: isLoading ? "Logging in..." : "Login")
                }
                .disabled(isLoading)
                .padding(.top, 4)

                HStack(spacing: 4) {
                    Spacer()
                    Text("Don't have an account yet?")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                    Text("Sign in")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(Color.appRed)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .onTapGesture {
                    withAnimation { appState.stage = .signUpAccount }
                    
                }
                Spacer().frame(height: 80)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28))
            .background(Color.black.opacity(0.15), in: UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }

    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                try await appState.signIn(email: email, password: password)
            } catch {
                errorMessage = "Incorrect email or password."
                print("login:", error)
            }
            isLoading = false
        }
    }

    @ViewBuilder
    func loginField<Content: View>(icon: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.white.opacity(0.7))
            content()
        }
        .foregroundStyle(.white)
        .padding()
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
