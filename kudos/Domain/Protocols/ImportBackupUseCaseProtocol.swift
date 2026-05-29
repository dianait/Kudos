import Foundation

struct ImportBackupResult: Equatable {
    let imported: Int
    let skipped: Int
}

enum ImportBackupError: Error, Equatable {
    case invalidFormat
    case unsupportedSchemaVersion(Int)
}

@MainActor
protocol ImportBackupUseCaseProtocol {
    func execute(data: Data) throws -> ImportBackupResult
}
