import Foundation

@MainActor
protocol EditAccomplishmentUseCaseProtocol {
    /// Replaces the text of an existing kudo. A photo kudo may end up with
    /// an empty caption; a text-only kudo must keep valid text.
    func execute(item: AccomplishmentItem, newText: String) throws
}

@MainActor
final class EditAccomplishmentUseCase: EditAccomplishmentUseCaseProtocol {
    private let repository: AccomplishmentRepositoryProtocol

    init(repository: AccomplishmentRepositoryProtocol) {
        self.repository = repository
    }

    func execute(item: AccomplishmentItem, newText: String) throws {
        let text: String
        if item.hasPhoto {
            text = newText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard text.count <= AccomplishmentValidator.maxTextLength else {
                throw ValidationError.textTooLong(maxLength: AccomplishmentValidator.maxTextLength)
            }
        } else {
            text = try AccomplishmentValidator.validateText(newText)
        }
        try repository.updateText(id: item.id, text: text)
    }
}
