//
//  DocumentExporter.swift
//  EucomCampusFeed
//

import SwiftUI
import UIKit

// The system "Save to Files" sheet for a file we already wrote to a temporary location.
struct DocumentExporter: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        UIDocumentPickerViewController(forExporting: [url], asCopy: true)
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}

enum ApplicationForm {
    // One empty A4 page.
    static func blankPDFData() -> Data {
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        return UIGraphicsPDFRenderer(bounds: page).pdfData { context in
            context.beginPage()
        }
    }

    // Writes the blank PDF into the temporary folder and returns its location.
    static func writeTemporaryFile(named name: String) throws -> URL {
        let safeName = name
            .components(separatedBy: CharacterSet(charactersIn: "/\\:?%*|\"<>"))
            .joined(separator: " ")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(safeName).pdf")
        try blankPDFData().write(to: url, options: .atomic)
        return url
    }
}
