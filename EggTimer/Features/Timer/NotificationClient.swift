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
}

extension NotificationClient: DependencyKey {
    static let liveValue = NotificationClient(
        requestAuthorization: {
            let center = UNUserNotificationCenter.current()

            return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        }
    )

    static let previewValue = NotificationClient(requestAuthorization: { true })
    static let testValue = NotificationClient(requestAuthorization: { true })
}

extension DependencyValues {
    var notifications: NotificationClient {
        get { self[NotificationClient.self] }
        set { self[NotificationClient.self] = newValue }
    }
}
