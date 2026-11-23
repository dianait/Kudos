import Foundation

struct ImportBackupResult: Equatable {
    let imported: Int
    let skipped: Int
}

enum ImportBackupError: Error, Equatable {
    case invalidFormat
    case unsupportedSchemaVersion(Int)
    case fileTooLarge
}

@MainActor
protocol ImportBackupUseCaseProtocol {
    func execute(data: Data) async throws -> ImportBackupResult
}
