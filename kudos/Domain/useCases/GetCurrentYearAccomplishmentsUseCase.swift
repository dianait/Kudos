import Foundation

protocol GetCurrentYearAccomplishmentsUseCaseProtocol {
    func execute() throws -> [AccomplishmentItem]
}

final class GetCurrentYearAccomplishmentsUseCase: GetCurrentYearAccomplishmentsUseCaseProtocol {
    private let repository: AccomplishmentRepositoryProtocol
    private let calendar: Calendar

    init(repository: AccomplishmentRepositoryProtocol, calendar: Calendar = .current) {
        self.repository = repository
        self.calendar = calendar
    }

    func execute() throws -> [AccomplishmentItem] {
        let all = try repository.fetchAllSortedByDateDescending()
        let currentYear = calendar.component(.year, from: Date())
        return all.filter { calendar.component(.year, from: $0.date) == currentYear }
    }
}
