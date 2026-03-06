## 프로젝트 구조
```
📁 LottoMate
├─ 📁 Presentation
│  ├─ 📁 Components
│  │  ├─ 📁 Banner
│  │  │  ├─ BannerView.swift
│  │  │  ├─ BannerManager.swift
│  │  │  └─ BannerType.swift
```

<img width="317" alt="Screenshot 2024-12-20 at 6 20 23 PM" src="https://github.com/user-attachments/assets/479bfbc6-fcfb-41a9-b5c1-af7c5cb3dfd8" />

<img width="1000" alt="Screenshot 2024-12-20 at 6 20 23 PM" src="https://github.com/user-attachments/assets/c4e807e6-af5c-4b46-a419-e43134370d1c" />

## 배너 네비게이션 시스템
### Overview
배너 네비게이션 시스템은 앱 전반에 걸쳐 랜덤으로 표시되는 배너의 탭 이벤트를 처리하고 적절한 화면으로 전환하는 역할을 합니다.  
BannerNavigationDelegate 프로토콜을 사용하여 배너와 화면 전환 로직을 분리하고, 각 화면에서 유연하게 네비게이션을 처리할 수 있도록 설계되었습니다.
<br>
<br>
### Core Components
#### BannerNavigationDelegate

📁 `App/Presentation/Components/Banner/BannerView.swift`  

```swift
protocol BannerNavigationDelegate: AnyObject {
    func navigate(to bannerType: BannerType)
}
```
- 배너 탭 이벤트에 따른 화면 전환을 처리하는 프로토콜
- 각 화면의 ViewController에서 구현하여 해당 화면에 맞는 네비게이션 로직 정의

#### BannerType
```swift
enum BannerType {
    case winningStore          // 당첨 판매점 보기
    case winnerReview          // 당첨자 후기 보기
    case numberPickerYellow    // 로또 번호 뽑기 (스타일1)
    case numberPickerBlue      // 로또 번호 뽑기 (스타일2)
    case winningLottoInfo      // 당첨 로또 정보
    case qrCodeScanner         // QR 스캐너
    case winnerGuideYellow     // 당첨자 가이드 (스타일1)
    case winnerGuideBlue       // 당첨자 가이드 (스타일2)
}
```
- 앱에서 사용되는 모든 배너 타입을 정의
- 각 case는 고유한 디자인과 네비게이션 동작을 가짐

#### BannerView
배너의 UI와 탭 이벤트 처리를 담당하는 커스텀 뷰입니다.
<br>
<br>
### Implementation Guide

#### 1. 배너 생성
```swift
// ViewController에서 배너 생성 후 view의 bannerContainer에 추가
private func setupBanner() {
    let banner = BannerManager.shared.createRandomBanner(navigationDelegate: self)
    // let banner = BannerManager.shared.createBanner(type: .winningStore, navigationDelegate: self) // 테스트용
    homeView.bannerContainer.flex.addItem(banner)
}
```

#### 2. 네비게이션 처리
```swift
extension HomeViewController: BannerNavigationDelegate {
    func navigate(to bannerType: BannerType) {
        switch bannerType {
        case .numberPickerYellow, .numberPickerBlue:
            showStorageRandomNumbersView()
        case .winningLottoInfo:
            reactor.action.onNext(.showWinningInfo)
        case .winnerGuideYellow, .winnerGuideBlue:
            reactor.action.onNext(.showWinnerGuide)
        // ... 기타 케이스들
        }
    }
}
```

### Benefits

1. **뷰/로직 분리**
   - 배너 UI와 네비게이션 로직이 분리되어 있어 유지보수가 용이
   - 각 화면에서 독립적으로 네비게이션 처리 가능

2. **확장성**
   - 새로운 배너 타입 추가가 용이
   - 각 화면에서 필요한 네비게이션 동작을 유연하게 구현 가능

3. **재사용성**
   - 동일한 배너를 다른 화면에서도 쉽게 사용 가능
   - 네비게이션 로직만 화면에 맞게 수정하여 사용

### Notes

- 배너 타입 추가 시 BannerType enum과 해당 configuration 업데이트 필요
- 각 ViewController에서 처리하지 않는 배너 타입에 대한 기본 동작 정의 필요
- 화면 전환 시 메모리 관리에 주의 (weak 참조 사용)