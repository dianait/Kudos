protocol AccomplishmentRepositoryProtocol {
    func save(_ accomplishment: NewAccomplishment) throws
    func savePhoto(_ accomplishment: NewPhotoAccomplishment) throws
    func fetchAllSortedByDateDescending() throws -> [Accomplishment]
    func delete(_ accomplishment: Accomplishment) throws
}
