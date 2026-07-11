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
        var isResetAlertPresented: Bool = false
        var recipe = RecipeFeature.State()
        var setting = SettingFeature.State()

        // 진행 중 여부 (버튼/타이틀 전환에 사용)
        var isRunning: Bool {
            return cookingState == .running
        }

        // 상단 타이틀
        var title: String {
            switch cookingState {
            case .idle: return "시작 버튼을 눌러주세요"
            case .running: return "달걀이 익고 있어요!"
            case .paused: return "이어서 계속 삶을 수 있어요"
            }
        }

        // MM:SS 형태의 남은 시간
        var timeText: String {
            return String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
        }
    }

    // 조리 상태
    enum CookingState: Equatable {
        case idle    // 시작 전
        case running // 진행 중
        case paused  // 일시정지
    }

    nonisolated enum Tab: Equatable, Sendable {
        case timer
        case recipe
        case setting
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case startTapped
        case pauseTapped
        case resumeTapped
        case resetTapped
        case resetConfirmed
        case resetCancelled
        case timerTicked
        case recipe(RecipeFeature.Action)
        case setting(SettingFeature.Action)
    }

    @Dependency(\.continuousClock) var clock

    nonisolated private enum CancelID {
        case timer
    }

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

                return startTimer()

            case .pauseTapped:
                // 카운트다운을 멈추고 일시정지 상태로 전환한다 (남은 시간은 유지)
                state.cookingState = .paused

                return .cancel(id: CancelID.timer)

            case .resumeTapped:
                // 일시정지된 지점부터 카운트다운을 다시 시작한다
                state.cookingState = .running

                return startTimer()

            case .resetTapped:
                // 초기화 확인 알럿을 띄운다
                state.isResetAlertPresented = true

                return .none

            case .resetConfirmed:
                // 시간을 초기화하고 시작 전 상태로 돌아간다
                state.remainingSeconds = state.selectedEgg.duration
                state.cookingState = .idle
                state.isResetAlertPresented = false

                return .cancel(id: CancelID.timer)

            case .resetCancelled:
                // 알럿만 닫고 현재 상태를 유지한다
                state.isResetAlertPresented = false

                return .none

            case .timerTicked:
                guard state.remainingSeconds > 0 else {
                    return .cancel(id: CancelID.timer)
                }
                state.remainingSeconds -= 1

                return .none

            case .recipe, .setting:
                return .none
            }
        }
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
