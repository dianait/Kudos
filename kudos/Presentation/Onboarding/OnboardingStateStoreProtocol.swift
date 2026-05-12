import Foundation

@MainActor
protocol OnboardingStateStoreProtocol: AnyObject {
    var hasCompletedOnboarding: Bool { get set }
}
