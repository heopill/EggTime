//
//  TimerView.swift
//  EggTimer
//

import SwiftUI
import UIKit
import ComposableArchitecture

struct TimerView: View {
    @Bindable var store: StoreOf<TimerFeature>
    @Environment(\.scenePhase) private var scenePhase

    // 좌우 회전 각도(20 → -20도) 및 한 방향에 걸리는 시간(초)
    private let waterPhases: [Double] = [30, -10]
    private let waterDuration: Double = 2

    var body: some View {
        TabView(selection: $store.selectedTab) {
            GeometryReader { proxy in
                // 피그마는 아이폰 13 mini(375×812) 기준으로 디자인되어, 전체 콘텐츠를 기기 높이 비율로 확대한다.
                // 배율은 1.3으로 상한을 둔다 (아이폰은 최대 ~1.18이라 실질적으로 아이패드 등 큰 화면에만 적용됨)
                // 하한은 SE(375×667) 기준인 667/812(≈0.82)로 둔다. 그보다 작은 화면에서도 콘텐츠가 더 축소되지 않게 한다
                let screenHeight = proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom
                let heightRatio = min(max(screenHeight / 812, 667 / 812), 1.3)

                ZStack {
                    Color(.background)
                        .ignoresSafeArea()

                    // 배경 물결 장식 (상단 중앙 고정, 좌우로 흔들리는 애니메이션)
                    waterBackground(scale: heightRatio)

                    // 타이머 콘텐츠 - 피그마 기준(너비 375, mini 사이즈)으로 배치한 뒤 전체를 높이 비율로 확대하고,
                    // SafeArea 중앙에 배치한다. (egg·버튼·글자·간격·여백이 모두 같은 비율로 커진다)
                    VStack(spacing: 0) {
                        timerSection

                        EggInfoView(selection: $store.selectedEgg, isSwipeDisabled: store.cookingState != .idle)
                            .padding(.top, 16)

                        // 피그마 기준 dots↔버튼 간격 83 (scaleEffect로 함께 확대된다)
                        Spacer()
                            .frame(height: 83)

                        controlButtons
                    }
                    .frame(width: 375)
                    .scaleEffect(heightRatio, anchor: .center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .tabItem {
                Label(String(localized: "Timer", table: "Timer"), image: "Timer")
            }
            .tag(TimerFeature.Tab.timer)

            // 레시피 메뉴
            RecipeView(store: store.scope(state: \.recipe, action: \.recipe))
                .tabItem {
                    Label(String(localized: "Recipe", table: "Timer"), image: "Book")
                }
                .tag(TimerFeature.Tab.recipe)

            // 설정 메뉴
            SettingView(store: store.scope(state: \.setting, action: \.setting))
                .tabItem {
                    Label(String(localized: "Settings", table: "Timer"), image: "Setting")
                }
                .tag(TimerFeature.Tab.setting)
        }
        .tint(Color("BrandPrimary"))
        .overlay {
            if store.isResetAlertPresented {
                CustomAlertView(
                    title: String(localized: "This cannot be undone\nafter resetting.", table: "Timer"),
                    message: String(localized: "Reset the timer?", table: "Timer"),
                    confirmTitle: String(localized: "Reset timer", table: "Timer"),
                    cancelTitle: String(localized: "Cancel", table: "Timer"),
                    confirmAction: { store.send(.resetConfirmed) },
                    cancelAction: { store.send(.resetCancelled) }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: store.isResetAlertPresented)
        .task {
            // 앱 첫 진입 시 알림 권한 요청
            store.send(.onAppear)
        }
        .onChange(of: scenePhase) { _, newPhase in
            // 백그라운드에서 돌아오면 남은 시간을 즉시 다시 계산한다
            if newPhase == .active {
                store.send(.timerTicked)
            }
        }
        .onChange(of: store.isRunning) { _, isRunning in
            // 타이머가 진행 중일 때만 화면이 자동으로 꺼지지 않도록 한다
            UIApplication.shared.isIdleTimerDisabled = isRunning
        }
    }

    // 배경 물결 장식 (상단 중앙에 고정하고 좌우로 흔들리는 애니메이션을 준다)
    // 화면보다 큰 이미지를 Color.clear 오버레이로 감싸, 넘치는 크기가 부모 레이아웃을 밀지 않도록 한다
    private func waterBackground(scale: CGFloat) -> some View {
        Color.clear
            .overlay(alignment: .top) {
                Image("WaterNeg20")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 766 * scale, height: 768 * scale)
                    // 중심을 유지한 채 원래 크기에서 5% 축소
                    .scaleEffect(0.95)
                    .phaseAnimator(waterPhases) { view, angle in
                        view.rotationEffect(.degrees(angle))
                    } animation: { _ in
                        .easeInOut(duration: waterDuration)
                    }
                    // 화면 상단 중앙을 기준으로 피그마 값(-160)만큼 위로 올린다
                    .offset(y: -160 * scale)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }

    // 상단 타이틀 + 남은 시간 표시
    private var timerSection: some View {
        VStack(spacing: 4) {
            // 진행 중이거나 완료됐을 때 타이틀은 Primary(주황), 그 외에는 TextNormal 색상을 사용한다
            Text(store.title)
                .fontStyle(.title16)
                .foregroundColor(store.isTitleHighlighted ? Color("BrandPrimary") : Color("TextNormal"))

            Text(store.timeText)
                .fontStyle(.body64)
                .foregroundColor(Color("TextStrong"))
        }
    }

    // 조리 상태에 따른 컨트롤 버튼
    @ViewBuilder
    private var controlButtons: some View {
        switch store.cookingState {
        case .idle:
            // 시작 전: 시작 버튼만 표시
            TimerControlButton(iconName: "Play", title: String(localized: "Start", table: "Timer")) {
                store.send(.startTapped)
            }

        case .running:
            // 진행 중: 일시정지 + 초기화
            HStack(spacing: 20) {
                TimerControlButton(iconName: "Pause", title: String(localized: "Pause", table: "Timer")) {
                    store.send(.pauseTapped)
                }
                TimerControlButton(iconName: "Restart", title: String(localized: "Reset", table: "Timer")) {
                    store.send(.resetTapped)
                }
            }

        case .paused:
            // 일시정지: 재시작 + 초기화
            HStack(spacing: 20) {
                TimerControlButton(iconName: "Play", title: String(localized: "Resume", table: "Timer")) {
                    store.send(.resumeTapped)
                }
                TimerControlButton(iconName: "Restart", title: String(localized: "Reset", table: "Timer")) {
                    store.send(.resetTapped)
                }
            }

        case .completed:
            // 완료: 재시작 + 초기화
            HStack(spacing: 20) {
                TimerControlButton(iconName: "Play", title: String(localized: "Resume", table: "Timer")) {
                    store.send(.restartTapped)
                }
                TimerControlButton(iconName: "Restart", title: String(localized: "Reset", table: "Timer")) {
                    store.send(.resetConfirmed)
                }
            }
        }
    }
}

#Preview {
    TimerView(
        store: Store(initialState: TimerFeature.State()) {
            TimerFeature()
        }
    )
}

