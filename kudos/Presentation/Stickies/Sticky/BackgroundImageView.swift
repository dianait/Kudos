import SwiftUI

struct BackgroundImageView: View {
    var color: String

    var body: some View {
        Image(CustomImage.postit.rawValue)
            .resizable()
            .colorMultiply(Color.fromString(color))
            .aspectRatio(contentMode: .fill)
            .frame(width: Dimensions.stickyBackgroundSize, height: Dimensions.stickyBackgroundSize)
            .shadow(color: .black.opacity(0.5), radius: 5, x: 5, y: 5)
            .accessibilityHidden(true)
    }
}

#Preview {
    Group {
        BackgroundImageView(color: "yellow")
        BackgroundImageView(color: "green")
    }
}
