//
//  EggTimerWidgetAttributes.swift
//  EggTimer
//
//  앱(ActivityKit 요청)과 위젯(Live Activity UI)이 공유하는 Live Activity 속성 모델.
//  두 타겟(EggTimer, EggTimerWidgetExtension)에 모두 포함되어야 한다.
//

import ActivityKit
import Foundation

nonisolated struct EggTimerWidgetAttributes: ActivityAttributes {
    public nonisolated struct ContentState: Codable, Hashable {
        // 카운트다운 시작 시각
        var startDate: Date
        // 타이머가 끝나는 목표 시각
        var deadline: Date
        // 완료 여부 (진행중 / 완료 디자인 분기)
        var isCompleted: Bool
    }
}
