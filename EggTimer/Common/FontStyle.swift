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
    static let body12 = FontStyle(fontName: "Pretendard-Regular", fontSize: 12, lineHeightMultiple: 1.5)
    static let body14 = FontStyle(fontName: "Pretendard-Regular", fontSize: 14, lineHeightMultiple: 1.5)
    static let body16 = FontStyle(fontName: "Pretendard-Regular", fontSize: 16, lineHeightMultiple: 1.5)
    static let body18 = FontStyle(fontName: "Pretendard-Regular", fontSize: 18, lineHeightMultiple: 1.5)

    // MARK: - Pretendard-SemiBold (Title)
    static let title12 = FontStyle(fontName: "Pretendard-SemiBold", fontSize: 12, lineHeightMultiple: 1.35)
    static let title14 = FontStyle(fontName: "Pretendard-SemiBold", fontSize: 14, lineHeightMultiple: 1.35)
    static let title16 = FontStyle(fontName: "Pretendard-SemiBold", fontSize: 16, lineHeightMultiple: 1.35)
    static let title18 = FontStyle(fontName: "Pretendard-SemiBold", fontSize: 18, lineHeightMultiple: 1.35)
    static let title20 = FontStyle(fontName: "Pretendard-SemiBold", fontSize: 20, lineHeightMultiple: 1.35)
    static let title24 = FontStyle(fontName: "Pretendard-SemiBold", fontSize: 24, lineHeightMultiple: 1.35)

    // MARK: - OkDanDan-Bold (Logo / Display)
    static let logo24 = FontStyle(fontName: "OkDanDan-Bold", fontSize: 24, lineHeightMultiple: 1.2)
    static let logo32 = FontStyle(fontName: "OkDanDan-Bold", fontSize: 32, lineHeightMultiple: 1.2)
    static let logo64 = FontStyle(fontName: "OkDanDan-Bold", fontSize: 64, lineHeightMultiple: 1.2)
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
