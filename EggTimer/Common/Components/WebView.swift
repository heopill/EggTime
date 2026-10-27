//
//  WebView.swift
//  EggTimer
//

import SwiftUI
import WebKit

// 번들에 포함된 로컬 HTML 파일을 표시하는 WebView
struct WebView: UIViewRepresentable {
    // 표시할 로컬 HTML 파일 URL
    let fileURL: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        // 배경을 앱과 맞추고(투명), 가로 스크롤은 막는다
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear

        // file:// 로드는 시뮬레이터에서 한글 글꼴이 깨지는 문제가 있어, HTML 문자열로 로드한다
        if let html = try? String(contentsOf: fileURL, encoding: .utf8) {
            webView.loadHTMLString(html, baseURL: fileURL.deletingLastPathComponent())
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        /// 본문의 링크(웹 · 메일)는 WebView 안에서 이동하지 않고 Safari · 메일 앱으로 연다
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            guard navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url else {
                return .allow
            }

            await UIApplication.shared.open(url)

            return .cancel
        }
    }
}
