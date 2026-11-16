//
//  TermsView.swift
//  EucomCampusFeed
//
//  DRAFT text. Have the university's legal office review it before launch.
//

import SwiftUI

struct TermsView: View {
    @Environment(\.dismiss) var dismiss

    private let sections: [(title: String, body: String)] = [
        ("1. Acceptance",
         "By creating a UNICOM account you agree to these Terms of Service and the Privacy Policy below. If you do not agree, please do not use the app."),
        ("2. Who can use UNICOM",
         "UNICOM is for the students and employees of the university. You must register with your own school email and give accurate details. One person, one account."),
        ("3. Your account",
         "You are responsible for your password and for everything done through your account. Tell the university if you think someone else has used it."),
        ("4. Acceptable use",
         "Be respectful. Do not post anything that is unlawful, harassing, hateful, sexually explicit, or misleading. Do not impersonate other people or organizations, spam, or try to break or misuse the app."),
        ("5. Posts and content",
         "You own what you post, but you allow UNICOM to display it to other members based on the audience you choose. Official announcements come from verified university accounts. Posts that break these terms may be removed."),
        ("6. Privacy Policy",
         "We collect the details you give us: your name, school email, student or employee number, department, course and year or position, optional birthday and profile photo, and the posts, comments and messages you send. We use them to run the app, show your profile to other members, and send you notifications. We do not sell your data. We handle personal data in line with the Data Privacy Act of 2012 (Republic Act No. 10173). You may ask to view, correct or delete your data through the university's administrators."),
        ("7. Account suspension",
         "The university may suspend or remove accounts that break these terms. You can stop using UNICOM at any time."),
        ("8. Changes",
         "These terms may be updated from time to time. Continuing to use UNICOM after an update means you accept the new version.")
    ]

    var body: some View {
        ZStack {
            AppBackdrop()

            VStack(spacing: 0) {
                HStack {
                    Text("Terms of Service & Privacy Policy")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .padding()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        ForEach(0..<sections.count, id: \.self) { index in
                            let section = sections[index]
                            VStack(alignment: .leading, spacing: 6) {
                                Text(section.title)
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                Text(section.body)
                                    .font(.system(.footnote, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.75))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .glassCard()
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

#Preview {
    TermsView()
}
