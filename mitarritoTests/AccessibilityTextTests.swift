import Testing
@testable import kudos

@Suite("Accessibility Text Tests")
struct AccessibilityTextTests {

    @Test("Tarrito label with different counts", arguments: [
        (0, "Tarrito con 0 logros guardados"),
        (1, "Tarrito con 1 logro guardado"),
        (2, "Tarrito con 2 logros guardados"),
        (5, "Tarrito con 5 logros guardados"),
        (10, "Tarrito con 10 logros guardados"),
        (100, "Tarrito con 100 logros guardados")
    ])
    func tarritoLabel(count: Int, expected: String) {
        #expect(A11y.Tarrito.label(count: count) == expected)
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
