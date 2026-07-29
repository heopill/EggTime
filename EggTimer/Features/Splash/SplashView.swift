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
            Color("BrandPrimary")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 앱 타이틀
                Text(String(localized: "EggTimer", table: "Splash"))
                    .fontStyle(.logo64)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)

                // 계란 이미지
                Image("EggTwo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 130, height: 190)
                    .padding(.top, 5)
            }
        }
    }
}

#Preview {
    SplashView()
}
