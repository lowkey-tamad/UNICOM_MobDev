//
//  SignUpCompleteView.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI

struct SignUpCompleteView: View {
    @EnvironmentObject var appState: AppState
    @State private var confettiFallen = false

    var body: some View {
        ZStack {
            AppBackdrop()

            VStack(spacing: 24) {
                HStack {
                    Image(systemName: "arrow.left")
                        .foregroundStyle(.white.opacity(0.4))
                    Spacer()
                }

                VStack(spacing: 8) {
                    Text("Create Account")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text("Join the University Community\nand stay connected.")
                        .font(.system(.footnote, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.7))
                }

                SignUpStepper(currentStep: 3)

                Spacer()
                    .frame(height: 45)

                Image("Verify")
                    .font(.system(size: 90))
                    .foregroundStyle(.blue)
                    .frame(width: 160, height: 160)

                Text("Account Created!")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("Welcome to University App.\nLets build connections and create\nopportunities together.")
                    .font(.system(.footnote, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.7))

                Spacer()
            }
            .padding(.horizontal, 24)

            ConfettiView(isFalling: confettiFallen)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                confettiFallen = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { appState.stage = .main }
            }
        }
    }
}

struct ConfettiView: View {
    var isFalling: Bool

    let colors: [Color] = [.appRed, .pink, .green, .yellow, .blue, .orange]
    let pieces = (0..<24).map { index -> (x: CGFloat, delay: Double, rotation: Double) in
        (x: CGFloat.random(in: 0...1), delay: Double.random(in: 0...0.4), rotation: Double.random(in: 0...360))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<pieces.count, id: \.self) { index in
                    Rectangle()
                        .fill(colors[index % colors.count])
                        .frame(width: 8, height: 14)
                        .rotationEffect(.degrees(isFalling ? pieces[index].rotation : 0))
                        .position(
                            x: pieces[index].x * geo.size.width,
                            y: isFalling ? geo.size.height + 40 : -40
                        )
                        .animation(
                            .easeIn(duration: 1.6).delay(pieces[index].delay),
                            value: isFalling
                        )
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

#Preview {
    SignUpCompleteView()
        .environmentObject(AppState())
}
