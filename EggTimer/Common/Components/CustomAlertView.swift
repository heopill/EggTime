//
//  CustomAlertView.swift
//  EggTimer
//

import SwiftUI

// 확인 / 취소 두 개의 선택지를 가진 커스텀 알럿 (배경 스크림 포함)
struct CustomAlertView: View {
    let title: String
    let message: String
    let confirmTitle: String
    let cancelTitle: String
    let confirmAction: () -> Void
    let cancelAction: () -> Void

    // 알럿 카드 너비 및 구분선 색
    private let cardWidth: CGFloat = 270
    private let dividerColor = Color(hex: "9C9C9C")

    var body: some View {
        ZStack {
            // 배경 스크림 (탭하면 취소)
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { cancelAction() }

            // 알럿 카드
            VStack(spacing: 0) {
                VStack(spacing: 10) {
                    Text(title)
                        .fontStyle(.title16)
                        .foregroundColor(Color("TextStrong"))
                        .multilineTextAlignment(.center)

                    Text(message)
                        .fontStyle(.body14)
                        .foregroundColor(Color("TextStrong"))
                        .multilineTextAlignment(.center)
                }
                .padding(16)

                optionButton(title: confirmTitle, color: Color("BrandPrimary"), action: confirmAction)
                optionButton(title: cancelTitle, color: Color("TextStrong"), action: cancelAction)
            }
            .frame(width: cardWidth)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // 상단 구분선 + 선택지 버튼 한 줄
    private func optionButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(dividerColor)
                .frame(height: 0.5)

            Button(action: action) {
                Text(title)
                    .fontStyle(.title16)
                    .foregroundColor(color)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
            }
        }
    }
}

#Preview {
    CustomAlertView(
        title: "초기화 이후에는\n취소할 수 없습니다.",
        message: "타이머를 초기화 하시겠습니까?",
        confirmTitle: "초기화 하기",
        cancelTitle: "취소",
        confirmAction: {},
        cancelAction: {}
    )
}
