//
//  SoundSettingsClient.swift
//  EggTimer
//

import ComposableArchitecture

// 사운드 모드 · 타이머 종료음 설정을 저장/로드한다
struct SoundSettingsClient: Sendable {
    // 저장된 사운드 모드를 읽어온다
    var load: @Sendable () -> SoundMode
    // 사운드 모드를 저장한다
    var save: @Sendable (SoundMode) -> Void
    // 저장된 종료음을 읽어온다
    var loadEndSound: @Sendable () -> TimerEndSound
    // 종료음을 저장한다
    var saveEndSound: @Sendable (TimerEndSound) -> Void
}

extension SoundSettingsClient: DependencyKey {
    static let liveValue = SoundSettingsClient(
        load: { SoundMode.current },
        save: { SoundMode.save($0) },
        loadEndSound: { TimerEndSound.current },
        saveEndSound: { TimerEndSound.save($0) }
    )

    static let previewValue = SoundSettingsClient(
        load: { .vibrationAndSound },
        save: { _ in },
        loadEndSound: { .fanfare },
        saveEndSound: { _ in }
    )
    static let testValue = previewValue
}

extension DependencyValues {
    var soundSettings: SoundSettingsClient {
        get { self[SoundSettingsClient.self] }
        set { self[SoundSettingsClient.self] = newValue }
    }
}
