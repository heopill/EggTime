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
        case .one: return CGSize(width: 130, height: 194)
        case .two: return CGSize(width: 130, height: 190)
        case .three: return CGSize(width: 130, height: 190)
        case .four: return CGSize(width: 130, height: 190)
        }
    }

    // 익힘 정도 이름
    var title: String {
        switch self {
        case .one: return String(localized: "Runny", table: "Common")
        case .two: return String(localized: "Soft", table: "Common")
        case .three: return String(localized: "Medium", table: "Common")
        case .four: return String(localized: "Hard-boiled", table: "Common")
        }
    }

    // 익힘 정도별 설명글
    var description: String {
        switch self {
        case .one: return String(localized: "Soft-boiled with a runny yolk", table: "Common")
        case .two: return String(localized: "Soft-boiled with a moist yolk", table: "Common")
        case .three: return String(localized: "Soft-boiled with a medium yolk", table: "Common")
        case .four: return String(localized: "Hard-boiled with a fully cooked yolk", table: "Common")
        }
    }

    // 익힘 정도별 타이머 시간(초)
    var duration: Int {
        switch self {
        case .one: return 6 * 60
        case .two: return 8 * 60
        case .three: return 10 * 60
        case .four: return 12 * 60
        }
    }
}

struct EggInfoView: View {
    // 현재 선택된 달걀 (스와이프 시 상위 뷰의 타이머 시간과 연동)
    @Binding var selection: EggDoneness
    // 타이머 진행 중에는 달걀 선택 스와이프를 막는다
    var isSwipeDisabled: Bool = false

    // 달걀 이미지를 감싸는 프레임 (크기가 달라도 동일한 위치에 배치되도록)
    private let eggFrameSize: CGFloat = 200

    var body: some View {
        VStack(spacing: 16) {
            TabView(selection: $selection) {
                ForEach(EggDoneness.allCases) { egg in
                    eggPage(egg)
                        .tag(egg)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 278)
            .disabled(isSwipeDisabled)

            pageIndicator
        }
    }

    // 달걀 이미지 + 익힘 정도 텍스트 한 페이지
    private func eggPage(_ egg: EggDoneness) -> some View {
        VStack(spacing: 8) {
            Image(egg.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: egg.imageSize.width, height: egg.imageSize.height)
                .frame(width: eggFrameSize, height: eggFrameSize)

            VStack(spacing: 4) {
                Text(egg.title)
                    .fontStyle(.title32)
                    .foregroundColor(Color("TextStrong"))

                Text(egg.description)
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
                    .fill(egg == selection ? Color("BrandPrimary") : Color("Dot"))
                    .frame(width: 8, height: 8)
            }
        }
    }

}

#Preview {
    EggInfoView(selection: .constant(.one))
}
