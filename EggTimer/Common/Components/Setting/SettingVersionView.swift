//
//  SettingVersionView.swift
//  EggTimer
//

import SwiftUI

// 현재 앱 버전과 앱스토어 최신 버전을 나란히 표시하는 카드
struct SettingVersionView: View {
    // 현재 실행 중인 앱 버전
    let currentVersion: String
    // 앱스토어에 등록된 최신 버전
    let latestVersion: String

    // 현재 버전이 최신 버전과 같은지 여부 (업데이트 버튼 활성화 판단에 사용)
    // "1.1"과 "1.1.0"처럼 자리 수가 달라도 같은 버전으로 취급한다
    var isUpToDate: Bool {
        return Self.compareVersion(currentVersion, latestVersion) == .orderedSame
    }

    // 버전 문자열을 점으로 나눠 각 자리를 숫자로 비교한다 (모자란 자리는 0으로 채운다)
    static func compareVersion(_ lhs: String, _ rhs: String) -> ComparisonResult {
        let lhsParts = lhs.split(separator: ".").map { Int($0) ?? 0 }
        let rhsParts = rhs.split(separator: ".").map { Int($0) ?? 0 }
        let count = max(lhsParts.count, rhsParts.count)

        for index in 0..<count {
            let left = index < lhsParts.count ? lhsParts[index] : 0
            let right = index < rhsParts.count ? rhsParts[index] : 0

            if left != right {
                return left < right ? .orderedAscending : .orderedDescending
            }
        }

        return .orderedSame
    }

    var body: some View {
        VStack(spacing: 8) {
            row(title: String(localized: "App Version", table: "Setting"), version: currentVersion)
            row(title: String(localized: "Latest Version", table: "Setting"), version: latestVersion)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // 라벨(좌) + 버전 값(우) 한 줄
    private func row(title: String, version: String) -> some View {
        HStack(spacing: 10) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(version)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .fontStyle(.body16)
        .foregroundColor(Color("TextNormal"))
        .frame(height: 44)
    }
}

#Preview {
    VStack(spacing: 20) {
        SettingVersionView(currentVersion: "1.1", latestVersion: "1.1")
        SettingVersionView(currentVersion: "1.0", latestVersion: "1.1")
    }
    .frame(width: 335)
    .padding()
    .background(Color(.background))
}
