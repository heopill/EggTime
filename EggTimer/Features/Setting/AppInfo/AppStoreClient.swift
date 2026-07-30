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
}

// 앱스토어의 최신 버전/링크를 조회한다
struct AppStoreClient: Sendable {
    // 최신 버전 정보를 조회한다 (미배포 상태이거나 조회 실패 시 nil)
    var lookup: @Sendable () async -> AppStoreLookup?
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

            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let results = json["results"] as? [[String: Any]],
                  let first = results.first,
                  let version = first["version"] as? String,
                  let trackURLString = first["trackViewUrl"] as? String,
                  let trackURL = URL(string: trackURLString) else {
                return nil
            }

            return AppStoreLookup(version: version, url: trackURL)
        }
    )

    static let previewValue = AppStoreClient(lookup: { nil })
    static let testValue = previewValue
}

extension DependencyValues {
    var appStore: AppStoreClient {
        get { self[AppStoreClient.self] }
        set { self[AppStoreClient.self] = newValue }
    }
}
