import SwiftUI

struct ItemTextView: View {
    var text: String
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var textSize: Font {
        if text.count > 100 || dynamicTypeSize >= .xLarge {
            return .body
        }
        return .largeTitle
    }

    var body: some View {
        Text(text.trimmingCharacters(in: .whitespaces).isEmpty ? "" : text)
            .font(textSize)
            .minimumScaleFactor(0.5)
            .lineLimit(nil)
            .frame(width: Dimensions.stickyWidth, height: Dimensions.stickyHeight)
            .multilineTextAlignment(.center)
    }
}
