//
//  AppBarView.swift
//  EggTimer
//

import SwiftUI

struct AppBarView: View {
    // 화면 상단에 표시할 타이틀 (없으면 빈 문자열)
    var title: String = ""
    // 좌측 아이콘 버튼 (없으면 표시 안 함)
    var leadingIcon: String? = nil
    // 좌측 버튼 탭 동작
    var onLeadingTap: () -> Void = {}
    // 우측 아이콘 버튼 (없으면 표시 안 함)
    var trailingIcon: String? = nil
    // 우측 버튼 탭 동작
    var onTrailingTap: () -> Void = {}

    var body: some View {
        ZStack {
            Text(title)
                .fontStyle(.title20)
                .foregroundColor(Color("TextNormal"))

            HStack {
                if let leadingIcon {
                    IconButtonView(iconName: leadingIcon, action: onLeadingTap)
                }

                Spacer()

                if let trailingIcon {
                    IconButtonView(iconName: trailingIcon, action: onTrailingTap)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .padding(.horizontal, 20)
    }
}

#Preview {
    VStack(spacing: 20) {
        AppBarView(title: "설정")

        AppBarView(
            title: "레시피",
            leadingIcon: "ChevronLeft",
            trailingIcon: "BookmarkDefault"
        )
    }
}
