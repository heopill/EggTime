//
//  EggTimerApp.swift
//  EggTimer
//
//  Created by 허성필 on 7/6/26.
//

import SwiftUI
import ComposableArchitecture
import UserNotifications

// 포그라운드에서도 시스템 배너를 띄우기 위한 알림 델리게이트
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self

        return true
    }

    // 앱이 켜져 있을 때도 배너 + 소리로 알림을 표시한다
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound, .list]
    }
}

@main
struct EggTimerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
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
