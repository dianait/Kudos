import Foundation
import Observation

@Observable
@MainActor
final class BackupViewModel {
    var pendingExport: BackupExportPayload?
    var importResult: ImportBackupResult?
    var errorMessage: String?

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

    func prepareExport() {
        do {
            let data = try exportUseCase.execute()
            pendingExport = BackupExportPayload(
                data: data,
                suggestedFilename: makeFilename()
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func handleImport(from url: URL) {
        let needsRelease = url.startAccessingSecurityScopedResource()
        defer { if needsRelease { url.stopAccessingSecurityScopedResource() } }

        do {
            let data = try Data(contentsOf: url)
            importResult = try importUseCase.execute(data: data)
        } catch let error as ImportBackupError {
            errorMessage = localizedMessage(for: error)
        } catch {
            errorMessage = error.localizedDescription
        }
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
        }
    }
}

struct BackupExportPayload: Identifiable, Equatable {
    let id = UUID()
    let data: Data
    let suggestedFilename: String
}
