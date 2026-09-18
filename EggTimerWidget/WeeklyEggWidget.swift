//
//  WeeklyEggWidget.swift
//  EggTimerWidget
//
//  "이번 주 나의 에그타임!" - 이번 주(월~일) 완료 여부를 보여주는 중간 위젯.
//

import WidgetKit
import SwiftUI

struct WeeklyEggWidget: Widget {
    let kind = "WeeklyEggWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: EggRecordProvider()) { entry in
            WeeklyEggWidgetView(record: entry.record)
                .containerBackground(for: .widget) {
                    EggWidgetBackground()
                }
        }
        .configurationDisplayName(LocalizedStringResource("weeklyWidgetDisplayName"))
        .description(LocalizedStringResource("weeklyWidgetDescription"))
        .supportedFamilies([.systemMedium])
    }
}

struct WeeklyEggWidgetView: View {
    let record: EggRecord

    // 월요일 시작 요일 라벨 (Localizable 키)
    private let dayLabels = [
        "weekdayShortMon",
        "weekdayShortTue",
        "weekdayShortWed",
        "weekdayShortThu",
        "weekdayShortFri",
        "weekdayShortSat",
        "weekdayShortSun"
    ]

    var body: some View {
        let completion = record.weeklyCompletion()

        ZStack {
            // 계란 캐릭터 (오른쪽 모서리에 배치, 왼쪽으로 15° 기울여 잘림)
            GeometryReader { geo in
                let eggWidth = geo.size.width * 0.353
                let eggHeight = eggWidth * (570.0 / 390.0)

                Image("EggTwo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: eggWidth, height: eggHeight)
                    .rotationEffect(.degrees(-15))
                    .position(x: geo.size.width * 0.9418, y: geo.size.height * 0.7242)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("weeklyWidgetTitle")
                    .font(.eggWidgetTitle)
                    .foregroundStyle(.white)
                    .lineSpacing(2)

                weekdayRow(completion: completion)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    // 월~일 완료 여부를 흰색 반투명 카드에 나열한다
    private func weekdayRow(completion: [Bool]) -> some View {
        HStack(spacing: 4) {
            ForEach(Array(dayLabels.enumerated()), id: \.offset) { index, label in
                WeekdayCell(
                    label: label,
                    isCompleted: completion.indices.contains(index) ? completion[index] : false
                )
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.8))
        )
    }
}

// 요일 한 칸 (완료: 오렌지 원 + 체크 / 미완료: 흰색 테두리 원)
struct WeekdayCell: View {
    let label: String
    let isCompleted: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if isCompleted {
                    Circle()
                        .fill(Color("BrandPrimary"))

                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Circle()
                        .stroke(.white, lineWidth: 1.5)
                }
            }
            .frame(width: 28, height: 28)

            Text(LocalizedStringKey(label))
                .font(.eggWidgetDay)
                .foregroundStyle(Color("BrandPrimary"))
        }
        .frame(maxWidth: .infinity)
    }
}
