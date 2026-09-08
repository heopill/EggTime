//
//  LiveActivityClient.swift
//  EggTimer
//

import ActivityKit
import ComposableArchitecture
import Foundation

// 다이나믹 아일랜드 / 잠금화면 Live Activity를 제어하는 기능을 감싼다
struct LiveActivityClient: Sendable {
    // 진행 중 Live Activity를 시작한다 (기존 활동이 있으면 정리 후 새로 시작)
    var start: @Sendable (_ startDate: Date, _ deadline: Date) async -> Void
    // 완료 상태(00:00)로 전환한다
    var complete: @Sendable () async -> Void
    // Live Activity를 화면에서 제거한다
    var end: @Sendable () async -> Void
}

// 실행 중인 Activity 참조와 표시 시각을 보관하는 저장소
private actor ActivityStore {
    private var activity: Activity<EggTimerWidgetAttributes>?
    private var startDate: Date = .now
    private var deadline: Date = .now

    // 완료 배너를 유지한 뒤 자동으로 사라지게 하는 시간 (30분)
    private static let completedDismissDelay: TimeInterval = 60 * 30

    // 진행 중 Live Activity를 시작한다
    func start(startDate: Date, deadline: Date) async {
        // 시스템 설정에서 Live Activity가 꺼져 있으면 아무것도 하지 않는다
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return
        }
        // 이전에 남아 있던 활동(앱 재실행 시의 잔여 포함)을 모두 정리한다
        await endAll()

        self.startDate = startDate
        self.deadline = deadline

        let state = EggTimerWidgetAttributes.ContentState(
            startDate: startDate,
            deadline: deadline,
            isCompleted: false
        )
        let content = ActivityContent(state: state, staleDate: deadline)

        activity = try? Activity.request(
            attributes: EggTimerWidgetAttributes(),
            content: content,
            pushType: nil
        )
    }

    // 완료 상태(00:00)로 전환하고, 일정 시간 뒤 자동으로 사라지도록 종료 예약한다
    func complete() async {
        guard let activity else {
            return
        }
        let state = EggTimerWidgetAttributes.ContentState(
            startDate: startDate,
            deadline: deadline,
            isCompleted: true
        )
        let content = ActivityContent(state: state, staleDate: nil)
        let dismissDate = Date().addingTimeInterval(Self.completedDismissDelay)

        // 완료 디자인을 최종 상태로 보여준 뒤 지정 시각에 자동 제거한다
        await activity.end(content, dismissalPolicy: .after(dismissDate))
        self.activity = nil
    }

    // 실행 중인 Live Activity를 모두 즉시 종료한다
    func endAll() async {
        for activity in Activity<EggTimerWidgetAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        activity = nil
    }
}

extension LiveActivityClient: DependencyKey {
    static let liveValue: LiveActivityClient = {
        let store = ActivityStore()

        return LiveActivityClient(
            start: { startDate, deadline in
                await store.start(startDate: startDate, deadline: deadline)
            },
            complete: {
                await store.complete()
            },
            end: {
                await store.endAll()
            }
        )
    }()

    static let previewValue = LiveActivityClient(
        start: { _, _ in },
        complete: {},
        end: {}
    )
    static let testValue = previewValue
}

extension DependencyValues {
    var liveActivity: LiveActivityClient {
        get { self[LiveActivityClient.self] }
        set { self[LiveActivityClient.self] = newValue }
    }
}
