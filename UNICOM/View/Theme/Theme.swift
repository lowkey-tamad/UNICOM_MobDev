//  Theme.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI

extension Color {
    static let appBackground = Color(red: 0.07, green: 0.07, blue: 0.08)
    static let appRed = Color(red: 0.85, green: 0.16, blue: 0.16)
    static let appMaroon = Color(red: 0.42, green: 0.08, blue: 0.12)
    static let appPink = Color(red: 0.98, green: 0.72, blue: 0.75)
}

//background
struct AppBackdrop: View {
    var body: some View {
        GeometryReader { geo in
            Image("Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
        }
        .ignoresSafeArea()
    }
}

//liquid glass texture
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}


struct GlassCapsuleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.tint(.appRed.opacity(0.25)), in: Capsule())
        } else {
            content
                .background(.ultraThinMaterial, in: Capsule())
        }
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }

    func glassCapsule() -> some View {
        modifier(GlassCapsuleModifier())
    }
}

//button
struct PrimaryGlassButton: View {
    var title: String
    var systemImage: String? = nil

    var body: some View {
        HStack {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(title)
                .font(.system(.headline, design: .rounded))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .modifier(GlassTintModifier(tint: .appRed, shape: RoundedRectangle(cornerRadius: 16, style: .continuous)))
    }
}

//opacity
struct GlassTintModifier<S: Shape>: ViewModifier {
    var tint: Color
    var shape: S

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.tint(tint.opacity(0.55)), in: shape)
        } else {
            content
                .background(tint.opacity(0.55), in: shape)
                .background(.ultraThinMaterial, in: shape)
        }
    }
}

//colot
extension View {
    func glassTint(_ tint: Color, in shape: some Shape) -> some View {
        modifier(GlassTintModifier(tint: tint, shape: shape))
    }
}
