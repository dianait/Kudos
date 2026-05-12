import Foundation
import Observation

@Observable
@MainActor
final class OnboardingViewModel {
    let pages: [OnboardingPage]
    var currentIndex: Int = 0

    private let onComplete: @MainActor () -> Void

    init(
        pages: [OnboardingPage] = OnboardingPagesProvider.makePages(),
        onComplete: @escaping @MainActor () -> Void
    ) {
        self.pages = pages
        self.onComplete = onComplete
    }

    var isLastPage: Bool {
        currentIndex >= pages.count - 1
    }

    var primaryButtonKey: String {
        isLastPage ? "onboarding_button_start" : "onboarding_button_next"
    }

    func goToNextPage() {
        guard !isLastPage else { return }
        currentIndex += 1
    }

    func skip() {
        onComplete()
    }

    func primaryButtonTapped() {
        if isLastPage {
            onComplete()
        } else {
            goToNextPage()
        }
    }
}
