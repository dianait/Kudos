import Foundation
import SwiftData

/// Represents a user achievement stored as a sticky note.
///
/// Each accomplishment contains:
/// - Text content (optional, validated, max 140 characters)
/// - Photo data (optional, stored externally for performance)
/// - Color (one of the predefined palette colors)
/// - Creation date (automatically set)
///
/// An accomplishment must have either text OR photo (or both).
/// The model validates data on initialization to ensure data integrity.
@Model
final class Accomplishment {
    var date: Date
    var text: String
    var color: String

    /// Photo data stored externally by SwiftData for better performance
    @Attribute(.externalStorage) var photoData: Data?

    /// Indicates if this accomplishment has a photo
    var hasPhoto: Bool {
        photoData != nil
    }

    /// Indicates if this accomplishment has text content
    var hasText: Bool {
        !text.isEmpty
    }

    /// Initializes a new Accomplishment with text validation.
    ///
    /// - Parameters:
    ///   - text: The achievement text (will be trimmed and validated)
    ///   - color: The color string (defaults to random color if not provided)
    /// - Throws: `ValidationError` if text is empty or too long
    init(_ text: String, color: String = AccomplishmentColor.randomColorString()) throws {
        // Validate text (empty check, length check, trim whitespace)
        let textResult = AccomplishmentValidator.validateText(text)
        guard case .success(let validatedText) = textResult else {
            // Extract the error from the Result using pattern matching
            if case .failure(let error) = textResult {
                throw error
            }
            // Fallback (should never happen, but compiler requires it)
            throw ValidationError.emptyText
        }

        // Color is not validated as it always comes from the predefined palette
        self.date = Date()
        self.text = validatedText
        self.color = color
        self.photoData = nil
    }

    /// Initializes a new Accomplishment with photo data.
    ///
    /// - Parameters:
    ///   - photoData: The photo data (required, must not be empty)
    ///   - text: Optional text caption for the photo
    ///   - color: The color string (defaults to random color if not provided)
    /// - Throws: `ValidationError` if photo data is empty
    init(photoData: Data, text: String? = nil, color: String = AccomplishmentColor.randomColorString()) throws {
        guard !photoData.isEmpty else {
            throw ValidationError.emptyPhoto
        }

        self.date = Date()
        self.photoData = photoData
        self.color = color

        // If text is provided, validate it; otherwise use empty string
        if let text = text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let textResult = AccomplishmentValidator.validateText(text)
            if case .success(let validatedText) = textResult {
                self.text = validatedText
            } else {
                self.text = ""
            }
        } else {
            self.text = ""
        }
    }

    /// Convenience initializer for pre-validated data.
    ///
    /// Use this initializer only when you're certain the data is already validated.
    /// This is useful for previews, mocks, and cases where validation has already occurred.
    ///
    /// - Parameters:
    ///   - validatedText: Pre-validated text (should be trimmed and within length limits)
    ///   - validatedColor: Pre-validated color (should be a valid color string)
    ///   - photoData: Optional photo data
    init(validatedText: String, validatedColor: String, photoData: Data? = nil) {
        self.date = Date()
        self.text = validatedText
        self.color = validatedColor
        self.photoData = photoData
    }
}
