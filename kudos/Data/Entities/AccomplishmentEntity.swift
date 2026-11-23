import Foundation

// The @Model itself lives in Shared/KudosSchema.swift (versioned, shared with
// the widget); these mappings are app-only.

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
    convenience init(from new: NewAccomplishment) {
        self.init(
            date: new.date,
            text: new.text ?? "",
            colorHex: new.color,
            photoData: new.photoData
        )
    }
}
