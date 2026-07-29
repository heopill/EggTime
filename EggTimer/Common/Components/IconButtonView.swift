//
//  IconButtonView.swift
//  EggTimer
//

import SwiftUI

struct IconButtonView: View {
    // 아이콘 버튼의 표시 방식
    enum Style {
        case plain   // 일반 배경 위: 아이콘만 표시
        case overlay // 사진 위: 아이콘 뒤에 반투명 배경을 함께 표시
    }

    // 버튼에 표시할 아이콘 에셋 이름
    let iconName: String
    // 아이콘 표시 방식 (사진 위에 올릴 때만 .overlay 사용)
    var style: Style = .plain
    // 버튼 탭 동작
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            content
        }
        .buttonStyle(.plain)
    }

    // 표시 방식과 무관한 아이콘 본체
    private var icon: some View {
        Image(iconName)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
    }

    // 표시 방식에 따른 버튼 모양 (패딩 10을 유지해 두 방식 모두 44pt 탭 영역을 갖는다)
    @ViewBuilder
    private var content: some View {
        switch style {
        case .plain:
            icon
                .foregroundStyle(Color("TextStrong"))
                .padding(10)

        case .overlay:
            icon
                .foregroundStyle(.white)
                .padding(10)
                .background(Color("TextStrong").opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 0.5)
                )
                .shadow(color: Color("TextNormal").opacity(0.25), radius: 8, x: 0, y: 8)
        }
    }
}

#Preview {
    VStack {
        IconButtonView(iconName: "ChevronLeft")
            .padding()
            .background(Color("Background"))

        IconButtonView(iconName: "ChevronLeft", style: .overlay)
            .padding()
            .background(Color.gray)
    }
}
