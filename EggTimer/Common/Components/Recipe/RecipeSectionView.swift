//
//  RecipeSectionView.swift
//  EggTimer
//

import SwiftUI

// 레시피 상세의 접었다 펼 수 있는 섹션 (설명/재료/조리법 등에 재사용)
struct RecipeSectionView<Content: View>: View {
    // 섹션 제목 (예: "재료")
    let title: String
    // 펼침 여부 (섹션 내부에서 관리)
    @State private var isExpanded: Bool
    // 펼쳤을 때 표시할 내용
    @ViewBuilder let content: () -> Content

    init(
        title: String,
        isExpanded: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self._isExpanded = State(initialValue: isExpanded)
        self.content = content
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            if isExpanded {
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 22)
                    .background(Color.white)
            }
        }
        .overlay(alignment: .top) {
            // 섹션 상단 구분선 (2pt)
            Rectangle()
                .fill(Color("Background"))
                .frame(height: 2)
        }
    }

    // 제목 + chevron 헤더 (탭하면 펼침/접힘 토글)
    private var header: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 10) {
                Text(title)
                    .fontStyle(.title16)
                    .foregroundColor(Color("TextNormal"))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image("ChevronDown")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(Color("TextNormal"))
                    .frame(width: 24, height: 24)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .padding(12)
            .frame(height: 68)
            .frame(maxWidth: .infinity)
            .background(Color.white)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 0) {
            RecipeSectionView(title: "설명") {
                Text("부드럽게 삶은 달걀과 고소한 마요네즈가 어우러진 달걀 샐러드는 간단하면서도 든든한 한 끼로 즐기기 좋습니다.")
                    .fontStyle(.body16)
                    .foregroundColor(Color("TextNormal"))
            }

            RecipeSectionView(title: "재료") {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(["달걀 4개", "마요네즈 3큰술", "다진 양파 2큰술", "소금 약간"], id: \.self) { item in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                            Text(item)
                        }
                        .fontStyle(.body16)
                        .foregroundColor(Color("TextNormal"))
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}
