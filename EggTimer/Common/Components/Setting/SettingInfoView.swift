//
//  SettingInfoView.swift
//  EggTimer
//

import SwiftUI

// 설정 화면의 안내 문구 박스 (불릿 목록, 문구는 여러 개 가능)
struct SettingInfoView: View {
    // 표시할 안내 문구 목록 (2개 이상이면 문구 사이에 한 줄을 띄운다)
    let messages: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: FontStyle.body16.fontSize * FontStyle.body16.lineHeightMultiple) {
            ForEach(Array(messages.enumerated()), id: \.offset) { _, message in
                bulletRow(message)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("BrandSecondary"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // 불릿(•) + 문구로 구성된 한 줄 (여러 줄로 넘어가면 문구 기준으로 정렬)
    private func bulletRow(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .fontStyle(.body16)
                .foregroundColor(Color("TextNormal"))

            Text(message)
                .fontStyle(.body16)
                .foregroundColor(Color("TextNormal"))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SettingInfoView(
            messages: ["탭하여 종료음을 미리 들어보고, 마음에 드는 종료음을 선택하세요."]
        )

        SettingInfoView(
            messages: [
                "첫 번째 안내 문구입니다.",
                "두 번째 안내 문구입니다. 문구가 두 개 이상이면 문구 사이에 한 줄을 띄웁니다."
            ]
        )
    }
    .frame(width: 335)
    .padding()
    .background(Color(.background))
}
