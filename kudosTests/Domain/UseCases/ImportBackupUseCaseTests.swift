import Testing
import Foundation
@testable import kudos

@Suite("ImportBackupUseCase Tests")
@MainActor
struct ImportBackupUseCaseTests {

    @Test("execute imports all items when repository is empty")
    func importsAllIntoEmpty() throws {
        let backup = BackupFile(
            schemaVersion: BackupFile.currentSchemaVersion,
            exportedAt: Date(timeIntervalSince1970: 0),
            appVersion: nil,
            accomplishments: [
                makeBackup(id: "a"),
                makeBackup(id: "b")
            ]
        )
        let repository = BackupSpyRepository(items: [])
        let sut = ImportBackupUseCase(repository: repository)

        let result = try sut.execute(data: encode(backup))

        #expect(result.imported == 2)
        #expect(result.skipped == 0)
        #expect(repository.lastInsertedIDs == ["a", "b"])
    }

    @Test("execute skips items whose id already exists in the repository")
    func skipsExistingIDs() throws {
        let existing = AccomplishmentItem(
            id: "a",
            date: Date(timeIntervalSince1970: 1),
            text: "old",
            colorHex: "#000000",
            photoData: nil
        )
        let backup = BackupFile(
            schemaVersion: BackupFile.currentSchemaVersion,
            exportedAt: Date(timeIntervalSince1970: 0),
            appVersion: nil,
            accomplishments: [
                makeBackup(id: "a", text: "new"),
                makeBackup(id: "b")
            ]
        )
        let repository = BackupSpyRepository(items: [existing])
        let sut = ImportBackupUseCase(repository: repository)

        let result = try sut.execute(data: encode(backup))

        #expect(result.imported == 1)
        #expect(result.skipped == 1)
        #expect(repository.lastInsertedIDs == ["b"])
    }

    @Test("execute dedupes ids within the same backup file")
    func dedupesIDsInsideBackup() throws {
        let backup = BackupFile(
            schemaVersion: BackupFile.currentSchemaVersion,
            exportedAt: Date(),
            appVersion: nil,
            accomplishments: [
                makeBackup(id: "a"),
                makeBackup(id: "a")
            ]
        )
        let repository = BackupSpyRepository(items: [])
        let sut = ImportBackupUseCase(repository: repository)

        let result = try sut.execute(data: encode(backup))

        #expect(result.imported == 1)
        #expect(result.skipped == 1)
    }

    @Test("export then import is a round-trip")
    func roundTrip() throws {
        let originals: [AccomplishmentItem] = [
            AccomplishmentItem(
                id: "a",
                date: Date(timeIntervalSince1970: 1_700_000_000),
                text: "primer logro",
                colorHex: "#FFCC00",
                photoData: nil
            ),
            AccomplishmentItem(
                id: "b",
                date: Date(timeIntervalSince1970: 1_800_000_000),
                text: "segundo",
                colorHex: "#00FF00",
                photoData: Data([0xAA, 0xBB, 0xCC])
            )
        ]
        let source = BackupSpyRepository(items: originals)
        let exporter = ExportBackupUseCase(repository: source)
        let data = try exporter.execute()

        let destination = BackupSpyRepository(items: [])
        let importer = ImportBackupUseCase(repository: destination)
        let result = try importer.execute(data: data)

        #expect(result.imported == 2)
        let inserted = destination.lastInserted
        #expect(inserted.map(\.id) == ["a", "b"])
        #expect(inserted.first(where: { $0.id == "b" })?.photoData == Data([0xAA, 0xBB, 0xCC]))
        #expect(inserted.first(where: { $0.id == "a" })?.text == "primer logro")
    }

    @Test("execute throws invalidFormat for corrupt json")
    func invalidFormatThrows() {
        let sut = ImportBackupUseCase(repository: BackupSpyRepository(items: []))
        let garbage = Data("no soy un json valido".utf8)

        #expect(throws: ImportBackupError.invalidFormat) {
            try sut.execute(data: garbage)
        }
    }

    @Test("execute throws unsupportedSchemaVersion for a future version")
    func unsupportedVersionThrows() throws {
        let backup = BackupFile(
            schemaVersion: 999,
            exportedAt: Date(),
            appVersion: nil,
            accomplishments: []
        )
        let sut = ImportBackupUseCase(repository: BackupSpyRepository(items: []))

        #expect(throws: ImportBackupError.unsupportedSchemaVersion(999)) {
            try sut.execute(data: encode(backup))
        }
    }

    @Test("execute propagates repository insert errors")
    func propagatesInsertError() throws {
        let backup = BackupFile(
            schemaVersion: BackupFile.currentSchemaVersion,
            exportedAt: Date(),
            appVersion: nil,
            accomplishments: [makeBackup(id: "a")]
        )
        let sut = ImportBackupUseCase(repository: BackupSpyRepository(items: [], insertThrows: true))

        #expect(throws: (any Error).self) {
            try sut.execute(data: encode(backup))
        }
    }

    // MARK: - Helpers

    private func makeBackup(id: String, text: String = "logro") -> AccomplishmentBackup {
        AccomplishmentBackup(
            id: id,
            date: Date(timeIntervalSince1970: 0),
            text: text,
            colorHex: "#FFCC00",
            photoBase64: nil
        )
    }

    private func encode(_ backup: BackupFile) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(backup)
    }
}

@MainActor
final class BackupSpyRepository: AccomplishmentRepositoryProtocol {
    private(set) var items: [AccomplishmentItem]
    private(set) var lastInserted: [AccomplishmentItem] = []
    var lastInsertedIDs: [String] { lastInserted.map(\.id) }

    private let fetchThrows: Bool
    private let insertThrows: Bool

    init(items: [AccomplishmentItem] = [], fetchThrows: Bool = false, insertThrows: Bool = false) {
        self.items = items
        self.fetchThrows = fetchThrows
        self.insertThrows = insertThrows
    }

    func save(_ accomplishment: NewAccomplishment) throws {}

    func fetchAllSortedByDateDescending() throws -> [AccomplishmentItem] {
        if fetchThrows { throw BackupTestError.generic }
        return items
    }

    func delete(_ accomplishment: AccomplishmentItem) throws {}

    func insert(items newItems: [AccomplishmentItem]) throws {
        if insertThrows { throw BackupTestError.generic }
        lastInserted.append(contentsOf: newItems)
        items.append(contentsOf: newItems)
    }
}

enum BackupTestError: Error { case generic }
