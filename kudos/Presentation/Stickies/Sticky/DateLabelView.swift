import SwiftUI

struct DateLabelView: View {
    var date: Date
    @Environment(LocalizationManager.self) private var languageManager

    private var formattedDate: String {
        return date.formatted(.dateTime.day().month(.abbreviated).year().locale(languageManager.locale))
    }

    var body: some View {
        HStack {
            Spacer()
            Text(formattedDate)
                .font(.caption)
                .padding(.vertical, Space.small)
                .padding(.horizontal, Space.medium)
                .background(Color.black.opacity(0.6))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .shadow(color: .gray.opacity(0.5), radius: 4, x: 0, y: 2)
                .overlay(Capsule().stroke(Color.white, lineWidth: 2))
        }
    }
}

#if targetEnvironment(simulator)
    #Preview {
        DateLabelView(date: Date())
            .padding()
            .border(.red)
            .environment(LocalizationManager.shared)
    }
#endif
