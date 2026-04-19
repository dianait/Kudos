import SwiftUI

struct StickiesView: View {
    let lastItem: Accomplishment?
    @Binding var mode: Mode

    private var lastMessage: String {
        lastItem?.text ?? ""
    }

    @State private var placeholderItem = Accomplishment(validatedText: " ", validatedColor: Copies.Colors.yellow.rawValue)
    @State private var backgroundItem1 = Accomplishment(validatedText: Copies.StickiesView.accomplishmentExample3, validatedColor: Copies.Colors.green.rawValue)
    @State private var backgroundItem2 = Accomplishment(validatedText: Copies.StickiesView.accomplishmentExample2, validatedColor: Copies.Colors.blue.rawValue)
    @State private var backgroundItem3 = Accomplishment(validatedText: Copies.StickiesView.accomplishmentExample1, validatedColor: Copies.Colors.orange.rawValue)

    var body: some View {
        HStack {
            ZStack {
                backgroundStickies()
                Button {
                    openEdit()
                } label: {
                    StickyView(item: mode == .view ? (lastItem ?? placeholderItem) : placeholderItem)
                }
                .buttonStyle(.plain)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(A11y.StickiesView.label(lastMessage: lastMessage))
            .accessibilityHint(A11y.StickiesView.hint)
            .accessibilityAddTraits([.isButton])
            .accessibilityIdentifier(A11y.StickiesView.stickie)
            .accessibilityAction(.default) {
                openEdit()
            }
        }
    }

    @ViewBuilder
    private func backgroundStickies() -> some View {
        Group {
            StickyView(item: backgroundItem1)
                .offset(
                    x: -CGFloat(Size.extraExtraExtraLarge.rawValue),
                    y: -CGFloat(Size.extraExtraLarge.rawValue)
                )
                .rotationEffect(Angle(degrees: -CGFloat(Size.mediumLarge.rawValue)))
                .accessibilityHidden(true)

            StickyView(item: backgroundItem2)
                .offset(
                    x: CGFloat(Size.extraExtraExtraLarge.rawValue),
                    y: -CGFloat(Size.extraLarge.rawValue)
                )
                .rotationEffect(Angle(degrees: CGFloat(Size.mediumLarge.rawValue)))
                .accessibilityHidden(true)

            StickyView(item: backgroundItem3)
                .offset(
                    x: CGFloat(Size.extraSmall.rawValue),
                    y: CGFloat(Size.extraLarge.rawValue)
                )
                .rotationEffect(Angle(degrees: CGFloat(Size.extraSmall.rawValue)))
                .accessibilityHidden(true)
        }
    }

    private func openEdit() {
        mode = .edit
    }
}

#Preview {
    StickiesView(lastItem: nil, mode: .constant(.view))
}
