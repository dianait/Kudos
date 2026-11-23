import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Turns untrusted image bytes (e.g. from an imported backup) into a safe,
/// bounded JPEG.
///
/// A tiny file can declare huge pixel dimensions (a "decompression bomb");
/// decoding it at full size gets the app killed every time the photo is
/// drawn. This checks the declared size *before* decoding, downsamples, and
/// re-encodes, which also drops EXIF/GPS metadata.
enum PhotoSanitizer {
    static let maxInputBytes = 15 * 1024 * 1024
    static let maxSourceDimension = 12_000
    static let maxSourcePixels = 50_000_000
    static let maxOutputDimension = 2048
    static let jpegQuality = 0.8

    static func sanitize(_ data: Data) -> Data? {
        guard data.count <= maxInputBytes,
              let source = CGImageSourceCreateWithData(
                data as CFData,
                [kCGImageSourceShouldCache: false] as CFDictionary
              ),
              CGImageSourceGetCount(source) > 0,
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? Int,
              let height = properties[kCGImagePropertyPixelHeight] as? Int,
              (1...maxSourceDimension).contains(width),
              (1...maxSourceDimension).contains(height),
              width * height <= maxSourcePixels
        else { return nil }

        let thumbnailOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxOutputDimension
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions as CFDictionary) else {
            return nil
        }

        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            output, UTType.jpeg.identifier as CFString, 1, nil
        ) else { return nil }
        CGImageDestinationAddImage(
            destination,
            image,
            [kCGImageDestinationLossyCompressionQuality: jpegQuality] as CFDictionary
        )
        guard CGImageDestinationFinalize(destination) else { return nil }
        return output as Data
    }
}
