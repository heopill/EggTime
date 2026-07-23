//
//  TimerFeature.swift
//  EggTimer
//

import Foundation
import ComposableArchitecture

@Reducer
struct TimerFeature {
    @ObservableState
    struct State: Equatable {
        var selectedTab: Tab = .timer
        var selectedEgg: EggDoneness = .one
        var cookingState: CookingState = .idle
        var remainingSeconds: Int = EggDoneness.one.duration
        // 타이머가 끝나는 목표 시각 (진행 중일 때만 값이 있음)
        var deadline: Date?
        var isResetAlertPresented: Bool = false
        var recipe = RecipeFeature.State()
        var setting = SettingFeature.State()

        // 진행 중 여부 (버튼/타이틀 전환에 사용)
        var isRunning: Bool {
            return cookingState == .running
        }

        // 타이틀을 Primary 색상으로 강조할지 여부 (진행 중 · 완료)
        var isTitleHighlighted: Bool {
            return cookingState == .running || cookingState == .completed
        }

        // 상단 타이틀
        var title: String {
            switch cookingState {
            case .idle: return String(localized: "Press the start button", table: "Timer")
            case .running: return String(localized: "Your egg is cooking!", table: "Timer")
            case .paused: return String(localized: "You can resume boiling", table: "Timer")
            case .completed: return String(localized: "Your egg is perfectly boiled!", table: "Timer")
            }
        }

        // MM:SS 형태의 남은 시간
        var timeText: String {
            return String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
        }
    }

    // 조리 상태
    enum CookingState: Equatable {
        case idle      // 시작 전
        case running   // 진행 중
        case paused    // 일시정지
        case completed // 완료
    }

    nonisolated enum Tab: Equatable, Sendable {
        case timer
        case recipe
        case setting
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case startTapped
        case pauseTapped
        case resumeTapped
        case restartTapped
        case resetTapped
        case resetConfirmed
        case resetCancelled
        case timerTicked
        case recipe(RecipeFeature.Action)
        case setting(SettingFeature.Action)
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.date) var date
    @Dependency(\.notifications) var notifications
    @Dependency(\.timerPersistence) var persistence
    @Dependency(\.soundSettings) var soundSettings

    nonisolated private enum CancelID {
        case timer
    }

    // 일시정지 상태를 복원할 수 있는 최대 시간 (1시간). 이 시간을 넘기면 만료 처리한다
    private static let pausedExpiration: TimeInterval = 60 * 60

