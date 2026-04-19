import SwiftUI
import UIKit

// MARK: - Camera Helpers

/// Camera utility functions for checking availability and image compression
enum CameraHelpers {
    /// Checks if the camera is available on this device
    /// - Returns: True if camera is available, false otherwise
    static func isCameraAvailable() -> Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    /// Compresses an image to reduce storage size
    /// - Parameters:
    ///   - image: The UIImage to compress
    ///   - maxSizeKB: Maximum size in kilobytes (default 500KB)
    /// - Returns: Compressed image data, or nil if compression fails
    /// - Note: Must run on main actor because it uses UIGraphicsBeginImageContext which is not thread-safe
    @MainActor
    static func compressImage(_ image: UIImage, maxSizeKB: Int = 500) -> Data? {
        let maxBytes = maxSizeKB * 1024
        var compression: CGFloat = 1.0
        let step: CGFloat = 0.1

        // Start with JPEG compression
        guard var imageData = image.jpegData(compressionQuality: compression) else {
            return nil
        }

        // Reduce quality until we're under the size limit
        while imageData.count > maxBytes && compression > step {
            compression -= step
            if let newData = image.jpegData(compressionQuality: compression) {
                imageData = newData
            }
        }

        // If still too large, resize the image
        if imageData.count > maxBytes {
            let scale = sqrt(Double(maxBytes) / Double(imageData.count))
            let newSize = CGSize(
                width: image.size.width * scale,
                height: image.size.height * scale
            )

            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            if let resized = resizedImage {
                imageData = resized.jpegData(compressionQuality: 0.8) ?? imageData
            }
        }

        return imageData
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
