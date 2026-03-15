# ReactorKit / RxSwift Refactoring Guide

## 목적

이 문서는 LottoMate 프로젝트 리팩토링 작업 시 매번 확인하는 공통 기준 문서입니다.  
목표는 아래와 같습니다.

1. `View`를 렌더링 전용으로 단순화합니다.
2. 상태 흐름을 Reactor 중심으로 일원화합니다.
3. 화면 이동과 외부 동작을 화면 코드에서 분리합니다.
4. 큰 파일을 역할별로 분해해 수정성과 테스트 용이성을 높입니다.

## 핵심 원칙

### 1. View

- `View`는 상태를 직접 저장하지 않습니다.
- `View`는 UI 이벤트를 외부로 전달하고, 전달받은 상태를 렌더링만 합니다.
- `View` 안에서 API 호출, 저장, 지연 실행, 화면 이동을 하지 않습니다.
- 상태 변경마다 전체 뷰를 다시 만드는 패턴을 줄이고, 고정 레이아웃 위에 데이터만 갱신합니다.

### 2. Reactor

- Reactor는 화면의 단일 상태 소스여야 합니다.
- 사용자 입력은 가능한 한 모두 `Action`으로 수렴합니다.
- Reactor는 상태 계산과 비동기 흐름 조합만 담당합니다.
- Reactor 안에서 UIKit 객체를 직접 다루지 않습니다.

### 3. ViewController

- `ViewController`는 생명주기, navigation, modal, toast, alert 같은 외부 동작만 담당합니다.
- 일회성 화면 이동이나 표시 이벤트는 상태값이 아니라 route 또는 별도 이벤트로 처리합니다.
- 긴 분기 로직이 생기면 `Handler`, `Coordinator`, `Service`로 이동합니다.

### 4. Service / Handler

- API 호출
- `UserDefaults`, clipboard, 권한 요청
- QR 처리
- 로딩 단계 제어
- 화면 전환 판단 로직

위 책임은 화면 본문이 아니라 별도 타입으로 분리합니다.

## 금지 패턴

- `View` 내부에서 `DispatchQueue`, `UserDefaults`, 랜덤 mock, 화면 이동 처리
- Reactor와 singleton `ViewModel` 동시 사용
- `Bool` 상태값으로 화면 전환 트리거 관리
- `subviews.removeFromSuperview()` 후 전체 재조립 반복
- 하나의 메서드에서 렌더링, 비즈니스 로직, navigation을 동시에 처리
- 테스트용 코드와 운영 코드를 같은 흐름에 섞어 유지

## 권장 구조

한 기능은 아래 구조를 기본으로 합니다.

1. `ViewController`
2. `View`
3. `Reactor`
4. `Service` / `Handler`
5. `Mapper` / `Formatter`
6. `Component View`

파일이 커지면 아래 순서로 먼저 분리합니다.

1. 입력 폼 또는 바텀시트
2. 반복 카드 또는 섹션
3. 포맷터와 표시 모델
4. 외부 동작 처리기

## 작업 순서

리팩토링은 아래 순서로 진행합니다.

1. 현재 파일의 상태, 입력, 화면 이동, 외부 동작을 분리해서 적습니다.
2. 어떤 값이 Reactor 상태이고 어떤 값이 일회성 이벤트인지 구분합니다.
3. 입력 경로를 `Action` 중심으로 정리합니다.
4. `View` 내부의 비동기 호출과 저장 로직을 제거합니다.
5. 긴 렌더링 메서드를 컴포넌트로 분리합니다.
6. 화면 이동과 토스트를 `ViewController` 또는 별도 처리기로 이동합니다.
7. 필요한 mapper, formatter, handler를 추가합니다.
8. Reactor 테스트가 가능한 구조인지 확인합니다.

## HomeView 기준 적용 포인트

- `HomeView`는 Reactor 외에 별도 singleton `ViewModel` 의존성을 제거해야 합니다.
- 결과 카드 조립 코드는 섹션 컴포넌트로 분리해야 합니다.
- 복권 타입 전환, 회차 이동, QR 확인, 지도 이동, 공지 이동은 입력 경로를 일관되게 맞춰야 합니다.
- `HomeViewController`의 QR 분기와 화면 전환 흐름은 별도 handler 또는 route 체계로 분리해야 합니다.
- `State Bool -> navigation` 패턴은 route 또는 일회성 이벤트 처리로 바꿔야 합니다.

## 완료 기준

아래 조건을 만족하면 1차 리팩토링 완료로 봅니다.

1. `View`가 렌더링 중심 구조로 정리되어 있습니다.
2. 상태 흐름이 Reactor 중심으로 정리되어 있습니다.
3. 화면 이동과 외부 동작이 화면 본문에서 분리되어 있습니다.
4. 큰 메서드가 섹션 또는 컴포넌트 단위로 나뉘어 있습니다.
5. mock 또는 임시 코드가 운영 흐름에서 제거되어 있습니다.
6. 기존 기능이 깨질 가능성이 큰 지점이 식별되어 있습니다.
7. 최소한의 Reactor 테스트 추가가 가능한 구조가 되어 있습니다.
