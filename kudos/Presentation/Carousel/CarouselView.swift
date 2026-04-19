import SwiftUI


struct CarouselView: View {
    let accomplishments: [AccomplishmentItem]
    let onDelete: (AccomplishmentItem) -> Void

    @State private var selectedYear: Int? = nil
    @State private var currentIndex: Int = 0
    @State private var translation: CGFloat = 0
    @State private var selectedItem: AccomplishmentItem? = nil
    @State private var dragSessionId: UUID?
    @State private var lastDragEndTime: Date = .distantPast
    @State private var itemToDelete: AccomplishmentItem?
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

    private var sourceAccomplishments: [AccomplishmentItem] {
        #if DEBUG
        let calendar = Calendar.current
        let now = Date()
        let debugItems: [AccomplishmentItem] = [
            AccomplishmentItem(id: "dbg-1", date: calendar.date(byAdding: .day,  value: -3,  to: now)!, text: "🧪 Hace 3 días",   colorHex: "yellow", photoData: nil),
            AccomplishmentItem(id: "dbg-2", date: calendar.date(byAdding: .day,  value: -15, to: now)!, text: "🧪 Hace 15 días",  colorHex: "green",  photoData: nil),
            AccomplishmentItem(id: "dbg-3", date: calendar.date(byAdding: .year, value: -1,  to: now)!, text: "🧪 Año pasado",    colorHex: "blue",   photoData: nil),
            AccomplishmentItem(id: "dbg-4", date: calendar.date(byAdding: .year, value: -2,  to: now)!, text: "🧪 Hace 2 años",   colorHex: "orange", photoData: nil),
        ]
        return accomplishments + debugItems
        #else
        return accomplishments
        #endif
    }

    private var availableYears: [Int] {
        let years = Set(sourceAccomplishments.map { Calendar.current.component(.year, from: $0.date) })
        return years.sorted()
    }

    private var filteredAccomplishments: [AccomplishmentItem] {
        guard let year = selectedYear else { return sourceAccomplishments }
        return sourceAccomplishments.filter {
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
            Picker("", selection: $selectedYear) {
                Text(Copies.CarouselFilter.all).tag(Int?.none)
                ForEach(availableYears, id: \.self) { year in
                    Text(String(year)).tag(Int?.some(year))
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, Space.small)
            .padding(.bottom, Space.medium)

            if filteredAccomplishments.isEmpty {
                EmptyStateView()
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
        .onChange(of: selectedYear) { _, _ in
            currentIndex = 0
        }
        .onChange(of: accomplishments) { _, newItems in
            if let selectedItem, !newItems.contains(where: { $0.id == selectedItem.id }) {
                self.selectedItem = nil
            }
        }
        .onDisappear {
            dragResetTask?.cancel()
            dragResetTask = nil
        }
    }

    @ViewBuilder
    private func cardView(for item: AccomplishmentItem, at index: Int) -> some View {
        StickyView(item: item, delete: {
            itemToDelete = item
        })
        .modifier(CarouselCardModifier(
            index: index,
            currentIndex: currentIndex,
            totalCount: filteredAccomplishments.count,
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
            if gesture.translation.width < -threshold, currentIndex < filteredAccomplishments.count - 1 {
                currentIndex += 1
            } else if gesture.translation.width > threshold, currentIndex > 0 {
                currentIndex -= 1
            }
            translation = 0
        }
    }
    
}

#Preview {
    let calendar = Calendar.current
    let now = Date()
    let accomplishments: [AccomplishmentItem] = [
        AccomplishmentItem(id: "1", date: now, text: "Hoy: terminé el proyecto 🎉", colorHex: "orange", photoData: nil),
        AccomplishmentItem(id: "2", date: calendar.date(byAdding: .day, value: -3, to: now)!, text: "Hace 3 días: hice ejercicio", colorHex: "yellow", photoData: nil),
        AccomplishmentItem(id: "3", date: calendar.date(byAdding: .day, value: -6, to: now)!, text: "Hace 6 días: aprendí algo nuevo", colorHex: "green", photoData: nil),
        AccomplishmentItem(id: "4", date: calendar.date(byAdding: .day, value: -15, to: now)!, text: "Hace 15 días: superé un miedo", colorHex: "blue", photoData: nil),
        AccomplishmentItem(id: "5", date: calendar.date(byAdding: .day, value: -20, to: now)!, text: "Hace 20 días: ayudé a alguien", colorHex: "orange", photoData: nil),
        AccomplishmentItem(id: "6", date: calendar.date(byAdding: .month, value: -2, to: now)!, text: "Hace 2 meses: ascenso en el trabajo", colorHex: "yellow", photoData: nil),
        AccomplishmentItem(id: "7", date: calendar.date(byAdding: .month, value: -5, to: now)!, text: "Hace 5 meses: corrí 10km", colorHex: "green", photoData: nil),
        AccomplishmentItem(id: "8", date: calendar.date(byAdding: .month, value: -8, to: now)!, text: "Hace 8 meses: aprendí SwiftUI", colorHex: "blue", photoData: nil),
        AccomplishmentItem(id: "9", date: calendar.date(byAdding: .year, value: -2, to: now)!, text: "Hace 2 años: viajé sola por primera vez", colorHex: "orange", photoData: nil),
    ]
    CarouselView(accomplishments: accomplishments, onDelete: { _ in })
        .environment(LanguageManager.shared)
        .preferredColorScheme(.dark)
}
