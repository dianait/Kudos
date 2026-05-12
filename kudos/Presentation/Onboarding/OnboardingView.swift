import SwiftUI

struct OnboardingView: View {
    @Bindable var viewModel: OnboardingViewModel
    @Environment(LocalizationManager.self) private var languageManager

    var body: some View {
        VStack(spacing: 0) {
            skipButtonRow

            TabView(selection: $viewModel.currentIndex) {
                ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                    OnboardingPageView(page: page, language: languageManager.currentLanguage)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            primaryButton
                .padding(.horizontal, Space.mediumLarge)
                .padding(.bottom, Space.mediumLarge)
        }
        .background(Color("OnboardingBackground").ignoresSafeArea())
        .localized()
    }

    private var skipButtonRow: some View {
        HStack {
            Spacer()
            if !viewModel.isLastPage {
                Button(action: viewModel.skip) {
                    Text("onboarding_button_skip".localized)
                        .font(.system(size: CGFloat(Size.smallMedium.rawValue), weight: .medium))
                        .foregroundStyle(Color("TextColor").opacity(0.6))
                }
                .padding(.trailing, Space.mediumLarge)
                .padding(.top, Space.medium)
            } else {
                Color.clear.frame(height: CGFloat(Size.large.rawValue))
            }
        }
    }

    private var primaryButton: some View {
        Button(action: {
            withAnimation(.easeInOut) { viewModel.primaryButtonTapped() }
        }) {
            Text(viewModel.primaryButtonKey.localized)
                .font(.system(size: CGFloat(Size.medium.rawValue), weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Space.medium)
                .background(
                    Capsule().fill(Color("PrimaryButtonBackground"))
                )
        }
        .accessibilityIdentifier("onboarding_primary_button")
    }
}

#Preview {
    OnboardingView(viewModel: OnboardingViewModel(onComplete: {}))
        .environment(LocalizationManager.shared)
}
