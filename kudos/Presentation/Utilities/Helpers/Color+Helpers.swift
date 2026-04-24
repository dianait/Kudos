import SwiftUI

// MARK: - AccomplishmentColor SwiftUI extension
extension AccomplishmentColor {
    /// RGB values for each color (0.0 - 1.0 range)
    var rgbValues: (red: Double, green: Double, blue: Double) {
        switch self {
        case .yellow:  return (0.968, 0.875, 0.631)
        case .orange:  return (0.922, 0.659, 0.420)
        case .blue:    return (0.70,  0.82,  0.90)
        case .green:   return (0.75,  0.88,  0.78)
        case .pink:    return (0.95,  0.85,  0.82)
        case .teal:    return (0.75,  0.88,  0.85)
        }
    }

    var color: Color {
        let rgb = rgbValues
        return Color(red: rgb.red, green: rgb.green, blue: rgb.blue)
    }
}

// MARK: - Color Extension
extension Color {
    static func fromString(_ colorString: String) -> Color {
        guard let accomplishmentColor = AccomplishmentColor(rawValue: colorString.lowercased()) else {
            return Color(red: 0.85, green: 0.85, blue: 0.85)
        }
        return accomplishmentColor.color
    }

    static let appPrimaryYellow = Color(red: 0.968, green: 0.875, blue: 0.631)
    static let appGoldenYellow  = Color(red: 0.953, green: 0.784, blue: 0.475)
}
