//
//  BannerAdView.swift
//  EggTimer
//

import SwiftUI
import GoogleMobileAds

// 배너 광고를 노출하는 위치별 AdMob 광고 단위
enum BannerAdUnit {
    case home
    case setting
    case recipeDetail

    // 광고 단위 ID (디버그 빌드에서는 실제 광고 대신 구글 테스트 광고 단위를 사용한다)
    var id: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/2435281174"
        #else
        switch self {
        case .home: return "ca-app-pub-1475161326527575/6458608814"
        case .setting: return "ca-app-pub-1475161326527575/2860029176"
        case .recipeDetail: return "ca-app-pub-1475161326527575/7780263496"
        }
        #endif
    }
}

// 화면 너비에 꽉 차는 높이 50의 배너 광고
struct BannerAdView: View {
    // 배너 영역 높이 (광고가 없을 때도 같은 높이를 유지해 레이아웃이 흔들리지 않게 한다)
    static let height: CGFloat = 50

    let adUnit: BannerAdUnit

    var body: some View {
        GeometryReader { proxy in
            if proxy.size.width > 0 {
                BannerAdContainer(adUnitID: adUnit.id, width: proxy.size.width, maxHeight: Self.height)
                    .frame(width: proxy.size.width, height: Self.height)
            }
        }
        .frame(height: Self.height)
    }
}

// GoogleMobileAds의 BannerView(UIKit)를 SwiftUI에서 쓰기 위한 래퍼
private struct BannerAdContainer: UIViewRepresentable {
    let adUnitID: String
    let width: CGFloat
    let maxHeight: CGFloat

    /// 너비에 맞춘 적응형 배너를 만들고 광고를 요청한다
    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: inlineAdaptiveBanner(width: width, maxHeight: maxHeight))
        bannerView.adUnitID = adUnitID
        bannerView.load(Request())

        return bannerView
    }

    /// 광고는 생성 시 한 번만 요청하므로 갱신할 내용이 없다
    func updateUIView(_ uiView: BannerView, context: Context) {}
}
