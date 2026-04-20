import SwiftData

@MainActor
enum AppFactory {
    static func makeMainViewModel(modelContext: ModelContext) -> MainViewModel {
        let repository = SwiftDataAccomplishmentRepository(modelContext: modelContext)

        return MainViewModel(
            addAccomplishmentUseCase: AddAccomplishmentUseCase(repository: repository),
            addPhotoAccomplishmentUseCase: AddPhotoAccomplishmentUseCase(repository: repository),
            repository: repository
        )
    }

}
