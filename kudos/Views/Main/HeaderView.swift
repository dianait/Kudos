import SwiftUI

struct HeaderView: View {
    @Binding var mode: Mode
    @Binding var text: String
    @Environment(\.screenSize) private var screenSize
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(LanguageManager.self) var languageManager

    var shouldShowEditHeader: Bool {
        mode == .edit && !text.isEmpty
    }

    var title: String {
        shouldShowEditHeader ? Copies.editTitle : Copies.viewTitle(screenWidth: screenSize.width)
    }

    var description: String {
        shouldShowEditHeader ? Copies.editDescription(screenWidth: screenSize.width) : Copies.viewDecription(screenWidth: screenSize.width)
    }

    var body: some View {
        VStack {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.orange)
                .multilineTextAlignment(.center)
            Text(description)
                .font(.subheadline)
                .foregroundStyle(Color("TextColor"))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .accessibilityElement(children: .combine)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Space.small)
                .fill(Color.appPrimaryYellow.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: CGFloat(Size.small.rawValue))
                        .stroke(Color.orange.opacity(0.5), lineWidth: 2)
                )
        )
        .fixedSize(horizontal: false, vertical: true)
        .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : nil)
        .minimumScaleFactor(0.7)
        .localized()
    }
}

#if targetEnvironment(simulator)
    #Preview("✏️ Edit Mode") {
        HeaderView(mode: .constant(.edit), text: .constant(""))
            .environment(LanguageManager.shared)
    }

    #Preview("👀 View Mode") {
        HeaderView(mode: .constant(.view), text: .constant(""))
            .environment(LanguageManager.shared)
    }
#endif
