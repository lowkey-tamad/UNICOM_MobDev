//
//  FeaturedOrganizationPanel.swift
//  EucomCampusFeed
//

import SwiftUI

// Light panel with a horizontally scrolling row of organization cards (PDF: Organization Screen).
struct FeaturedOrganizationPanel: View {
    var organizations: [StudentOrganization]
    var onSeeAll: () -> Void
    @State private var scrolledID: UUID? = nil

    private var currentIndex: Int {
        let id = scrolledID ?? organizations.first?.id
        return organizations.firstIndex { $0.id == id } ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Featured Organization")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Spacer()
                Button("See all", action: onSeeAll)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.8))
            }

            if organizations.isEmpty {
                Text("No organizations found.")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(organizations) { org in
                            NavigationLink {
                                OrganizationDetailView(organization: org)
                            } label: {
                                FeaturedOrganizationCard(org: org)
                            }
                            .buttonStyle(.plain)
                            .id(org.id)
                        }
                    }
                    .padding(.vertical, 4)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $scrolledID)

                if organizations.count > 1 {
                    PageDots(count: organizations.count, current: currentIndex)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(14)
        .background(Color.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
    }
}

struct FeaturedOrganizationCard: View {
    var org: StudentOrganization

    var body: some View {
        VStack(spacing: 0) {
            AssetImage(name: org.bannerImage)
                .frame(width: 140, height: 88)
                .clipped()

            VStack(spacing: 3) {
                Text(org.shortName)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appRed)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 34)
                Text(org.type)
                    .font(.system(size: 9, design: .rounded))
                    .foregroundStyle(.black.opacity(0.45))
                Divider()
                    .padding(.vertical, 3)
                Text("**\(org.memberCount)** Members")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.black.opacity(0.75))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .frame(width: 140)
            .background(Color(white: 0.96))
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 4, x: 0, y: 3)
    }
}
