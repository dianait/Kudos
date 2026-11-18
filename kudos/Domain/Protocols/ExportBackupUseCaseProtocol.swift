import Foundation

@MainActor
protocol ExportBackupUseCaseProtocol {
    func execute() async throws -> Data
}
