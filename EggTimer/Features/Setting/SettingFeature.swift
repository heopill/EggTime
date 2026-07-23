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
        // 선택된 사운드 모드 (UserDefaults가 원본, 이 값은 화면 표시용 사본)
        var soundMode: SoundMode = .vibrationAndSound
        // 현재 시스템 알림 권한 허용 여부 (알림 화면 라디오 표시용)
        var isNotificationAuthorized: Bool = false
        // 선택된 타이머 종료음 (UserDefaults가 원본, 이 값은 화면 표시용 사본)
        var timerEndSound: TimerEndSound = .fanfare
        // 앱스토어에서 조회한 최신 버전 정보 (미배포/조회 실패 시 nil)
        var appStoreLookup: AppStoreLookup?
    }

    // 설정 메뉴에서 이동할 수 있는 하위 화면들
    nonisolated enum Route: Hashable, Sendable {
        case notification
        case soundMode
        case timerEndSound
        case appInfo
        case privacyPolicy
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case notificationTapped
        case notificationStatusRequested
        case notificationStatusLoaded(Bool)
        case soundModeTapped
        case soundModeSelected(SoundMode)
        case timerEndSoundTapped
        case timerEndSoundSelected(TimerEndSound)
        case appInfoTapped
        case appStoreVersionRequested
        case appStoreVersionLoaded(AppStoreLookup?)
        case privacyPolicyTapped
        case backTapped
    }

    @Dependency(\.soundSettings) var soundSettings
    @Dependency(\.notifications) var notifications
    @Dependency(\.appStore) var appStore

    var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                // 저장된 사운드 모드와 종료음을 불러와 반영한다
                state.soundMode = soundSettings.load()
                state.timerEndSound = soundSettings.loadEndSound()

                return .none

            case .notificationTapped:
                state.path.append(.notification)

                return .none

            case .notificationStatusRequested:
                // 현재 시스템 알림 권한 상태를 읽어와 라디오 기본값에 반영한다
                return .run { [notifications] send in
                    let authorized = await notifications.isAuthorized()
                    await send(.notificationStatusLoaded(authorized))
                }

            case let .notificationStatusLoaded(authorized):
                state.isNotificationAuthorized = authorized

                return .none

            case .soundModeTapped:
                state.path.append(.soundMode)

                return .none

            case let .soundModeSelected(mode):
                state.soundMode = mode

                return .run { [soundSettings] _ in
                    soundSettings.save(mode)
                }

            case .timerEndSoundTapped:
                state.path.append(.timerEndSound)

                return .none

            case let .timerEndSoundSelected(sound):
                state.timerEndSound = sound

                return .run { [soundSettings] _ in
                    soundSettings.saveEndSound(sound)
                }

            case .appInfoTapped:
                state.path.append(.appInfo)

                return .none

            case .appStoreVersionRequested:
                // 앱스토어의 최신 버전을 조회한다
                return .run { [appStore] send in
                    let lookup = await appStore.lookup()
                    await send(.appStoreVersionLoaded(lookup))
                }

            case let .appStoreVersionLoaded(lookup):
                state.appStoreLookup = lookup

                return .none

            case .privacyPolicyTapped:
                state.path.append(.privacyPolicy)

                return .none

            case .backTapped:
                _ = state.path.popLast()

                return .none

            case .binding:
                return .none
            }
        }
    }
}
