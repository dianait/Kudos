import SwiftData

protocol AccomplishmentRepositoryProtocol {
    func save(_ accomplishment: NewAccomplishment) throws
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
}
