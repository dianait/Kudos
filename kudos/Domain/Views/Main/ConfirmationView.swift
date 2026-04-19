import SwiftUI

struct ConfirmationView: View {
    @Binding var isPresented: Bool
    var onDismiss: (() -> Void)? = nil
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        VStack {
            HStack {
                Spacer()
                ZStack(alignment: .top) {
                    VStack(alignment: .center, spacing: CGFloat(Size.small.rawValue)) {
                        Spacer().frame(height: CGFloat(Size.large.rawValue))

                        Text(Copies.ConfirmationView.title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        Text(Copies.ConfirmationView.description)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(reduceTransparency ? 1.0 : 0.9))

                        Button(action: {
                            withAnimation(reduceMotion ? .none : .default) {
                                isPresented = false
                                onDismiss?()
                            }
                        }) {
                            Text(Copies.ConfirmationView.button)
                                .fontWeight(.semibold)
                                .foregroundStyle(.green)
                                .padding(.horizontal, CGFloat(Size.extraLarge.rawValue))
                                .padding(.vertical, CGFloat(Size.extraExtraSmall.rawValue))
                                .background(Capsule().fill(Color.white))
                        }
                        .padding(.top, CGFloat(Size.extraSmall.rawValue))
                        .accessibilityIdentifier(A11y.ConfirmationView.button)
                    }

                    .padding(.vertical, CGFloat(Size.large.rawValue))
                    .padding(.horizontal, CGFloat(Size.extraExtraLarge.rawValue))
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, CGFloat(Size.large.rawValue))
                    .background(
                        RoundedRectangle(cornerRadius: CGFloat(Size.extraLarge.rawValue))
                            .fill(Color.green)
                    )
                    .shadow(color: reduceTransparency ? .clear : Color.black.opacity(0.1),
                            radius: 8, x: 0, y: 5)

                    HStack(spacing: -CGFloat(Size.extraSmall.rawValue)) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                                .shadow(color: reduceTransparency ? .clear : Color.black.opacity(0.1),
                                        radius: 2, x: 0, y: 1)
                                .accessibilityHidden(true)

                            Image(systemName: Icon.checkmark.rawValue)
                                .font(.system(size: CGFloat(Size.extraLarge.rawValue), weight: .bold))
                                .foregroundStyle(.green)
                                .accessibilityHidden(true)
                        }
                    }
                    .offset(y: -CGFloat(Size.large.rawValue))
                    .accessibilityHidden(true)
                }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier(A11y.ConfirmationView.view)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.top, CGFloat(Size.extraExtraExtraLarge.rawValue))
        }
        .transition(.asymmetric(
            insertion: reduceMotion ? .opacity : .scale.combined(with: .opacity),
            removal: .opacity
        ))
        .animation(reduceMotion ? .none : .spring(), value: isPresented)
        .zIndex(100)
        .onAppear {
            UIAccessibility.post(
                notification: .announcement,
                argument: A11y.ConfirmationView.noti
            )

            if UIAccessibility.isVoiceOverRunning {
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(15))
                    if isPresented {
                        isPresented = false
                        onDismiss?()
                    }
                }
            }
        }
        .localized()
    }
}

extension View {
    func savedConfirmation(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil) -> some View {
        ZStack {
            self

            if isPresented.wrappedValue {
                ConfirmationView(isPresented: isPresented, onDismiss: onDismiss)
            }
        }
    }
}

#Preview {
    Color.gray.opacity(0.3)
        .savedConfirmation(isPresented: .constant(true))
}
