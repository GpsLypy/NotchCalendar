import SwiftUI

/// The notch and workspace share the same date and text colors.
enum AlcovePalette {
    static var accent: Color { WorkspacePalette.accent }
    static var accentWash: Color { accent.opacity(0.17) }
    static var primaryText: Color { WorkspacePalette.primaryText }
    static var secondaryText: Color { WorkspacePalette.secondaryText }
}
