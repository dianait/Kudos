import SwiftData
import Foundation

final class SwiftDataAccomplishmentRepository: AccomplishmentRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ accomplishment: NewAccomplishment) throws {
        let model = try Accomplishment(from: accomplishment)
        modelContext.insert(model)
    }

    func savePhoto(_ accomplishment: NewPhotoAccomplishment) throws {
        let model = try Accomplishment(
            photoData: accomplishment.photoData,
            text: accomplishment.caption,
            color: accomplishment.color
        )
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
