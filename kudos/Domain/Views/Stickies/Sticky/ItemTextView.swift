import SwiftUI

struct ItemTextView: View {
    var text: String

    var textSize: Font {
        if text.count > 100 {
            return .body
        }
        return .largeTitle
    }

    var body: some View {
        Text(text.trimmingCharacters(in: .whitespaces).isEmpty ? "" : text)
            .font(textSize)
            .frame(width: 200, height: 200)
            .multilineTextAlignment(.center)
    }
}
