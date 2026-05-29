import Testing
import Foundation
@testable import kudos

@Suite("ExportBackupUseCase Tests")
@MainActor
struct ExportBackupUseCaseTests {

    @Test("execute returns JSON with schema version, exported date and app version")
    func returnsEnvelopeMetadata() throws {
        let item = AccomplishmentItem(
            id: "id-1",
            date: Date(timeIntervalSince1970: 1_700_000_000),
            text: "logro",
            colorHex: "#FFCC00",
            photoData: nil
        )
        let repository = BackupSpyRepository(items: [item])
        let frozenDate = Date(timeIntervalSince1970: 1_800_000_000)
        let sut = ExportBackupUseCase(
            repository: repository,
            appVersion: "1.10",
            dateProvider: { frozenDate }
        )

        let data = try sut.execute()
        let decoded = try decodeBackup(data)

        #expect(decoded.schemaVersion == BackupFile.currentSchemaVersion)
        #expect(decoded.appVersion == "1.10")
        #expect(decoded.exportedAt == frozenDate)
        #expect(decoded.accomplishments.count == 1)
    }

    @Test("execute serializes photo data as base64")
    func serializesPhotoAsBase64() throws {
        let photo = Data([0x01, 0x02, 0x03])
        let item = AccomplishmentItem(
            id: "id-1",
            date: Date(timeIntervalSince1970: 0),
            text: "",
            colorHex: "#FF0000",
            photoData: photo
        )
        let sut = ExportBackupUseCase(repository: BackupSpyRepository(items: [item]))

        let data = try sut.execute()
        let decoded = try decodeBackup(data)

        #expect(decoded.accomplishments.first?.photoBase64 == photo.base64EncodedString())
    }

    @Test("execute with empty repository returns empty accomplishments array")
    func emptyRepository() throws {
        let sut = ExportBackupUseCase(repository: BackupSpyRepository(items: []))

        let data = try sut.execute()
        let decoded = try decodeBackup(data)

        #expect(decoded.accomplishments.isEmpty)
    }

    @Test("execute propagates repository fetch errors")
    func propagatesFetchError() {
        let sut = ExportBackupUseCase(repository: BackupSpyRepository(fetchThrows: true))

        #expect(throws: (any Error).self) {
            try sut.execute()
        }
    }

    private func decodeBackup(_ data: Data) throws -> BackupFile {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(BackupFile.self, from: data)
    }
}
