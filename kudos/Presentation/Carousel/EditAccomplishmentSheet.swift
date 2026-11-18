import SwiftUI

/// Edits the text of an existing kudo. Applies the same 140-character limit
/// as the main editor; a photo kudo may have an empty caption.
struct EditAccomplishmentSheet: View {
    let allowsEmpty: Bool
    /// Returns true when the text was stored, which closes the sheet.
    let onSave: (String) -> Bool

    @Environment(\.dismiss) private var dismiss
    @State private var text: String
    @FocusState private var isFocused: Bool

    private let maxCharacters = Limits.maxCharacters

    init(initialText: String, allowsEmpty: Bool, onSave: @escaping (String) -> Bool) {
        self.allowsEmpty = allowsEmpty
        self.onSave = onSave
        _text = State(initialValue: initialText)
    }

    private var canSave: Bool {
        allowsEmpty || !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .trailing, spacing: Space.small) {
                TextEditor(text: Binding(
                    get: { text },
                    set: { text = String($0.prefix(maxCharacters)) }
                ))
                .focused($isFocused)
                .font(.body)
                .scrollContentBackground(.hidden)
                .padding(Space.small)
                .background(
                    RoundedRectangle(cornerRadius: Space.small)
                        .fill(Color(.secondarySystemBackground))
                )
                .frame(minHeight: 160)
                .accessibilityLabel(A11y.StickiesViewOverview.textEditorLabel)

                Text("\(text.count)/\(maxCharacters)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel(
                        A11y.StickiesViewOverview.charCounterLabel(count: text.count, max: maxCharacters)
                    )
                Spacer()
            }
            .padding()
            .navigationTitle(Copies.AccomplishmentDetail.editTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Copies.AccomplishmentDetail.editCancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Copies.AccomplishmentDetail.editSave) {
                        if onSave(text) { dismiss() }
                    }
                    .disabled(!canSave)
                    .accessibilityIdentifier(A11y.AccomplishmentDetail.editSaveIdentifier)
                }
            }
            .onAppear { isFocused = true }
        }
        .presentationDetents([.medium, .large])
    }
}
