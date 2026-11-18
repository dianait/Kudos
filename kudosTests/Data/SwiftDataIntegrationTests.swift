import Testing
import SwiftData
import Foundation
@testable import kudos

@Suite("SwiftData Integration Tests")
struct SwiftDataIntegrationTests {

    func makeTestContext() throws -> ModelContext {
        let schema = Schema([AccomplishmentEntity.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }

    @Test("Save and fetch accomplishment")
    func saveAndFetchAccomplishment() throws {
        let context = try makeTestContext()
        let text = "Test logro para SwiftData"
        let color = "yellow"

        let accomplishment = AccomplishmentEntity(from: NewAccomplishment(text: text, photoData: nil, color: color, date: Date()))
        context.insert(accomplishment)

        let descriptor = FetchDescriptor<AccomplishmentEntity>()
        let fetched = try context.fetch(descriptor)

        #expect(fetched.count == 1)
        let first = try #require(fetched.first)
        #expect(first.text == text)
        #expect(first.colorHex == color)
    }

    @Test("Delete accomplishment")
    func deleteAccomplishment() throws {
        let context = try makeTestContext()
        let accomplishment = AccomplishmentEntity(from: NewAccomplishment(text: "Logro para eliminar", photoData: nil, color: "blue", date: Date()))
        context.insert(accomplishment)

        var descriptor = FetchDescriptor<AccomplishmentEntity>()
        #expect(try context.fetch(descriptor).count == 1)

        context.delete(accomplishment)

        descriptor = FetchDescriptor<AccomplishmentEntity>()
        #expect(try context.fetch(descriptor).count == 0)
    }

    @Test("Fetch with sorting", arguments: [
        (SortOrder.forward, "Logro antiguo"),
        (SortOrder.reverse, "Logro nuevo")
    ])
    func fetchWithSorting(order: SortOrder, expectedFirst: String) throws {
        let context = try makeTestContext()

        let oldAccomplishment = AccomplishmentEntity(id: UUID().uuidString, date: Date(timeIntervalSinceNow: -86400), text: "Logro antiguo", colorHex: "blue", photoData: nil)
        let newAccomplishment = AccomplishmentEntity(id: UUID().uuidString, date: Date(), text: "Logro nuevo", colorHex: "blue", photoData: nil)

        context.insert(oldAccomplishment)
        context.insert(newAccomplishment)

        let descriptor = FetchDescriptor<AccomplishmentEntity>(sortBy: [SortDescriptor(\.date, order: order)])
        let fetched = try context.fetch(descriptor)

        #expect(fetched.count == 2)
        #expect(try #require(fetched.first).text == expectedFirst)
    }

    @Test("Multiple accomplishments maintain order")
    func multipleAccomplishmentsOrder() throws {
        let context = try makeTestContext()

        let items: [(TimeInterval, String)] = [
            (-3600, "Logro 0"),
            (-7200, "Logro 1"),
            (-1800, "Logro 2")
        ]

        for (offset, text) in items {
            context.insert(AccomplishmentEntity(id: UUID().uuidString, date: Date(timeIntervalSinceNow: offset), text: text, colorHex: "blue", photoData: nil))
        }

        let descriptor = FetchDescriptor<AccomplishmentEntity>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let fetched = try context.fetch(descriptor)

        #expect(fetched.count == 3)
        #expect(fetched[0].text == "Logro 2")
        #expect(fetched[1].text == "Logro 0")
        #expect(fetched[2].text == "Logro 1")
    }
}

@Suite("SwiftDataAccomplishmentRepository Tests")
@MainActor
struct SwiftDataAccomplishmentRepositoryTests {
    /// Kept alive for the whole test: a ModelContext must not outlive its container.
    private let container: ModelContainer
    private let sut: SwiftDataAccomplishmentRepository

    init() throws {
        let schema = Schema([AccomplishmentEntity.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        sut = SwiftDataAccomplishmentRepository(modelContext: ModelContext(container))
    }

    @Test("save then fetch returns newest first")
    func saveAndFetchSorted() throws {
        try sut.save(NewAccomplishment(text: "Antiguo", photoData: nil, color: "blue", date: Date(timeIntervalSinceNow: -60)))
        try sut.save(NewAccomplishment(text: "Nuevo", photoData: nil, color: "green", date: Date()))

        let items = try sut.fetchAllSortedByDateDescending()

        #expect(items.map(\.text) == ["Nuevo", "Antiguo"])
    }

    @Test("insert keeps ids and delete removes only that item")
    func insertAndDeleteByID() throws {
        let a = makeItem(id: "a", text: "A")
        let b = makeItem(id: "b", text: "B")
        try sut.insert(items: [a, b])

        try sut.delete(a)

        let items = try sut.fetchAllSortedByDateDescending()
        #expect(items.map(\.id) == ["b"])
    }

    @Test("delete of a missing id is a no-op")
    func deleteMissingIsNoOp() throws {
        try sut.insert(items: [makeItem(id: "a", text: "A")])

        try sut.delete(makeItem(id: "missing", text: ""))

        #expect(try sut.fetchAllSortedByDateDescending().count == 1)
    }

    @Test("updateText changes only the text")
    func updateTextChangesText() throws {
        let photo = Data([0x01, 0x02])
        try sut.insert(items: [makeItem(id: "a", text: "Antes", photo: photo)])

        try sut.updateText(id: "a", text: "Después")

        let item = try #require(try sut.fetchAllSortedByDateDescending().first)
        #expect(item.text == "Después")
        #expect(item.photoData == photo)
        #expect(item.colorHex == "blue")
    }

    private func makeItem(id: String, text: String, photo: Data? = nil) -> AccomplishmentItem {
        AccomplishmentItem(id: id, date: Date(), text: text, colorHex: "blue", photoData: photo)
    }
}
