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
    private let notificationDeliveryModeKey = "athena.notificationDeliveryMode"
    private let notificationCooldownStoreKey = "athena.notificationCooldownStore"
    private let apiBaseURLKey = "athena.apiBaseURL"

    enum NotificationFrequency: String {
        case low, medium, high
    }

    enum NotificationDeliveryMode: String {
        case local
        case backend
    }
    
    private init() {}

    static let sourceCitationText = "Sources: World Athletics • FloTrack • Track & Field News • LA28"

    private var deliveryMode: NotificationDeliveryMode {
        let raw = UserDefaults.standard.string(forKey: notificationDeliveryModeKey) ?? NotificationDeliveryMode.local.rawValue
        return NotificationDeliveryMode(rawValue: raw) ?? .local
    }

    private var apiBaseURL: URL? {
        let raw = UserDefaults.standard.string(forKey: apiBaseURLKey) ?? "http://localhost:8080"
        return URL(string: raw)
    }

    private var session: URLSession {
        URLSession.shared
    }
    
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
        guard shouldSendNotification(identifier: "result-\(result.id)", cooldown: 10 * 60) else { return }

        if deliveryMode == .backend {
            queueBackendNotification(
                title: "\(athlete.name) just competed!",
                body: "\(result.placement)th place in \(result.eventName)",
                identifier: "result-\(result.id)",
                type: "athlete_result",
                cooldownSeconds: Int(10 * 60)
            )
            return
        }

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
        let identifier = "competing-\(athlete.id)-\(eventName.lowercased())"
        guard shouldSendNotification(identifier: identifier, cooldown: 6 * 3600) else { return }

        if deliveryMode == .backend {
            queueBackendNotification(
                title: "\(athlete.name) competes today",
                body: "\(eventName) — tap to follow along.",
                identifier: identifier,
                type: "athlete_competing_today",
                cooldownSeconds: Int(6 * 3600)
            )
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "\(athlete.name) competes today"
        content.body = "\(eventName) — tap to follow along."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier,
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
        let identifier = "meet-\(meet.id)"
        guard shouldSendNotification(identifier: identifier, cooldown: 8 * 3600) else { return }

        if deliveryMode == .backend {
            queueBackendNotification(
                title: "\(meet.name) starts soon",
                body: "Get ready to watch at \(meet.location)",
                identifier: identifier,
                type: "meet_reminder",
                cooldownSeconds: Int(8 * 3600)
            )
            return
        }

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
        let identifier = reminderIdentifier(for: event.id)
        guard shouldSendNotification(identifier: identifier, cooldown: 10 * 60) else { return }

        if deliveryMode == .backend {
            queueBackendNotification(
                title: "\(event.name) starts soon",
                body: "\(meet.name) • \(meet.location)",
                identifier: identifier,
                type: "event_reminder",
                cooldownSeconds: Int(10 * 60)
            )
            setEventReminderEnabled(eventID: event.id, enabled: true)
            return
        }

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
            identifier: identifier,
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

    private var cooldownStore: [String: TimeInterval] {
        get { UserDefaults.standard.dictionary(forKey: notificationCooldownStoreKey) as? [String: TimeInterval] ?? [:] }
        set { UserDefaults.standard.set(newValue, forKey: notificationCooldownStoreKey) }
    }

    private func shouldSendNotification(identifier: String, cooldown: TimeInterval) -> Bool {
        let now = Date().timeIntervalSince1970
        let store = cooldownStore
        if let lastSent = store[identifier], now - lastSent < cooldown {
            return false
        }
        var updated = store
        updated[identifier] = now
        cooldownStore = updated
        return true
    }

    private func queueBackendNotification(
        title: String,
        body: String,
        identifier: String,
        type: String,
        cooldownSeconds: Int
    ) {
        Task {
            guard let base = apiBaseURL else {
                print("Failed to queue backend notification: invalid base URL")
                return
            }

            let endpoint = base.appendingPathComponent("notifications/queue")
            var request = URLRequest(url: endpoint)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let payload = BackendNotificationQueueRequest(
                id: identifier,
                type: type,
                title: title,
                body: body,
                scheduledFor: ISO8601DateFormatter().string(from: Date()),
                cooldownSeconds: cooldownSeconds,
                userContext: .init(
                    followedAthleteId: nil,
                    eventGroup: inferEventGroup(from: "\(title) \(body)"),
                    frequency: notificationFrequency.rawValue
                ),
                analytics: nil
            )

            do {
                request.httpBody = try JSONEncoder().encode(payload)
                let (_, response) = try await session.data(for: request)
                if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                    print("Failed to queue backend notification: status \(http.statusCode)")
                }
            } catch {
                print("Failed to queue backend notification: \(error.localizedDescription)")
            }
        }
    }

    private func inferEventGroup(from text: String) -> String {
        let lower = text.lowercased()
        if lower.contains("hurd") {
            return "hurdles"
        }
        if lower.contains("100m") || lower.contains("200m") || lower.contains("400m") || lower.contains("sprint") {
            return "sprints"
        }
        if lower.contains("800m") || lower.contains("1500m") || lower.contains("5000m") || lower.contains("10000m") || lower.contains("marathon") {
            return "distance"
        }
        if lower.contains("vault") || lower.contains("jump") || lower.contains("throw") || lower.contains("field") {
            return "field"
        }
        return "mixed"
    }

    /// Trigger a notification with an associated analytics signal (e.g. Breakout Priority, Must Watch).
    /// Routes through backend queue when `deliveryMode == .backend`, falls back to local.
    func scheduleAnalyticsAlert(
        title: String,
        body: String,
        identifier: String,
        feature: String,
        score: Int,
        band: String,
        cooldownSeconds: Int = 3 * 3600
    ) {
        guard notificationsEnabled else { return }
        guard shouldSendNotification(identifier: identifier, cooldown: TimeInterval(cooldownSeconds)) else { return }

        if deliveryMode == .backend {
            Task {
                guard let base = apiBaseURL else { return }
                let endpoint = base.appendingPathComponent("notifications/queue")
                var request = URLRequest(url: endpoint)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let payload = BackendNotificationQueueRequest(
                    id: identifier,
                    type: "analytics_alert",
                    title: title,
                    body: body,
                    scheduledFor: ISO8601DateFormatter().string(from: Date()),
                    cooldownSeconds: cooldownSeconds,
                    userContext: .init(
                        followedAthleteId: nil,
                        eventGroup: "mixed",
                        frequency: notificationFrequency.rawValue
                    ),
                    analytics: .init(feature: feature, score: score, band: band)
                )
                do {
                    request.httpBody = try JSONEncoder().encode(payload)
                    let (_, response) = try await session.data(for: request)
                    if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                        print("Analytics alert queue failed: status \(http.statusCode)")
                    }
                } catch {
                    print("Analytics alert queue error: \(error.localizedDescription)")
                }
            }
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        ) { error in
            if let error { print("Analytics alert local schedule error: \(error)") }
        }
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
            notifyFieldKey,
            notificationDeliveryModeKey,
            notificationCooldownStoreKey
        ].forEach { defaults.removeObject(forKey: $0) }

        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

private struct BackendNotificationQueueRequest: Codable {
    let id: String
    let type: String
    let title: String
    let body: String
    let scheduledFor: String
    let cooldownSeconds: Int
    let userContext: UserContext
    let analytics: AnalyticsContext?

    struct UserContext: Codable {
        let followedAthleteId: String?
        let eventGroup: String
        let frequency: String
    }

    struct AnalyticsContext: Codable {
        let feature: String
        let score: Int
        let band: String
    }
}
