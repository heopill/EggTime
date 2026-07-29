//
//  EggTimerApp.swift
//  EggTimer
//
//  Created by 허성필 on 7/6/26.
//

import SwiftUI
import ComposableArchitecture
import UserNotifications
import AudioToolbox

// 포그라운드에서도 시스템 배너를 띄우기 위한 알림 델리게이트
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self

        return true
    }

    // 앱이 켜져 있을 때(포그라운드)의 완료 알림을 사운드 모드에 맞춰 표시한다
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        let mode = SoundMode.current

        // 진동 모드면 앱이 직접 진동을 울린다
        if mode.playsVibration {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }

        // 소리 모드면 무음 스위치를 무시하고 앱이 직접 완료음을 재생한다
        // (알림의 .sound는 무음 스위치를 따르므로 사용하지 않는다)
        if mode.playsSound {
            CompletionSoundPlayer.shared.play()
        }

        // 소리는 위에서 직접 재생하므로 알림은 배너만 표시한다
        return [.banner, .list]
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
