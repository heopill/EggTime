//
//  ToastMessageView.swift
//  EggTimer
//

import SwiftUI

// 화면에 잠깐 나타나는 토스트 메시지
struct ToastMessageView: View {
    let message: String

    // 토스트 너비 및 모서리 반경
    private let toastWidth: CGFloat = 250
    private let cornerRadius: CGFloat = 12

    // 텍스트 한 줄 높이. lineSpacing은 한 줄일 때 적용되지 않으므로 line-height를 직접 계산해 지정한다
    private var lineHeight: CGFloat {
        return FontStyle.body14.fontSize * FontStyle.body14.lineHeightMultiple
    }

    var body: some View {
        Text(message)
            .fontStyle(.body14)
            .foregroundColor(Color("BrandPrimary"))
            .lineLimit(1)
            .frame(height: lineHeight)
            .padding(8)
            .frame(width: toastWidth)
            .background(Color("Secondary"))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

#Preview {
    ToastMessageView(message: "레시피가 저장되었습니다")
}
