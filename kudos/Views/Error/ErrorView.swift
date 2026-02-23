import SwiftUI

struct ErrorView: View {
    let error: Error?
    @Environment(LanguageManager.self) var languageManager
    
    var body: some View {
        VStack(spacing: Space.large) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.orange)
            
            Text(Copies.ErrorView.title)
                .font(.headline)
                .foregroundStyle(.primary)
            
            if let error = error {
                VStack(spacing: Space.small) {
                    Text(Copies.ErrorView.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
            } else {
                Text(Copies.ErrorView.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Text(Copies.ErrorView.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color("MainBackground"))
        .localized()
    }
}

#if targetEnvironment(simulator)
#Preview {
    ErrorView(error: NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error message"]))
        .environment(LanguageManager.shared)
}
#endif

