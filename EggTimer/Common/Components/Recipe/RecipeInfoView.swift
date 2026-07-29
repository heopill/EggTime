//
//  RecipeInfoView.swift
//  EggTimer
//

import SwiftUI

struct RecipeInfoView: View {
    // 정보 아이콘 에셋 이름
    let iconName: String
    // 정보 텍스트 (예: "20분 조리")
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color("TextNormal"))
                .frame(width: 20, height: 20)

            Text(text)
                .fontStyle(.title12)
                .foregroundColor(Color("TextNormal"))
                .lineLimit(1)
        }
        .padding(4)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color("Background"), lineWidth: 1)
        )
    }
}

#Preview {
    HStack(spacing: 8) {
        RecipeInfoView(iconName: "Stopwatch", text: "20분 조리")
        RecipeInfoView(iconName: "Timer", text: "쉬움")
    }
    .padding()
}
