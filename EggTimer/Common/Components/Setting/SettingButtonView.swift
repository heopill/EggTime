//
//  SettingButtonView.swift
//  EggTimer
//

import SwiftUI

// 설정 화면 하단의 액션 버튼 (선택 가능 여부에 따라 색이 바뀜)
struct SettingButtonView: View {
    // 버튼 텍스트
    let title: String
    // 선택 가능 여부 (false면 비활성 색으로 표시되고 탭이 막힌다)
    var isEnabled: Bool = true
    // 버튼 탭 동작
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontStyle(.title16)
                // 활성: 흰 글씨, 비활성: TextNormal(#555555) 글씨
                .foregroundColor(isEnabled ? .white : Color("TextNormal"))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                // 활성: BrandPrimary 배경, 비활성: 앱 배경색과 동일(Background)
                .background(isEnabled ? Color("BrandPrimary") : Color("Background"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack(spacing: 20) {
        SettingButtonView(title: "업데이트하기", isEnabled: true)
        SettingButtonView(title: "업데이트하기", isEnabled: false)
    }
    .frame(width: 335)
    .padding()
    .background(Color(.background))
}
