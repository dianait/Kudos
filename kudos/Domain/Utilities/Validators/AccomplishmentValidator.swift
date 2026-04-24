struct AccomplishmentValidator {
    static let maxTextLength = Limits.maxCharacters

    static func validateText(_ text: String) throws -> String {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedText.isEmpty else {
            throw ValidationError.emptyText
        }

        guard trimmedText.count <= maxTextLength else {
            throw ValidationError.textTooLong(maxLength: maxTextLength)
        }

        return trimmedText
    }
}
