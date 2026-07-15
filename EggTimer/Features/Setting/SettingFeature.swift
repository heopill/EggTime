//
//  SettingFeature.swift
//  EggTimer
//

import ComposableArchitecture

@Reducer
struct SettingFeature {
    @ObservableState
    struct State: Equatable {
        // 설정 화면에서 밀어 넣은 하위 화면 경로
        var path: [Route] = []
    }

    // 설정 메뉴에서 이동할 수 있는 하위 화면들
    nonisolated enum Route: Hashable, Sendable {
        case soundMode
        case timerEndSound
        case appInfo
        case privacyPolicy
        case contact
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case soundModeTapped
        case timerEndSoundTapped
        case appInfoTapped
        case privacyPolicyTapped
        case contactTapped
    }

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .soundModeTapped:
                state.path.append(.soundMode)

                return .none

            case .timerEndSoundTapped:
                state.path.append(.timerEndSound)

                return .none

            case .appInfoTapped:
                state.path.append(.appInfo)

                return .none

            case .privacyPolicyTapped:
                state.path.append(.privacyPolicy)

                return .none

            case .contactTapped:
                state.path.append(.contact)

                return .none

            case .binding:
                return .none
            }
        }
    }
}
