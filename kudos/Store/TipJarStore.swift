import Observation
import StoreKit

@Observable
@MainActor
final class TipJarStore {
    static let shared = TipJarStore()

    private let supporterProductID = "dev.dianait.kudosapp.supporter"

    var isSupporter: Bool = false
    var product: Product?
    var isPurchasing: Bool = false
    var errorMessage: String?

    private init() {}

    func load() async {
        do {
            let products = try await Product.products(for: [supporterProductID])
            product = products.first
        } catch {
            errorMessage = error.localizedDescription
        }
        await refreshEntitlements()
    }

    func purchase() async {
        guard let product else { return }
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    isSupporter = true
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == supporterProductID,
               transaction.revocationDate == nil {
                isSupporter = true
                return
            }
        }
    }
}
