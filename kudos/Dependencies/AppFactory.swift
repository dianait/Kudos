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

}
