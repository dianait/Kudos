import Foundation
import SwiftUI

extension String {
    var localized: String {
        return LanguageManager.shared.localizedString(for: self)
    }
}

enum Copies {
    private static let minScreenWidth = CGFloat(380)
    static func viewTitle(screenWidth: CGFloat) -> String {
        screenWidth < minScreenWidth ? "celebrate_title_short".localized : "celebrate_title_long".localized
    }

    static func viewDecription(screenWidth: CGFloat) -> String {
        screenWidth < minScreenWidth ? "view_description_short".localized : "view_description_long".localized
    }

    static func editDescription(screenWidth: CGFloat) -> String {
        screenWidth < minScreenWidth ? "edit_description_short".localized : "edit_description_long".localized
    }

    static var editTitle: String {
        return "edit_title".localized
    }

    static var aboutTitle: String {
        return "about_title".localized
    }

    static var setingsTitle: String {
        return "settings_title".localized
    }

    enum LanguageSettingsView {
        static var title: String {
            return "select_language".localized
        }
    }

    enum ConfirmationView {
        static var title: String {
            return "confirmation_title".localized
        }

        static var description: String {
            return "confirmation_description".localized
        }

        static var button: String {
            return "confirmation_button".localized
        }
    }

    enum StickisView {
        static var accomplishmentExample1: String {
            return "accomplishment_example1".localized
        }

        static var accomplishmentExample2: String {
            return "accomplishment_example2".localized
        }

        static var accomplishmentExample3: String {
            return "accomplishment_example3".localized
        }
    }

    enum StickiesViewOverView {
        static var textEditorPlaceHolder: String {
            return "text_editor_placeholder".localized
        }

        static var saveButton: String {
            return "stickies_overview_save_button".localized
        }
    }

    enum Colors: String, CaseIterable {
        case orange
        case yellow
        case green
        case blue
    }

    enum Carrusel {
        enum EmptyState {
            static var title: String {
                return "carousel_empty_title".localized
            }

            static var description: String {
                return "carousel_empty_description".localized
            }

            static var benefit1: String {
                return "carousel_empty_benefit1".localized
            }

            static var benefit2: String {
                return "carousel_empty_benefit2".localized
            }

            static var benefit3: String {
                return "carousel_empty_benefit3".localized
            }

            static var addNewButton: String {
                return "carousel_empty_add_button".localized
            }
        }
    }

    enum AboutMe {
        static var title: String {
            return "about_me_title".localized
        }

        static var description: String {
            return "about_me_description".localized
        }

        enum Privacy {
            static var title: String {
                return "privacy_title".localized
            }

            static var description: String {
                return "privacy_description".localized
            }
        }

        enum Timeline {
            static var title: String {
                return "timeline_title".localized
            }

            private enum Step1 {
                static var title: String {
                    return "step1_title".localized
                }

                static var description: String {
                    return "step1_description".localized
                }
            }

            private enum Step2 {
                static var title: String {
                    return "step2_title".localized
                }

                static var description: String {
                    return "step2_description".localized
                }
            }

            private enum Step3 {
                static var title: String {
                    return "step3_title".localized
                }

                static var description: String {
                    return "step3_description".localized
                }
            }

            private enum Step4 {
                static var title: String {
                    return "step4_title".localized
                }

                static var description: String {
                    return "step4_description".localized
                }
            }

            static var steps: [(title: String, description: String, icon: String)] {
                return [
                    (Step1.title, Step1.description, "lightbulb.fill"),
                    (Step2.title, Step2.description, "brain.head.profile"),
                    (Step3.title, Step3.description, "bird.fill"),
                    (Step4.title, Step4.description, "iphone.gen3"),
                ]
            }
        }

        enum Footer {
            static var title: String {
                return "footer_title".localized
            }

            static var socialLinks: String {
                return "footer_social_links".localized
            }
        }
    }

    enum ErrorView {
        static var title: String {
            return "error_view_title".localized
        }

        static var message: String {
            return "error_view_message".localized
        }

        static var description: String {
            return "error_view_description".localized
        }
    }

    enum InMemoryWarning {
        static var title: String {
            return "in_memory_warning_title".localized
        }

        static var message: String {
            return "in_memory_warning_message".localized
        }

        static var okButton: String {
            return "in_memory_warning_ok".localized
        }
    }

    enum Camera {
        static var addPhoto: String {
            return "camera_add_photo".localized
        }

        static var changePhoto: String {
            return "camera_change_photo".localized
        }

        static var removePhoto: String {
            return "camera_remove_photo".localized
        }

        static var addPhotoHint: String {
            return "camera_add_photo_hint".localized
        }

        static var notAvailable: String {
            return "camera_not_available".localized
        }
    }
    
    enum ValidationAlert {
        static var title: String {
            return "validation_alert_title".localized
        }

        static var okButton: String {
            return "validation_alert_ok".localized
        }

        static var defaultMessage: String {
            return "validation_alert_default_message".localized
        }
    }

    enum AccomplishmentDetail {
        static var dateLabel: String {
            return "accomplishment_detail_date_label".localized
        }
        
        static var deleteButton: String {
            return "accomplishment_detail_delete_button".localized
        }
        
        static var deleteHint: String {
            return "accomplishment_detail_delete_hint".localized
        }
        
        static var closeButton: String {
            return "accomplishment_detail_close_button".localized
        }
        
        static var deleteConfirmationTitle: String {
            return "accomplishment_detail_delete_confirmation_title".localized
        }
        
        static var deleteConfirmationMessage: String {
            return "accomplishment_detail_delete_confirmation_message".localized
        }
        
        static var deleteCancel: String {
            return "accomplishment_detail_delete_cancel".localized
        }
        
        static var deleteConfirm: String {
            return "accomplishment_detail_delete_confirm".localized
        }
    }
}
