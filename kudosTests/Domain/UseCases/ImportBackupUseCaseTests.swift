import Testing
import Foundation
import ImageIO
import UniformTypeIdentifiers
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
                photoData: TestImages.png(width: 4, height: 3)
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
        let photo = try #require(inserted.first(where: { $0.id == "b" })?.photoData)
        #expect(TestImages.pixelSize(of: photo) == CGSize(width: 4, height: 3))
        #expect(inserted.first(where: { $0.id == "a" })?.text == "primer logro")
    }

    @Test("execute skips entries with text over the limit")
    func skipsTooLongText() throws {
        let tooLong = String(repeating: "a", count: AccomplishmentValidator.maxTextLength + 1)
        let backup = makeFile([makeBackup(id: "a", text: tooLong), makeBackup(id: "b")])
        let repository = BackupSpyRepository(items: [])

        let result = try ImportBackupUseCase(repository: repository).execute(data: encode(backup))

        #expect(result.imported == 1)
        #expect(result.skipped == 1)
        #expect(repository.lastInsertedIDs == ["b"])
    }

    @Test("execute skips entries with an empty or oversized id")
    func skipsInvalidIDs() throws {
        let hugeID = String(repeating: "x", count: ImportBackupUseCase.maxIDLength + 1)
        let backup = makeFile([makeBackup(id: ""), makeBackup(id: hugeID), makeBackup(id: "ok")])
        let repository = BackupSpyRepository(items: [])

        let result = try ImportBackupUseCase(repository: repository).execute(data: encode(backup))

        #expect(result.imported == 1)
        #expect(repository.lastInsertedIDs == ["ok"])
    }

    @Test("execute skips entries with no text and no valid photo")
    func skipsEmptyEntries() throws {
        let notAnImage = Data("not an image".utf8).base64EncodedString()
        let backup = makeFile([
            makeBackup(id: "blank", text: "   "),
            makeBackup(id: "badPhoto", text: "", photoBase64: notAnImage)
        ])
        let repository = BackupSpyRepository(items: [])

        let result = try ImportBackupUseCase(repository: repository).execute(data: encode(backup))

        #expect(result.imported == 0)
        #expect(result.skipped == 2)
    }

    @Test("execute keeps the text but drops a photo that is not a valid image")
    func dropsInvalidPhotoKeepsText() throws {
        let notAnImage = Data("not an image".utf8).base64EncodedString()
        let backup = makeFile([makeBackup(id: "a", text: "logro", photoBase64: notAnImage)])
        let repository = BackupSpyRepository(items: [])

        _ = try ImportBackupUseCase(repository: repository).execute(data: encode(backup))

        #expect(repository.lastInserted.first?.text == "logro")
        #expect(repository.lastInserted.first?.photoData == nil)
    }

    @Test("execute rejects photos whose declared size is too large to decode safely")
    func rejectsOversizedPhoto() throws {
        let huge = TestImages.png(width: PhotoSanitizer.maxSourceDimension + 1, height: 1)
        let backup = makeFile([makeBackup(id: "a", text: "", photoBase64: huge.base64EncodedString())])
        let repository = BackupSpyRepository(items: [])

        let result = try ImportBackupUseCase(repository: repository).execute(data: encode(backup))

        #expect(result.imported == 0)
        #expect(result.skipped == 1)
    }

    @Test("imported photos are downsampled to the max output dimension")
    func downsamplesLargePhotos() throws {
        let large = TestImages.png(width: PhotoSanitizer.maxOutputDimension * 2, height: 10)
        let backup = makeFile([makeBackup(id: "a", text: "", photoBase64: large.base64EncodedString())])
        let repository = BackupSpyRepository(items: [])

        _ = try ImportBackupUseCase(repository: repository).execute(data: encode(backup))

        let photo = try #require(repository.lastInserted.first?.photoData)
        let size = try #require(TestImages.pixelSize(of: photo))
        #expect(Int(size.width) == PhotoSanitizer.maxOutputDimension)
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

    private func makeBackup(id: String, text: String = "logro", photoBase64: String? = nil) -> AccomplishmentBackup {
        AccomplishmentBackup(
            id: id,
            date: Date(timeIntervalSince1970: 0),
            text: text,
            colorHex: "#FFCC00",
            photoBase64: photoBase64
        )
    }

    private func makeFile(_ accomplishments: [AccomplishmentBackup]) -> BackupFile {
        BackupFile(
            schemaVersion: BackupFile.currentSchemaVersion,
            exportedAt: Date(timeIntervalSince1970: 0),
            appVersion: nil,
            accomplishments: accomplishments
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

/// Generates real (tiny) image bytes so photo validation can be exercised.
enum TestImages {
    static func png(width: Int, height: Int) -> Data {
        let context = CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        context.setFillColor(red: 1, green: 0.8, blue: 0, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        let image = context.makeImage()!
        let output = NSMutableData()
        let destination = CGImageDestinationCreateWithData(output, UTType.png.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(destination, image, nil)
        CGImageDestinationFinalize(destination)
        return output as Data
    }

    static func pixelSize(of data: Data) -> CGSize? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? Int,
              let height = properties[kCGImagePropertyPixelHeight] as? Int
        else { return nil }
        return CGSize(width: width, height: height)
    }
}
