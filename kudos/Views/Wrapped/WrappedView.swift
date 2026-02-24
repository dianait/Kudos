import SwiftData
import SwiftUI

struct WrappedView: View {
    @Query(sort: \Accomplishment.date, order: .forward) private var allItems: [Accomplishment]
    var onDismiss: (() -> Void)?

    private var currentYearItems: [Accomplishment] {
        let year = Calendar.current.component(.year, from: Date())
        return allItems.filter { Calendar.current.component(.year, from: $0.date) == year }
    }

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    introSlide
                        .containerRelativeFrame(.vertical)

                    ForEach(currentYearItems, id: \.persistentModelID) { item in
                        achievementSlide(for: item)
                            .containerRelativeFrame(.vertical)
                    }

                    outroSlide
                        .containerRelativeFrame(.vertical)
                }
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .ignoresSafeArea()

            if onDismiss != nil {
                closeButton
                    .padding(.top, Space.extraLarge)
                    .padding(.trailing, Space.medium)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Slides

    private var introSlide: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.4, green: 0.1, blue: 0.8), Color(red: 0.15, green: 0.05, blue: 0.45)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: Space.large) {
                Text("✨")
                    .font(.system(size: 72))

                Text(Copies.Wrapped.introTitle(year: currentYear))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)

                Text(Copies.Wrapped.introSubtitle(count: currentYearItems.count))
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)

                Image(systemName: "chevron.down")
                    .foregroundStyle(.white.opacity(0.6))
                    .font(.title2)
                    .padding(.top, Space.large)
            }
            .padding(.horizontal, Space.extraLarge)
        }
    }

    @ViewBuilder
    private func achievementSlide(for item: Accomplishment) -> some View {
        ZStack {
            if item.hasPhoto, let photoData = item.photoData, let uiImage = UIImage(data: photoData) {
                photoSlide(image: uiImage, caption: item.hasText ? item.text : nil)
            } else {
                textSlide(text: item.text, colorName: item.color)
            }
        }
    }

    private func photoSlide(image: UIImage, caption: String?) -> some View {
        ZStack(alignment: .bottom) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .clipped()

            if let caption = caption {
                LinearGradient(
                    colors: [.black.opacity(0.0), .black.opacity(0.75)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                Text(caption)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Space.extraLarge)
                    .padding(.bottom, Space.extraLarge * 2)
            }
        }
    }

    private func textSlide(text: String, colorName: String) -> some View {
        ZStack {
            gradient(for: colorName)
                .ignoresSafeArea()

            VStack(spacing: Space.large) {
                Text("🌟")
                    .font(.system(size: 64))

                Text(text)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal, Space.extraLarge)
        }
    }

    private var outroSlide: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.6, blue: 0.4), Color(red: 0.05, green: 0.35, blue: 0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: Space.large) {
                Text("🎉")
                    .font(.system(size: 72))

                Text(Copies.Wrapped.outroTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)

                Text(Copies.Wrapped.outroSubtitle)
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Space.extraLarge)
        }
    }

    // MARK: - Close Button

    private var closeButton: some View {
        Button(action: { onDismiss?() }) {
            Image(systemName: "xmark.circle.fill")
                .font(.title)
                .foregroundStyle(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
        }
        .accessibilityLabel(Copies.Wrapped.close)
        .accessibilityIdentifier(A11y.Wrapped.buttonIdentifier)
    }

    // MARK: - Gradient Helpers

    private func gradient(for colorName: String) -> LinearGradient {
        switch colorName.lowercased() {
        case "orange":
            return LinearGradient(
                colors: [Color.orange, Color.red],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "yellow":
            return LinearGradient(
                colors: [Color.yellow, Color.orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "green":
            return LinearGradient(
                colors: [Color.green, Color.teal],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "blue":
            return LinearGradient(
                colors: [Color.blue, Color.indigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [Color.purple, Color.pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

#if targetEnvironment(simulator)
    #Preview {
        WrappedView(onDismiss: {})
    }
#endif
