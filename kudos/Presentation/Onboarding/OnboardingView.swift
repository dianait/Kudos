import SwiftUI

struct OnboardingView: View {
    @Bindable var viewModel: OnboardingViewModel
    @Environment(LocalizationManager.self) private var languageManager

    private static let supportedLocales: [(code: String, flag: String, a11yLabel: String)] = [
        ("es", "🇪🇸", "Spanish"),
        ("en", "🇬🇧", "English")
    ]

    var body: some View {
        VStack(spacing: 0) {
            topRow

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
    }

    private var topRow: some View {
        HStack(alignment: .center) {
            languageToggle
                .padding(.leading, Space.mediumLarge)

            Spacer()

            if !viewModel.isLastPage {
                Button(action: viewModel.skip) {
                    Text("onboarding_button_skip".localized)
                        .font(.system(size: CGFloat(Size.smallMedium.rawValue), weight: .medium))
                        .foregroundStyle(Color("TextColor").opacity(0.6))
                }
                .padding(.trailing, Space.mediumLarge)
            }
        }
        .padding(.top, Space.medium)
        .frame(minHeight: CGFloat(Size.large.rawValue))
    }

    private var languageToggle: some View {
        HStack(spacing: Space.extraSmall) {
            ForEach(Self.supportedLocales, id: \.code) { locale in
                languageButton(code: locale.code, flag: locale.flag, a11yLabel: locale.a11yLabel)
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func languageButton(code: String, flag: String, a11yLabel: String) -> some View {
        let isActive = code == languageManager.currentLanguage
        return Button {
            guard !isActive else { return }
            languageManager.setLanguage(code)
        } label: {
            Text(flag)
                .font(.system(size: CGFloat(Size.large.rawValue)))
                .opacity(isActive ? 1.0 : 0.35)
                .scaleEffect(isActive ? 1.0 : 0.85)
                .animation(.easeInOut(duration: 0.2), value: languageManager.currentLanguage)
        }
        .accessibilityLabel(a11yLabel)
        .accessibilityAddTraits(isActive ? .isSelected : [])
        .accessibilityIdentifier("onboarding_lang_\(code)_button")
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
