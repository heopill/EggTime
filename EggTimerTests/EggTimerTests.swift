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

// MARK: - Test Helpers (파일 스코프 · 비격리라 send 검증 클로저 안에서도 쓸 수 있다)

/// 테스트 기준 시각 (epoch). 시간 계산의 출발점으로 사용한다
private let epoch = Date(timeIntervalSince1970: 0)

/// 기본 달걀(반숙)의 조리 시간(초). 대부분의 테스트가 기본 상태로 시작한다
private let defaultEggDuration = TimeInterval(EggDoneness.one.duration)

/// 기준 시각(epoch)으로부터 지정한 초만큼 지난 시각
private func date(after seconds: TimeInterval) -> Date {
    return Date(timeIntervalSince1970: seconds)
}

@MainActor
struct TimerFeatureTests {

    /// 시간을 조종할 수 있는 TimerFeature 테스트 스토어를 만든다.
    /// - Parameters:
    ///   - now: 현재 시각. `now.setValue(...)`로 시간을 앞당겨 완료 등을 검증할 수 있다.
    ///   - clock: 카운트다운 이펙트용 테스트 시계.
    ///   - configure: 알림 스파이 등 추가 의존성 주입 지점.
    private func makeStore(
        now: LockIsolated<Date> = LockIsolated(epoch),
        clock: TestClock<Duration> = TestClock(),
        configure: (inout DependencyValues) -> Void = { _ in }
    ) -> TestStoreOf<TimerFeature> {
        return TestStore(initialState: TimerFeature.State()) {
            TimerFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.date = DateGenerator { now.value }
            configure(&$0)
        }
    }

    // MARK: - Tests

    // 시작 전(idle)에 달걀을 바꾸면 남은 시간이 그 달걀 기준으로 갱신된다
    @Test
    func selectingEggUpdatesRemainingSeconds() async {
        let store = makeStore()

        await store.send(.binding(.set(\.selectedEgg, .four))) {
            $0.selectedEgg = .four
            $0.remainingSeconds = EggDoneness.four.duration   // 완숙 = 720초
        }
    }

    // 시작 버튼을 누르면 진행 중 상태로 전환되고 목표 종료 시각이 설정된다
    @Test
    func startTappedBeginsCountdown() async {
        let store = makeStore()

        await store.send(.startTapped) {
            $0.cookingState = .running
            $0.deadline = date(after: defaultEggDuration)
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
        // 남은 시간은 date.now 기준으로 계산되므로, 시간을 앞당겨 완료를 재현한다
        let now = LockIsolated(epoch)
        let store = makeStore(now: now)

        await store.send(.startTapped) {
            $0.cookingState = .running
            $0.deadline = date(after: defaultEggDuration)
        }

        // 시간이 목표 종료 시각에 도달했다고 가정
        now.setValue(date(after: defaultEggDuration))

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
        // 알림 예약 시 전달된 시간(초)을 잡아두는 스파이
        let scheduledSeconds = LockIsolated<TimeInterval?>(nil)
        let store = makeStore {
            $0.notifications.scheduleCompletion = { seconds, _, _ in
                scheduledSeconds.setValue(seconds)
            }
        }

        await store.send(.startTapped) {
            $0.cookingState = .running
            $0.deadline = date(after: defaultEggDuration)
        }

        // 진행 중 타이머 이펙트를 정리하고, 모든 이펙트가 끝나길 기다린다
        await store.send(.pauseTapped) {
            $0.cookingState = .paused
            $0.deadline = nil
        }
        await store.finish()

        // 시작 시 남은 시간 뒤로 완료 알림이 예약됐는지 확인한다
        #expect(scheduledSeconds.value == defaultEggDuration)
    }

    // 초기화하면 시간이 기본값으로 돌아가고 시작 전(idle) 상태가 된다
    @Test
    func resetReturnsToIdle() async {
        let store = makeStore()

        await store.send(.startTapped) {
            $0.cookingState = .running
            $0.deadline = date(after: defaultEggDuration)
        }

        // 초기화하면 시작 전 상태로 돌아간다 (진행 중 timer 이펙트도 취소)
        // 남은 시간은 이미 기본 달걀 기준이라 값 변화가 없다
        await store.send(.resetConfirmed) {
            $0.cookingState = .idle
            $0.deadline = nil
        }
    }
}
