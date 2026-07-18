//
//  NotificationClient.swift
//  EggTimer
//

import ComposableArchitecture
import UserNotifications

// 로컬 알림 관련 시스템 기능을 감싼다
struct NotificationClient: Sendable {
    // 알림 권한을 요청하고 허용 여부를 반환한다
    var requestAuthorization: @Sendable () async -> Bool
    // 타이머 완료 알림을 지정한 시간(초) 뒤에 예약한다
    var scheduleCompletion: @Sendable (_ after: TimeInterval) async -> Void
    // 예약된 타이머 완료 알림을 취소한다
    var cancel: @Sendable () -> Void
}

extension NotificationClient: DependencyKey {
    static let liveValue = NotificationClient(
        requestAuthorization: {
            let center = UNUserNotificationCenter.current()

            return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        },
        scheduleCompletion: { after in
            let content = UNMutableNotificationContent()
            content.title = String(localized: "EggTime", table: "Timer")
            content.body = String(localized: "Your egg is perfectly boiled!", table: "Timer")
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, after), repeats: false)
            let request = UNNotificationRequest(
                identifier: "timerCompletion",
                content: content,
                trigger: trigger
            )

            try? await UNUserNotificationCenter.current().add(request)
        },
        cancel: {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timerCompletion"])
        }
    )

    static let previewValue = NotificationClient(
        requestAuthorization: { true },
        scheduleCompletion: { _ in },
        cancel: {}
    )
    static let testValue = previewValue
}

extension DependencyValues {
    var notifications: NotificationClient {
        get { self[NotificationClient.self] }
        set { self[NotificationClient.self] = newValue }
    }
}
