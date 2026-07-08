//
//  SplashView.swift
//  EggTimer
//
//  Created by 허성필 on 7/8/26.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color(red: 0.99, green: 1, blue: 0.78)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 앱 타이틀
                Text(String(localized: "EggTimer", table: "Splash"))
                    .fontStyle(.logo64)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))

                // 계란 이미지
                Image("SplashImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 203, height: 170)
                    .padding(.top, 40)
            }
        }
    }
}

#Preview {
    SplashView()
}
