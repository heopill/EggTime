//
//  SoundSettingsClient.swift
//  EggTimer
//

import ComposableArchitecture

// 사운드 모드 설정을 저장/로드한다
struct SoundSettingsClient: Sendable {
    // 저장된 사운드 모드를 읽어온다
    var load: @Sendable () -> SoundMode
    // 사운드 모드를 저장한다
    var save: @Sendable (SoundMode) -> Void
}

extension SoundSettingsClient: DependencyKey {
    static let liveValue = SoundSettingsClient(
        load: { SoundMode.current },
        save: { SoundMode.save($0) }
    )

    static let previewValue = SoundSettingsClient(
        load: { .vibrationAndSound },
        save: { _ in }
    )
    static let testValue = previewValue
}

extension DependencyValues {
    var soundSettings: SoundSettingsClient {
        get { self[SoundSettingsClient.self] }
        set { self[SoundSettingsClient.self] = newValue }
    }
}
