import Foundation
import SwiftData
import SwiftUI

struct CarouselView: View {
    @Environment(\.modelContext) private var modelContext
    let accomplishments: [Accomplishment]
    @State private var currentIndex: Int = 0
    @State private var translation: CGFloat = 0
    @State private var selectedItem: Accomplishment? = nil
    @State private var dragSessionId: UUID?
    @State private var lastDragEndTime: Date = .distantPast

    private var isDragging: Bool {
        dragSessionId != nil
    }

    private var canTap: Bool {
        Date().timeIntervalSince(lastDragEndTime) > Timing.carouselTapDelay
    }

    private var visibleRange: Range<Int> {
        let windowSize = Limits.carouselWindowSize
        let start = max(0, currentIndex - 1)
        let end = min(accomplishments.count, currentIndex + windowSize)
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
            .accessibilityLabel(A11y.CarouselView.label)
            .accessibilityHint(A11y.CarouselView.itemHint)
            .navigationDestination(item: $selectedItem) { item in
                AccomplishmentDetailView(accomplishment: item)
            }
        }
    }
    
    @ViewBuilder
    private func cardView(for item: Accomplishment, at index: Int) -> some View {
        ZStack {
            StickyView(item: item, delete: { removeItem(item: item) })

            Button {
                if !isDragging && canTap {
                    selectedItem = item
                }
            } label: {
                Color.clear
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
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
        .accessibilityLabel(A11y.CarouselView.itemLabel(index: index, total: accomplishments.count))
        .accessibilityHint(A11y.CarouselView.itemHint)
        .accessibilityAddTraits(.isButton)
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: Limits.carouselDragMinimumDistance)
            .onChanged { gesture in
                if dragSessionId == nil {
                    dragSessionId = UUID()
                }
                if abs(gesture.translation.width) > 10 {
                    translation = gesture.translation.width
                }
            }
            .onEnded { gesture in
                let currentSessionId = dragSessionId
                handleDragEnd(gesture: gesture)
                lastDragEndTime = Date()
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(Timing.carouselTapDelay))
                    if dragSessionId == currentSessionId {
                        dragSessionId = nil
                    }
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

    private func removeItem(item: Accomplishment) {
        withAnimation {
            let itemIndex = accomplishments.firstIndex { $0 === item } ?? currentIndex
            modelContext.delete(item)
            if itemIndex <= currentIndex && currentIndex > 0 {
                currentIndex -= 1
            } else if currentIndex >= accomplishments.count - 1 {
                currentIndex = max(0, accomplishments.count - 2)
            }
        }
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
    CarouselView(accomplishments: [])
        .preferredColorScheme(.dark)
}
