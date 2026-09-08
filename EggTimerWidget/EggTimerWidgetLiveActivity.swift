//
//  EggTimerWidgetLiveActivity.swift
//  EggTimerWidget
//
//  Created by 허성필 on 8/25/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

// EggTimerWidgetAttributes는 앱과 공유하는 EggTimerWidgetAttributes.swift에 정의되어 있다.

// MARK: - Design Tokens

private extension Color {
    // 브랜드 오렌지 (#FF6F00) - 프로젝트 에셋
    static let brand = Color("BrandPrimary")
    // 밝은 배경/글자 (#EFEFEF) - 프로젝트 에셋
    static let eggBackground = Color("Background")
}

private extension Font {
    /// 진행/완료 안내 문구용 (Pretendard SemiBold 14)
    static let islandTitle = Font.custom("Pretendard-SemiBold", size: 14)
    /// compact 타이머 숫자용 (Pretendard SemiBold 12)
    static let islandCompactTime = Font.custom("Pretendard-SemiBold", size: 12)
    /// expanded / 잠금화면 타이머 숫자용 (Pretendard SemiBold 40)
    static let islandLargeTime = Font.custom("Pretendard-SemiBold", size: 40)
}

// MARK: - Reusable Views

// 남은 시간(또는 완료 시 00:00)을 표시하는 텍스트
struct EggTimerCountdownText: View {
    let state: EggTimerWidgetAttributes.ContentState
    let font: Font
    let color: Color

    var body: some View {
        Group {
            // 완료됐거나 이미 마감 시각이 지났으면 00:00 고정 (음수 카운트업 방지)
            if state.isCompleted || state.deadline <= Date() {
                Text("00:00")
            } else {
                Text(timerInterval: Date()...state.deadline, countsDown: true)
                    .multilineTextAlignment(.trailing)
            }
        }
        .font(font)
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .foregroundStyle(color)
    }
}

// 상태 아이콘 (진행중=Timer, 완료=Check)
struct EggTimerStatusIcon: View {
    let isCompleted: Bool
    let size: CGFloat
    let color: Color

    var body: some View {
        Image(isCompleted ? "Check" : "Timer")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(color)
    }
}

// MARK: - Live Activity

struct EggTimerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: EggTimerWidgetAttributes.self) { context in
            // 잠금화면 배너 (배경색 지정 가능 → 피그마 색상 그대로)
            lockScreenBanner(context)
                .activityBackgroundTint(context.state.isCompleted ? .eggBackground : .brand)
                .activitySystemActionForegroundColor(.brand)

        } dynamicIsland: { context in
            let isCompleted = context.state.isCompleted
            // 검정 배경 위에서는 진행중=오렌지 / 완료=밝은색
            let tint: Color = isCompleted ? .eggBackground : .brand

            return DynamicIsland {
                // expanded: 문구(왼쪽)+타이머(오른쪽)를 세로 중앙 정렬로 배치한다 (leading/trailing은 노치 옆 세로 중앙)
                DynamicIslandExpandedRegion(.leading) {
                    Text(message(isCompleted: isCompleted))
                        .font(.islandTitle)
                        .foregroundStyle(tint)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .fixedSize()
                        .frame(maxHeight: .infinity, alignment: .center)
                        .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    EggTimerCountdownText(state: context.state, font: .islandLargeTime, color: tint)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                        .padding(.trailing, 4)
                }
            } compactLeading: {
                // compact 왼쪽: 상태 아이콘
                EggTimerStatusIcon(isCompleted: isCompleted, size: 18, color: tint)
            } compactTrailing: {
                // compact 오른쪽: 남은 시간
                EggTimerCountdownText(state: context.state, font: .islandCompactTime, color: tint)
                    .frame(maxWidth: 44)
            } minimal: {
                // minimal: 상태 아이콘만
                EggTimerStatusIcon(isCompleted: isCompleted, size: 16, color: tint)
            }
        }
    }

    // 잠금화면 배너 뷰 (진행중=밝은 글씨 / 완료=오렌지 글씨)
    private func lockScreenBanner(_ context: ActivityViewContext<EggTimerWidgetAttributes>) -> some View {
        let isCompleted = context.state.isCompleted
        let contentColor: Color = isCompleted ? .brand : .eggBackground

        return HStack(alignment: .center, spacing: 12) {
            Text(message(isCompleted: isCompleted))
                .font(.islandTitle)
                .foregroundStyle(contentColor)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .fixedSize()

            // 타이머가 나머지 공간을 채우며 오른쪽 정렬 (fixedSize를 쓰면 진행중 타이머가 사라짐)
            EggTimerCountdownText(state: context.state, font: .islandLargeTime, color: contentColor)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // 상태별 안내 문구 (피그마 디자인대로 두 줄로 표시, 위젯 번들의 문자열 카탈로그로 로컬라이징)
    private func message(isCompleted: Bool) -> LocalizedStringResource {
        return isCompleted ? "맛있는 계란이\n준비되었어요!" : "계란이 맛있게\n익고 있어요!"
    }
}

// MARK: - Preview

extension EggTimerWidgetAttributes {
    fileprivate static var preview: EggTimerWidgetAttributes {
        EggTimerWidgetAttributes()
    }
}

extension EggTimerWidgetAttributes.ContentState {
    // 진행중 (03:10 남음)
    fileprivate static var running: EggTimerWidgetAttributes.ContentState {
        EggTimerWidgetAttributes.ContentState(
            startDate: Date(),
            deadline: Date().addingTimeInterval(190),
            isCompleted: false
        )
    }

    // 완료
    fileprivate static var completed: EggTimerWidgetAttributes.ContentState {
        EggTimerWidgetAttributes.ContentState(
            startDate: Date().addingTimeInterval(-600),
            deadline: Date(),
            isCompleted: true
        )
    }
}

#Preview("Dynamic Island", as: .dynamicIsland(.expanded), using: EggTimerWidgetAttributes.preview) {
    EggTimerWidgetLiveActivity()
} contentStates: {
    EggTimerWidgetAttributes.ContentState.running
    EggTimerWidgetAttributes.ContentState.completed
}

#Preview("Lock Screen", as: .content, using: EggTimerWidgetAttributes.preview) {
    EggTimerWidgetLiveActivity()
} contentStates: {
    EggTimerWidgetAttributes.ContentState.running
    EggTimerWidgetAttributes.ContentState.completed
}
