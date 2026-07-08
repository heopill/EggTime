//
//  EggTimerApp.swift
//  EggTimer
//
//  Created by 허성필 on 7/6/26.
//

import SwiftUI
import ComposableArchitecture

@main
struct EggTimerApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView()
                    .onAppear {
                        /// 2초 후 메인 화면으로 전환
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                TimerView(
                    store: Store(initialState: TimerFeature.State()) {
                        TimerFeature()
                    }
                )
            }
        }
    }
}
