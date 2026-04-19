import SwiftUI

enum Dimensions {
    // Text editor dimensions
    static let textEditorWidth: CGFloat = 220
    static let textEditorHeight: CGFloat = 150
    static let counterFrameWidth: CGFloat = 250

    // Sticky note dimensions
    static let stickyWidth: CGFloat = 200
    static let stickyHeight: CGFloat = 200

    // Date label offsets
    static let dateLabelXOffset: CGFloat = -180
    static let dateLabelYOffset: CGFloat = -250

    // KudosJar dimensions
    static let kudosJarWidth: CGFloat = 120
    static let kudosJarHeight: CGFloat = 75
    static let kudosJarBadgePadding: CGFloat = 5
    static let kudosJarBadgeStrokeWidth: CGFloat = 2
    static let kudosJarBadgeOffsetX: CGFloat = 1
    static let kudosJarShadowRadius: CGFloat = 2

    // EmptyStateView dimensions
    static let emptyStateCardWidthRatio: CGFloat = 0.90
    static let emptyStateCardMaxWidth: CGFloat = 500
    static let emptyStateCircleSize: CGFloat = 90
    static let emptyStateCircleOffset: CGFloat = -45
    static let emptyStateBackgroundCircleSize: CGFloat = 20
    static let emptyStateBackgroundCircleCount: Int = 15
    static let emptyStateBackgroundCircleRangeX: ClosedRange<CGFloat> = -150...150
    static let emptyStateBackgroundCircleRangeY: ClosedRange<CGFloat> = -250...250
}

