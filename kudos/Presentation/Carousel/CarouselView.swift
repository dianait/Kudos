import SwiftUI

struct CarouselView: View {
    let accomplishments: [AccomplishmentItem]
    let onDelete: (AccomplishmentItem) -> Void
    var onAddNew: (() -> Void)? = nil

    @State private var selectedYear: Int? = nil
    @State private var currentIndex: Int = 0
    @State private var translation: CGFloat = 0
    @State private var selectedItem: AccomplishmentItem? = nil
    @State private var itemToDelete: AccomplishmentItem? = nil
    @State private var dragSessionId: UUID?
    @State private var lastDragEndTime: Date = .distantPast
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

    private var availableYears: [Int] {
        let years = Set(accomplishments.map { Calendar.current.component(.year, from: $0.date) })
        return years.sorted()
    }

    private func count(for year: Int) -> Int {
        accomplishments.filter { Calendar.current.component(.year, from: $0.date) == year }.count
    }

    private var filteredAccomplishments: [AccomplishmentItem] {
        guard let year = selectedYear else { return accomplishments }
        return accomplishments.filter {
            Calendar.current.component(.year, from: $0.date) == year
        }
    }

    private var visibleRange: Range<Int> {
        let windowSize = Limits.carouselWindowSize
        let halfWindow = windowSize / 2
        let start = max(0, currentIndex - halfWindow)
        let end = min(filteredAccomplishments.count, start + windowSize)
        return start..<end
    }

    private var visibleItems: [(index: Int, item: AccomplishmentItem)] {
        visibleRange.compactMap { index -> (Int, AccomplishmentItem)? in
            guard index < filteredAccomplishments.count else { return nil }
            return (index, filteredAccomplishments[index])
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if !accomplishments.isEmpty {
                Picker(A11y.CarouselView.yearFilterLabel, selection: $selectedYear) {
                    Text(Copies.CarouselFilter.all).tag(Int?.none)
                    ForEach(availableYears, id: \.self) { year in
                        Text("\(year) (\(count(for: year)))").tag(Int?.some(year))
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, Space.small)
                .padding(.bottom, Space.medium)
            }

            if filteredAccomplishments.isEmpty {
                EmptyStateView(onAddNew: onAddNew)
            } else {
                ZStack {
                    Color("MainBackground")
                        .ignoresSafeArea()

                    ForEach(visibleItems, id: \.item.id) { index, item in
                        cardView(for: item, at: index)
                    }
                }
                .highPriorityGesture(dragGesture)
                .accessibilityElement(children: .contain)
            }
        }
        .background(Color("MainBackground").ignoresSafeArea())
        .navigationDestination(item: $selectedItem) { item in
            AccomplishmentDetailView(accomplishment: item, onDelete: onDelete)
        }
        .onChange(of: selectedYear) { _, _ in
            currentIndex = 0
        }
        .onChange(of: accomplishments) { _, newItems in
            if let selectedItem, !newItems.contains(where: { $0.id == selectedItem.id }) {
                self.selectedItem = nil
            }
            let newFiltered = selectedYear.map { year in
                newItems.filter { Calendar.current.component(.year, from: $0.date) == year }
            } ?? newItems
            // Deleting the last kudo of the filtered year would leave the
            // picker on a year that no longer exists and show the empty state
            // while other years still have kudos: fall back to "All".
            if selectedYear != nil, newFiltered.isEmpty, !newItems.isEmpty {
                selectedYear = nil
                return
            }
            currentIndex = min(currentIndex, max(0, newFiltered.count - 1))
        }
        .onDisappear {
            dragResetTask?.cancel()
            dragResetTask = nil
        }
        .alert(
            Copies.AccomplishmentDetail.deleteConfirmationTitle,
            isPresented: isShowingDeleteAlert,
            presenting: itemToDelete
        ) { item in
            Button(Copies.AccomplishmentDetail.deleteConfirm, role: .destructive) {
                onDelete(item)
            }
            Button(Copies.AccomplishmentDetail.deleteCancel, role: .cancel) {
                itemToDelete = nil
            }
        } message: { _ in
            Text(Copies.AccomplishmentDetail.deleteConfirmationMessage)
        }
    }

    @ViewBuilder
    private func cardView(for item: AccomplishmentItem, at index: Int) -> some View {
        StickyView(item: item, delete: index == currentIndex ? { itemToDelete = item } : nil)
        .modifier(CarouselCardModifier(
            index: index,
            currentIndex: currentIndex,
            totalCount: filteredAccomplishments.count,
            translation: translation,
            isDragging: isDragging,
            canTap: canTap,
            onTap: {
                selectedItem = item
            },
            onAdjust: adjust
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
        let onAdjust: (AccessibilityAdjustmentDirection) -> Void
        @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
                // Label comes from the combined sticky (it includes the kudo text);
                // the position goes in the value: "<text>, 2 of 5".
                .accessibilityValue(A11y.CarouselView.itemLabel(index: index, total: totalCount))
                .accessibilityIdentifier(A11y.CarouselView.itemIdentifier(index: index + 1))
                .accessibilityAddTraits(index == currentIndex ? .isButton : [])
                // VoiceOver: only the front card is focusable; swipe up/down
                // on it moves to the next/previous kudo.
                .accessibilityHidden(index != currentIndex)
                .accessibilityAdjustableAction(onAdjust)
                .onTapGesture {
                    if index == currentIndex && !isDragging && canTap {
                        onTap()
                    }
                }
        }

        private var cardRotation: CGFloat {
            guard !reduceMotion else { return 0 }
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

                dragResetTask = Task {
                    try? await Task.sleep(for: .seconds(Timing.carouselTapDelay))
                    guard !Task.isCancelled, dragSessionId == sessionId else { return }
                    dragSessionId = nil
                    dragResetTask = nil
                }
            }
    }

    private func adjust(_ direction: AccessibilityAdjustmentDirection) {
        switch direction {
        case .increment where currentIndex < filteredAccomplishments.count - 1:
            currentIndex += 1
        case .decrement where currentIndex > 0:
            currentIndex -= 1
        default:
            break
        }
    }

    private func handleDragEnd(gesture: DragGesture.Value) {
        let threshold = Limits.carouselSwipeThreshold

        withAnimation(.spring(response: AnimationConstants.springResponse, dampingFraction: AnimationConstants.springDampingFraction)) {
            if gesture.translation.width < -threshold, currentIndex < filteredAccomplishments.count - 1 {
                currentIndex += 1
            } else if gesture.translation.width > threshold, currentIndex > 0 {
                currentIndex -= 1
            }
            translation = 0
        }
    }
}
