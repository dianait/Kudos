import Foundation

struct AccomplishmentItem: Identifiable, Equatable, Hashable {
    let id: String
    let date: Date
    let text: String
    let colorHex: String
    let photoData: Data?
    
    var hasPhoto: Bool {
        photoData != nil
    }

    var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    static func == (lhs: AccomplishmentItem, rhs: AccomplishmentItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
