import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    private let eventReminderPrefix = "event-reminder-"
    private let eventReminderStoreKey = "athena.eventReminderIDs"
    private let notificationsEnabledKey = "athena.notificationsEnabled"
    private let mutedAthleteAlertsKey = "athena.mutedAthleteAlertIDs"
    private let notificationFrequencyKey = "athena.notificationFrequency"
    private let notifySprintsKey = "athena.notifySprints"
    private let notifyHurdlesKey = "athena.notifyHurdles"
    private let notifyDistanceKey = "athena.notifyDistance"
    private let notifyFieldKey = "athena.notifyField"

    enum NotificationFrequency: String {
        case low, medium, high
    }
    
    private init() {}

    static let sourceCitationText = "Sources: World Athletics • FloTrack • Track & Field News • LA28"
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    func scheduleAthleteResultNotification(athlete: Athlete, result: Result) {
        guard notificationsEnabled, isAthleteAlertEnabled(athleteID: athlete.id) else { return }
        guard shouldNotifyFor(eventName: result.eventName) else { return }
        let content = UNMutableNotificationContent()
        content.title = "\(athlete.name) just competed!"
        content.body = "\(result.placement)th place in \(result.eventName)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: result.id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    // Schedules a "competing today" alert for a followed athlete — fired 5 seconds after call for demo.
    func scheduleCompetingTodayNotification(athlete: Athlete, eventName: String) {
        guard notificationsEnabled, isAthleteAlertEnabled(athleteID: athlete.id) else { return }
        guard shouldNotifyFor(eventName: eventName) else { return }
        let content = UNMutableNotificationContent()
        content.title = "\(athlete.name) competes today"
        content.body = "\(eventName) — tap to follow along."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "competing-\(athlete.id)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule competing-today notification: \(error)")
            }
        }
    }

    // Schedules competing-today alerts for all followed athletes with events today.
    func scheduleNotificationsForFollowedAthletes(_ athletes: [Athlete], meets: [Meet]) {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        for meet in meets where meet.date >= today && meet.date < tomorrow {
            for event in meet.events {
                guard shouldNotifyFor(eventDiscipline: event.discipline) else { continue }
                guard shouldSendForFrequency(meetDate: meet.date) else { continue }
                let athleteIDs = Set(event.results.map { $0.athleteID })
                for athlete in athletes where athlete.isFollowing && athleteIDs.contains(athlete.id) {
                    scheduleCompetingTodayNotification(athlete: athlete, eventName: event.name)
                }
            }
        }
    }

    func isAthleteAlertEnabled(athleteID: String) -> Bool {
        !mutedAthleteAlertIDs.contains(athleteID)
    }

    func setAthleteAlertEnabled(athleteID: String, enabled: Bool) {
        var muted = mutedAthleteAlertIDs
        if enabled {
            muted.remove(athleteID)
        } else {
            muted.insert(athleteID)
        }
        mutedAthleteAlertIDs = muted
    }
    
    func scheduleMeetReminder(meet: Meet) {
        guard notificationsEnabled else { return }
        let content = UNMutableNotificationContent()
        content.title = "\(meet.name) starts soon"
        content.body = "Get ready to watch at \(meet.location)"
        content.sound = .default
        
        let timeInterval = meet.date.timeIntervalSinceNow - 3600 // 1 hour before
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, timeInterval), repeats: false)
        let request = UNNotificationRequest(identifier: meet.id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule meet reminder: \(error)")
            }
        }
    }

    func scheduleEventReminder(event: Event, meet: Meet) {
        guard notificationsEnabled else { return }
        let content = UNMutableNotificationContent()
        content.title = "\(event.name) starts soon"
        content.body = "\(meet.name) • \(meet.location)"
        content.sound = .default

        let triggerDate = event.scheduledTime.addingTimeInterval(-3600)
        let trigger: UNNotificationTrigger
        if triggerDate > Date() {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        } else {
            // If event is too close, fire soon so the user still gets value.
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        }

        let request = UNNotificationRequest(
            identifier: reminderIdentifier(for: event.id),
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                print("Failed to schedule event reminder: \(error)")
            } else {
                self?.setEventReminderEnabled(eventID: event.id, enabled: true)
            }
        }
    }

    func cancelEventReminder(eventID: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderIdentifier(for: eventID)])
        setEventReminderEnabled(eventID: eventID, enabled: false)
    }

    func isEventReminderEnabled(eventID: String) -> Bool {
        eventReminderIDs.contains(eventID)
    }

    private func reminderIdentifier(for eventID: String) -> String {
        "\(eventReminderPrefix)\(eventID)"
    }

    private var eventReminderIDs: Set<String> {
        get { Set(UserDefaults.standard.stringArray(forKey: eventReminderStoreKey) ?? []) }
        set { UserDefaults.standard.set(Array(newValue), forKey: eventReminderStoreKey) }
    }

    private func setEventReminderEnabled(eventID: String, enabled: Bool) {
        var ids = eventReminderIDs
        if enabled {
            ids.insert(eventID)
        } else {
            ids.remove(eventID)
        }
        eventReminderIDs = ids
    }

    private var notificationsEnabled: Bool {
        if UserDefaults.standard.object(forKey: notificationsEnabledKey) == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: notificationsEnabledKey)
    }

    private var mutedAthleteAlertIDs: Set<String> {
        get { Set(UserDefaults.standard.stringArray(forKey: mutedAthleteAlertsKey) ?? []) }
        set { UserDefaults.standard.set(Array(newValue), forKey: mutedAthleteAlertsKey) }
    }

    private var notificationFrequency: NotificationFrequency {
        let raw = UserDefaults.standard.string(forKey: notificationFrequencyKey) ?? NotificationFrequency.medium.rawValue
        return NotificationFrequency(rawValue: raw) ?? .medium
    }

    private func shouldSendForFrequency(meetDate: Date) -> Bool {
        switch notificationFrequency {
        case .high:
            return true
        case .medium:
            return true
        case .low:
            let hours = meetDate.timeIntervalSinceNow / 3600
            return hours <= 24
        }
    }

    private func shouldNotifyFor(eventName: String) -> Bool {
        let lower = eventName.lowercased()
        if lower.contains("hurdle") {
            return shouldNotifyFor(eventDiscipline: "hurdles")
        }
        if lower.contains("100m") || lower.contains("200m") || lower.contains("400m") {
            return shouldNotifyFor(eventDiscipline: "sprints")
        }
        if lower.contains("800m") || lower.contains("1500m") || lower.contains("5000m") || lower.contains("10000m") || lower.contains("marathon") {
            return shouldNotifyFor(eventDiscipline: "distance")
        }
        if lower.contains("vault") || lower.contains("jump") || lower.contains("throw") {
            return shouldNotifyFor(eventDiscipline: "field")
        }
        return true
    }

    private func shouldNotifyFor(eventDiscipline: String) -> Bool {
        let lower = eventDiscipline.lowercased()
        if lower.contains("hurd") {
            return bool(forKey: notifyHurdlesKey, defaultValue: true)
        }
        if lower.contains("sprint") || lower == "100m" || lower == "200m" || lower == "400m" {
            return bool(forKey: notifySprintsKey, defaultValue: true)
        }
        if lower.contains("distance") || lower.contains("800") || lower.contains("1500") || lower.contains("5000") || lower.contains("10000") || lower.contains("marathon") {
            return bool(forKey: notifyDistanceKey, defaultValue: true)
        }
        if lower.contains("field") || lower.contains("vault") || lower.contains("jump") || lower.contains("throw") {
            return bool(forKey: notifyFieldKey, defaultValue: true)
        }
        return true
    }

    private func bool(forKey key: String, defaultValue: Bool) -> Bool {
        if UserDefaults.standard.object(forKey: key) == nil {
            return defaultValue
        }
        return UserDefaults.standard.bool(forKey: key)
    }

    func resetNotificationPreferences() {
        let defaults = UserDefaults.standard
        [
            eventReminderStoreKey,
            notificationsEnabledKey,
            mutedAthleteAlertsKey,
            notificationFrequencyKey,
            notifySprintsKey,
            notifyHurdlesKey,
            notifyDistanceKey,
            notifyFieldKey
        ].forEach { defaults.removeObject(forKey: $0) }

        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
