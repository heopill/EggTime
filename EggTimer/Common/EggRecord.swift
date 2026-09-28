//
//  EggRecord.swift
//  EggTimer
//
//  앱과 위젯 익스텐션이 App Group을 통해 공유하는 에그타임 기록 모델/스토어.
//  (위젯 타겟은 TCA를 링크하지 않으므로 Foundation만 의존한다)
//

import Foundation

// 위젯과 데이터를 공유하기 위한 App Group 식별자
enum AppGroup {
    static let identifier = "group.dev.seongpil.EggTimer"
}

// 오늘의 반숙/완숙 횟수와 이번 주 완료 날짜를 담는 기록
nonisolated struct EggRecord: Codable, Equatable, Sendable {
    // 오늘 카운트가 속한 날짜 (자정 기준). 날짜가 바뀌면 카운트를 리셋한다
    var todayDate: Date = .distantPast
    // 오늘 반숙(1~3단계) 완료 횟수
    var softBoiledCount: Int = 0
    // 오늘 완숙(4단계) 완료 횟수
    var hardBoiledCount: Int = 0
    // 타이머를 완료한 날짜들 (자정 기준, 이번 주 표시에 사용)
    var completedDates: [Date] = []
}

extension EggRecord {
    // 오늘 기준 반숙/완숙 횟수 (기록된 날짜가 오늘이 아니면 0을 반환한다)
    nonisolated func todayCounts(now: Date = Date()) -> (soft: Int, hard: Int) {
        let today = EggCalendar.mondayFirst.startOfDay(for: now)

        guard todayDate == today else {
            return (0, 0)
        }

        return (softBoiledCount, hardBoiledCount)
    }

    // 이번 주(월~일) 각 요일의 완료 여부
    nonisolated func weeklyCompletion(now: Date = Date()) -> [Bool] {
        let calendar = EggCalendar.mondayFirst

        return EggCalendar.currentWeekDays(now: now).map { day in
            completedDates.contains { calendar.isDate($0, inSameDayAs: day) }
        }
    }
}

// 월요일 시작 기준의 주간 계산 유틸리티
enum EggCalendar {
    // 월요일을 한 주의 시작으로 두는 캘린더 (디자인: 월 시작 · 일 끝)
    nonisolated static var mondayFirst: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2

        return calendar
    }

    // 이번 주 월~일에 해당하는 7개의 날짜 (자정 기준)
    nonisolated static func currentWeekDays(now: Date = Date()) -> [Date] {
        let calendar = mondayFirst

        guard let interval = calendar.dateInterval(of: .weekOfYear, for: now) else {
            return []
        }

        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: interval.start) }
    }
}

// App Group UserDefaults에 EggRecord를 저장/조회하는 스토어
nonisolated enum EggRecordStore {
    private static let key = "eggRecord"

    // 앱과 위젯이 공유하는 UserDefaults (App Group 접근 실패 시 표준 저장소로 폴백)
    private static var defaults: UserDefaults {
        return UserDefaults(suiteName: AppGroup.identifier) ?? .standard
    }

    // 저장된 기록을 읽어온다 (없으면 빈 기록)
    nonisolated static func load() -> EggRecord {
        guard let data = defaults.data(forKey: key),
              let record = try? JSONDecoder().decode(EggRecord.self, from: data) else {
            return EggRecord()
        }

        return record
    }

    // 기록을 저장한다
    nonisolated static func save(_ record: EggRecord) {
        guard let data = try? JSONEncoder().encode(record) else { return }

        defaults.set(data, forKey: key)
    }

    // 타이머 완료를 기록한다 (반숙/완숙 카운트 증가 + 완료 날짜 기록)
    nonisolated static func recordCompletion(isHardBoiled: Bool, now: Date = Date()) {
        let calendar = EggCalendar.mondayFirst
        let today = calendar.startOfDay(for: now)
        var record = load()

        // 날짜가 바뀌었으면 오늘 카운트를 리셋한다
        if record.todayDate != today {
            record.todayDate = today
            record.softBoiledCount = 0
            record.hardBoiledCount = 0
        }

        if isHardBoiled {
            record.hardBoiledCount += 1
        } else {
            record.softBoiledCount += 1
        }

        // 오늘 날짜를 완료 목록에 추가한다 (중복 방지)
        if !record.completedDates.contains(today) {
            record.completedDates.append(today)
        }

        // 이번 주 밖의 오래된 날짜는 정리해 배열이 무한히 커지지 않도록 한다
        let weekDays = EggCalendar.currentWeekDays(now: now)
        record.completedDates = record.completedDates.filter { date in
            weekDays.contains { calendar.isDate($0, inSameDayAs: date) }
        }

        save(record)
    }
}
