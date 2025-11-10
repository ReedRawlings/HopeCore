//
//  Category.swift
//  HopeCore
//
//  Data Model - Message Categories
//  Created for LLM-first development
//
//  AGENT NOTES:
//  - Categories help users personalize their message experience
//  - Free users receive all categories; premium users can filter
//  - Demotivation category is special: 1 per 5 messages for free users
//  - Categories are used for filtering in browse view and notifications
//

import Foundation
import SwiftData

/// Message categories for hopecore content
/// Users can select which categories resonate with them
@Model
final class Category {
    /// Unique identifier
    var id: UUID

    /// Category name (e.g., "Resilience", "Agency", "Rebuilding")
    var name: String

    /// Category description for onboarding/settings
    var categoryDescription: String

    /// Icon name from SF Symbols
    var iconName: String

    /// Whether this category is enabled for the user
    var isEnabled: Bool

    /// Sort order for display
    var sortOrder: Int

    /// Whether this is the special Demotivation category
    var isDemotivation: Bool

    init(
        id: UUID = UUID(),
        name: String,
        categoryDescription: String,
        iconName: String,
        isEnabled: Bool = true,
        sortOrder: Int = 0,
        isDemotivation: Bool = false
    ) {
        self.id = id
        self.name = name
        self.categoryDescription = categoryDescription
        self.iconName = iconName
        self.isEnabled = isEnabled
        self.sortOrder = sortOrder
        self.isDemotivation = isDemotivation
    }
}

// MARK: - Category Presets
extension Category {
    /// Default categories for the app
    /// AGENT NOTE: These align with technical_spec.md requirements
    static let defaultCategories: [Category] = [
        Category(
            name: "Resilience",
            categoryDescription: "Messages about bouncing back and inner strength",
            iconName: "heart.fill",
            sortOrder: 1
        ),
        Category(
            name: "Agency",
            categoryDescription: "Reminders of your power to choose and act",
            iconName: "hand.raised.fill",
            sortOrder: 2
        ),
        Category(
            name: "Rebuilding",
            categoryDescription: "Hope for reconstruction and new beginnings",
            iconName: "hammer.fill",
            sortOrder: 3
        ),
        Category(
            name: "Possibility",
            categoryDescription: "Opening to what could be",
            iconName: "sparkles",
            sortOrder: 4
        ),
        Category(
            name: "Demotivation",
            categoryDescription: "Challenging messages (1 per 5 for free users)",
            iconName: "exclamationmark.triangle.fill",
            isEnabled: false, // Disabled by default for premium users
            sortOrder: 5,
            isDemotivation: true
        )
    ]
}
