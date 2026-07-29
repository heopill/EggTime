# EggTimer Project Rules

## 기술 스택
- SwiftUI + TCA (The Composable Architecture)

## 코딩 컨벤션

### 함수 주석
- 함수 정의 위에 간략한 주석 설명을 추가한다.

```swift
/// 타이머를 시작한다
func startTimer() {
    ...
}
```

### return문 작성 규칙
- return문 위에 한 줄을 띄운다.
- 단, 함수 본문이 return문 한 줄만 있는 경우에는 띄우지 않는다.

```swift
// Good - 다른 코드가 있으면 한 줄 띄우고 return
func calculateTime() -> Int {
    let base = 60

    return base * multiplier
}

// Good - return문만 있으면 띄우지 않음
func defaultTime() -> Int {
    return 300
}
```

## 작업 검증 방침
- 코드 수정 후에는 **빌드(컴파일)가 성공하는지까지만** 확인한다.
- 시뮬레이터 실행, 스크린샷 캡처, 실제 동작(색상/레이아웃 등) 검증은 사용자가 직접 시뮬레이터에서 확인하므로 진행하지 않는다.
