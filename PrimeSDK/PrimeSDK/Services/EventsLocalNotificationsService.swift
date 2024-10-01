import UIKit
import UserNotifications

protocol EventsLocalNotificationsServiceProtocol: class {
    func canScheduleNotification(eventID: String, date: Date) -> Bool
    func scheduleNotification(eventID: String, date: Date)
}

final class EventsLocalNotificationsService: EventsLocalNotificationsServiceProtocol {
    private let defaults = UserDefaults.standard
    private static let key = "EventsLocalNotifications"
    static let eventIDKey = "eventID"

    func canScheduleNotification(eventID: String, date: Date) -> Bool {
        let notifications = retrieveNotifications()
        return !notifications.contains(EventLocalNotification(id: eventID, date: date))
    }

    func scheduleNotification(eventID: String, date: Date) {
        let event = EventLocalNotification(id: eventID, date: date)
        let notifications = retrieveNotifications() + [event]
        let filteredNotifications = notifications.filter { notification in
            Date().timeIntervalSince1970 - notification.date.timeIntervalSince1970 < 0
        }

        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(filteredNotifications) {
            defaults.set(encoded, forKey: EventsLocalNotificationsService.key)
        }

        scheduleLocalNotification(date: date, eventID: eventID)
    }

    private func retrieveNotifications() -> [EventLocalNotification] {
        if let objects = defaults.object(forKey: EventsLocalNotificationsService.key) as? Data {
            let decoder = JSONDecoder()
            if let events = try? decoder.decode([EventLocalNotification].self, from: objects) {
                return events
            }
        }
        return []
    }

    private func scheduleLocalNotification(date: Date, eventID: String) {
        let userInfo = [EventsLocalNotificationsService.eventIDKey: eventID]

        var dateComponents = Calendar.autoupdatingCurrent.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        dateComponents.hour = 7
        dateComponents.minute = 0
        dateComponents.second = 0

        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.body = "До события, которое вы хотели посетить, осталось совсем мало времени!"
            content.userInfo = userInfo

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )

            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request)
        } else {
            let notification = UILocalNotification()
            notification.alertBody = "До события, которое вы хотели посетить, осталось совсем мало времени!"
            notification.fireDate = dateComponents.date
            notification.userInfo = userInfo

            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
}

private struct EventLocalNotification: Codable, Equatable {
    let id: String
    let date: Date
}
