import SwiftUI

struct AccomplishmentDetailView: View {
    let accomplishment: AccomplishmentItem
    let onDelete: (AccomplishmentItem) -> Void
    /// Stores new text; returns false if it was rejected (error shown by the caller).
    var onEdit: ((AccomplishmentItem, String) -> Bool)? = nil
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var languageManager
    @State private var showDeleteConfirmation = false
    @State private var photoImage: UIImage?
    @State private var editedText: String?
    @State private var isEditing = false
    @State private var shareImage: Image?

    /// The kudo as currently shown, including an edit made from this screen.
    private var item: AccomplishmentItem {
        AccomplishmentItem(
            id: accomplishment.id,
            date: accomplishment.date,
            text: editedText ?? accomplishment.text,
            colorHex: accomplishment.colorHex,
            photoData: accomplishment.photoData
        )
    }

    private var isLongText: Bool {
        item.text.count > 80
    }

    private var formattedDate: String {
        return item.date.formatted(
            .dateTime.day().month(.wide).year().locale(languageManager.locale)
        )
    }
    
    var body: some View {
        ZStack {
            Color("MainBackground")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Space.large) {
                    // Photo view (full width) if has photo
                    if item.hasPhoto {
                        photoView
                    }

                    // Text content
                    if item.hasText {
                        if item.hasPhoto {
                            // Caption below photo
                            captionView
                        } else if isLongText {
                            // Long text without photo
                            textOnlyView
                        } else {
                            // Short text without photo - show sticky
                            StickyView(item: item)
                                .scaleEffect(1.2)
                                .padding(.top, Space.extraLarge)
                        }
                    }
                    dateCardView
                    deleteButtonView
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let shareImage {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(
                        item: shareImage,
                        preview: SharePreview(Copies.AccomplishmentDetail.shareTitle, image: shareImage)
                    ) {
                        Label(Copies.AccomplishmentDetail.shareButton, systemImage: "square.and.arrow.up")
                    }
                }
            }
            if onEdit != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(Copies.AccomplishmentDetail.editButton) {
                        isEditing = true
                    }
                    .accessibilityIdentifier(A11y.AccomplishmentDetail.editButtonIdentifier)
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditAccomplishmentSheet(
                initialText: item.text,
                allowsEmpty: item.hasPhoto,
                onSave: { newText in
                    guard onEdit?(item, newText) == true else { return false }
                    editedText = newText.trimmingCharacters(in: .whitespacesAndNewlines)
                    return true
                }
            )
        }
        .alert(Copies.AccomplishmentDetail.deleteConfirmationTitle, isPresented: $showDeleteConfirmation) {
            Button(Copies.AccomplishmentDetail.deleteCancel, role: .cancel) { }
            Button(Copies.AccomplishmentDetail.deleteConfirm, role: .destructive) {
                withAnimation { onDelete(item); dismiss() }
            }
            .accessibilityIdentifier(A11y.AccomplishmentDetail.deleteAlertConfirmIdentifier)
        } message: {
            Text(Copies.AccomplishmentDetail.deleteConfirmationMessage)
        }
        .task(id: item.photoData) {
            guard let data = item.photoData else { return }
            photoImage = await ImageDownsampler.image(from: data, maxPixelSize: ImageDownsampler.detailPixelSize)
        }
        // Re-render the share card when the text changes or the photo arrives.
        .task(id: "\(item.text)|\(photoImage != nil)|\(formattedDate)") {
            guard !item.hasPhoto || photoImage != nil else { return }
            shareImage = ShareCardView.render(
                text: item.text.trimmingCharacters(in: .whitespacesAndNewlines),
                date: formattedDate,
                colorHex: item.colorHex,
                photo: photoImage
            ).map { Image(uiImage: $0) }
        }
        .localized()
    }
    
    @ViewBuilder
    private var photoView: some View {
        if let uiImage = photoImage {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: Space.medium))
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                .padding(.horizontal)
                .padding(.top, Space.extraLarge)
        }
    }

    @ViewBuilder
    private var captionView: some View {
        Text(item.text)
            .font(.title3)
            .fontWeight(.medium)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Space.medium)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .padding(.horizontal)
    }

    @ViewBuilder
    private var textOnlyView: some View {
        VStack(alignment: .leading, spacing: Space.medium) {
            Text(item.text)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Space.medium)
                .fill(Color.fromString(item.colorHex).opacity(0.3))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
        .padding(.top, Space.extraLarge)
    }
    
    @ViewBuilder
    private var dateCardView: some View {
        VStack(spacing: Space.small) {
            Image(systemName: "calendar")
                .font(.title2)
                .foregroundStyle(.orange)
            
            Text(Copies.AccomplishmentDetail.dateLabel)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(formattedDate)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Space.medium)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var deleteButtonView: some View {
        Button {
            showDeleteConfirmation = true
        } label: {
            HStack {
                Image(systemName: Icon.trash.rawValue)
                Text(Copies.AccomplishmentDetail.deleteButton)
            }
            .font(.headline)
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .clipShape(.rect(cornerRadius: Space.small))
        }
        .padding(.horizontal)
        .padding(.bottom, Space.extraLarge)
        .accessibilityIdentifier(A11y.AccomplishmentDetail.deleteButtonIdentifier)
    }
    
}
