import SwiftData
import SwiftUI

struct KudosJarView: View {
    @Query private var items: [Accomplishment]
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    var body: some View {
        NavigationLink(destination: CarouselView()) {
            HStack {
                Spacer()
                ZStack(alignment: .top) {
                    Image(.kudosjar)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Dimensions.kudosJarWidth, height: Dimensions.kudosJarHeight)

                    Text("\(items.count)")
                        .font(.system(
                            size: CGFloat(Size.medium.rawValue),
                            weight: .bold
                        ))
                        .foregroundStyle(.white)
                        .padding(Dimensions.kudosJarBadgePadding)
                        .background(reduceTransparency ? Color.orange : Color.orange.opacity(0.9))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: Dimensions.kudosJarBadgeStrokeWidth)
                        )
                        .offset(
                            x: Dimensions.kudosJarBadgeOffsetX,
                            y: CGFloat(Size.mediumLarge.rawValue)
                        )
                        .shadow(color: reduceTransparency ? .clear : .gray.opacity(0.2), radius: Dimensions.kudosJarShadowRadius, x: 0, y: 2)
                }
                .padding(.trailing, Space.small)
            }
            .offset(x: CGFloat(Size.large.rawValue), y: .zero)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement()
        .accessibilityLabel(A11y.Jar.label(count: items.count))
        .accessibilityHint(A11y.Jar.hint)
        .accessibilityAddTraits([.isLink, .updatesFrequently])
        .accessibilityIdentifier(A11y.Jar.identifier)
        .minimumScaleFactor(0.8)
        .frame(minWidth: Space.extraLarge, minHeight: Space.extraLarge)
    }
}

#Preview {
    KudosJarView()
        .modelContainer(for: Accomplishment.self, inMemory: true)
}
