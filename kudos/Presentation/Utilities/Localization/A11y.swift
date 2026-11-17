import Foundation

enum A11y {
    enum Jar {
        static let identifier = "Jar Button"
        static func label(count: Int) -> String {
            "jar_button_label".localized.replacingOccurrences(of: "{count}", with: "\(count)").replacingOccurrences(of: "{plural}", with: count == 1 ? "jar_singular".localized : "jar_plural".localized)
        }
        static var hint: String { "jar_button_hint".localized }
    }

    enum StickiesView {
        static var stickie: String { "stickies_view_stickie".localized }
        static var hint: String { "stickies_view_hint".localized }
        static func label(lastMessage: String) -> String {
            lastMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "stickies_view_label_empty".localized : lastMessage
        }
    }

    enum MainView {
        static var settingsLabelButton: String { "main_view_settings_label".localized }
        static var aboutLabelButton: String { "main_view_about_label".localized }
        static var aboutHintButton: String { "main_view_about_hint".localized }
        static let aboutIndentifierButton = "About me Button"
        static let settingsIndentifierButton = "Settings Button"
        static let titleIdentifier = "About me Title"
    }

    enum ConfirmationView {
        static var label: String { "confirmation_view_label".localized }
        static var hint: String { "confirmation_view_hint".localized }
        static var noti: String { "confirmation_view_notification".localized }
        static let view = "Confirmation Pop-Up"
        static var button: String { "confirmation_view_button".localized }
    }

    enum StickiesViewOverview {
        static var editModeNotification: String { "stickies_overview_edit_mode".localized }
        static var textEditorLabel: String { "stickies_overview_text_editor_label".localized }
        static var textEditorHint: String { "stickies_overview_text_editor_hint".localized }
        static let textEditorIdentifer = "Text Editor"
        static let cancelButtonIdentifier = "Cancel button"
        static func charCounterLabel(count: Int, max: Int) -> String {
            "stickies_overview_char_counter".localized.replacingOccurrences(of: "{count}", with: "\(count)").replacingOccurrences(of: "{max}", with: "\(max)")
        }
        static var readyToSaveNotification: String { "stickies_overview_ready_to_save".localized }
        static var saveAction: String { "stickies_overview_save_action".localized }
        static var saveButtonLabel: String { "stickies_overview_save_button".localized }
        static var saveButtonHint: String { "stickies_overview_save_button_hint".localized }
        static let saveButtonIdentifier = "Save Button"
    }
    
    enum CarouselView {
        static var label: String { "carousel_view_label".localized }
        static var hint: String { "carousel_view_hint".localized }
        static var yearFilterLabel: String { "carousel_view_year_filter_label".localized }
        static func itemLabel(index: Int, total: Int) -> String {
            "carousel_view_item_label".localized
                .replacingOccurrences(of: "{index}", with: "\(index + 1)")
                .replacingOccurrences(of: "{total}", with: "\(total)")
        }
        static func itemIdentifier(index: Int) -> String { "Achievement \(index) Button" }
        static var itemHint: String { "carousel_view_item_hint".localized }
        static var deleteLabel: String { "carousel_view_delete_label".localized }
        static var deleteHint: String { "carousel_view_delete_hint".localized }
    }

    enum AccomplishmentDetail {
        static let deleteAlertConfirmIdentifier = "Delete Alert Button"
        static let deleteButtonIdentifier = "Delete achievement"
    }

    enum EmptyStateView {
        static let addButtonIdentifier = "Add Achievement Carousel Empty State Button"
    }
    
    enum StickyView {
        static var label: String { "sticky_view_label".localized }
        static var photoOnly: String { "sticky_view_photo_only".localized }
        static var photoWithCaption: String { "sticky_view_photo_with_caption".localized }
        static func dateLabel(date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return "sticky_view_date_label".localized.replacingOccurrences(of: "{date}", with: formatter.string(from: date))
        }
    }
}
