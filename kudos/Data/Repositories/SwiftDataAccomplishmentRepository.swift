import SwiftData
import Foundation

@MainActor
final class SwiftDataAccomplishmentRepository: AccomplishmentRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ accomplishment: NewAccomplishment) throws {
        let entity = AccomplishmentEntity(from: accomplishment)
        modelContext.insert(entity)
        try modelContext.save()
    }
    
    func fetchAllSortedByDateDescending() throws -> [AccomplishmentItem] {
        let descriptor = FetchDescriptor<AccomplishmentEntity>(
            sortBy: [SortDescriptor(\.date, order: .reverse)])
        let entities = try modelContext.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }
    
    func delete(_ accomplishment: AccomplishmentItem) throws {
        let id = accomplishment.id
        var descriptor = FetchDescriptor<AccomplishmentEntity>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        guard let entity = try modelContext.fetch(descriptor).first else { return }
        modelContext.delete(entity)
        try modelContext.save()
    }

    func insert(items: [AccomplishmentItem]) throws {
        guard !items.isEmpty else { return }
        for item in items {
            let entity = AccomplishmentEntity(
                id: item.id,
                date: item.date,
                text: item.text,
                colorHex: item.colorHex,
                photoData: item.photoData
            )
            modelContext.insert(entity)
        }
        try modelContext.save()
    }
}
