import Foundation

struct BackupFile: Codable, Equatable {
    static let currentSchemaVersion: Int = 1

    let schemaVersion: Int
    let exportedAt: Date
    let appVersion: String?
    let accomplishments: [AccomplishmentBackup]
}

struct AccomplishmentBackup: Codable, Equatable {
    let id: String
    let date: Date
    let text: String
    let colorHex: String
    let photoBase64: String?
}

extension AccomplishmentItem {
    func toBackup() -> AccomplishmentBackup {
        AccomplishmentBackup(
            id: id,
            date: date,
            text: text,
            colorHex: colorHex,
            photoBase64: photoData?.base64EncodedString()
        )
    }
}

extension AccomplishmentBackup {
    func toDomain() -> AccomplishmentItem {
        AccomplishmentItem(
            id: id,
            date: date,
            text: text,
            colorHex: colorHex,
            photoData: photoBase64.flatMap { Data(base64Encoded: $0) }
        )
    }
}
