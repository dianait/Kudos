import Foundation
import SwiftData

/// The model every install had before iCloud sync. It must stay exactly as it
/// shipped: SwiftData recognises existing stores by this shape.
enum KudosSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }
    static var models: [any PersistentModel.Type] { [AccomplishmentEntity.self] }

    @Model
    final class AccomplishmentEntity {
        @Attribute(.unique) var id: String
        var date: Date
        var text: String
        var colorHex: String
        var photoData: Data?

        init(id: String, date: Date, text: String, colorHex: String, photoData: Data?) {
            self.id = id
            self.date = date
            self.text = text
            self.colorHex = colorHex
            self.photoData = photoData
        }
    }
}

/// CloudKit-compatible model: CloudKit rejects unique constraints and needs a
/// default for every non-optional attribute. Photos move to external storage so
/// they sync as assets instead of bloating each record. Duplicate ids are still
/// prevented in code (backup import checks existing ids).
enum KudosSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(2, 0, 0) }
    static var models: [any PersistentModel.Type] { [AccomplishmentEntity.self] }

    @Model
    final class AccomplishmentEntity {
        var id: String = UUID().uuidString
        var date: Date = Date.now
        var text: String = ""
        var colorHex: String = "yellow"
        @Attribute(.externalStorage) var photoData: Data?

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
}

typealias AccomplishmentEntity = KudosSchemaV2.AccomplishmentEntity

enum KudosMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [KudosSchemaV1.self, KudosSchemaV2.self] }

    /// Only constraints and storage change, no data is transformed.
    static var stages: [MigrationStage] {
        [.lightweight(fromVersion: KudosSchemaV1.self, toVersion: KudosSchemaV2.self)]
    }
}
