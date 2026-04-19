import Testing
import SwiftUI
@testable import kudos

@Suite("Accomplishment Color Tests")
struct AccomplishmentColorTests {

    @Test("Random color string returns a value from the available palette")
    func randomColorString() {
        let randomColor = AccomplishmentColor.randomColorString()
        #expect(AccomplishmentColor.availableColorStrings.contains(randomColor))
    }

    @Test("Known color name resolves to a non-fallback color", arguments:
        AccomplishmentColor.allCases.map { $0.rawValue }
    )
    func colorFromKnownString(colorName: String) {
        let fallbackGray = Color(red: 0.85, green: 0.85, blue: 0.85)
        #expect(Color.fromString(colorName) != fallbackGray)
    }

    @Test("Unknown color string returns fallback gray")
    func unknownColorStringReturnsFallback() {
        let fallbackGray = Color(red: 0.85, green: 0.85, blue: 0.85)
        #expect(Color.fromString("nonexistent") == fallbackGray)
        #expect(Color.fromString("purple") == fallbackGray)
    }

    @Test("Palette contains exactly six colors")
    func allColorCasesCount() {
        #expect(AccomplishmentColor.allCases.count == 6)
    }

    @Test("Each color has RGB values in the 0–1 range", arguments: AccomplishmentColor.allCases)
    func rgbValuesValidation(colorCase: AccomplishmentColor) {
        let rgb = colorCase.rgbValues
        #expect(rgb.red >= 0.0 && rgb.red <= 1.0)
        #expect(rgb.green >= 0.0 && rgb.green <= 1.0)
        #expect(rgb.blue >= 0.0 && rgb.blue <= 1.0)
    }

    @Test("Color instance is built from its own RGB definition", arguments: AccomplishmentColor.allCases)
    func colorInstanceMatchesRGB(colorCase: AccomplishmentColor) {
        let rgb = colorCase.rgbValues
        let expected = Color(red: rgb.red, green: rgb.green, blue: rgb.blue)
        #expect(colorCase.color == expected)
    }

    @Test("rawValue round-trip: Color.fromString yields non-fallback color", arguments: AccomplishmentColor.allCases)
    func colorStringConversion(colorCase: AccomplishmentColor) {
        let fallbackGray = Color(red: 0.85, green: 0.85, blue: 0.85)
        #expect(Color.fromString(colorCase.rawValue) != fallbackGray)
    }
}
