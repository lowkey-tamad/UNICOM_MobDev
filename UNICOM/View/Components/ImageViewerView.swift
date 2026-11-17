//
//  ImageViewerView.swift
//  EucomCampusFeed
//

import SwiftUI

// Full-screen photo: pinch or double-tap to zoom, drag to pan, swipe down (or tap X) to close.
struct ImageViewerView: View {
    var assetName: String? = nil
    var url: URL? = nil

    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private var dragProgress: Double {
        scale > 1 ? 0 : min(abs(offset.height) / 300, 1)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black
                .opacity(1 - dragProgress * 0.6)
                .ignoresSafeArea()

            content
                .scaleEffect(scale)
                .offset(offset)
                .gesture(dragGesture)
                .gesture(zoomGesture)
                .onTapGesture(count: 2) {
                    withAnimation(.spring(duration: 0.3)) {
                        if scale > 1 { resetZoom() } else { scale = 2.5; lastScale = 2.5 }
                    }
                }

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.black.opacity(0.5), in: Circle())
            }
            .padding()
        }
    }

    @ViewBuilder
    private var content: some View {
        if let assetName, UIImage(named: assetName) != nil {
            Image(assetName)
                .resizable()
                .scaledToFit()
        } else if let url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFit()
                case .failure:
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.white.opacity(0.6))
                default:
                    ProgressView().tint(.white)
                }
            }
        }
    }

    private var zoomGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                scale = max(1, lastScale * value.magnification)
            }
            .onEnded { _ in
                if scale <= 1.01 { resetZoom() } else { lastScale = scale }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height)
            }
            .onEnded { value in
                if scale <= 1, abs(value.translation.height) > 120 {
                    dismiss()
                } else if scale <= 1 {
                    withAnimation(.spring(duration: 0.25)) { offset = .zero }
                    lastOffset = .zero
                } else {
                    lastOffset = offset
                }
            }
    }

    private func resetZoom() {
        scale = 1
        lastScale = 1
        offset = .zero
        lastOffset = .zero
    }
}
