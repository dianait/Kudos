import Foundation
import SwiftData

@MainActor
enum AppFactory {
    static func makeMainViewModel(modelContext: ModelContext) -> MainViewModel {
        let repository = SwiftDataAccomplishmentRepository(modelContext: modelContext)

        let saveAccomplishmentUseCase = SaveAccomplishmentUseCase(
            addAccomplishmentUseCase: AddAccomplishmentUseCase(repository: repository),
            addPhotoAccomplishmentUseCase: AddPhotoAccomplishmentUseCase(repository: repository)
        )

        return MainViewModel(
            saveAccomplishmentUseCase: saveAccomplishmentUseCase,
            repository: repository
        )
    }

    static func makeBackupViewModel(modelContext: ModelContext) -> BackupViewModel {
        let repository = SwiftDataAccomplishmentRepository(modelContext: modelContext)
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let exportUseCase = ExportBackupUseCase(repository: repository, appVersion: appVersion)
        let importUseCase = ImportBackupUseCase(repository: repository)
        return BackupViewModel(
            exportUseCase: exportUseCase,
            importUseCase: importUseCase
        )
    }
}
