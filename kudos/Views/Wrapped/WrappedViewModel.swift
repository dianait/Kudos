import Foundation

@Observable
@MainActor
final class WrappedViewModel {
    private let getAccomplishmentsUseCase: GetAccomplishmentsUseCaseProtocol
    var allItems: [AccomplishmentItem] = []
    var errorMessage: String?
    init(getAccomplishmentsUseCase: GetAccomplishmentsUseCaseProtocol) {
        self.getAccomplishmentsUseCase = getAccomplishmentsUseCase
    }

    func load() {
        do {
            allItems = try getAccomplishmentsUseCase.execute()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var currentYearItems: [AccomplishmentItem] {
        let year = Calendar.current.component(.year, from: Date())
        return allItems.filter { Calendar.current.component(.year, from: $0.date) == year }
    }

    var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
}
