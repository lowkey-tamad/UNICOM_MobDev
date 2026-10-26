//
//  SignUpVerifyView.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI

struct SignUpVerifyView: View {
    @EnvironmentObject var appState: AppState
    @State private var otpDigits = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?
    @State private var errorMessage: String? = nil
    @State private var infoMessage: String? = nil
    @State private var isVerifying = false

    var body: some View {
        ZStack {
            AppBackdrop()

            VStack(spacing: 24) {
                HStack {
                    Button {
                        withAnimation { appState.stage = .signUpAccount }
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

                SignUpStepper(currentStep: 2)

                Spacer()

                Image("Email")
                    .font(.system(size: 70))
                    .foregroundStyle(.white)

                Text("Verify your Email")
                    .font(.system(size: 30))
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("Please check your Outlook, we sent 6 digit\nverification code to your university email.")
                    .font(.system(.footnote, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.7))

                HStack(spacing: 10) {
                    ForEach(0..<6, id: \.self) { index in
                        TextField("", text: $otpDigits[index])
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 40, height: 48)
                            .foregroundStyle(.white)
                            .glassCard(cornerRadius: 10)
                            .focused($focusedField, equals: index)
                    }
                }

                HStack {
                    Spacer()
                    Text("Resend Code")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Color.appRed)
                        .onTapGesture {
                            Task {
                                do {
                                    try await appState.resendCode()
                                    errorMessage = nil
                                    infoMessage = "A new code was sent."
                                } catch {
                                    infoMessage = nil
                                    errorMessage = "Please wait a moment before requesting another code."
                                }
                            }
                        }
                }
                .padding(.horizontal, 24)

                Spacer()

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(Color.appPink)
                }
                if let infoMessage {
                    Text(infoMessage)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Button {
                    verify()
                } label: {
                    PrimaryGlassButton(title: isVerifying ? "Verifying..." : "Verify Email")
                }
                .disabled(isVerifying)
                .padding(.horizontal, 24)

                Text("Having a problem? Contact Support")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.horizontal, 24)
        }
        .onChange(of: otpDigits) { old, new in
            handleOTPChange(old: old, new: new)
        }
    }

    // Auto-advances between boxes and supports pasting the whole code
    func handleOTPChange(old: [String], new: [String]) {
        if let index = new.firstIndex(where: { $0.count > 2 }) {
            let digits = Array(new[index].filter(\.isNumber).prefix(6))
            var filled = Array(repeating: "", count: 6)
            for (i, digit) in digits.enumerated() { filled[i] = String(digit) }
            otpDigits = filled
            focusedField = min(digits.count, 5)
            return
        }
        if let index = new.firstIndex(where: { $0.count == 2 }) {
            otpDigits[index] = String(new[index].suffix(1))
            return
        }
        if let index = new.indices.first(where: { new[$0] != old[$0] }), !new[index].isEmpty {
            focusedField = index < 5 ? index + 1 : nil
        }
    }

    func verify() {
        let code = otpDigits.joined()
        guard code.count == 6 else {
            errorMessage = "Enter the 6-digit code."
            return
        }
        isVerifying = true
        errorMessage = nil
        Task {
            do {
                try await appState.verifyEmail(code: code)
                withAnimation { appState.stage = .signUpComplete }
            } catch {
                errorMessage = "Invalid or expired code."
                print("verify:", error)
            }
            isVerifying = false
        }
    }
}

#Preview {
    SignUpVerifyView()
        .environmentObject(AppState())
}

