import Foundation
import UserNotifications

/// Opt-in local notification every Sunday evening inviting the user to
/// write down a kudo. Nothing leaves the device.
@MainActor
enum WeeklyReminder {
    static let identifier = "weekly-kudos-reminder"
    /// Sunday (Gregorian weekday 1) at 19:00 local time.
    static let weekday = 1
    static let hour = 19

    /// Asks for permission if needed and schedules the reminder.
    /// Returns false when notifications are not allowed.
    static func enable() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        guard granted else { return false }
        await schedule()
        return true
    }

    static func disable() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    /// Re-creates the request with the current language. Safe to call on
    /// every launch; does nothing if permission was revoked meanwhile.
    static func refreshIfAuthorized() async {
        guard await authorizationStatus() == .authorized else { return }
        await schedule()
    }

    /// Reads the status off the main actor so only the (Sendable) enum crosses back.
    private nonisolated static func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    private static func schedule() async {
        let content = UNMutableNotificationContent()
        content.title = Copies.Reminder.title
        content.body = Copies.Reminder.body
        content.sound = .default

        var components = DateComponents()
        components.weekday = weekday
        components.hour = hour
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }
}
