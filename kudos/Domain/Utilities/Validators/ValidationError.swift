import Foundation

/// Domain validation failures. User-facing messages live in Presentation
/// (`ValidationError+Localized.swift`) so Domain does not depend on the
/// localization layer.
enum ValidationError: Error, Equatable {
    case emptyText
    case textTooLong(maxLength: Int)
    case invalidColor
    case emptyPhoto
    case emptyContent
}
