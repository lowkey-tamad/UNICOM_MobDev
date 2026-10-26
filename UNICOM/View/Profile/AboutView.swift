//
//  AboutView.swift
//  EucomCampusFeed
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss

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
                        Text("About")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    VStack(spacing: 10) {
                        Image("SettingsLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 90)

                        Text("UNICOM")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.black)
                            .foregroundStyle(.white)

                        Text("University Community")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .glassCard()
                    .padding(.horizontal)

                    Text("UNICOM connects students, organizations, and the university in one place. Stay updated with campus announcements, join organizations, and message your classmates, all within a university-only community.")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.leading)
                        .padding()
                        .glassCard()
                        .padding(.horizontal)

                    VStack(spacing: 0) {
                        AboutRow(title: "Version", value: "1.0.0")
                        AboutRow(title: "University", value: "MSEUF")
                        AboutRow(title: "Developer", value: "Siegfred Calayag")
                        AboutRow(title: "Built with", value: "SwiftUI")
                    }
                    .padding(.horizontal)
                    .glassCard()
                    .padding(.horizontal)

                    Text("© 2026 UNICOM. All rights reserved.")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.bottom, 40)
                }
            }
        }
        .toolbar(.hidden)
    }
}

// MARK: - Row
struct AboutRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
