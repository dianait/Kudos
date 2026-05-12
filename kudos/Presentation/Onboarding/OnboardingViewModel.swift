import Foundation
import Observation

@Observable
@MainActor
final class OnboardingViewModel {
    let pages: [OnboardingPage]
    var currentIndex: Int = 0

    private let stateStore: OnboardingStateStoreProtocol

    init(
        pages: [OnboardingPage] = OnboardingPagesProvider.makePages(),
        stateStore: OnboardingStateStoreProtocol
    ) {
        self.pages = pages
        self.stateStore = stateStore
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
        complete()
    }

    func primaryButtonTapped() {
        if isLastPage {
            complete()
        } else {
            goToNextPage()
        }
    }

    private func complete() {
        stateStore.hasCompletedOnboarding = true
    }
}
