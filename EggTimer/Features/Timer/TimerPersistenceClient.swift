//
//  TimerPersistenceClient.swift
//  EggTimer
//

import ComposableArchitecture
import Foundation

// 강제 종료 후 복원을 위해 저장하는 타이머 스냅샷
nonisolated struct TimerSnapshot: Codable, Equatable, Sendable {
    // 선택된 달걀 (EggDoneness rawValue)
    let eggRawValue: Int
    // 일시정지 상태 복원용 남은 시간
    let remainingSeconds: Int
    // 진행 중이면 목표 종료 시각, 일시정지면 nil
    let deadline: Date?
}

// 진행/일시정지 중인 타이머를 UserDefaults에 저장/복원한다
struct TimerPersistenceClient: Sendable {
    var save: @Sendable (TimerSnapshot) -> Void
    var load: @Sendable () -> TimerSnapshot?
    var clear: @Sendable () -> Void
}

extension TimerPersistenceClient: DependencyKey {
    static let liveValue = TimerPersistenceClient(
        save: { snapshot in
            guard let data = try? JSONEncoder().encode(snapshot) else { return }

            UserDefaults.standard.set(data, forKey: "runningTimerSnapshot")
        },
        load: {
            guard let data = UserDefaults.standard.data(forKey: "runningTimerSnapshot"),
                  let snapshot = try? JSONDecoder().decode(TimerSnapshot.self, from: data) else {
                return nil
            }

            return snapshot
        },
        clear: {
            UserDefaults.standard.removeObject(forKey: "runningTimerSnapshot")
        }
    )

    static let testValue = TimerPersistenceClient(
        save: { _ in },
        load: { nil },
        clear: {}
    )

    static let previewValue = testValue
}

extension DependencyValues {
    var timerPersistence: TimerPersistenceClient {
        get { self[TimerPersistenceClient.self] }
        set { self[TimerPersistenceClient.self] = newValue }
    }
}
