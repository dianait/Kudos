import Testing
import Foundation
@testable import kudos

@Suite("AccomplishmentEntity Tests")
struct AccomplishmentEntityTests {

    @Test("Maps NewAccomplishment to entity correctly")
    func mapsFromNewAccomplishment() {
        let new = NewAccomplishment(text: "Mi logro", photoData: nil, color: "blue", date: Date())
        let entity = AccomplishmentEntity(from: new)

        #expect(entity.text == "Mi logro")
        #expect(entity.colorHex == "blue")
        #expect(entity.photoData == nil)
    }

    @Test("Uses empty string when NewAccomplishment has nil text")
    func usesEmptyStringForNilText() {
        let new = NewAccomplishment(text: nil, photoData: nil, color: "yellow", date: Date())
        let entity = AccomplishmentEntity(from: new)

        #expect(entity.text == "")
    }

    @Test("Maps entity to domain AccomplishmentItem correctly")
    func mapsToDomain() {
        let date = Date()
        let entity = AccomplishmentEntity(id: "123", date: date, text: "Logro", colorHex: "green", photoData: nil)

        let item = entity.toDomain()

        #expect(item.id == "123")
        #expect(item.text == "Logro")
        #expect(item.colorHex == "green")
        #expect(item.date == date)
        #expect(item.photoData == nil)
    }

    @Test("Preserves photo data when mapping to domain")
    func preservesPhotoData() {
        let photo = Data([0x89, 0x50, 0x4E, 0x47])
        let entity = AccomplishmentEntity(id: "1", date: Date(), text: "", colorHex: "blue", photoData: photo)

        #expect(entity.toDomain().photoData == photo)
    }
}
