//
//  TimerEndSound.swift
//  EggTimer
//

import Foundation

// 타이머 완료 시 재생할 종료음
enum TimerEndSound: String, CaseIterable, Codable, Equatable, Sendable {
    case crowing
    case ding
    case arcade
    case goodResult
    case success
    case yay
    case levelPassed
    case fanfare
    case notification

    // 번들에 포함된 wav 파일 이름 (확장자 제외, rawValue와 동일)
    var fileName: String {
        return rawValue
    }

    // 설정 화면에 표시할 이름
    var title: String {
        switch self {
        case .crowing: return String(localized: "Crowing", table: "Setting")
        case .ding: return String(localized: "Ding", table: "Setting")
        case .arcade: return String(localized: "Arcade", table: "Setting")
        case .goodResult: return String(localized: "Good Result", table: "Setting")
        case .success: return String(localized: "Success", table: "Setting")
        case .yay: return String(localized: "Yay", table: "Setting")
        case .levelPassed: return String(localized: "Level Passed", table: "Setting")
        case .fanfare: return String(localized: "Fanfare", table: "Setting")
        case .notification: return String(localized: "Notification", table: "Setting")
        }
    }
}

extension TimerEndSound {
    // UserDefaults 저장 키
    nonisolated private static let storageKey = "timerEndSound"

    // 저장된 종료음 (없으면 팡파레를 기본값으로 사용)
    nonisolated static var current: TimerEndSound {
        guard let raw = UserDefaults.standard.string(forKey: storageKey),
              let sound = TimerEndSound(rawValue: raw) else {
            return .fanfare
        }

        return sound
    }

    // 종료음을 저장한다
    nonisolated static func save(_ sound: TimerEndSound) {
        UserDefaults.standard.set(sound.rawValue, forKey: storageKey)
    }
}
