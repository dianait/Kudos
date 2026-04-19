import SwiftData

@MainActor
enum AppFactory {
    static func makeMainViewModel(modelContext: ModelContext) -> MainViewModel {
        let repository = SwiftDataAccomplishmentRepository(modelContext: modelContext)

        return MainViewModel(
            addAccomplishmentUseCase: AddAccomplishmentUseCase(repository: repository),
            addPhotoAccomplishmentUseCase: AddPhotoAccomplishmentUseCase(repository: repository),
            getAccomplishmentsUseCase: GetAccomplishmentsUseCase(repository: repository),
            deleteAccomplishmentUseCase: DeleteAccomplishmentUseCase(repository: repository)
        )
    }

    static func makeWrappedViewModel(modelContext: ModelContext) -> WrappedViewModel {
        let repository = SwiftDataAccomplishmentRepository(modelContext: modelContext)

        return WrappedViewModel(
            getAccomplishmentsUseCase: GetAccomplishmentsUseCase(repository: repository)
        )
    }
}
