import Foundation
import Observation

@MainActor
@Observable
final class TipJarStore {
    static let shared = TipJarStore()
    var isLoaded: Bool = false

    private init() {}

    func load() async {
        try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
        isLoaded = true
    }
}
