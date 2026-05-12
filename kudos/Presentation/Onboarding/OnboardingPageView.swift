import SwiftUI
import UIKit

struct OnboardingPageView: View {
    let page: OnboardingPage
    let language: String

    private var resolvedImageName: String {
        let localized = "\(page.imageName)_\(language)"
        return UIImage(named: localized) != nil ? localized : page.imageName
    }

    var body: some View {
        VStack(spacing: Space.mediumLarge) {
            Spacer(minLength: Space.large)

            Image(resolvedImageName)
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
        ),
        language: "es"
    )
    .environment(LocalizationManager.shared)
    .background(Color("OnboardingBackground"))
}
