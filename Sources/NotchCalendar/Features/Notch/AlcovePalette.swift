import SwiftUI

/// A restrained red-and-white palette inspired by Alcove's calendar surface.
enum AlcovePalette {
    static var accent: Color { Color(red: 0.956, green: 0.231, blue: 0.357) } // #F43B5B
    static var accentWash: Color { accent.opacity(0.17) }
    static var primaryText: Color { .white.opacity(0.95) }
    static var secondaryText: Color { .white.opacity(0.56) }
}
