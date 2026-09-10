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
    // 완료 후 30분 뒤 Activity를 자동 종료하는 예약 작업
    private var autoEndTask: Task<Void, Never>?

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

    // 완료 상태(00:00)로 전환하고 다이나믹 아일랜드에 완료 디자인을 계속 표시한다.
    // end가 아니라 update를 쓰는 이유: 다이나믹 아일랜드는 진행 중(active) Activity만 표시하므로,
    // end를 호출하면 완료 디자인이 곧바로 사라진다. 30분 뒤 자동 종료를 별도로 예약한다.
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

        // 완료 디자인을 유지한 채 Activity를 살려둔다 (다이나믹 아일랜드에 계속 표시)
        await activity.update(content)

        // 30분 뒤 자동으로 종료한다. 그 전에 사용자가 잠금화면에서 지우면 같은 Activity라 함께 사라지고,
        // 이 예약 작업은 남은 Activity가 없어 빈 동작이 된다
        autoEndTask?.cancel()
        autoEndTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(Self.completedDismissDelay))
            guard !Task.isCancelled else {
                return
            }
            await self?.endAll()
        }
    }

    // 실행 중인 Live Activity를 모두 즉시 종료한다
    func endAll() async {
        autoEndTask?.cancel()
        autoEndTask = nil

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
