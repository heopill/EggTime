//
//  AppLanguage.swift
//  EggTimer
//

import Foundation

// 앱에서 사용할 언어
enum AppLanguage: String, CaseIterable, Codable, Equatable, Sendable {
    case system  // 시스템 언어
    case korean  // 한국어
    case english // English

    // 설정 화면에 표시할 이름
    var title: String {
        switch self {
        case .system: return String(localized: "appLanguageSystem", table: "Setting")
        case .korean: return String(localized: "appLanguageKorean", table: "Setting")
        case .english: return String(localized: "appLanguageEnglish", table: "Setting")
        }
    }

    // AppleLanguages에 저장할 언어 코드 (시스템 언어는 저장하지 않는다)
    nonisolated var languageCode: String? {
        switch self {
        case .system: return nil
        case .korean: return "ko"
        case .english: return "en"
        }
    }
}

extension AppLanguage {
    // 앱 도메인에 저장되는 언어 우선순위 키 (iOS 설정 > 앱 > 언어와 같은 값을 공유한다)
    nonisolated private static let storageKey = "AppleLanguages"

    // 현재 앱에 지정된 언어 (앱 도메인에 값이 없으면 시스템 언어를 따른다)
    nonisolated static var current: AppLanguage {
        guard let bundleID = Bundle.main.bundleIdentifier,
              let languages = UserDefaults.standard.persistentDomain(forName: bundleID)?[storageKey] as? [String],
              let first = languages.first else {
            return .system
        }

        if first.hasPrefix("ko") { return .korean }
        if first.hasPrefix("en") { return .english }

        return .system
    }

    // 앱 언어를 저장한다 (다음 실행부터 적용된다)
    nonisolated static func save(_ language: AppLanguage) {
        if let code = language.languageCode {
            UserDefaults.standard.set([code], forKey: storageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: storageKey)
        }
    }
}
