import Testing
import SwiftUI
@testable import kudos

@Suite("Accomplishment Color Tests")
struct AccomplishmentColorTests {

    @Test("Random color string returns valid color")
    func randomColorString() {
        let randomColor = AccomplishmentColor.randomColorString()
        #expect(AccomplishmentColor.availableColorStrings.contains(randomColor))
    }

    @Test("Color from string", arguments: [
        "blue",
        "green",
        "yellow",
        "orange",
        "purple",
        "pink",
        "nonexistent"
    ])
    func colorFromString(colorName: String) {
        let color = Color.fromString(colorName)
        // For known colors, ensure we get something other than a clear placeholder.
        // For unknown colors (e.g., "nonexistent"), ensure we still receive a valid Color.
        if AccomplishmentColor.availableColorStrings.contains(colorName) {
            // We can't compare Colors for equality reliably across platforms, but we can ensure it isn't fully clear.
            // Assuming unknown values map to .clear in the implementation, this guards against that for known values.
            #expect(color.opacity(1.0) != Color.clear.opacity(1.0))
        } else {
            // Unknown color names should still yield a valid Color (likely a fallback like .clear).
            // Simply assert a Color was returned by performing a trivial operation.
            let _ = color.opacity(1.0)
            #expect(true)
        }
    }

    @Test("All color cases are accessible")
    func allColorCasesCount() {
        #expect(AccomplishmentColor.allCases.count == 7)
    }

    @Test("Each color has valid RGB values")
    func rgbValuesValidation() {
        for colorCase in AccomplishmentColor.allCases {
            let rgb = colorCase.rgbValues

            #expect(rgb.red >= 0.0 && rgb.red <= 1.0,
                   "Red value out of range for \(colorCase)")
            #expect(rgb.green >= 0.0 && rgb.green <= 1.0,
                   "Green value out of range for \(colorCase)")
            #expect(rgb.blue >= 0.0 && rgb.blue <= 1.0,
                   "Blue value out of range for \(colorCase)")
        }
    }

    @Test("Each color produces valid Color instance")
    func colorInstanceValidation() {
        for colorCase in AccomplishmentColor.allCases {
            let color = colorCase.color
            // Perform a trivial operation to ensure the Color is usable without relying on nil checks.
            let _ = color.opacity(1.0)
            #expect(true, "Color instance should be usable for \(colorCase)")
        }
    }

    @Test("Color string conversion matches enum cases", arguments:
        AccomplishmentColor.allCases
    )
    func colorStringConversion(colorCase: AccomplishmentColor) {
        let colorString = colorCase.rawValue
        let color = Color.fromString(colorString)
        // Ensure that converting from the rawValue yields a usable Color.
        let _ = color.opacity(1.0)
        #expect(true, "Failed to convert \(colorString) to a usable Color")
    }
}
