//
//  AppBarView.swift
//  EggTimer
//

import SwiftUI

struct AppBarView: View {
    // 화면 상단에 표시할 타이틀
    let title: String

    var body: some View {
        Text(title)
            .fontStyle(.title20)
            .foregroundColor(Color("TextNormal"))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .padding(.horizontal, 20)
    }
}

#Preview {
    AppBarView(title: "설정")
}
