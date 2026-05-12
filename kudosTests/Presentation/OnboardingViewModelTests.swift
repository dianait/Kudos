import Testing
import Foundation
@testable import kudos

@Suite("OnboardingViewModel Tests")
@MainActor
struct OnboardingViewModelTests {

    private func makePages(_ count: Int) -> [OnboardingPage] {
        (0..<count).map {
            OnboardingPage(id: $0, imageName: "img_\($0)", titleKey: "title_\($0)", subtitleKey: nil)
        }
    }

    private func makeSUT(
        pageCount: Int = 4,
        stateStore: MockOnboardingStateStore? = nil
    ) -> (OnboardingViewModel, MockOnboardingStateStore) {
        let store = stateStore ?? MockOnboardingStateStore()
        let vm = OnboardingViewModel(pages: makePages(pageCount), stateStore: store)
        return (vm, store)
    }

    // MARK: - Initial state

    @Test("Starts at page 0")
    func startsAtFirstPage() {
        let (sut, _) = makeSUT()

        #expect(sut.currentIndex == 0)
    }

    // MARK: - isLastPage

    @Test(
        "isLastPage reflects whether currentIndex is at the end",
        arguments: [
            (pageCount: 3, currentIndex: 0, expected: false),
            (pageCount: 3, currentIndex: 1, expected: false),
            (pageCount: 3, currentIndex: 2, expected: true),
            (pageCount: 1, currentIndex: 0, expected: true)
        ] as [(pageCount: Int, currentIndex: Int, expected: Bool)]
    )
    func isLastPage(pageCount: Int, currentIndex: Int, expected: Bool) {
        let (sut, _) = makeSUT(pageCount: pageCount)
        sut.currentIndex = currentIndex

        #expect(sut.isLastPage == expected)
    }

    // MARK: - goToNextPage

    @Test("goToNextPage increments currentIndex")
    func goToNextPageAdvances() {
        let (sut, _) = makeSUT()

        sut.goToNextPage()

        #expect(sut.currentIndex == 1)
    }

    @Test("goToNextPage stops at the last page")
    func goToNextPageStopsAtEnd() {
        let (sut, _) = makeSUT(pageCount: 2)
        sut.currentIndex = 1

        sut.goToNextPage()

        #expect(sut.currentIndex == 1)
    }

    // MARK: - primaryButtonTapped

    @Test("primaryButtonTapped advances when not on last page and does not complete")
    func primaryButtonAdvancesMidway() {
        let (sut, store) = makeSUT(pageCount: 3)

        sut.primaryButtonTapped()

        #expect(sut.currentIndex == 1)
        #expect(store.hasCompletedOnboarding == false)
    }

    @Test("primaryButtonTapped completes when on last page")
    func primaryButtonCompletesOnLast() {
        let (sut, store) = makeSUT(pageCount: 2)
        sut.currentIndex = 1

        sut.primaryButtonTapped()

        #expect(store.hasCompletedOnboarding == true)
    }

    // MARK: - skip

    @Test("skip marks onboarding as completed")
    func skipCompletes() {
        let (sut, store) = makeSUT()

        sut.skip()

        #expect(store.hasCompletedOnboarding == true)
    }

    // MARK: - primaryButtonKey

    @Test(
        "primaryButtonKey returns next/start based on isLastPage",
        arguments: [
            (pageCount: 3, currentIndex: 0, expected: "onboarding_button_next"),
            (pageCount: 3, currentIndex: 1, expected: "onboarding_button_next"),
            (pageCount: 3, currentIndex: 2, expected: "onboarding_button_start"),
            (pageCount: 1, currentIndex: 0, expected: "onboarding_button_start")
        ] as [(pageCount: Int, currentIndex: Int, expected: String)]
    )
    func primaryButtonKey(pageCount: Int, currentIndex: Int, expected: String) {
        let (sut, _) = makeSUT(pageCount: pageCount)
        sut.currentIndex = currentIndex

        #expect(sut.primaryButtonKey == expected)
    }

    // MARK: - Provider integration

    @Test("OnboardingPagesProvider supplies non-empty pages with unique ids")
    func providerSuppliesPages() {
        let pages = OnboardingPagesProvider.makePages()

        #expect(pages.isEmpty == false)
        #expect(Set(pages.map(\.id)).count == pages.count)
    }
}

@MainActor
private final class MockOnboardingStateStore: OnboardingStateStoreProtocol {
    var hasCompletedOnboarding: Bool = false
}
