import Foundation

@MainActor
protocol ExportBackupUseCaseProtocol {
    func execute() throws -> Data
}
