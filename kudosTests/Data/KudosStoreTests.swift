import Foundation
import SwiftData
import Testing
@testable import kudos

@Suite("Kudos store: schema migration and App Group copy")
struct KudosStoreTests {
    private let directory: URL

    init() throws {
        directory = FileManager.default.temporaryDirectory
            .appending(path: "KudosStoreTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    /// Writes one kudo with the pre-iCloud model, like an existing install.
    private func makeV1Store(at url: URL, photo: Data?) throws {
        let schema = Schema(versionedSchema: KudosSchemaV1.self)
        let configuration = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = ModelContext(container)
        context.insert(KudosSchemaV1.AccomplishmentEntity(
            id: "kudo-1",
            date: Date(timeIntervalSince1970: 1_700_000_000),
            text: "Ran my first 10K",
            colorHex: "green",
            photoData: photo
        ))
        try context.save()
    }

    @Test func migratesAV1StoreKeepingEveryField() throws {
        let url = directory.appending(path: "old.store")
        let photo = Data((0..<4096).map { UInt8($0 % 256) })
        try makeV1Store(at: url, photo: photo)

        let container = try KudosStore.makeContainer(url: url, cloudKitDatabase: .none)
        let kudos = try ModelContext(container).fetch(FetchDescriptor<AccomplishmentEntity>())

        #expect(kudos.count == 1)
        let kudo = try #require(kudos.first)
        #expect(kudo.id == "kudo-1")
        #expect(kudo.text == "Ran my first 10K")
        #expect(kudo.colorHex == "green")
        #expect(kudo.date == Date(timeIntervalSince1970: 1_700_000_000))
        #expect(kudo.photoData == photo)
    }

    @Test func copiesTheOldStoreAndLeavesTheOriginal() throws {
        let source = directory.appending(path: "default.store")
        let destination = directory.appending(path: "group/Library/Kudos.store")
        try makeV1Store(at: source, photo: nil)

        #expect(KudosStore.copyStoreIfNeeded(from: source, to: destination))

        #expect(FileManager.default.fileExists(atPath: source.path(percentEncoded: false)))
        let container = try KudosStore.makeContainer(url: destination, cloudKitDatabase: .none)
        let kudos = try ModelContext(container).fetch(FetchDescriptor<AccomplishmentEntity>())
        #expect(kudos.map(\.id) == ["kudo-1"])
    }

    @Test func neverOverwritesAnExistingDestination() throws {
        let source = directory.appending(path: "default.store")
        let destination = directory.appending(path: "Kudos.store")
        try Data("old".utf8).write(to: source)
        try Data("current".utf8).write(to: destination)

        #expect(KudosStore.copyStoreIfNeeded(from: source, to: destination))

        #expect(try Data(contentsOf: destination) == Data("current".utf8))
    }

    @Test func freshInstallHasNothingToCopy() {
        let source = directory.appending(path: "missing.store")
        let destination = directory.appending(path: "Kudos.store")

        #expect(KudosStore.copyStoreIfNeeded(from: source, to: destination))
        #expect(!FileManager.default.fileExists(atPath: destination.path(percentEncoded: false)))
    }
}
