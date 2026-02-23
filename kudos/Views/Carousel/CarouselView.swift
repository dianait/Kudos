import Foundation
import SwiftData
import SwiftUI

struct CarouselView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Accomplishment.date, order: .reverse) private var items: [Accomplishment]
    @State private var currentIndex: Int = 0
    @State private var translation: CGFloat = 0
    @State private var selectedItem: Accomplishment? = nil

    // Drag state management with session tracking to prevent race conditions
    @State private var dragSessionId: UUID?
    @State private var lastDragEndTime: Date = .distantPast

    // Cache for item indices to optimize removal
    @State private var itemIndexMap: [PersistentIdentifier: Int] = [:]

    // Computed property to check if we're in a drag session
    private var isDragging: Bool {
        dragSessionId != nil
    }

    // Check if enough time has passed since last drag to allow tap
    private var canTap: Bool {
        Date().timeIntervalSince(lastDragEndTime) > Timing.carouselTapDelay
    }

    // Calculate the range of visible items to optimize performance
    private var visibleRange: Range<Int> {
        let windowSize = Limits.carouselWindowSize
        let start = max(0, currentIndex - 1)
        let end = min(items.count, currentIndex + windowSize)
        return start..<end
    }
    
    // Get visible items with their indices for efficient rendering
    private var visibleItems: [(index: Int, item: Accomplishment)] {
        Array(visibleRange)
            .compactMap { index -> (Int, Accomplishment)? in
                guard index < items.count else { return nil }
                return (index, items[index])
            }
    }
    
    var body: some View {
        NavigationStack {
            if items.isEmpty {
                EmptyStateView()
            } else {
                ZStack {
                    Color("MainBackground")
                        .ignoresSafeArea()
                    
                    // Only render visible items using persistent IDs for better performance
                    ForEach(visibleItems, id: \.item.persistentModelID) { index, item in
                        cardView(for: item, at: index)
                    }
                }
                .highPriorityGesture(dragGesture)
                .accessibilityElement(children: .contain)
                .accessibilityLabel(A11y.CarouselView.label)
                .accessibilityHint(A11y.CarouselView.itemHint)
                .onAppear {
                    updateIndexMap()
                }
                .onChange(of: items.count) { _, _ in
                    updateIndexMap()
                }
                .navigationDestination(isPresented: Binding(
                    get: { selectedItem != nil },
                    set: { if !$0 { selectedItem = nil } }
                )) {
                    if let item = selectedItem {
                        AccomplishmentDetailView(accomplishment: item)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func cardView(for item: Accomplishment, at index: Int) -> some View {
        ZStack {
            // Show delete button and date in carousel
            StickyView(item: item, delete: { removeItem(item: item) })
            
            // Tap gesture for navigation - only active when not dragging
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    // Only navigate if we're not dragging and enough time has passed
                    if !isDragging && canTap {
                        selectedItem = item
                    }
                }
        }
        .rotation3DEffect(
            .degrees(Double(cardRotation(index))),
            axis: (x: 0, y: 1, z: 0),
            anchor: .center,
            perspective: AnimationConstants.carouselPerspective
        )
        .offset(x: cardOffset(index))
        .opacity(cardOpacity(index))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(A11y.CarouselView.itemLabel(index: index, total: items.count))
        .accessibilityHint(A11y.CarouselView.itemHint)
        .accessibilityAddTraits(.isButton)
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: Limits.carouselDragMinimumDistance)
            .onChanged { gesture in
                // Start new drag session if not already dragging
                if dragSessionId == nil {
                    dragSessionId = UUID()
                }
                // Only update translation if drag is significant
                if abs(gesture.translation.width) > 10 {
                    translation = gesture.translation.width
                }
            }
            .onEnded { gesture in
                // Capture current session ID before async delay
                let currentSessionId = dragSessionId

                handleDragEnd(gesture: gesture)

                // Record end time for tap delay calculation
                lastDragEndTime = Date()

                // Reset drag session after animation completes
                // Using session ID comparison prevents race conditions with rapid gestures
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(Timing.carouselTapDelay))
                    // Only clear if this is still the same session
                    if dragSessionId == currentSessionId {
                        dragSessionId = nil
                    }
                }
            }
    }
    
    private func handleDragEnd(gesture: DragGesture.Value) {
        let threshold = Limits.carouselSwipeThreshold
        
        withAnimation(.spring(response: AnimationConstants.springResponse, dampingFraction: AnimationConstants.springDampingFraction)) {
            if gesture.translation.width < -threshold, currentIndex < items.count - 1 {
                currentIndex += 1
            } else if gesture.translation.width > threshold, currentIndex > 0 {
                currentIndex -= 1
            }
            translation = 0
        }
    }

    private func removeItem(item: Accomplishment) {
        withAnimation {
            // Use cached index map for O(1) lookup instead of O(n) firstIndex
            let itemIndex = itemIndexMap[item.persistentModelID] ?? currentIndex
            modelContext.delete(item)
            
            // Adjust index after deletion
            if itemIndex <= currentIndex && currentIndex > 0 {
                currentIndex -= 1
            } else if currentIndex >= items.count - 1 {
                currentIndex = max(0, items.count - 2)
            }
            
            // Update index map after deletion
            updateIndexMap()
        }
    }
    
    private func updateIndexMap() {
        itemIndexMap = Dictionary(uniqueKeysWithValues: items.enumerated().map { ($1.persistentModelID, $0) })
    }

    private func cardRotation(_ index: Int) -> CGFloat {
        let offset = CGFloat(index - currentIndex)
        return offset * AnimationConstants.carouselRotationDegrees
    }

    private func cardOffset(_ index: Int) -> CGFloat {
        let offset = CGFloat(index - currentIndex)
        return offset * AnimationConstants.carouselOffsetMultiplier + translation
    }
    
    private func cardOpacity(_ index: Int) -> Double {
        abs(index - currentIndex) > Limits.carouselVisibilityThreshold ? 0 : 1
    }
}

#Preview {
    CarouselView()
        .modelContainer(for: Accomplishment.self, inMemory: true)
        .preferredColorScheme(.dark)
}
