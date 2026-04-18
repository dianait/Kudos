import Foundation
import SwiftData

@Model
final class Accomplishment {
    var date: Date
    var text: String
    var color: String

    @Attribute(.externalStorage) var photoData: Data?

    var hasPhoto: Bool {
        photoData != nil
    }

    var hasText: Bool {
        !text.isEmpty
    }

    init(_ text: String, color: String) throws {
        self.date = Date()
        self.text = try AccomplishmentValidator.validateText(text)
        self.color = color
        self.photoData = nil
    }

    init(photoData: Data, text: String? = nil, color: String) throws {
        guard !photoData.isEmpty else {
            throw ValidationError.emptyPhoto
        }

        self.date = Date()
        self.photoData = photoData
        self.color = color
        self.text = (try? AccomplishmentValidator.validateText(text ?? "")) ?? ""
    }

    init(validatedText: String, validatedColor: String, photoData: Data? = nil) {
        self.date = Date()
        self.text = validatedText
        self.color = validatedColor
        self.photoData = photoData
    }
    
    init(from new: NewAccomplishment) throws {
        self.date = Date()
        self.color = new.color
        if let photoData = new.photoData {
            guard !photoData.isEmpty else { throw ValidationError.emptyPhoto }
            self.photoData = photoData
            self.text = (try? AccomplishmentValidator.validateText(new.text ?? "")) ?? ""
        } else {
            self.photoData = nil
            self.text = try AccomplishmentValidator.validateText(new.text ?? "")
        }
    }
}
