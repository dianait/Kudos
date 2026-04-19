import SwiftUI

struct NewAccomplishment {
    let text: String?
    let photoData: Data?
    let color: String
}


struct AccomplishmentItem: Identifiable, Equatable {
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
}
