//
//  FontStyle.swift
//  EggTimer
//

import SwiftUI

struct FontStyle {
    let fontName: String
    let fontSize: CGFloat
    let lineHeightMultiple: CGFloat // 행간 비율

    // Font 타입 대응 변수
    var font: Font {
        return Font.custom(fontName, size: fontSize)
    }

    // SwiftUI lineSpacing에 대응하는 줄 간격
    var lineSpacing: CGFloat {
        return fontSize * (lineHeightMultiple - 1)
    }
}

extension FontStyle {
    // MARK: - Pretendard-Regular (Body)
    static let body12 = FontStyle(fontName: "Pretendard-Regular", fontSize: 12, lineHeightMultiple: 1.5) // Body XS
    static let body14 = FontStyle(fontName: "Pretendard-Regular", fontSize: 14, lineHeightMultiple: 1.5) // Body S (알럿 설명글)
    static let body16 = FontStyle(fontName: "Pretendard-Regular", fontSize: 16, lineHeightMultiple: 1.5) // Body M
    static let body64 = FontStyle(fontName: "Pretendard-Regular", fontSize: 64, lineHeightMultiple: 1.3) // Body L (타이머 숫자)

    // MARK: - Pretendard-SemiBold (Title)
    static let title14 = FontStyle(fontName: "Pretendard-SemiBold", fontSize: 14, lineHeightMultiple: 1.5) // Title S (버튼 텍스트)
    static let title16 = FontStyle(fontName: "Pretendard-SemiBold", fontSize: 16, lineHeightMultiple: 1.5) // Title S Strong
    static let title12 = FontStyle(fontName: "Pretendard-SemiBold", fontSize: 12, lineHeightMultiple: 1.5) // Title XS
    static let title20 = FontStyle(fontName: "Pretendard-SemiBold", fontSize: 20, lineHeightMultiple: 1.3) // Title M
    static let title32 = FontStyle(fontName: "Pretendard-SemiBold", fontSize: 32, lineHeightMultiple: 1.3) // Title L

    // MARK: - OkDanDan-Bold (App name)
    static let logo64 = FontStyle(fontName: "OkDanDan-Bold", fontSize: 64, lineHeightMultiple: 1.3)
}

private struct FontStyleModifier: ViewModifier {
    let style: FontStyle

    func body(content: Content) -> some View {
        content
            .font(style.font)
            .lineSpacing(style.lineSpacing)
    }
}

extension View {
    // 지정한 FontStyle(폰트, 크기, 행간)을 한 번에 적용한다
    func fontStyle(_ style: FontStyle) -> some View {
        modifier(FontStyleModifier(style: style))
    }
}
