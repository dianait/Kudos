import CoreFoundation

extension Limits {
    // Drag gesture thresholds
    static let saveDragThreshold: CGFloat = -50
    static let saveIndicatorThreshold: CGFloat = -100
    static let dragDampingFactor: CGFloat = 0.8

    // Carousel behaviour
    static let carouselSwipeThreshold: CGFloat = 50
    static let carouselDragMinimumDistance: CGFloat = 30
    static let carouselWindowSize: Int = 3
    static let carouselVisibilityThreshold: Int = 2
    static let carouselTranslationActivationThreshold: CGFloat = 10
}
