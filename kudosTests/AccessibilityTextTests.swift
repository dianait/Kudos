import Testing
@testable import kudos

@Suite("Accessibility Text Tests")
struct AccessibilityTextTests {

    @Test("Jar label with different counts", arguments: [
        (0, "Tarro con 0 logros guardados"),
        (1, "Tarro con 1 logro guardado"),
        (2, "Tarro con 2 logros guardados"),
        (5, "Tarro con 5 logros guardados"),
        (10, "Tarro con 10 logros guardados"),
        (100, "Tarro con 100 logros guardados")
    ])
    func jarLabel(count: Int, expected: String) {
        #expect(A11y.Jar.label(count: count) == expected)
    }

    @Test("Stickies view label", arguments: [
        ("", "Escribe aquí..."),
        ("Hola", "Hola"),
        ("Mi primer logro", "Mi primer logro"),
        ("   ", "Escribe aquí..."),
        (" texto ", " texto ")
    ])
    func stickiesViewLabel(message: String, expected: String) {
        #expect(A11y.StickiesView.label(lastMessage: message) == expected)
    }
}
