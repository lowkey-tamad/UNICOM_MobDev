//
//  RootView.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.isRestoring {
                ZStack {
                    AppBackdrop()
                    ProgressView()
                        .tint(.white)
                }
            } else {
                switch appState.stage {
                case .onboarding:
                    OnboardingView()
                case .login:
                    LoginView()
                case .signUpAccount:
                    SignUpAccountView()
                case .signUpVerify:
                    SignUpVerifyView()
                case .signUpComplete:
                    SignUpCompleteView()
                case .main:
                    RootTabView()
                }
            }
        }
        .animation(.easeInOut, value: appState.stage)
        .task { await appState.restoreSession() }
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
}
