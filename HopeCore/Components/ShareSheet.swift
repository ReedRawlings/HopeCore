//
//  ShareSheet.swift
//  HopeCore
//
//  Shared component - UIKit share sheet wrapper
//
//  AGENT NOTES:
//  - Reusable UIActivityViewController wrapper
//  - Used by HomeView and SavedMessagesView for sharing messages
//  - Conforms to UIViewControllerRepresentable for SwiftUI integration
//

import SwiftUI

/// UIKit share sheet wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
