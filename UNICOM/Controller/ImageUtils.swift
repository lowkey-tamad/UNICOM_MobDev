//
//  ImageUtils.swift
//  UNICOM
//
//  Created by Mac-LAB on 10/27/26.
//
import SwiftUI
import PhotosUI

extension UIImage {
    // Shrinks the image and compresses it so uploads stay small
    func resizedJPEG(maxDimension: CGFloat, quality: CGFloat = 0.7) -> Data? {
        let longest = max(size.width, size.height)
        let scale = min(1, maxDimension / longest)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let image = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return image.jpegData(compressionQuality: quality)
    }
}

extension PhotosPickerItem {
    func loadJPEG(maxDimension: CGFloat) async -> Data? {
        guard let data = try? await loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return nil }
        return image.resizedJPEG(maxDimension: maxDimension)
    }
}

