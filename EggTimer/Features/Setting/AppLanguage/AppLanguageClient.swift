//
//  AppLanguageClient.swift
//  EggTimer
//

import ComposableArchitecture

// 앱 언어 설정을 저장/로드한다
struct AppLanguageClient: Sendable {
    // 현재 지정된 앱 언어를 읽어온다
    var load: @Sendable () -> AppLanguage
    // 앱 언어를 저장한다
    var save: @Sendable (AppLanguage) -> Void
}

extension AppLanguageClient: DependencyKey {
    static let liveValue = AppLanguageClient(
        load: { AppLanguage.current },
        save: { AppLanguage.save($0) }
    )

    static let previewValue = AppLanguageClient(
        load: { .system },
        save: { _ in }
    )
    static let testValue = previewValue
}

extension DependencyValues {
    var appLanguage: AppLanguageClient {
        get { self[AppLanguageClient.self] }
        set { self[AppLanguageClient.self] = newValue }
    }
}
