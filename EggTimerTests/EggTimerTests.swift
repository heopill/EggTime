//
//  EggTimerTests.swift
//  EggTimerTests
//
//  Created by 허성필 on 8/6/26.
//

import ComposableArchitecture
import Testing
import Foundation
@testable import EggTimer

@MainActor
struct TimerFeatureTests {
    // 시작 전(idle)에 달걀을 바꾸면 남은 시간이 그 달걀 기준으로 갱신된다
    @Test
    func selectingEggUpdatesRemainingSeconds() async {
        let store = TestStore(initialState: TimerFeature.State()) {
            TimerFeature()
        }

        await store.send(.binding(.set(\.selectedEgg, .four))) {
            $0.selectedEgg = .four
            $0.remainingSeconds = 12 * 60   // 완숙 = 720초
        }
    }

    // 시작 버튼을 누르면 진행 중 상태로 전환되고 목표 종료 시각이 설정된다
    @Test
    func startTappedBeginsCountdown() async {
        let clock = TestClock()

        let store = TestStore(initialState: TimerFeature.State()) {
            TimerFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.date = .constant(Date(timeIntervalSince1970: 0))
        }

        await store.send(.startTapped) {
            $0.cookingState = .running
            $0.deadline = Date(timeIntervalSince1970: 360)   // 기본 달걀(반숙) 6분
        }

        // 진행 중인 타이머 이펙트를 정리한다 (일시정지가 timer 이펙트를 취소)
        await store.send(.pauseTapped) {
            $0.cookingState = .paused
            $0.deadline = nil
        }
    }

    // 남은 시간이 0에 도달하면 완료 상태로 전환된다
    @Test
    func timerReachingZeroCompletes() async {
        let clock = TestClock()
        // 시간을 조종할 수 있는 날짜 생성기 (남은 시간은 date.now 기준으로 계산되므로 필요)
        let now = LockIsolated(Date(timeIntervalSince1970: 0))

        let store = TestStore(initialState: TimerFeature.State()) {
            TimerFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.date = DateGenerator { now.value }
        }

        // 시작: 기본 달걀(반숙) 6분 = 360초 뒤가 목표 종료 시각
        await store.send(.startTapped) {
            $0.cookingState = .running
            $0.deadline = Date(timeIntervalSince1970: 360)
        }

        // 시간이 목표 종료 시각(360초)에 도달했다고 가정
        now.setValue(Date(timeIntervalSince1970: 360))

        // 틱이 발생하면 남은 시간이 0이 되고 완료 상태로 전환된다 (진행 중 timer 이펙트도 취소)
        await store.send(.timerTicked) {
            $0.remainingSeconds = 0
            $0.cookingState = .completed
            $0.deadline = nil
        }
    }

    // 시작하면 남은 시간(초) 뒤에 완료 알림이 예약된다
    @Test
    func startSchedulesCompletionNotification() async {
        let clock = TestClock()
        // 알림 예약 시 전달된 시간(초)을 잡아두는 스파이
        let scheduledSeconds = LockIsolated<TimeInterval?>(nil)

        let store = TestStore(initialState: TimerFeature.State()) {
            TimerFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.date = .constant(Date(timeIntervalSince1970: 0))
            $0.notifications.scheduleCompletion = { seconds, _, _ in
                scheduledSeconds.setValue(seconds)
            }
        }

        await store.send(.startTapped) {
            $0.cookingState = .running
            $0.deadline = Date(timeIntervalSince1970: 360)
        }

        // 진행 중 타이머 이펙트를 정리하고, 모든 이펙트가 끝나길 기다린다
        await store.send(.pauseTapped) {
            $0.cookingState = .paused
            $0.deadline = nil
        }
        await store.finish()

        // 시작 시 남은 시간(360초) 뒤로 완료 알림이 예약됐는지 확인한다
        #expect(scheduledSeconds.value == 360)
    }

    // 초기화하면 시간이 기본값으로 돌아가고 시작 전(idle) 상태가 된다
    @Test
    func resetReturnsToIdle() async {
        let clock = TestClock()

        let store = TestStore(initialState: TimerFeature.State()) {
            TimerFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.date = .constant(Date(timeIntervalSince1970: 0))
        }

        await store.send(.startTapped) {
            $0.cookingState = .running
            $0.deadline = Date(timeIntervalSince1970: 360)
        }

        // 초기화하면 시작 전 상태로 돌아간다 (진행 중 timer 이펙트도 취소)
        // 남은 시간은 이미 기본 달걀(360초)이라 값 변화가 없다
        await store.send(.resetConfirmed) {
            $0.cookingState = .idle
            $0.deadline = nil
        }
    }
}
