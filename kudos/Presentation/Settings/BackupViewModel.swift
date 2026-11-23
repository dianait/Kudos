import Foundation
import Observation

@Observable
@MainActor
final class BackupViewModel {
    var pendingExport: BackupExportPayload?
    var importResult: ImportBackupResult?
    var errorMessage: String?
    /// True while an export/import runs, to disable the buttons and show progress.
    private(set) var isWorking = false

    /// Generous cap (hundreds of photos fit) that still rejects files that
    /// would exhaust memory: the whole file is decoded in memory.
    nonisolated static let maxImportFileBytes = 200 * 1024 * 1024

    private let exportUseCase: ExportBackupUseCaseProtocol
    private let importUseCase: ImportBackupUseCaseProtocol
    private let dateProvider: () -> Date

    init(
        exportUseCase: ExportBackupUseCaseProtocol,
        importUseCase: ImportBackupUseCaseProtocol,
        dateProvider: @escaping () -> Date = Date.init
    ) {
        self.exportUseCase = exportUseCase
        self.importUseCase = importUseCase
        self.dateProvider = dateProvider
    }

    func prepareExport() async {
        guard !isWorking else { return }
        isWorking = true
        defer { isWorking = false }
        do {
            let data = try await exportUseCase.execute()
            pendingExport = BackupExportPayload(
                data: data,
                suggestedFilename: makeFilename()
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func handleImport(from url: URL) async {
        guard !isWorking else { return }
        isWorking = true
        defer { isWorking = false }
        do {
            let data = try await Self.readBackup(at: url)
            importResult = try await importUseCase.execute(data: data)
        } catch let error as ImportBackupError {
            errorMessage = localizedMessage(for: error)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Reads the picked file off the main actor, rejecting oversized files
    /// before loading them into memory.
    nonisolated static func readBackup(at url: URL) async throws -> Data {
        try await Task.detached(priority: .userInitiated) {
            let needsRelease = url.startAccessingSecurityScopedResource()
            defer { if needsRelease { url.stopAccessingSecurityScopedResource() } }
            let fileSize = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            guard fileSize <= maxImportFileBytes else {
                throw ImportBackupError.fileTooLarge
            }
            return try Data(contentsOf: url)
        }.value
    }

    private func makeFilename() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(Copies.Backup.defaultFilename)-\(formatter.string(from: dateProvider())).json"
    }

    private func localizedMessage(for error: ImportBackupError) -> String {
        switch error {
        case .invalidFormat: Copies.Backup.importErrorInvalid
        case .unsupportedSchemaVersion: Copies.Backup.importErrorUnsupported
        case .fileTooLarge: Copies.Backup.importErrorTooLarge
        }
    }
}

struct BackupExportPayload: Identifiable, Equatable {
    let id = UUID()
    let data: Data
    let suggestedFilename: String
}
