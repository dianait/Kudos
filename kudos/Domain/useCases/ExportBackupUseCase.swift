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

    func execute() async throws -> Data {
        let items = try repository.fetchAllSortedByDateDescending()
        let exportedAt = dateProvider()
        let appVersion = appVersion
        // Base64 + JSON encoding of every photo is the slow part: off main.
        return try await Task.detached(priority: .userInitiated) {
            let file = BackupFile(
                schemaVersion: BackupFile.currentSchemaVersion,
                exportedAt: exportedAt,
                appVersion: appVersion,
                accomplishments: items.map { $0.toBackup() }
            )
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
            return try encoder.encode(file)
        }.value
    }
}
