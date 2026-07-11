//
//  TimerView.swift
//  EggTimer
//

import SwiftUI
import ComposableArchitecture

struct TimerView: View {
    @Bindable var store: StoreOf<TimerFeature>

    // 좌우 회전 각도(20 → -20도) 및 한 방향에 걸리는 시간(초)
    private let waterPhases: [Double] = [30, -10]
    private let waterDuration: Double = 2

    var body: some View {
        TabView(selection: $store.selectedTab) {
            GeometryReader { proxy in
                // 피그마 기본 화면(너비 375) 대비 실제 화면 너비 비율
                let scale = proxy.size.width / 375

                // 상단 SafeArea 인셋과 전체 화면 높이
                let topInset = proxy.safeAreaInsets.top
                let screenHeight = proxy.size.height + topInset + proxy.safeAreaInsets.bottom

                // SafeArea 아래부터 버튼 top까지 거리(피그마 544)를 SafeArea 아래 전체 높이(피그마 768) 대비 비율로 환산해 배치한다
                let buttonTop = topInset + (544.0 / 768.0) * (screenHeight - topInset)

                ZStack(alignment: .topLeading) {
                    Color(.background)
                        .ignoresSafeArea()

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
                        .offset(x: -195 * scale, y: -180 * scale)

                    // 타이머 섹션 (타이틀 + 남은 시간) - 피그마 콘텐츠 top(84) 기준 배치
                    timerSection
                        .frame(width: proxy.size.width)
                        .padding(.top, 84 * scale)

                    EggInfoView(selection: $store.selectedEgg, isSwipeDisabled: store.cookingState != .idle)
                        .frame(width: proxy.size.width)
                        .padding(.top, 205 * scale)

                    // 컨트롤 버튼 (시작 / 일시정지 · 재시작) - SafeArea 기준 비율 위치에 배치
                    controlButtons
                        .frame(width: proxy.size.width)
                        .padding(.top, buttonTop)
                }
                .ignoresSafeArea()
            }
            .tabItem {
                Label("타이머", image: "Timer")
            }
            .tag(TimerFeature.Tab.timer)

            // 레시피 메뉴
            RecipeView(store: store.scope(state: \.recipe, action: \.recipe))
                .tabItem {
                    Label("레시피", image: "Book")
                }
                .tag(TimerFeature.Tab.recipe)

            // 설정 메뉴
            SettingView(store: store.scope(state: \.setting, action: \.setting))
                .tabItem {
                    Label("설정", image: "Setting")
                }
                .tag(TimerFeature.Tab.setting)
        }
        .tint(Color("BrandPrimary"))
        .overlay {
            if store.isResetAlertPresented {
                CustomAlertView(
                    title: "초기화 이후에는\n취소할 수 없습니다.",
                    message: "타이머를 초기화 하시겠습니까?",
                    confirmTitle: "초기화 하기",
                    cancelTitle: "취소",
                    confirmAction: { store.send(.resetConfirmed) },
                    cancelAction: { store.send(.resetCancelled) }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: store.isResetAlertPresented)
    }

    // 상단 타이틀 + 남은 시간 표시
    private var timerSection: some View {
        VStack(spacing: 4) {
            // 진행 중일 때 타이틀은 Primary(주황), 그 외에는 TextNormal 색상을 사용한다
            Text(store.title)
                .fontStyle(.title16)
                .foregroundColor(store.isRunning ? Color("BrandPrimary") : Color("TextNormal"))

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
            TimerControlButton(iconName: "Play", title: "시작") {
                store.send(.startTapped)
            }

        case .running:
            // 진행 중: 일시정지 + 초기화
            HStack(spacing: 20) {
                TimerControlButton(iconName: "Pause", title: "일시정지") {
                    store.send(.pauseTapped)
                }
                TimerControlButton(iconName: "Restart", title: "초기화") {
                    store.send(.resetTapped)
                }
            }

        case .paused:
            // 일시정지: 재시작 + 초기화
            HStack(spacing: 20) {
                TimerControlButton(iconName: "Play", title: "재시작") {
                    store.send(.resumeTapped)
                }
                TimerControlButton(iconName: "Restart", title: "초기화") {
                    store.send(.resetTapped)
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

