import SwiftUI

struct TimelineView: View {
    private var primaryColor: Color { Color.orange }
    var body: some View {
        VStack(alignment: .leading, spacing: Space.small) {
            HStack {
                Image(systemName: Icon.book.rawValue)
                    .font(.title)
                    .foregroundStyle(primaryColor)

                Text(Copies.AboutMe.Timeline.title)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(primaryColor)
            }
            .padding(.vertical, Space.mediumLarge)

            LazyVStack(alignment: .leading, spacing: Space.mediumLarge) {

                ForEach(Copies.AboutMe.Timeline.steps, id: \.title) { step in
                    TimelineItem(
                        icon: step.icon,
                        title: step.title,
                        description: step.description
                    )
                }
            }
        }

        .padding(.leading, Space.small)
    }
}

struct TimelineItem: View {
    let icon: String
    let title: String
    let description: String

    private let circleSize = CGFloat(Size.smallMedium.rawValue)
    private let circleBackgroundSize = CGFloat(Size.large.rawValue)
    private let iconSize = CGFloat(Size.medium.rawValue)
    private let spacing = CGFloat(Size.mediumLarge.rawValue)

    var body: some View {
        VStack(alignment: .leading, spacing: Space.small) {
            HStack(spacing: Space.small) {
                Image(systemName: icon)
                    .foregroundStyle(.orange)
                    .font(.system(size: Space.mediumLarge))

                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.primary)
            }

            Text(description)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, Space.small)
        }
        .background(Color("MainBackground"))
    }
}

#if targetEnvironment(simulator)
    #Preview {
        TimelineView()
            .padding()
    }
#endif
