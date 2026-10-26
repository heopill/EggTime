//
//  AppStoreClient.swift
//  EggTimer
//

import ComposableArchitecture
import Foundation

// 현재 앱 정보(번들 기준)
enum AppInfo {
    // 현재 실행 중인 앱의 표시 버전 (예: "1.0")
    static var currentVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    }
}

// 앱스토어에서 조회한 최신 버전 정보
struct AppStoreLookup: Equatable, Sendable {
    // 앱스토어에 등록된 최신 버전
    let version: String
    // 앱스토어 상세 페이지 URL (업데이트 버튼 이동용)
    let url: URL
    // 최신 버전이 요구하는 최소 iOS 버전 (예: "17.0")
    let minimumOSVersion: String?
}

extension AppStoreLookup {
    // 설치된 버전보다 앱스토어 버전이 높고, 이 기기의 iOS에서 받을 수 있으면 업데이트 대상이다
    var isUpdateAvailable: Bool {
        guard SettingVersionView.compareVersion(AppInfo.currentVersion, version) == .orderedAscending else {
            return false
        }

        // 새 버전이 요구하는 iOS보다 낮은 기기는 업데이트를 받을 수 없으므로 알리지 않는다
        guard let minimumOSVersion else {
            return true
        }
        let os = ProcessInfo.processInfo.operatingSystemVersion
        let currentOSVersion = "\(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"

        return SettingVersionView.compareVersion(currentOSVersion, minimumOSVersion) != .orderedAscending
    }
}

// 앱스토어의 최신 버전/링크를 조회한다
struct AppStoreClient: Sendable {
    // 최신 버전 정보를 조회한다 (미배포 상태이거나 조회 실패 시 nil)
    var lookup: @Sendable () async -> AppStoreLookup?
    // 업데이트 알림에서 "나중에"를 누른 버전 (같은 버전은 다시 알리지 않는다)
    var skippedVersion: @Sendable () -> String?
    // "나중에"를 누른 버전을 저장한다
    var skipVersion: @Sendable (String) -> Void
}

extension AppStoreClient: DependencyKey {
    static let liveValue = AppStoreClient(
        lookup: {
            // 번들 ID로 iTunes Lookup API를 조회한다 (앱이 앱스토어에 게시된 후에만 결과가 있음)
            guard let bundleID = Bundle.main.bundleIdentifier else {
                return nil
            }

            // country를 지정하지 않으면 US 스토어 기준으로 조회되어, 미출시 국가에서는 결과가 비어 nil이 된다.
            // 기기 지역에 맞춰 조회하고, 지역을 못 구하면 US로 폴백한다
            let country = Locale.current.region?.identifier ?? "US"

            var components = URLComponents(string: "https://itunes.apple.com/lookup")
            components?.queryItems = [
                URLQueryItem(name: "bundleId", value: bundleID),
                URLQueryItem(name: "country", value: country)
            ]

            guard let url = components?.url else {
                return nil
            }

            // Lookup 응답에는 max-age(약 24시간) 캐시 헤더가 붙어 있어, 로컬 캐시를 쓰면
            // 새 버전이 배포된 뒤에도 기기에 저장된 이전 버전을 계속 보여준다.
            // 항상 최신 버전을 조회하도록 로컬 캐시를 무시한다
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalCacheData

            guard let (data, _) = try? await URLSession.shared.data(for: request),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let results = json["results"] as? [[String: Any]],
                  let first = results.first,
                  let version = first["version"] as? String,
                  let trackURLString = first["trackViewUrl"] as? String,
                  let trackURL = URL(string: trackURLString) else {
                return nil
            }
            let minimumOSVersion = first["minimumOsVersion"] as? String

            return AppStoreLookup(version: version, url: trackURL, minimumOSVersion: minimumOSVersion)
        },
        skippedVersion: {
            return UserDefaults.standard.string(forKey: "skippedUpdateVersion")
        },
        skipVersion: { version in
            UserDefaults.standard.set(version, forKey: "skippedUpdateVersion")
        }
    )

    static let previewValue = AppStoreClient(
        lookup: { nil },
        skippedVersion: { nil },
        skipVersion: { _ in }
    )
    static let testValue = previewValue
}

extension DependencyValues {
    var appStore: AppStoreClient {
        get { self[AppStoreClient.self] }
        set { self[AppStoreClient.self] = newValue }
    }
}
