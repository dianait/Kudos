import Foundation

@Observable
@MainActor
final class WrappedViewModel {
    private let getCurrentYearAccomplishmentsUseCase: GetCurrentYearAccomplishmentsUseCaseProtocol
    var currentYearItems: [AccomplishmentItem] = []
    var errorMessage: String?

    var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    init(getCurrentYearAccomplishmentsUseCase: GetCurrentYearAccomplishmentsUseCaseProtocol) {
        self.getCurrentYearAccomplishmentsUseCase = getCurrentYearAccomplishmentsUseCase
    }

    func load() {
        do {
            currentYearItems = try getCurrentYearAccomplishmentsUseCase.execute()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
