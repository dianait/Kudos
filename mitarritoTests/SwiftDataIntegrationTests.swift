import Testing
import SwiftData
import Foundation
@testable import kudos

@Suite("SwiftData Integration Tests")
struct SwiftDataIntegrationTests {

    // Helper to create isolated test context for each test
    func makeTestContext() throws -> ModelContext {
        let schema = Schema([Accomplishment.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }

    @Test("Save and fetch accomplishment")
    func saveAndFetchAccomplishment() throws {
        let context = try makeTestContext()
        let text = "Test logro para SwiftData"
        let color = "yellow"

        let accomplishment = try Accomplishment(text, color: color)
        context.insert(accomplishment)

        let descriptor = FetchDescriptor<Accomplishment>()
        let fetchedAccomplishments = try context.fetch(descriptor)

        #expect(fetchedAccomplishments.count == 1)
        let fetched = try #require(fetchedAccomplishments.first)
        #expect(fetched.text == text)
        #expect(fetched.color == color)
    }

    @Test("Delete accomplishment")
    func deleteAccomplishment() throws {
        let context = try makeTestContext()
        let accomplishment = try Accomplishment("Logro para eliminar")
        context.insert(accomplishment)

        var descriptor = FetchDescriptor<Accomplishment>()
        var fetchedAccomplishments = try context.fetch(descriptor)
        #expect(fetchedAccomplishments.count == 1)

        context.delete(accomplishment)

        descriptor = FetchDescriptor<Accomplishment>()
        fetchedAccomplishments = try context.fetch(descriptor)
        #expect(fetchedAccomplishments.count == 0)
    }

    @Test("Fetch with sorting", arguments: [
        (SortOrder.forward, "Logro antiguo"),
        (SortOrder.reverse, "Logro nuevo")
    ])
    func fetchWithSorting(order: SortOrder, expectedFirst: String) throws {
        let context = try makeTestContext()
        let oldDate = Date(timeIntervalSinceNow: -86400) // Yesterday
        let newDate = Date()

        let oldAccomplishment = try Accomplishment("Logro antiguo")
        oldAccomplishment.date = oldDate

        let newAccomplishment = try Accomplishment("Logro nuevo")
        newAccomplishment.date = newDate

        context.insert(oldAccomplishment)
        context.insert(newAccomplishment)

        let sortDescriptor = SortDescriptor(\Accomplishment.date, order: order)
        let descriptor = FetchDescriptor<Accomplishment>(sortBy: [sortDescriptor])
        let fetchedAccomplishments = try context.fetch(descriptor)

        #expect(fetchedAccomplishments.count == 2)
        let first = try #require(fetchedAccomplishments.first)
        #expect(first.text == expectedFirst)
    }

    @Test("Multiple accomplishments maintain order")
    func multipleAccomplishmentsOrder() throws {
        let context = try makeTestContext()

        // Create accomplishments with specific dates
        let dates = [
            Date(timeIntervalSinceNow: -3600),  // 1 hour ago
            Date(timeIntervalSinceNow: -7200),  // 2 hours ago
            Date(timeIntervalSinceNow: -1800),  // 30 min ago
        ]

        for (index, date) in dates.enumerated() {
            let accomplishment = try Accomplishment("Logro \(index)")
            accomplishment.date = date
            context.insert(accomplishment)
        }

        let descriptor = FetchDescriptor<Accomplishment>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let fetched = try context.fetch(descriptor)

        #expect(fetched.count == 3)
        #expect(fetched[0].text == "Logro 2") // Most recent
        #expect(fetched[1].text == "Logro 0")
        #expect(fetched[2].text == "Logro 1") // Oldest
    }
}
