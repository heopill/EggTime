//
//  EggInfoView.swift
//  EggTimer
//

import SwiftUI

// 달걀 익힘 정도 (촉촉한 반숙 ~ 완숙)
enum EggDoneness: Int, CaseIterable, Identifiable {
    case one, two, three, four

    var id: Int { rawValue }

    // 달걀 이미지 에셋 이름
    var imageName: String {
        switch self {
        case .one: return "EggOne"
        case .two: return "EggTwo"
        case .three: return "EggThree"
        case .four: return "EggFour"
        }
    }

    // 달걀 이미지 원본 크기 (에셋 기준, 달걀마다 크기가 다름)
    var imageSize: CGSize {
        switch self {
        case .one: return CGSize(width: 128, height: 187)
        case .two: return CGSize(width: 127, height: 176)
        case .three: return CGSize(width: 125, height: 176)
        case .four: return CGSize(width: 126, height: 176)
        }
    }

    // 익힘 정도 이름
    var title: String {
        switch self {
        case .one: return "촉촉한 반숙"
        case .two: return "적당한 반숙"
        case .three: return "거의 완숙"
        case .four: return "완숙"
        }
    }
}

struct EggInfoView: View {
    // 모든 달걀에 공통으로 표시되는 설명글 (추후 변경될 수 있어 파라미터로 받음)
    let description: String

    @State private var selection: EggDoneness = .one

    // 달걀 이미지를 감싸는 프레임 (크기가 달라도 동일한 위치에 배치되도록)
    private let eggFrameSize: CGFloat = 200
    // 좌우 회전 각도 및 한 사이클에 걸리는 시간(초)
    // ⚠️ Water(TimerView)와 회전 위상을 맞추기 위해 period는 Water와 동일하게 유지한다
    private let wobbleAngle: Double = 10
    private let wobblePeriod: Double = 6

    var body: some View {
        VStack(spacing: 16) {
            TabView(selection: $selection) {
                ForEach(EggDoneness.allCases) { egg in
                    eggPage(egg)
                        .tag(egg)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 290)

            pageIndicator
        }
    }

    // 달걀 이미지 + 익힘 정도 텍스트 한 페이지
    private func eggPage(_ egg: EggDoneness) -> some View {
        VStack(spacing: 8) {
            // .page TabView 안에서는 시간 기반(TimelineView) 회전이 안정적으로 동작한다
            TimelineView(.animation) { timeline in
                Image(egg.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: egg.imageSize.width, height: egg.imageSize.height)
                    .rotationEffect(.degrees(currentAngle(at: timeline.date)))
                    .frame(width: eggFrameSize, height: eggFrameSize)
            }

            VStack(spacing: 4) {
                Text(egg.title)
                    .fontStyle(.title32)
                    .foregroundColor(Color("TextStrong"))

                Text(description)
                    .fontStyle(.body16)
                    .foregroundColor(Color(hex: "555555"))
            }
        }
    }

    // 페이지 인디케이터 (현재 달걀만 강조)
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(EggDoneness.allCases) { egg in
                Circle()
                    .fill(egg == selection ? Color("Primary") : Color(hex: "8ACDE1"))
                    .frame(width: 8, height: 8)
            }
        }
    }

    // 현재 시각 기준 -wobbleAngle ~ wobbleAngle 사이를 반복하는 회전 각도
    // Water와 동일한 절대 시간 + cos 위상을 사용해 회전 방향이 일치한다
    private func currentAngle(at date: Date) -> Double {
        let t = date.timeIntervalSinceReferenceDate

        return wobbleAngle * cos(2 * .pi * t / wobblePeriod)
    }
}

#Preview {
    EggInfoView(description: "반숙 설명글입니다.")
}
