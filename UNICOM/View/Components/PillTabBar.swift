//
//  PillTabBar.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI

struct PillTabBar: View {
    var titles: [String]
    var icons: [String]? = nil
    @Binding var selected: String
    var namespace: Namespace.ID

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Array(titles.enumerated()), id: \.element) { index, title in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selected = title
                    }
                } label: {
                    HStack(spacing: 6) {
                        if let icons, index < icons.count {
                            Image(systemName: icons[index])
                        }
                        Text(title)
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(selected == title ? .semibold : .regular)
                    }
                    .foregroundStyle(selected == title ? .white : .white.opacity(0.6))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background {
                        if selected == title {
                            Capsule()
                                .fill(Color.appRed)
                                .matchedGeometryEffect(id: "pill", in: namespace)
                        }
                    }
                }
            }
            Spacer()
        }
    }
}
