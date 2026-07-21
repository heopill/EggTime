//
//  SettingRadioOptionView.swift
//  EggTimer
//

import SwiftUI

// 여러 선택지 중 하나만 고르는 라디오 옵션 카드 (선택지 개수는 가변)
struct SettingRadioOptionView<Option: Hashable>: View {
    // 표시할 선택지 목록
    let options: [Option]
    // 각 선택지의 표시 텍스트
    let title: (Option) -> String
    // 현재 선택된 선택지
    let selected: Option
    // 선택지 탭 동작
    var onSelect: (Option) -> Void = { _ in }

    var body: some View {
        VStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                row(option)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // 선택지 제목 + 라디오 버튼으로 구성된 한 줄
    private func row(_ option: Option) -> some View {
        Button {
            onSelect(option)
        } label: {
            HStack(spacing: 10) {
                Text(title(option))
                    .fontStyle(.body16)
                    .foregroundColor(Color("TextNormal"))
                    .frame(maxWidth: .infinity, alignment: .leading)

                radioButton(isSelected: option == selected)
            }
            .frame(height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // 선택 여부에 따른 라디오 버튼 (선택 시 주황 링 + 가운데 점)
    private func radioButton(isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .strokeBorder(
                    isSelected ? Color("BrandPrimary") : Color(hex: "D9D9D9"),
                    lineWidth: 2
                )

            if isSelected {
                Circle()
                    .fill(Color("BrandPrimary"))
                    .frame(width: 12, height: 12)
            }
        }
        .frame(width: 24, height: 24)
    }
}

#Preview {
    SettingRadioOptionView(
        options: ["선택지 1", "선택지 2", "선택지 3", "선택지 4", "선택지 5"],
        title: { $0 },
        selected: "선택지 3"
    )
    .frame(width: 335)
    .padding()
    .background(Color(.background))
}
