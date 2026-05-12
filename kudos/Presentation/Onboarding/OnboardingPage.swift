import Foundation

struct OnboardingPage: Identifiable, Equatable, Hashable {
    let id: Int
    let imageName: String
    let titleKey: String
    let subtitleKey: String?
}
