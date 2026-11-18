import Testing
import Foundation
@testable import kudos

@Suite("BackupViewModel Tests")
@MainActor
struct BackupViewModelTests {

    private func makeSUT(
        export: MockExportBackupUseCase = MockExportBackupUseCase(),
        importer: MockImportBackupUseCase = MockImportBackupUseCase()
    ) -> BackupViewModel {
        BackupViewModel(
            exportUseCase: export,
            importUseCase: importer,
            dateProvider: { Date(timeIntervalSince1970: 0) }
        )
    }

    private func writeTempFile(_ data: Data) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        try data.write(to: url)
        return url
    }

    // MARK: - Export

    @Test("prepareExport creates a payload with a dated filename")
    func prepareExportCreatesPayload() async {
        let sut = makeSUT(export: MockExportBackupUseCase(result: Data("{}".utf8)))

        await sut.prepareExport()

        #expect(sut.pendingExport?.data == Data("{}".utf8))
        #expect(sut.pendingExport?.suggestedFilename.hasSuffix("-1970-01-01.json") == true)
        #expect(sut.isWorking == false)
        #expect(sut.errorMessage == nil)
    }

    @Test("prepareExport shows an error when the use case fails")
    func prepareExportFailure() async {
        let sut = makeSUT(export: MockExportBackupUseCase(shouldThrow: true))

        await sut.prepareExport()

        #expect(sut.pendingExport == nil)
        #expect(sut.errorMessage != nil)
        #expect(sut.isWorking == false)
    }

    // MARK: - Import

    @Test("handleImport passes the file contents and stores the result")
    func handleImportSuccess() async throws {
        let importer = MockImportBackupUseCase(result: ImportBackupResult(imported: 3, skipped: 1))
        let sut = makeSUT(importer: importer)
        let url = try writeTempFile(Data("contenido".utf8))
        defer { try? FileManager.default.removeItem(at: url) }

        await sut.handleImport(from: url)

        #expect(importer.receivedData == Data("contenido".utf8))
        #expect(sut.importResult == ImportBackupResult(imported: 3, skipped: 1))
        #expect(sut.errorMessage == nil)
        #expect(sut.isWorking == false)
    }

    @Test("handleImport maps ImportBackupError to a message")
    func handleImportKnownError() async throws {
        let sut = makeSUT(importer: MockImportBackupUseCase(error: .invalidFormat))
        let url = try writeTempFile(Data("x".utf8))
        defer { try? FileManager.default.removeItem(at: url) }

        await sut.handleImport(from: url)

        #expect(sut.importResult == nil)
        #expect(sut.errorMessage == Copies.Backup.importErrorInvalid)
    }

    @Test("handleImport reports a missing file without calling the use case")
    func handleImportMissingFile() async {
        let importer = MockImportBackupUseCase()
        let sut = makeSUT(importer: importer)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("no-existe-\(UUID().uuidString).json")

        await sut.handleImport(from: url)

        #expect(importer.receivedData == nil)
        #expect(sut.errorMessage != nil)
    }
}

@MainActor
private final class MockExportBackupUseCase: ExportBackupUseCaseProtocol {
    private let result: Data
    private let shouldThrow: Bool

    init(result: Data = Data(), shouldThrow: Bool = false) {
        self.result = result
        self.shouldThrow = shouldThrow
    }

    func execute() async throws -> Data {
        if shouldThrow { throw BackupTestError.generic }
        return result
    }
}

@MainActor
private final class MockImportBackupUseCase: ImportBackupUseCaseProtocol {
    private let result: ImportBackupResult
    private let error: ImportBackupError?
    private(set) var receivedData: Data?

    init(result: ImportBackupResult = ImportBackupResult(imported: 0, skipped: 0), error: ImportBackupError? = nil) {
        self.result = result
        self.error = error
    }

    func execute(data: Data) async throws -> ImportBackupResult {
        receivedData = data
        if let error { throw error }
        return result
    }
}
