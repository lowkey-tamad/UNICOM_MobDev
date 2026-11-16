//
//  PageDots.swift
//  EucomCampusFeed
//

import SwiftUI

struct PageDots: View {
    var count: Int
    var current: Int
    var inactive: Color = .white.opacity(0.3)

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == current ? Color.appRed : inactive)
                    .frame(width: 6, height: 6)
            }
        }
    }
}
