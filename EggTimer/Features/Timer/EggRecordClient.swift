//
//  EggRecordClient.swift
//  EggTimer
//

import ComposableArchitecture
import Foundation
import WidgetKit

// 타이머 완료를 에그타임 기록에 반영하고 위젯을 갱신하는 클라이언트
struct EggRecordClient: Sendable {
    // 완료를 기록한다 (isHardBoiled: 완숙(4단계) 여부)
    var recordCompletion: @Sendable (_ isHardBoiled: Bool) -> Void
}

extension EggRecordClient: DependencyKey {
    static let liveValue = EggRecordClient(
        recordCompletion: { isHardBoiled in
            EggRecordStore.recordCompletion(isHardBoiled: isHardBoiled)

            // 저장 직후 홈 화면 위젯을 새로고침한다
            WidgetCenter.shared.reloadAllTimelines()
        }
    )

    static let testValue = EggRecordClient(
        recordCompletion: { _ in }
    )

    static let previewValue = testValue
}

extension DependencyValues {
    var eggRecord: EggRecordClient {
        get { self[EggRecordClient.self] }
        set { self[EggRecordClient.self] = newValue }
    }
}
