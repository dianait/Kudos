import Foundation
import SwiftUI

struct AboutView: View {
    @State private var scrollID = UUID()
    var body: some View {
        ZStack {
            Color("MainBackground")
                .ignoresSafeArea()
            ScrollView {
                LazyVStack(alignment: .center, spacing: Space.medium) {
                    Headline()
                    
                    SectionCard(
                        title: Copies.AboutMe.Privacy.title,
                        icon: Icon.lock.rawValue,
                        content: {
                            Text(Copies.AboutMe.Privacy.description)
                        }
                    )
                    SocialLinks()
                    TimelineView()
                }
                .padding()
                .background(Color("MainBackground"))
            }
        }
        .localized()
    }
}

struct Headline: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Space.small) {
                Text(Copies.AboutMe.title)
                    .font(.system(
                        size: CGFloat(Size.extraLarge.rawValue),
                        design: .rounded
                    ))
                    .foregroundStyle(.orange)
                    .accessibilityIdentifier(A11y.MainView.titleIdentifier)

                Text(Copies.AboutMe.description)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(.gray)
            }

            Spacer()

            Image(systemName: Icon.sparkles.rawValue)
                .font(.system(size: CGFloat(Size.extraLarge.rawValue)))
                .foregroundStyle(.orange)
        }
        .padding(.bottom, Space.small)
    }
}

struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content

    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Space.small) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.orange)

                Text(title)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }

            content
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Space.medium)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

#if targetEnvironment(simulator)
    #Preview {
        AboutView()
    }
#endif
