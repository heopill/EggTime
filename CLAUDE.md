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

### Localizable 키 네이밍
- Localizable(String Catalog) 키는 `-`나 `_` 같은 구분자를 사용하지 않는다.
- 단어를 붙여쓰되 다음 단어의 첫 글자를 대문자로 하는 camelCase로 작성한다.
- 키에는 한글을 쓰지 않고, 표시 문자열은 코드에 직접 한글을 쓰지 않는다.

```swift
// Good
Text("todayWidgetTitle")

// Bad
Text("today_widget_title")
Text("오늘의 에그타임!")
```

## 작업 검증 방침
- 코드 수정 후에는 **빌드(컴파일)가 성공하는지까지만** 확인한다.
- 시뮬레이터 실행, 스크린샷 캡처, 실제 동작(색상/레이아웃 등) 검증은 사용자가 직접 시뮬레이터에서 확인하므로 진행하지 않는다.
