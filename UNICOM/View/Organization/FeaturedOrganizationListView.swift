//
//  FeaturedOrganizationListView.swift
//  EucomCampusFeed
//
//  Created by Siegfred Calayag on 14/9/2026.
//

import SwiftUI

struct FeaturedOrganizationListView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @Namespace private var namespace
    @State private var searchText = ""
    @State private var selectedTab = "All"

    var filteredOrganizations: [StudentOrganization] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return appState.organizations.filter { org in
            (selectedTab == "All" || org.type.contains(selectedTab))
                && (query.isEmpty || org.name.localizedCaseInsensitiveContains(query)
                    || org.shortName.localizedCaseInsensitiveContains(query))
        }
    }

    var body: some View {
        ZStack {
            AppBackdrop()

            VStack(spacing: 16) {
                TopBarView(searchText: $searchText, onAdd: {}, onNotification: {})

                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(.white)
                    }
                    Text("Featured Organization")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal)

                PillTabBar(titles: ["All", "University", "Department"], selected: $selectedTab, namespace: namespace)
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 12) {
                        if filteredOrganizations.isEmpty {
                            Text("No organizations found.")
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.top, 30)
                        }

                        ForEach(filteredOrganizations) { org in
                            NavigationLink {
                                OrganizationDetailView(organization: org)
                            } label: {
                                OrganizationRow(org: org)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 90)
                }
            }
        }
        .toolbar(.hidden)
    }
}

// Light glass card: logo on the left, text on the right, member count bottom-right (PDF: See all).
struct OrganizationRow: View {
    var org: StudentOrganization
    private let ink = Color(white: 0.12)

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            AssetImage(name: org.logoImage)
                .frame(width: 58, height: 58)
                .background(.white)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .top) {
                    Text(org.shortName)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(ink)
                        .lineLimit(2)
                    Spacer(minLength: 4)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(ink.opacity(0.4))
                }
                Text(org.type)
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(ink.opacity(0.65))
                Text(org.shortDescription)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(ink.opacity(0.55))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
                HStack(spacing: 4) {
                    Spacer()
                    Image(systemName: "person.2")
                    Text("\(org.memberCount) Members")
                }
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(ink.opacity(0.6))
                .padding(.top, 2)
            }
        }
        .padding(14)
        .background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.7), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        FeaturedOrganizationListView()
            .environmentObject(AppState())
    }
}
