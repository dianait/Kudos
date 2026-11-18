import ImageIO
import UIKit

/// Decodes photo data off the main thread at the size it is displayed,
/// instead of `UIImage(data:)` at full resolution on the main thread.
enum ImageDownsampler {
    /// Sticky thumbnails (~250pt @3x).
    static let stickyPixelSize = 800
    /// Full-width detail and editor previews.
    static let detailPixelSize = 1600

    static func image(from data: Data, maxPixelSize: Int) async -> UIImage? {
        let cgImage = await Task.detached(priority: .userInitiated) {
            thumbnail(from: data, maxPixelSize: maxPixelSize)
        }.value
        return cgImage.map { UIImage(cgImage: $0) }
    }

    private nonisolated static func thumbnail(from data: Data, maxPixelSize: Int) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(
            data as CFData,
            [kCGImageSourceShouldCache: false] as CFDictionary
        ) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    }
}
