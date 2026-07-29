//
//  Color+Hex.swift
//  EggTimer
//

import SwiftUI

extension Color {
    /// hex 문자열로 Color를 생성한다
    init(hex: String) {
        let hexValue = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        var rgbValue: UInt64 = 0
        Scanner(string: hexValue).scanHexInt64(&rgbValue)

        let red = Double((rgbValue >> 16) & 0xFF) / 255
        let green = Double((rgbValue >> 8) & 0xFF) / 255
        let blue = Double(rgbValue & 0xFF) / 255

        self.init(red: red, green: green, blue: blue)
    }
}
