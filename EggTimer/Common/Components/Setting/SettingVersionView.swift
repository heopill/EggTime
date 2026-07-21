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

    // 현재 버전이 최신 버전과 일치하는지 여부 (업데이트 버튼 활성화 판단에 사용)
    var isUpToDate: Bool {
        return currentVersion == latestVersion
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
