protocol AccomplishmentRepositoryProtocol {
    func save(_ accomplishment: NewAccomplishment) throws
    func fetchAllSortedByDateDescending() throws -> [Accomplishment]
    func delete(_ accomplishment: Accomplishment) throws
}
