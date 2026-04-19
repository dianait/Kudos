import Testing
@testable import kudos

// NOTE: These tests assert Spanish (ES) strings. The suite init forces the language
// to "es" before running. .serialized prevents intra-suite races on the shared
// LanguageManager singleton. If other suites ever modify LanguageManager in
// parallel, those would need to be addressed separately.
@Suite("Accessibility Text Tests", .serialized)
struct AccessibilityTextTests {

    init() async {
        await MainActor.run {
            LanguageManager.shared.setLanguage("es")
        }
    }

    @Test("Jar label with different counts", arguments: [
        (0, "Tarro con 0 logros guardados"),
        (1, "Tarro con 1 logro guardado"),
        (2, "Tarro con 2 logros guardados"),
        (5, "Tarro con 5 logros guardados"),
        (10, "Tarro con 10 logros guardados"),
        (100, "Tarro con 100 logros guardados")
    ] as [(Int, String)])
    func jarLabel(count: Int, expected: String) {
        #expect(A11y.Jar.label(count: count) == expected)
    }

    @Test("Stickies view label", arguments: [
        ("", "Escribe aquí..."),
        ("Hola", "Hola"),
        ("Mi primer logro", "Mi primer logro"),
        ("   ", "Escribe aquí..."),
        (" texto ", " texto ")
    ] as [(String, String)])
    func stickiesViewLabel(message: String, expected: String) {
        #expect(A11y.StickiesView.label(lastMessage: message) == expected)
    }
}
