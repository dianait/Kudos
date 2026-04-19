import Foundation
import SwiftData

@Model

final class AccomplishmentEntity {
    @Attribute(.unique) var id: String
    var date: Date
    var text: String
    var colorHex: String
    var photoData: Data?

    init(
        id: String = UUID().uuidString,
        date: Date,
        text: String,
        colorHex: String,
        photoData: Data?
    ) {
        self.id = id
        self.date = date
        self.text = text
        self.colorHex = colorHex
        self.photoData = photoData
    }
}

extension AccomplishmentEntity {
    func toDomain() -> AccomplishmentItem {
        AccomplishmentItem(
            id: id,
            date: date,
            text: text,
            colorHex: colorHex,
            photoData: photoData
        )
    }
}

extension AccomplishmentEntity {
    convenience init(from new: NewAccomplishment) throws {
        let rawText = new.text ?? ""
        let validatedText = try AccomplishmentValidator.validateText(rawText)
        self.init(
            date: Date(),
            text: validatedText,
            colorHex: new.color,
            photoData: new.photoData
        )
    }
}
