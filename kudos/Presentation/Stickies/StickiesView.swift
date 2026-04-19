import SwiftUI

struct StickiesView: View {
    let lastItem: AccomplishmentItem?
    @Binding var mode: Mode

    private var lastMessage: String {
        lastItem?.text ?? ""
    }

    @State private var placeholderItem = AccomplishmentItem(
        id: "1",
        date: Date(),
        text: " ",
        colorHex: Copies.Colors.yellow.rawValue,
        photoData: nil
    )

    @State private var backgroundItem1 = AccomplishmentItem(
        id: "2",
        date: Date(),
        text: Copies.StickiesView.accomplishmentExample3,
        colorHex: Copies.Colors.green.rawValue,
        photoData: nil
    )

    @State private var backgroundItem2 = AccomplishmentItem(
        id: "3",
        date: Date(),
        text: Copies.StickiesView.accomplishmentExample2,
        colorHex: Copies.Colors.blue.rawValue,
        photoData: nil
    )

    @State private var backgroundItem3 = AccomplishmentItem(
        id: "4",
        date: Date(),
        text: Copies.StickiesView.accomplishmentExample1,
        colorHex: Copies.Colors.orange.rawValue,
        photoData: nil
    )

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
