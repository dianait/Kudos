import SwiftUI

/// Fixed-size card rendered to an image for sharing a kudo.
/// Takes an already decoded photo: ImageRenderer draws synchronously, so it
/// can't wait for StickyView's async thumbnail.
struct ShareCardView: View {
    let text: String
    let date: String
    let colorHex: String
    let photo: UIImage?

    static let width: CGFloat = 400

    var body: some View {
        VStack(spacing: Space.large) {
            if let photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: Self.width - 64, height: Self.width - 64)
                    .clipShape(RoundedRectangle(cornerRadius: Space.medium))
            }
            if !text.isEmpty {
                Text(text)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(date)
                .font(.subheadline)
                .foregroundStyle(.black.opacity(0.6))
            Text("🎉 Kudos")
                .font(.headline)
                .foregroundStyle(.orange)
        }
        .padding(32)
        .frame(width: Self.width)
        .background(Color.fromString(colorHex))
        .environment(\.colorScheme, .light)
    }

    /// Renders the card at 3x for crisp sharing. Must run on the main actor.
    @MainActor
    static func render(text: String, date: String, colorHex: String, photo: UIImage?) -> UIImage? {
        let renderer = ImageRenderer(
            content: ShareCardView(text: text, date: date, colorHex: colorHex, photo: photo)
        )
        renderer.scale = 3
        return renderer.uiImage
    }
}
