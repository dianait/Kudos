import Foundation

enum ValidationError: LocalizedError, Equatable, Sendable {
    case emptyText
    case textTooLong(maxLength: Int)
    case invalidColor
    case emptyPhoto
    case emptyContent

    var errorDescription: String? {
        switch self {
        case .emptyText:
            return "validation_error_empty_text".localized
        case .textTooLong(let maxLength):
            return "validation_error_text_too_long".localized.replacingOccurrences(of: "{max}", with: "\(maxLength)")
        case .invalidColor:
            return "validation_error_invalid_color".localized
        case .emptyPhoto:
            return "validation_error_empty_photo".localized
        case .emptyContent:
            return "validation_error_empty_content".localized
        }
    }

    static func == (lhs: ValidationError, rhs: ValidationError) -> Bool {
        switch (lhs, rhs) {
        case (.emptyText, .emptyText):
            return true
        case (.textTooLong(let lhsMax), .textTooLong(let rhsMax)):
            return lhsMax == rhsMax
        case (.invalidColor, .invalidColor):
            return true
        case (.emptyPhoto, .emptyPhoto):
            return true
        case (.emptyContent, .emptyContent):
            return true
        default:
            return false
        }
    }
}

