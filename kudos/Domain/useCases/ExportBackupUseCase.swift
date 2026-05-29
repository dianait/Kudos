import Foundation

@MainActor
final class ExportBackupUseCase: ExportBackupUseCaseProtocol {
    private let repository: AccomplishmentRepositoryProtocol
    private let appVersion: String?
    private let dateProvider: () -> Date

    init(
        repository: AccomplishmentRepositoryProtocol,
        appVersion: String? = nil,
        dateProvider: @escaping () -> Date = Date.init
    ) {
        self.repository = repository
        self.appVersion = appVersion
        self.dateProvider = dateProvider
    }

    func execute() throws -> Data {
        let items = try repository.fetchAllSortedByDateDescending()
        let backups = items.map { $0.toBackup() }
        let file = BackupFile(
            schemaVersion: BackupFile.currentSchemaVersion,
            exportedAt: dateProvider(),
            appVersion: appVersion,
            accomplishments: backups
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(file)
    }
}
