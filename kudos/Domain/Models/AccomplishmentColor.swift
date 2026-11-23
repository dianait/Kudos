enum AccomplishmentColor: String, CaseIterable {
    case yellow
    case orange
    case blue
    case green
    case pink
    case teal

    static func randomColorString() -> String {
        allCases.randomElement()?.rawValue ?? "yellow"
    }

    static var availableColorStrings: [String] {
        allCases.map { $0.rawValue }
    }

    /// RGB values for each color (0.0 - 1.0 range). Plain numbers so the widget
    /// shares them without pulling in the app's UI layer.
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
}
