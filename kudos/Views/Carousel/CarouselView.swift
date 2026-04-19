import SwiftUI

struct CarouselView: View {
    let accomplishments: [Accomplishment]
    let onDelete: (Accomplishment) -> Void

    @State private var currentIndex: Int = 0
    @State private var translation: CGFloat = 0
    @State private var selectedItem: Accomplishment? = nil
    @State private var dragSessionId: UUID?
    @State private var lastDragEndTime: Date = .distantPast
    @State private var itemToDelete: Accomplishment?
    @State private var dragResetTask: Task<Void, Never>?

    private var isDragging: Bool {
        dragSessionId != nil
    }

    private var canTap: Bool {
        Date().timeIntervalSince(lastDragEndTime) > Timing.carouselTapDelay
    }
    
    private var isShowingDeleteAlert: Binding<Bool> {
        Binding(
            get: { itemToDelete != nil },
            set: { if !$0 { itemToDelete = nil } }
        )
    }

    private var visibleRange: Range<Int> {
        let windowSize = Limits.carouselWindowSize
        let halfWindow = windowSize / 2
        let start = max(0, currentIndex - halfWindow)
        let end = min(accomplishments.count, start + windowSize)
        return start..<end
    }

    private var visibleItems: [(index: Int, item: Accomplishment)] {
        Array(visibleRange)
            .compactMap { index -> (Int, Accomplishment)? in
                guard index < accomplishments.count else { return nil }
                return (index, accomplishments[index])
            }
    }

    var body: some View {
        if accomplishments.isEmpty {
            EmptyStateView()
        } else {
            ZStack {
                Color("MainBackground")
                    .ignoresSafeArea()

                ForEach(visibleItems, id: \.item.persistentModelID) { index, item in
                    cardView(for: item, at: index)
                }
            }
            .highPriorityGesture(dragGesture)
            .accessibilityElement(children: .contain)
            .navigationDestination(item: $selectedItem) { item in
                AccomplishmentDetailView(accomplishment: item)
            }
            .alert(
                Copies.AccomplishmentDetail.deleteConfirmationTitle,
                isPresented: isShowingDeleteAlert,
                presenting: itemToDelete
            ) { item in
                Button(Copies.AccomplishmentDetail.deleteConfirm, role: .destructive) {
                    onDelete(item)
                    itemToDelete = nil
                }
                Button(Copies.AccomplishmentDetail.deleteCancel, role: .cancel) {
                    itemToDelete = nil
                }
            } message: { _ in
                Text(Copies.AccomplishmentDetail.deleteConfirmationMessage)
            }
            .onChange(of: accomplishments) { _, newItems in
                if let selectedItem, !newItems.contains(where: { $0.persistentModelID == selectedItem.persistentModelID }) {
                    self.selectedItem = nil
                }

            }
            .onDisappear {
                dragResetTask?.cancel()
                dragResetTask = nil
            }
        }
    }

    @ViewBuilder
    private func cardView(for item: Accomplishment, at index: Int) -> some View {
        StickyView(item: item, delete: {
            itemToDelete = item
        })
        .modifier(CarouselCardModifier(
            index: index,
            currentIndex: currentIndex,
            totalCount: accomplishments.count,
            translation: translation,
            isDragging: isDragging,
            canTap: canTap,
            onTap: {
                selectedItem = item
            }
        ))
    }

    private struct CarouselCardModifier: ViewModifier {
        let index: Int
        let currentIndex: Int
        let totalCount: Int
        let translation: CGFloat
        let isDragging: Bool
        let canTap: Bool
        let onTap: () -> Void

        func body(content: Content) -> some View {
            content
                .rotation3DEffect(
                    .degrees(Double(cardRotation)),
                    axis: (x: 0, y: 1, z: 0),
                    anchor: .center,
                    perspective: AnimationConstants.carouselPerspective
                )
                .offset(x: cardOffset)
                .opacity(cardOpacity)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(A11y.CarouselView.itemLabel(index: index, total: totalCount))
                .accessibilityHint(A11y.CarouselView.itemHint)
                .accessibilityAddTraits(index == currentIndex ? .isButton : [])
                .onTapGesture {
                    if index == currentIndex && !isDragging && canTap {
                        onTap()
                    }
                }
        }

        private var cardRotation: CGFloat {
            let offset = CGFloat(index - currentIndex)
            return offset * AnimationConstants.carouselRotationDegrees
        }

        private var cardOffset: CGFloat {
            let offset = CGFloat(index - currentIndex)
            return offset * AnimationConstants.carouselOffsetMultiplier + translation
        }

        private var cardOpacity: Double {
            abs(index - currentIndex) > Limits.carouselVisibilityThreshold ? 0 : 1
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: Limits.carouselDragMinimumDistance)
            .onChanged { gesture in
                if dragSessionId == nil {
                    dragSessionId = UUID()
                }

                if abs(gesture.translation.width) > Limits.carouselTranslationActivationThreshold {
                    translation = gesture.translation.width
                }
            }
            .onEnded { gesture in
                handleDragEnd(gesture: gesture)
                lastDragEndTime = Date()

                dragResetTask?.cancel()
                let sessionId = dragSessionId

                dragResetTask = Task { @MainActor in
                    try? await Task.sleep(for: .seconds(Timing.carouselTapDelay))
                    guard !Task.isCancelled, dragSessionId == sessionId else { return }
                    dragSessionId = nil
                    dragResetTask = nil
                }
            }
    }

    private func handleDragEnd(gesture: DragGesture.Value) {
        let threshold = Limits.carouselSwipeThreshold

        withAnimation(.spring(response: AnimationConstants.springResponse, dampingFraction: AnimationConstants.springDampingFraction)) {
            if gesture.translation.width < -threshold, currentIndex < accomplishments.count - 1 {
                currentIndex += 1
            } else if gesture.translation.width > threshold, currentIndex > 0 {
                currentIndex -= 1
            }
            translation = 0
        }
    }
    
}

#Preview {
    CarouselView(
        accomplishments: [],
        onDelete: { _ in }
    )
    .preferredColorScheme(.dark)
}
