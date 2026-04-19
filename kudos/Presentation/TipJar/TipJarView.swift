import StoreKit
import SwiftUI

struct TipJarView: View {
    @Environment(TipJarStore.self) var store
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color("MainBackground").ignoresSafeArea()

            VStack(spacing: Space.large) {
                header
                Spacer()
                if store.isSupporter {
                    thanksView
                } else {
                    purchaseButton
                    restoreButton
                }
                Spacer()
            }
            .padding(Space.medium)
        }
        .localized()
        .alert(Copies.TipJar.errorTitle, isPresented: Binding(
            get: { store.errorMessage != nil },
            set: { if !$0 { store.errorMessage = nil } }
        )) {
            Button(Copies.ValidationAlert.okButton, role: .cancel) {
                store.errorMessage = nil
            }
        } message: {
            Text(store.errorMessage ?? "")
        }
    }

    private var header: some View {
        VStack(spacing: Space.small) {
            Image(systemName: Icon.heart.rawValue)
                .font(.system(size: 52))
                .foregroundStyle(.orange)
                .padding(.top, Space.large)

            Text(Copies.TipJar.sheetTitle)
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)

            Text(Copies.TipJar.sheetDescription)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var thanksView: some View {
        VStack(spacing: Space.small) {
            Image(systemName: Icon.check.rawValue)
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text(Copies.TipJar.thankYouTitle)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)

            Text(Copies.TipJar.thankYouDescription)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var purchaseButton: some View {
        Button {
            Task { await store.purchase() }
        } label: {
            HStack(spacing: Space.small) {
                if store.isPurchasing {
                    ProgressView().tint(.white)
                } else {
                    Text(Copies.TipJar.buyButton)
                    if let price = store.product?.displayPrice {
                        Text("· \(price)")
                    }
                }
            }
            .font(.system(.body, design: .rounded))
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.orange)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: Space.medium))
        }
        .disabled(store.isPurchasing || store.product == nil)
    }

    private var restoreButton: some View {
        Button(Copies.TipJar.restoreButton) {
            Task { await store.restore() }
        }
        .font(.system(.footnote, design: .rounded))
        .foregroundStyle(.secondary)
    }
}

#Preview {
    TipJarView()
        .environment(TipJarStore.shared)
        .environment(LanguageManager.shared)
}
