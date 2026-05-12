import Foundation

enum OnboardingPagesProvider {
    static func makePages() -> [OnboardingPage] {
        [
            OnboardingPage(
                id: 0,
                imageName: "onboarding_stickies",
                titleKey: "onboarding_page1_title",
                subtitleKey: "onboarding_page1_subtitle"
            ),
            OnboardingPage(
                id: 1,
                imageName: "onboarding_confetti",
                titleKey: "onboarding_page2_title",
                subtitleKey: "onboarding_page2_subtitle"
            ),
            OnboardingPage(
                id: 2,
                imageName: "onboarding_jar_growth",
                titleKey: "onboarding_page3_title",
                subtitleKey: "onboarding_page3_subtitle"
            ),
            OnboardingPage(
                id: 3,
                imageName: "onboarding_privacy",
                titleKey: "onboarding_page4_title",
                subtitleKey: "onboarding_page4_subtitle"
            )
        ]
    }
}
