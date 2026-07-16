//
//  IconButtonView.swift
//  EggTimer
//

import SwiftUI

struct IconButtonView: View {
    // 버튼에 표시할 아이콘 에셋 이름
    let iconName: String
    // 버튼 탭 동작
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(iconName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .padding(10)
                .background(Color("TextStrong").opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 0.5)
                )
                .shadow(color: Color("TextNormal").opacity(0.25), radius: 8, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        IconButtonView(iconName: "ChevronLeft")
            .padding()
            .background(Color.gray)
        IconButtonView(iconName: "BookmarkDefault")
            .padding()
            .background(Color.gray)
    }
}
