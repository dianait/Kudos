import SwiftUI

struct AccomplishmentDetailView: View {
    let accomplishment: AccomplishmentItem
    let onDelete: (AccomplishmentItem) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageManager.self) private var languageManager
    @State private var showDeleteConfirmation = false

    private var isLongText: Bool {
        accomplishment.text.count > 80
    }

    private var formattedDate: String {
        return accomplishment.date.formatted(
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
                    if accomplishment.hasPhoto {
                        photoView
                    }

                    // Text content
                    if accomplishment.hasText {
                        if accomplishment.hasPhoto {
                            // Caption below photo
                            captionView
                        } else if isLongText {
                            // Long text without photo
                            textOnlyView
                        } else {
                            // Short text without photo - show sticky
                            StickyView(item: accomplishment)
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
        .alert(Copies.AccomplishmentDetail.deleteConfirmationTitle, isPresented: $showDeleteConfirmation) {
            Button(Copies.AccomplishmentDetail.deleteCancel, role: .cancel) { }
            Button(Copies.AccomplishmentDetail.deleteConfirm, role: .destructive) {
                withAnimation { onDelete(accomplishment); dismiss() }
            }
            .accessibilityIdentifier(A11y.AccomplishmentDetail.deleteAlertConfirmIdentifier)
        } message: {
            Text(Copies.AccomplishmentDetail.deleteConfirmationMessage)
        }
        .localized()
    }
    
    @ViewBuilder
    private var photoView: some View {
        if let photoData = accomplishment.photoData, let uiImage = UIImage(data: photoData) {
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
        Text(accomplishment.text)
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
            Text(accomplishment.text)
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
                .fill(Color.fromString(accomplishment.colorHex).opacity(0.3))
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
