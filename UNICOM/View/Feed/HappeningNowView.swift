//
//  HappeningNowView.swift
//  EucomCampusFeed
//

import SwiftUI

struct HappeningNowView: View {
    var items: [Announcement]
    @State private var scrolledID: UUID? = nil

    private var currentIndex: Int {
        let id = scrolledID ?? items.first?.id
        return items.firstIndex { $0.id == id } ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Happening Now", systemImage: "chart.line.uptrend.xyaxis")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items) { item in
                        HappeningCard(item: item)
                            .id(item.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrolledID)

            if items.count > 1 {
                PageDots(count: items.count, current: currentIndex)
                    .frame(maxWidth: .infinity)
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

struct HappeningCard: View {
    var item: Announcement

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AssetImage(name: item.imageName)

            LinearGradient(
                colors: [.clear, Color(red: 0.45, green: 0.04, blue: 0.08).opacity(0.92)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                if !item.source.isEmpty {
                    Text(item.source)
                        .font(.system(size: 10, weight: .regular, design: .rounded))
                        .opacity(0.8)
                }
            }
            .foregroundStyle(.white)
            .padding(10)
        }
        .overlay(alignment: .topLeading) {
            Text(item.tag)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(red: 0.55, green: 0.1, blue: 0.14), in: Capsule())
                .padding(8)
        }
        .frame(width: 150, height: 190)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
