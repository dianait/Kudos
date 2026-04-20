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
}
