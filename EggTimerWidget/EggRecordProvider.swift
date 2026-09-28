//
//  EggRecordProvider.swift
//  EggTimerWidget
//
//  오늘의 에그타임 / 이번 주 나의 에그타임 위젯이 공유하는 타임라인 프로바이더.
//

import WidgetKit
import SwiftUI

// 위젯 한 프레임에 표시할 기록 스냅샷
struct EggRecordEntry: TimelineEntry {
    let date: Date
    let record: EggRecord
}

// App Group에 저장된 EggRecord를 읽어 위젯 타임라인을 구성한다
struct EggRecordProvider: TimelineProvider {
    // 위젯 갤러리 등에서 보여줄 자리표시자
    func placeholder(in context: Context) -> EggRecordEntry {
        return EggRecordEntry(date: Date(), record: EggRecord())
    }

    // 위젯 갤러리 미리보기용 스냅샷
    func getSnapshot(in context: Context, completion: @escaping (EggRecordEntry) -> Void) {
        completion(EggRecordEntry(date: Date(), record: EggRecordStore.load()))
    }

    // 실제 타임라인. 날짜가 바뀌면 오늘 카운트·요일 표시가 갱신되어야 하므로 다음 자정에 새로고침한다
    func getTimeline(in context: Context, completion: @escaping (Timeline<EggRecordEntry>) -> Void) {
        let now = Date()
        let entry = EggRecordEntry(date: now, record: EggRecordStore.load())

        let nextMidnight = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) ?? now.addingTimeInterval(60 * 60)

        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }
}

// MARK: - Design Tokens

extension Color {
    // 위젯 배경 그라데이션 상단 (#FF9748)
    static let eggGradientTop = Color(red: 1.0, green: 151.0 / 255.0, blue: 72.0 / 255.0)
    // 위젯 배경 그라데이션 하단 · 브랜드 오렌지 (#FF6F00)
    static let eggGradientBottom = Color("BrandPrimary")
}

extension Font {
    // 위젯 소제목 (Pretendard SemiBold 14)
    static let eggWidgetCaption = Font.custom("Pretendard-SemiBold", size: 14)
    // 위젯 본문 강조 (Pretendard SemiBold 20)
    static let eggWidgetTitle = Font.custom("Pretendard-SemiBold", size: 20)
    // 요일 라벨 (Pretendard SemiBold 12)
    static let eggWidgetDay = Font.custom("Pretendard-SemiBold", size: 12)
}

// 위젯 공용 배경 그라데이션
struct EggWidgetBackground: View {
    var body: some View {
        LinearGradient(
            colors: [.eggGradientTop, .eggGradientBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
