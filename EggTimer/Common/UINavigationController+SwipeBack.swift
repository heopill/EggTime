//
//  UINavigationController+SwipeBack.swift
//  EggTimer
//

import UIKit

// 네비게이션 바(뒤로가기 버튼)를 숨긴 화면에서도 좌측 엣지 스와이프로 뒤로가기가 되도록 한다
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    // 스택에 되돌아갈 화면이 있을 때만 스와이프 뒤로가기를 허용한다 (루트에서는 비활성)
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
