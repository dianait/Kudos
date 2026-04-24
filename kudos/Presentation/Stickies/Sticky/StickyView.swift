import SwiftUI

struct StickyView: View {
    var item: AccomplishmentItem
    var delete: (() -> Void)? = nil

    @State private var cachedImage: UIImage?

    var isEditMode: Bool {
        delete != nil
    }

    var widthOffset: CGFloat {
        isEditMode ? .zero : -CGFloat(Size.extraLarge.rawValue)
    }

    var heightOffset: CGFloat {
        isEditMode ?
            -CGFloat(Size.extraSmall.rawValue) :
            CGFloat(Size.mediumLarge.rawValue)
    }

    private var photoStickySize: CGFloat {
        Dimensions.stickyWidth * 1.25
    }

    var body: some View {
        Group {
            if item.hasPhoto, let uiImage = cachedImage {
                // Photo mode: date outside image like text stickies
                ZStack {
                    photoBackgroundView(image: uiImage)

                    // Delete button at top-right of image
                    if isEditMode {
                        VStack {
                            HStack {
                                Spacer()
                                DeleteButtonView(action: { delete?() })
                            }
                            Spacer()
                        }
                        .padding(Space.small)
                        .offset(x: .zero, y: Dimensions.photoStickyDeleteButtonOffsetY)
                    }

                    // Caption at bottom if has text
                    if item.hasText {
                        textOverlayView
                    }

                    // Date label positioned outside, top-left (like text stickies)
                    if isEditMode {
                        DateLabelView(date: item.date)
                            .accessibilityLabel(A11y.StickyView.dateLabel(date: item.date))
                            .offset(x: Dimensions.photoStickyDateLabelOffsetX, y: Dimensions.photoStickyDateLabelOffsetY)
                    }
                }
                .frame(width: photoStickySize, height: photoStickySize)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(accessibilityLabelText)
            } else {
                // Text mode: original layout
                VStack {
                    ZStack(alignment: .topTrailing) {
                        BackgroundImageView(color: item.colorHex)
                        textModeOverlay
                    }
                }
                .frame(width: Dimensions.stickyWidth, height: Dimensions.stickyHeight)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(accessibilityLabelText)
            }
        }
        .task(id: item.photoData) {
            cachedImage = item.photoData.flatMap { UIImage(data: $0) }
        }
    }

    // MARK: - Text Mode Overlay

    @ViewBuilder
    private var textModeOverlay: some View {
        VStack {
            if isEditMode {
                DeleteButtonView(action: { delete?() })
                    .offset(
                        x: -CGFloat(Size.mediumLarge.rawValue),
                        y: CGFloat(Size.mediumLarge.rawValue)
                    )
            }

            // Show text only if there is text content
            if item.hasText {
                ItemTextView(text: item.text)
                    .multilineTextAlignment(.center)
                    .offset(x: widthOffset, y: heightOffset)
            }

            if isEditMode {
                DateLabelView(date: item.date)
                    .offset(x: Dimensions.dateLabelXOffset, y: Dimensions.dateLabelYOffset)
                    .accessibilityLabel(A11y.StickyView.dateLabel(date: item.date))
            }
        }
        .padding()
    }

    // MARK: - Subviews

    @ViewBuilder
    private func photoBackgroundView(image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: photoStickySize, height: photoStickySize)
            .clipShape(RoundedRectangle(cornerRadius: CGFloat(Size.small.rawValue)))
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
            .offset(x: .zero, y: Dimensions.photoStickyImageOffsetY)
    }

    @ViewBuilder
    private var textOverlayView: some View {
        VStack {
            Spacer()
            Text(item.text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, Space.small)
                .padding(.vertical, Space.extraSmall)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.6))
        }
    }

    // MARK: - Accessibility

    private var accessibilityLabelText: String {
        if item.hasPhoto && item.hasText {
            return "\(A11y.StickyView.photoWithCaption): \(item.text)"
        } else if item.hasPhoto {
            return A11y.StickyView.photoOnly
        } else {
            return A11y.StickyView.label
        }
    }
}
