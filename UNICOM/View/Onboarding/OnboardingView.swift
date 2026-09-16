//
//  OnboardingView.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var pageIndex = 0
    private let totalPages = 4

    var body: some View {
        ZStack {
            AppBackdrop()

            TabView(selection: $pageIndex) {
                OnboardingLogoPage()
                    .tag(0)
                OnboardingConnectPage()
                    .tag(1)
                OnboardingSharePage()
                    .tag(2)
                OnboardingDiscoverPage()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack {
                Spacer()

                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(index == pageIndex ? Color.appRed : .white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 24)

                if pageIndex == 0 {
                    Button {
                        withAnimation { pageIndex = 1 }
                    } label: {
                        PrimaryGlassButton(title: "Get Started")
                    }
                    .padding(.horizontal, 40)
                } else {
                    HStack {
                        Button {
                            withAnimation { pageIndex -= 1 }
                        } label: {
                            Image(systemName: "arrow.left")
                                .foregroundStyle(.white)
                                .frame(width: 50, height: 50)
                        }
                        .glassCard(cornerRadius: 25)

                        Spacer()

                        Button {
                            if pageIndex == totalPages - 1 {
                                withAnimation { appState.stage = .login }
                            } else {
                                withAnimation { pageIndex += 1 }
                            }
                        } label: {
                            Image(systemName: "arrow.right")
                                .foregroundStyle(.white)
                                .frame(width: 50, height: 50)
                        }
                        .glassTint(.appRed, in: Circle())
                    }
                    .padding(.horizontal, 40)
                }
            }
            .padding(.bottom, 20)
        }
    }
}

struct OnboardingLogoPage: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image("OnboardingLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 240, height: 240)
                .shadow(color: .black.opacity(0.3), radius: 16, y: 8)

            Text("Welcome to your University App.\nConnect. Share. Discover.\nAll in one place.")
                .font(.system(.body, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.75))
                .padding(.horizontal, 32)
                .padding(.top, 8)

            Spacer()
            Spacer()
        }
    }
}

struct OnboardingConnectPage: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image("OnboardingConnect")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 240, height: 240)
                .shadow(color: .black.opacity(0.3), radius: 16, y: 8)

            Text("Connect")
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text("Join organizations, find study groups,\nask questions, and connect\nwith fellow student and staff.")
                .font(.system(.body, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.75))
                .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }
}

struct OnboardingSharePage: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image("OnboardingShare")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 240, height: 240)
                .shadow(color: .black.opacity(0.3), radius: 16, y: 8)

            Text("Share")
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text("Share announcements, ideas, questions,\nexperiences, and helpful information with\nfellow students and staff.")
                .font(.system(.body, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.75))
                .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }
}

struct OnboardingDiscoverPage: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image("OnboardingDiscover")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 240, height: 240)
                .shadow(color: .black.opacity(0.3), radius: 16, y: 8)

            Text("Discover")
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text("Stay updated with university news,\nevents, and announcements\nthat matter to you.")
                .font(.system(.body, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.75))
                .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
