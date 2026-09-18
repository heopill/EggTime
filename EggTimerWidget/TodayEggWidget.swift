//
//  TodayEggWidget.swift
//  EggTimerWidget
//
//  "오늘의 에그타임!" - 오늘 반숙/완숙 완료 횟수를 보여주는 작은 위젯.
//

import WidgetKit
import SwiftUI

struct TodayEggWidget: Widget {
    let kind = "TodayEggWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: EggRecordProvider()) { entry in
            TodayEggWidgetView(record: entry.record)
                .containerBackground(for: .widget) {
                    EggWidgetBackground()
                }
        }
        .configurationDisplayName(LocalizedStringResource("todayWidgetDisplayName"))
        .description(LocalizedStringResource("todayWidgetDescription"))
        .supportedFamilies([.systemSmall])
    }
}

struct TodayEggWidgetView: View {
    let record: EggRecord

    var body: some View {
        let counts = record.todayCounts()

        ZStack {
            // 계란 캐릭터 (우하단 모서리에 배치, 왼쪽으로 15° 기울여 절반만 보이도록 잘림)
            GeometryReader { geo in
                let eggWidth = geo.size.width * 0.751
                let eggHeight = eggWidth * (570.0 / 390.0)

                Image("EggTwo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: eggWidth, height: eggHeight)
                    .rotationEffect(.degrees(-15))
                    .position(x: geo.size.width * 0.9918, y: geo.size.height * 1.0290)
            }

            // 텍스트 (좌상단 정렬)
            VStack(alignment: .leading, spacing: 6) {
                Text("todayWidgetTitle")
                    .font(.eggWidgetCaption)

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(format: String(localized: "todayWidgetSoftCount"), counts.soft))
                    Text(String(format: String(localized: "todayWidgetHardCount"), counts.hard))
                }
                .font(.eggWidgetTitle)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .foregroundStyle(.white)
        }
    }
}
