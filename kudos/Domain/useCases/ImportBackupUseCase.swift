import Foundation

@MainActor
final class ImportBackupUseCase: ImportBackupUseCaseProtocol {
    private let repository: AccomplishmentRepositoryProtocol

    init(repository: AccomplishmentRepositoryProtocol) {
        self.repository = repository
    }

    func execute(data: Data) throws -> ImportBackupResult {
        let file = try decode(data)
        guard file.schemaVersion == BackupFile.currentSchemaVersion else {
            throw ImportBackupError.unsupportedSchemaVersion(file.schemaVersion)
        }

        let existing = try repository.fetchAllSortedByDateDescending()
        let existingIDs = Set(existing.map(\.id))

        var seenInBatch = Set<String>()
        var toImport: [AccomplishmentItem] = []
        toImport.reserveCapacity(file.accomplishments.count)

        for backup in file.accomplishments {
            guard !existingIDs.contains(backup.id), !seenInBatch.contains(backup.id) else { continue }
            seenInBatch.insert(backup.id)
            toImport.append(backup.toDomain())
        }

        try repository.insert(items: toImport)

        return ImportBackupResult(
            imported: toImport.count,
            skipped: file.accomplishments.count - toImport.count
        )
    }

    private func decode(_ data: Data) throws -> BackupFile {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(BackupFile.self, from: data)
        } catch {
            throw ImportBackupError.invalidFormat
        }
    }
}
