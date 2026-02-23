import SwiftUI
import Observation

/// Represents the current mode of the main view
public enum Mode {
    case edit
    case view
}

/// ViewModel for MainView that manages all state related to the main screen.
///
/// This ViewModel consolidates multiple `@State` properties into a single `@State`,
/// following MVVM pattern and improving code organization and testability.
///
/// Uses the modern `@Observable` macro (iOS 17+) for automatic change tracking
/// without the need for `@Published` wrappers.
///
/// Responsibilities:
/// - Managing edit/view mode state
/// - Handling text input state
/// - Managing photo capture state
/// - Managing celebration animations (confetti counter)
/// - Controlling UI visibility (save indicators, messages, settings)
/// - Managing drag gesture offset for save interaction
@Observable
@MainActor
class MainViewModel {
    // MARK: - Editing State

    /// Current text input for the achievement being created
    var text: String = ""

    /// Current mode: `.edit` when user is typing, `.view` when displaying
    var mode: Mode = .view

    // MARK: - Photo State

    /// Selected photo data for the achievement (compressed JPEG)
    var selectedPhotoData: Data?

    /// Controls camera sheet visibility
    var showCamera: Bool = false

    /// Indicates if the current achievement has a photo
    var hasPhoto: Bool {
        selectedPhotoData != nil
    }

    // MARK: - Celebration State

    /// Counter for confetti animation triggers (increments on each save)
    var counter: Int = 0

    // MARK: - UI State

    /// Indicates when user has dragged enough to trigger save (visual feedback)
    var showSaveIndicator: Bool = false

    /// Shows confirmation message after successful save
    var showSavedMessage: Bool = false

    /// Controls language settings sheet visibility
    var showLanguageSettings: Bool = false

    /// Current drag offset for save gesture (used in StickiesViewOverview)
    var dragOffset: CGSize = .zero

    // MARK: - Actions

    /// Increments the celebration counter (triggers confetti animation)
    func incrementCounter() {
        counter += 1
    }

    /// Resets the text input field after saving
    func resetText() {
        text = ""
    }

    /// Resets photo data after saving
    func resetPhoto() {
        selectedPhotoData = nil
    }

    /// Resets all input state (text and photo)
    func resetAllInput() {
        text = ""
        selectedPhotoData = nil
    }

    /// Resets all save-related UI state
    func resetSaveState() {
        showSaveIndicator = false
        dragOffset = .zero
    }

    /// Hides the saved message confirmation
    func hideSavedMessage() {
        showSavedMessage = false
    }
}