    // 하위 리듀서(BindingReducer, Scope)를 조합하므로 반환 타입은 some Reducer<State, Action>를 사용한다
    var body: some Reducer<State, Action> {
        BindingReducer()

        Scope(state: \.recipe, action: \.recipe) {
            RecipeFeature()
        }
        Scope(state: \.setting, action: \.setting) {
            SettingFeature()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                // 앱 첫 실행 시 알림 권한을 요청한다 (이미 응답했다면 프롬프트는 다시 뜨지 않음)
                let authEffect: Effect<Action> = .run { [notifications] _ in
                    _ = await notifications.requestAuthorization()
                }

                // 저장된(강제 종료 전) 타이머가 있으면 복원한다
                guard let saved = persistence.load() else {
                    return authEffect
                }
                state.selectedEgg = EggDoneness(rawValue: saved.eggRawValue) ?? state.selectedEgg

                if let deadline = saved.deadline {
                    // 진행 중이던 타이머
                    let remaining = remainingSeconds(until: deadline)
                    state.remainingSeconds = remaining
                    state.cookingState = .running

                    guard remaining > 0 else {
                        // 앱이 꺼진 사이 이미 완료됨
                        state.deadline = nil
                        state.cookingState = .completed

                        return .merge(authEffect, .run { [persistence] _ in persistence.clear() })
                    }
                    state.deadline = deadline

                    return .merge(authEffect, startTimer())
                } else {
                    // 일시정지 상태이던 타이머
                    // 일시정지 후 1시간이 지났으면 복원하지 않고 초기화한다
                    if let pausedAt = saved.pausedAt,
                       date.now.timeIntervalSince(pausedAt) > Self.pausedExpiration {
                        state.remainingSeconds = state.selectedEgg.duration

                        return .merge(authEffect, .run { [persistence] _ in persistence.clear() })
                    }
                    state.remainingSeconds = saved.remainingSeconds
                    state.cookingState = .paused

                    return authEffect
                }

            case .binding(\.selectedEgg):
                // 달걀을 바꾸면(스와이프) 진행 중이 아닐 때 타이머 시간을 새 달걀 기준으로 갱신한다
                if !state.isRunning {
                    state.remainingSeconds = state.selectedEgg.duration
                }

                return .none

            case .binding:
                return .none

            case .startTapped:
                state.cookingState = .running
                // 현재 남은 시간을 기준으로 목표 종료 시각을 정한다
                state.deadline = date.now.addingTimeInterval(TimeInterval(state.remainingSeconds))

                return .merge(startTimer(), saveEffect(state), scheduleNotificationEffect(after: state.remainingSeconds))

            case .pauseTapped:
                // 카운트다운을 멈추고 일시정지 상태로 전환한다 (남은 시간을 정확히 계산해 유지)
                if let deadline = state.deadline {
                    state.remainingSeconds = remainingSeconds(until: deadline)
                }
                state.cookingState = .paused
                state.deadline = nil

                return .merge(.cancel(id: CancelID.timer), saveEffect(state), cancelNotificationEffect())

            case .resumeTapped:
                // 일시정지된 지점의 남은 시간으로 목표 종료 시각을 다시 계산한다
                state.cookingState = .running
                state.deadline = date.now.addingTimeInterval(TimeInterval(state.remainingSeconds))

                return .merge(startTimer(), saveEffect(state), scheduleNotificationEffect(after: state.remainingSeconds))

            case .restartTapped:
                // 완료된 타이머를 선택한 달걀 기준 시간으로 처음부터 다시 시작한다
                state.remainingSeconds = state.selectedEgg.duration
                state.cookingState = .running
                state.deadline = date.now.addingTimeInterval(TimeInterval(state.remainingSeconds))

                return .merge(startTimer(), saveEffect(state), scheduleNotificationEffect(after: state.remainingSeconds))

            case .resetTapped:
                // 초기화 확인 알럿을 띄운다
                state.isResetAlertPresented = true

                return .none

            case .resetConfirmed:
                // 시간을 초기화하고 시작 전 상태로 돌아간다
                state.remainingSeconds = state.selectedEgg.duration
                state.cookingState = .idle
                state.deadline = nil
                state.isResetAlertPresented = false

                return .merge(.cancel(id: CancelID.timer), clearEffect(), cancelNotificationEffect())

            case .resetCancelled:
                // 알럿만 닫고 현재 상태를 유지한다
                state.isResetAlertPresented = false

                return .none

            case .timerTicked:
                // 남은 시간을 목표 종료 시각 기준으로 다시 계산한다 (백그라운드 경과 시간도 반영)
                guard let deadline = state.deadline else {
                    return .cancel(id: CancelID.timer)
                }
                state.remainingSeconds = remainingSeconds(until: deadline)

                guard state.remainingSeconds > 0 else {
                    state.deadline = nil
                    state.cookingState = .completed

                    return .merge(.cancel(id: CancelID.timer), clearEffect())
                }

                return .none

            case .recipe, .setting:
                return .none
            }
        }
    }

    // 현재 타이머 상태를 UserDefaults에 저장하는 이펙트
    private func saveEffect(_ state: State) -> Effect<Action> {
        let snapshot = TimerSnapshot(
            eggRawValue: state.selectedEgg.rawValue,
            remainingSeconds: state.remainingSeconds,
            deadline: state.deadline,
            pausedAt: state.cookingState == .paused ? date.now : nil
        )

        return .run { [persistence] _ in
            persistence.save(snapshot)
        }
    }

    // 저장된 타이머 상태를 지우는 이펙트
    private func clearEffect() -> Effect<Action> {
        return .run { [persistence] _ in
            persistence.clear()
        }
    }

    // 완료 알림을 예약하는 이펙트 (사운드 모드에 따라 알림음 유무를, 종료음 설정에 따라 알림음 종류를 결정)
    private func scheduleNotificationEffect(after seconds: Int) -> Effect<Action> {
        let playSound = soundSettings.load().playsSound
        let soundName = soundSettings.loadEndSound().fileName

        return .run { [notifications] _ in
            await notifications.scheduleCompletion(TimeInterval(seconds), playSound, soundName)
        }
    }

    // 예약된 완료 알림을 취소하는 이펙트
    private func cancelNotificationEffect() -> Effect<Action> {
        return .run { [notifications] _ in
            notifications.cancel()
        }
    }

    // 목표 종료 시각까지 남은 초를 계산한다 (올림 처리)
    private func remainingSeconds(until deadline: Date) -> Int {
        let remaining = deadline.timeIntervalSince(date.now)

        return max(0, Int(remaining.rounded(.up)))
    }

    // 1초마다 timerTicked를 보내는 카운트다운 이펙트
    private func startTimer() -> Effect<Action> {
        return .run { [clock] send in
            for await _ in clock.timer(interval: .seconds(1)) {
                await send(.timerTicked)
            }
        }
        .cancellable(id: CancelID.timer, cancelInFlight: true)
    }
}
