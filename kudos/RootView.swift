import SwiftUI

struct RootView: View {
    @Environment(AppSettings.self) private var appSettings
    @State private var onboardingViewModel: OnboardingViewModel?

    var body: some View {
        ZStack {
            ContentView()

            if !appSettings.hasCompletedOnboarding, let vm = onboardingViewModel {
                OnboardingView(viewModel: vm)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: appSettings.hasCompletedOnboarding)
        .task {
            if onboardingViewModel == nil {
                onboardingViewModel = OnboardingViewModel(stateStore: appSettings)
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: AccomplishmentEntity.self, inMemory: true)
        .environment(LocalizationManager.shared)
        .environment(AppSettings.shared)
}
