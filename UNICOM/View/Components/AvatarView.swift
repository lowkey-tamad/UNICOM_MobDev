//
//  AvatarView.swift
//  UNICOM
//
//  Created by Mac-LAB on 10/27/26.
//

import SwiftUI

struct AvatarView: View {
    var url: String
    var size: CGFloat = 44
    var assetName: String? = nil   // picture bundled in the asset catalog (used by sample data)

    var body: some View {
        Group {
            if let assetName, UIImage(named: assetName) != nil {
                Image(assetName).resizable().scaledToFill()
            } else if !url.isEmpty, let imageURL = URL(string: url) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    var placeholder: some View {
        ZStack {
            Circle().fill(.white.opacity(0.15))
            Image(systemName: "person.fill")
                .font(.system(size: size * 0.45))
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

