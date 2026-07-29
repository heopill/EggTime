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
    // 현재 알림 권한이 허용 상태인지 반환한다
    var isAuthorized: @Sendable () async -> Bool
    // 타이머 완료 알림을 지정한 시간(초) 뒤에 예약한다
    // playSound가 false면 무음 알림, true면 soundName.wav를 알림음으로 사용한다
    var scheduleCompletion: @Sendable (_ after: TimeInterval, _ playSound: Bool, _ soundName: String) async -> Void
    // 예약된 타이머 완료 알림을 취소한다
    var cancel: @Sendable () -> Void
}

extension NotificationClient: DependencyKey {
    static let liveValue = NotificationClient(
        requestAuthorization: {
            let center = UNUserNotificationCenter.current()

            return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        },
        isAuthorized: {
            let settings = await UNUserNotificationCenter.current().notificationSettings()

            // 정식 허용과 임시(provisional) 허용을 켜짐으로 본다
            return settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
        },
        scheduleCompletion: { after, playSound, soundName in
            let content = UNMutableNotificationContent()
            content.title = String(localized: "EggTime", table: "Timer")
            content.body = String(localized: "Your egg is perfectly boiled!", table: "Timer")
            // 소리 모드에서만 선택된 종료음을 재생하고, 그 외에는 무음으로 예약한다
            content.sound = playSound ? UNNotificationSound(named: UNNotificationSoundName("\(soundName).wav")) : nil

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
        isAuthorized: { true },
        scheduleCompletion: { _, _, _ in },
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
