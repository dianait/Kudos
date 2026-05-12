import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: Space.mediumLarge) {
            Spacer(minLength: Space.large)

            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, Space.medium)
                .accessibilityHidden(true)

            VStack(spacing: Space.small) {
                Text(page.titleKey.localized)
                    .font(.system(size: CGFloat(Size.extraLarge.rawValue), weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color("TextColor"))

                if let subtitleKey = page.subtitleKey {
                    Text(subtitleKey.localized)
                        .font(.system(size: CGFloat(Size.medium.rawValue)))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color("TextColor").opacity(0.75))
                        .padding(.horizontal, Space.medium)
                }
            }
            .padding(.horizontal, Space.medium)

            Spacer(minLength: Space.large)
        }
    }
}

#Preview {
    OnboardingPageView(
        page: OnboardingPage(
            id: 0,
            imageName: "onboarding_stickies",
            titleKey: "onboarding_page1_title",
            subtitleKey: "onboarding_page1_subtitle"
        )
    )
    .environment(LocalizationManager.shared)
    .background(Color("MainBackground"))
}
