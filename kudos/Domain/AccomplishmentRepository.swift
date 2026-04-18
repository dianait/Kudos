import SwiftData
import Foundation


protocol AccomplishmentRepositoryProtocol {
    func save(_ accomplishment: NewAccomplishment) throws
    func fetchAllSortedByDateDescending() throws -> [Accomplishment]
    func delete(_ accomplishment: Accomplishment) throws
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
    
    func fetchAllSortedByDateDescending() throws -> [Accomplishment] {
            try modelContext.fetch(
                FetchDescriptor<Accomplishment>(
                    sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
        )
    }
    
    func delete(_ accomplishment: Accomplishment) throws {
            modelContext.delete(accomplishment)
    }
}
