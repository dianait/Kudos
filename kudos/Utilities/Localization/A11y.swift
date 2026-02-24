import Foundation

enum A11y {
    enum Jar {
        static let identifier = "jar_button_identifier".localized
        static func label(count: Int) -> String {
            "jar_button_label".localized.replacingOccurrences(of: "{count}", with: "\(count)").replacingOccurrences(of: "{plural}", with: count == 1 ? "jar_singular".localized : "jar_plural".localized)
        }
        static let hint = "jar_button_hint".localized
    }

    enum StickiesView {
        static let stickie = "stickies_view_stickie".localized
        static let hint = "stickies_view_hint".localized
        static func label(lastMessage: String) -> String {
            lastMessage.isEmpty ? "stickies_view_label_empty".localized : lastMessage
        }
    }

    enum MainView {
        static let settingsLabelButton = "main_view_settings_label".localized
        static let aboutLabelButton = "main_view_about_label".localized
        static let aboutHintButton = "main_view_about_hint".localized
        static let aboutIndentifierButton = "main_view_about_identifier".localized
        static let settingsIndentifierButton = "main_view_settings_identifier".localized
        static let titleIdentifier = "main_view_title_identifier".localized
    }

    enum ConfirmationView {
        static let label = "confirmation_view_label".localized
        static let hint = "confirmation_view_hint".localized
        static let noti = "confirmation_view_notification".localized
        static let view = "confirmation_view_identifier".localized
        static let button = "confirmation_view_button".localized
    }

    enum StickiesViewOverview {
        static let editModeNotification = "stickies_overview_edit_mode".localized
        static let textEditorLabel = "stickies_overview_text_editor_label".localized
        static let textEditorHint = "stickies_overview_text_editor_hint".localized
        static let textEditorIdentifer = "stickies_overview_text_editor_identifier".localized
        static func charCounterLabel(count: Int, max: Int) -> String {
            "stickies_overview_char_counter".localized.replacingOccurrences(of: "{count}", with: "\(count)").replacingOccurrences(of: "{max}", with: "\(max)")
        }
        static let readyToSaveNotification = "stickies_overview_ready_to_save".localized
        static let saveAction = "stickies_overview_save_action".localized
        static let saveButtonLabel = "stickies_overview_save_button".localized
        static let saveButtonHint = "stickies_overview_save_button_hint".localized
        static let saveButtonIdentifier = "stickies_overview_save_button_identifier".localized
    }
    
    enum CarouselView {
        static let label = "carousel_view_label".localized
        static let hint = "carousel_view_hint".localized
        static func itemLabel(index: Int, total: Int) -> String {
            "carousel_view_item_label".localized
                .replacingOccurrences(of: "{index}", with: "\(index + 1)")
                .replacingOccurrences(of: "{total}", with: "\(total)")
        }
        static let itemHint = "carousel_view_item_hint".localized
        static let deleteHint = "carousel_view_delete_hint".localized
    }
    
    enum Wrapped {
        static let buttonHint = "wrapped_button_hint".localized
        static let buttonIdentifier = "wrapped_button_identifier".localized
    }

    enum StickyView {
        static let label = "sticky_view_label".localized
        static let photoOnly = "sticky_view_photo_only".localized
        static let photoWithCaption = "sticky_view_photo_with_caption".localized
        static func dateLabel(date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return "sticky_view_date_label".localized.replacingOccurrences(of: "{date}", with: formatter.string(from: date))
        }
    }
}
