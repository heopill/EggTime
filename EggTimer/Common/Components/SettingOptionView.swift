//
//  SettingOptionView.swift
//  EggTimer
//

import SwiftUI

// 설정 카드에 들어가는 개별 메뉴 항목
struct SettingOptionItem: Identifiable {
    let id = UUID()
    // 메뉴 아이콘 에셋 이름
    let iconName: String
    // 메뉴 이름
    let title: String
    // 메뉴 선택 시 동작
    var action: () -> Void = {}
}

struct SettingOptionView: View {
    // 하나의 카드에 표시할 메뉴 항목들 (섹션 단위)
    let items: [SettingOptionItem]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(items) { item in
                row(item)
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // 아이콘 + 제목 + 화살표로 구성된 메뉴 한 줄
    private func row(_ item: SettingOptionItem) -> some View {
        Button(action: item.action) {
            HStack(spacing: 10) {
                Image(item.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(10)
                    .background(Color("Background"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(item.title)
                    .fontStyle(.body16)
                    .foregroundColor(Color("TextNormal"))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image("ChevronRight")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            .frame(height: 44)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingOptionView(
        items: [
            SettingOptionItem(iconName: "Sound", title: "사운드 모드"),
            SettingOptionItem(iconName: "Music", title: "타이머 종료음")
        ]
    )
    .frame(width: 335)
    .padding()
    .background(Color(.background))
}
