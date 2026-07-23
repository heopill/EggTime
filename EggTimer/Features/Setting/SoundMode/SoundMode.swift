//
//  SoundMode.swift
//  EggTimer
//

import Foundation

// 타이머 완료 시 알림 방식
enum SoundMode: String, CaseIterable, Codable, Equatable, Sendable {
    case vibration         // 진동
    case sound             // 소리
    case vibrationAndSound // 진동 및 소리
    case off               // 끄기

    // 설정 화면에 표시할 이름
    var title: String {
        switch self {
        case .vibration: return String(localized: "Vibration", table: "Setting")
        case .sound: return String(localized: "Sound", table: "Setting")
        case .vibrationAndSound: return String(localized: "Vibration and Sound", table: "Setting")
        case .off: return String(localized: "Off", table: "Setting")
        }
    }

    // 소리를 재생하는 모드인지 여부
    var playsSound: Bool {
        return self == .sound || self == .vibrationAndSound
    }

    // 진동을 울리는 모드인지 여부
    var playsVibration: Bool {
        return self == .vibration || self == .vibrationAndSound
    }
}

extension SoundMode {
    // UserDefaults 저장 키
    nonisolated private static let storageKey = "soundMode"

    // 저장된 사운드 모드 (없으면 진동 및 소리를 기본값으로 사용)
    nonisolated static var current: SoundMode {
        guard let raw = UserDefaults.standard.string(forKey: storageKey),
              let mode = SoundMode(rawValue: raw) else {
            return .vibrationAndSound
        }

        return mode
    }

    // 사운드 모드를 저장한다
    nonisolated static func save(_ mode: SoundMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: storageKey)
    }
}
