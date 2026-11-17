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
            guard !existingIDs.contains(backup.id), !seenInBatch.contains(backup.id),
                  let item = Self.validatedItem(from: backup) else { continue }
            seenInBatch.insert(backup.id)
            toImport.append(item)
        }

        try repository.insert(items: toImport)

        return ImportBackupResult(
            imported: toImport.count,
            skipped: file.accomplishments.count - toImport.count
        )
    }

    static let maxIDLength = 128

    /// A backup file is untrusted input: apply the same rules as the editor
    /// and re-encode photos. Entries that can't be made valid are skipped
    /// (counted in `skipped`). A broken photo is dropped but its text kept.
    static func validatedItem(from backup: AccomplishmentBackup) -> AccomplishmentItem? {
        guard !backup.id.isEmpty, backup.id.count <= maxIDLength else { return nil }

        let text = backup.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.count <= AccomplishmentValidator.maxTextLength else { return nil }

        let photoData = backup.photoBase64
            .flatMap { Data(base64Encoded: $0) }
            .flatMap(PhotoSanitizer.sanitize)
        guard !text.isEmpty || photoData != nil else { return nil }

        return AccomplishmentItem(
            id: backup.id,
            date: backup.date,
            text: text,
            colorHex: backup.colorHex,
            photoData: photoData
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
