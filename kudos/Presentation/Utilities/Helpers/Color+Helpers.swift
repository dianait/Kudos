import SwiftUI

// MARK: - Accomplishment Color System
/// Enum that defines all available colors for accomplishments with their RGB values
/// Palette based on warm yellows and soft oranges for a positive, cohesive app experience
enum AccomplishmentColor: String, CaseIterable {
    case yellow
    case orange
    case blue
    case green
    case pink
    case teal
    
    /// RGB values for each color (0.0 - 1.0 range)
    /// Colors are warm, positive, and cohesive with the app's yellow/orange theme
    var rgbValues: (red: Double, green: Double, blue: Double) {
        switch self {
        case .yellow:
            // #F7DFA1 - amarillo pastel cálido (primary)
            return (0.968, 0.875, 0.631)
        case .orange:
            // #EBA86B - naranja melocotón suave (accent)
            return (0.922, 0.659, 0.420)
        case .blue:
            // Soft blue that complements the warm palette
            return (0.70, 0.82, 0.90)
        case .green:
            // Soft mint green that works with warm tones
            return (0.75, 0.88, 0.78)
        case .pink:
            // Soft rose pink that harmonizes with yellows
            return (0.95, 0.85, 0.82)
        case .teal:
            // Soft aqua that complements the palette
            return (0.75, 0.88, 0.85)
        }
    }
    
    /// SwiftUI Color representation
    var color: Color {
        let rgb = rgbValues
        return Color(red: rgb.red, green: rgb.green, blue: rgb.blue)
    }
    
    /// Array of all color names as strings
    static var availableColorStrings: [String] {
        return AccomplishmentColor.allCases.map { $0.rawValue }
    }
    
    /// Returns a random color string
    static func randomColorString() -> String {
        return allCases.randomElement()?.rawValue ?? "gray"
    }
}

// MARK: - Color Extension
extension Color {
    /// Converts a color string to a SwiftUI Color
    /// - Parameter colorString: The color name as a string
    /// - Returns: A SwiftUI Color, or a default gray if the string doesn't match
    static func fromString(_ colorString: String) -> Color {
        guard let accomplishmentColor = AccomplishmentColor(rawValue: colorString.lowercased()) else {
            // Return soft gray as default
            return Color(red: 0.85, green: 0.85, blue: 0.85)
        }
        return accomplishmentColor.color
    }
    
    // MARK: - App Color Palette
    /// Primary warm yellow - #F7DFA1 (amarillo pastel cálido)
    static let appPrimaryYellow = Color(red: 0.968, green: 0.875, blue: 0.631)
    
    /// Secondary golden yellow - #F3C879 (amarillo dorado suave)
    static let appGoldenYellow = Color(red: 0.953, green: 0.784, blue: 0.475)
}

