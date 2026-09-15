//
//  SignUpStepper.swift
//  EucomCampusFeed
//
//  Created by Mac-LAB on 14/9/2026.
//

import SwiftUI

struct SignUpStepper: View {
    var currentStep: Int

    let labels = ["Account", "Verify", "Complete"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...3, id: \.self) { step in
                VStack(spacing: 6) {
                    Circle()
                        .fill(step <= currentStep ? Color.appRed : .white.opacity(0.15))
                        .frame(width: 28, height: 28)
                        .overlay {
                            Text("\(step)")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                    Text(labels[step - 1])
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(step <= currentStep ? .white : .white.opacity(0.5))
                }

                if step < 3 {
                    Rectangle()
                        .fill(step < currentStep ? Color.appRed : .white.opacity(0.15))
                        .frame(height: 2)
                        .padding(.bottom, 16)
                }
            }
        }
        .padding(.horizontal, 40)
    }
}
