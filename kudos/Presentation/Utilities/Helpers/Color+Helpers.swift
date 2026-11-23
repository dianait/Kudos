import SwiftUI

// MARK: - AccomplishmentColor SwiftUI extension
extension AccomplishmentColor {
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
