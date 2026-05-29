@MainActor
protocol AccomplishmentRepositoryProtocol {
    func save(_ accomplishment: NewAccomplishment) throws
    func fetchAllSortedByDateDescending() throws -> [AccomplishmentItem]
    func delete(_ accomplishment: AccomplishmentItem) throws
    func insert(items: [AccomplishmentItem]) throws
}
