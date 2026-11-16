//
//  AssetImage.swift
//  EucomCampusFeed
//

import SwiftUI

// A picture from the asset catalog that fills its frame.
// A missing or empty name shows a red gradient instead of a blank view.
struct AssetImage: View {
    var name: String?

    var body: some View {
        if let name, !name.isEmpty, UIImage(named: name) != nil {
            Image(name)
                .resizable()
                .scaledToFill()
        } else {
            LinearGradient(
                colors: [Color.appRed.opacity(0.85), Color(red: 0.35, green: 0.05, blue: 0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
