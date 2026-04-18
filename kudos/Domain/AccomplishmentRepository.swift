import SwiftData
import Foundation


protocol AccomplishmentRepositoryProtocol {
    func save(_ accomplishment: NewAccomplishment) throws
    func count() throws -> Int
    func fetchAllSortedByDateDescending() throws -> [Accomplishment]
}

final class SwiftDataAccomplishmentRepository: AccomplishmentRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ accomplishment: NewAccomplishment) throws {
        let model = try Accomplishment(accomplishment.text)
        modelContext.insert(model)
    }
    
    func count() throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<Accomplishment>())
    }
    
    func fetchAllSortedByDateDescending() throws -> [Accomplishment] {
            try modelContext.fetch(
                FetchDescriptor<Accomplishment>(
                    sortBy: [SortDescriptor(\.date, order: .reverse)]
                )

            )

        }
}
