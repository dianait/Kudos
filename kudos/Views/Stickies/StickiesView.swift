import SwiftData
import SwiftUI

struct StickiesView: View {
    @Query(sort: \Accomplishment.date, order: .reverse) private var items: [Accomplishment]
    @Binding var mode: Mode

    /// The most recent accomplishment to display
    private var lastItem: Accomplishment? {
        mode == .view ? items.first : nil
    }

    /// Text to show (for accessibility and fallback)
    private var lastMessage: String {
        lastItem?.text ?? ""
    }

    /// Default placeholder item when no accomplishments exist
    private var placeholderItem: Accomplishment {
        Accomplishment(
            validatedText: " ",
            validatedColor: Copies.Colors.yellow.rawValue
        )
    }

    var body: some View {
        HStack {
            ZStack {
                backgroundStickies()

                // Show the actual last item (with photo if it has one) or placeholder
                if let item = lastItem {
                    Button {
                        openEdit()
                    } label: {
                        StickyView(item: item)
                            .offset(x: .zero, y: .zero)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button {
                        openEdit()
                    } label: {
                        StickyView(item: placeholderItem)
                            .offset(x: .zero, y: .zero)
                    }
                    .buttonStyle(.plain)
                }
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
            StickyView(item: Accomplishment(validatedText: Copies.StickisView.accomplishmentExample3, validatedColor: Copies.Colors.green.rawValue))
                .offset(
                    x: -CGFloat(Size.extraExtraExtraLarge.rawValue),
                    y: -CGFloat(Size.extraExtraLarge.rawValue)
                )
                .rotationEffect(Angle(degrees: -CGFloat(Size.mediumLarge.rawValue)))
                .accessibilityHidden(true)

            StickyView(
                item: Accomplishment(
                    validatedText: Copies.StickisView.accomplishmentExample2,
                    validatedColor: Copies.Colors.blue.rawValue
                )
            )
            .offset(
                x: CGFloat(Size.extraExtraExtraLarge.rawValue),
                y: -CGFloat(Size.extraLarge.rawValue)
            )
            .rotationEffect(Angle(degrees: CGFloat(Size.mediumLarge.rawValue)))
            .accessibilityHidden(true)

            StickyView(
                item: Accomplishment(
                    validatedText: Copies.StickisView.accomplishmentExample1,
                    validatedColor: Copies.Colors.orange.rawValue
                )
            )
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
    StickiesView(mode: .constant(.view))
        .modelContainer(for: Accomplishment.self, inMemory: true)
}
