import SwiftUI
import UIKit

// MARK: - Camera Helpers

/// Camera utility functions for checking availability and image compression
enum CameraHelpers {
    /// Checks if the camera is available on this device
    /// - Returns: True if camera is available, false otherwise
    @MainActor
    static func isCameraAvailable() -> Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    /// Compresses an image to reduce storage size.
    ///
    /// Resizes first (a 12 MP photo is never shown larger than ~2048 px) and
    /// only then lowers JPEG quality, instead of re-encoding the full-size
    /// photo up to ten times. UIGraphicsImageRenderer is thread-safe.
    static nonisolated func compressImage(_ image: UIImage, maxSizeKB: Int = 500) -> Data? {
        let maxBytes = maxSizeKB * 1024
        let resized = resize(image, maxPixelSize: CGFloat(PhotoSanitizer.maxOutputDimension))

        var compression: CGFloat = 0.8
        guard var imageData = resized.jpegData(compressionQuality: compression) else {
            return nil
        }
        while imageData.count > maxBytes && compression > 0.3 {
            compression -= 0.1
            if let newData = resized.jpegData(compressionQuality: compression) {
                imageData = newData
            }
        }
        return imageData
    }

    private static nonisolated func resize(_ image: UIImage, maxPixelSize: CGFloat) -> UIImage {
        let pixelWidth = image.size.width * image.scale
        let pixelHeight = image.size.height * image.scale
        let longestSide = max(pixelWidth, pixelHeight)
        guard longestSide > maxPixelSize else { return image }

        let ratio = maxPixelSize / longestSide
        let newSize = CGSize(width: (pixelWidth * ratio).rounded(), height: (pixelHeight * ratio).rounded())
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

// MARK: - Camera Picker View

/// A view that presents the camera to take a photo
struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    @MainActor
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView

        init(_ parent: CameraPickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            // Prefer edited image, fall back to original
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
