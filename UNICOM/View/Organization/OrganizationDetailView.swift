//
//  OrganizationDetailView.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI

struct OrganizationDetailView: View {
    var organization: StudentOrganization
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @Namespace private var namespace
    @State private var selectedTab = OrganizationDetailTab.overview.rawValue
    @State private var showDownloadConfirm = false
    @State private var showExporter = false
    @State private var exportURL: URL? = nil
    @State private var downloadError: String? = nil

    // Writes the empty PDF, then opens the system "Save to Files" sheet.
    func prepareDownload() {
        do {
            exportURL = try ApplicationForm.writeTemporaryFile(named: "\(organization.shortName) Application Form")
            downloadError = nil
            showExporter = true
        } catch {
            downloadError = "Could not create the file. Please try again."
        }
    }

    var body: some View {
        ZStack {
            AppBackdrop()

            VStack(spacing: 16) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(.white)
                    }
                    Text("Organization")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)

                HStack(spacing: 14) {
                    AssetImage(name: organization.logoImage)
                        .frame(width: 72, height: 72)
                        .background(.white)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 1))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(organization.name)
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                        Text(organization.type)
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                        Text("\(organization.memberCount) Members")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    PillTabBar(titles: OrganizationDetailTab.allCases.map(\.rawValue), selected: $selectedTab, namespace: namespace)
                        .padding(.horizontal)
                }

                ScrollView {
                    Group {
                        switch selectedTab {
                        case OrganizationDetailTab.officers.rawValue:
                            officersTab
                        case OrganizationDetailTab.requirements.rawValue:
                            requirementsTab
                        case OrganizationDetailTab.activities.rawValue:
                            activitiesTab
                        default:
                            overviewTab
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 90)
                }
            }

            VStack {
                Spacer()
                Button {
                    // Application flow is outside the iOS MVP's five core screens.
                } label: {
                    PrimaryGlassButton(title: "Apply now")
                }
                .padding()
            }
        }
        .sheet(isPresented: $showExporter) {
            if let exportURL {
                DocumentExporter(url: exportURL)
            }
        }
        .toolbar(.hidden)
    }

    var overviewTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Label("About Us", systemImage: "info.circle.fill")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.white)
                Text(organization.aboutUs)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))
            }
            .padding()
            .glassCard()

            HStack(spacing: 12) {
                statBadge(icon: "person.2.fill", value: organization.memberCount, label: "Members")
                statBadge(icon: "mappin.circle.fill", value: organization.campus, label: "Main Campus")
                statBadge(icon: "flag.fill", value: organization.founded, label: "Founded")
            }

            VStack(alignment: .leading, spacing: 10) {
                Label("Highlights", systemImage: "star.fill")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.white)
                HStack(spacing: 10) {
                    ForEach(0..<3) { _ in
                        VStack {
                            Image(systemName: "graduationcap.fill")
                            Text("Student\nAdvocacy")
                                .multilineTextAlignment(.center)
                                .font(.system(.caption2, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .glassCard(cornerRadius: 14)
                    }
                }
            }
        }
    }

    var officersTab: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Officers", systemImage: "person.3.fill")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.appRed)
            Text("Meet the leaders of our organization")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.black.opacity(0.5))
                .padding(.bottom, 4)

            ForEach(organization.officers) { officer in
                HStack(spacing: 12) {
                    AvatarView(url: "", size: 44, assetName: officer.photo.isEmpty ? nil : officer.photo)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(officer.name)
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.appRed)
                        Text(officer.position)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.black.opacity(0.5))
                    }
                    Spacer()
                }
                .padding(.vertical, 6)

                if officer.id != organization.officers.last?.id {
                    Divider()
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    var requirementsTab: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Requirements to Join", systemImage: "doc.text.fill")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(.white)
            Text("Be part of the University Collegiate Student Council and make a difference")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))

            ForEach(organization.requirements) { requirement in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text(requirement.text)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding()
                .glassCard(cornerRadius: 14)
            }

            VStack(alignment: .leading, spacing: 8) {
                Label("Application Form", systemImage: "doc.fill")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                HStack {
                    Image(systemName: "doc.richtext")
                    Text("Application Form\nPDF · 900 KB")
                        .font(.system(.caption2, design: .rounded))
                    Spacer()
                }
                .foregroundStyle(.white.opacity(0.8))

                Button {
                    showDownloadConfirm = true
                } label: {
                    PrimaryGlassButton(title: "Download", systemImage: "arrow.down")
                }
                .confirmationDialog("Download Application Form?", isPresented: $showDownloadConfirm, titleVisibility: .visible) {
                    Button("Download") { prepareDownload() }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("A PDF will be saved to your device. You choose where it is stored.")
                }

                if let downloadError {
                    Text(downloadError)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Color.appPink)
                }
            }
            .padding()
            .glassCard()

            VStack(alignment: .leading, spacing: 6) {
                Label("Application Period", systemImage: "calendar")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                Text(organization.applicationPeriod)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                Text(organization.applicationHours)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding()
            .glassCard()
        }
    }

    var activitiesTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Activities", systemImage: "calendar.badge.clock")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(.white)
            Text("Stay updated with our latest announcements, events, and activities")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))

            ForEach(organization.activities) { activity in
                let post = appState.live(activity)
                PostCardView(post: post, onVote: { appState.vote(on: post, value: $0) })
            }
        }
    }

    func statBadge(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(Color.appRed)
            Text(value)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 88)
        .glassCard(cornerRadius: 14)
    }
}

#Preview {
    NavigationStack {
        OrganizationDetailView(organization: AppState().organizations[0])
            .environmentObject(AppState())
    }
}
