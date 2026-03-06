# LottoMate Public Release Spec & Plan

## 1. 문서 목적
- 이 문서는 LottoMate iOS 프로젝트를 `public repository`로 전환하기 위한 실행 스펙과 체크리스트를 정의한다.
- 목표는 다음 4가지를 동시에 달성하는 것이다.
1. 민감정보 노출 방지
2. 코드 구조 개선(리팩토링)
3. 백엔드 미사용 환경에서 Mock 데이터 기반 정상 동작
4. XCTest 기반 품질 기준선 확보

## 2. 범위
### In Scope
1. 민감정보 점검 및 정리
2. 아키텍처 정리 및 대형 파일 분해
3. 네트워크 의존 코드의 Mock 전환
4. Unit/UI 테스트 추가
5. 공개용 README/문서 정리

### Out of Scope
1. 신규 기능 개발
2. 서버 기능 복구
3. 디자인 전면 개편

## 3. 현재 진단 요약
1. `GoogleService-Info.plist`가 추적 중이며 공개 전 정책 확정이 필요하다.
2. `Config.xcconfig`는 필수 값(서버/외부 연동)이 있으나 Git ignore 상태라 재현 가능한 빌드 구성이 약하다.
3. `xcuserdata`, breakpoint 등 개인 개발 환경 파일이 추적 중이다.
4. 대형 View/ViewController 파일(약 800~1200 LOC+)이 다수 존재한다.
5. 서버 호출 코드가 Reactor/Service 곳곳에 분산되어 Mock 전환 시 영향 범위가 넓다.
6. XCTest는 최소 수준이며 회귀 방지용 테스트가 부족하다.

## 3-1. Firebase 처리 정책 (확정)
1. 공개용 저장소에는 `GoogleService-Info.plist`를 포함하지 않는다.
2. Firebase Remote Config 기반 업데이트 체크는 제거한다.
3. 업데이트 정책은 `LocalUpdateConfigProvider`로 대체한다.
4. 기본 동작은 로컬 버전 정책(번들/상수)으로 결정한다.
5. 향후 필요 시 `UpdateConfigProvider` 프로토콜 구현체로만 재연결한다.
6. 공개 기본 모드는 `DataMode=mock`으로 운영한다.

## 4. 성공 기준 (Release Gate)
아래 6개를 모두 충족해야 공개 전환 완료로 본다.
1. 민감값/개인환경 파일 미노출
2. 클린 상태에서 문서만 보고 빌드 가능
3. 백엔드 없이 주요 화면 정상 동작(Mock)
4. 핵심 비즈니스 로직 테스트 통과
5. 최소 UI 스모크 테스트 통과
6. README에 실행 방법/한계/구조가 명확히 문서화됨

## 5. 트랙별 스펙 및 체크리스트

### Track A. Security & Public Hygiene
#### 스펙
1. 비밀값은 저장소에 직접 커밋하지 않는다.
2. `example` 템플릿과 실제 로컬 파일을 분리한다.
3. 민감 로그(토큰, raw response) 출력 금지 또는 마스킹한다.

#### 작업 체크리스트
- [ ] `Config.xcconfig.example` 생성 (dummy 값)
- [ ] `Config.xcconfig`는 ignore 유지 + README에 생성 절차 기재
- [ ] README에 `NMF_CLIENT_ID`는 사용자 개인 값 입력이 필요함을 명시
- [ ] `GoogleService-Info.plist` 처리 정책 결정
- [ ] `UpdateCheckService`를 `LocalUpdateConfigProvider` 기반으로 전환
- [ ] 개인 파일(`xcuserdata`, breakpoints, IDE scopes) 추적 해제
- [ ] 로그 정리: 토큰/응답 원문 `print` 제거 또는 `#if DEBUG + redaction`
- [ ] 키 회전 필요 목록 정리(Firebase/Naver/Google 등)
- [ ] 공개 전 최종 스캔 실행(`rg` 패턴 스캔)

#### 완료 기준 (DoD)
1. 민감 파일/값이 `git ls-files`에 남아있지 않다.
2. 신규 클론 환경에서 설정 가이드대로 빌드 준비가 가능하다.
3. `NMF_CLIENT_ID` 미설정 시 필요한 조치가 문서에 명확히 안내된다.
4. 키 노출 위험 로그가 기본 빌드 경로에 존재하지 않는다.

### Track B. Refactoring
#### 스펙
1. 거대 파일을 역할 기준으로 분해한다(UI/Binding/Navigation/State).
2. 네트워크 직접 호출은 Service/Repository 경계로 모은다.
3. 사이드이펙트(네트워크/스토리지/시간)를 주입 가능하게 만든다.

#### 우선순위 대상
1. `SettingView.swift`
2. `HomeView.swift`
3. `WinnerGuideView.swift`
4. `MapViewController.swift`
5. `HomeViewController.swift`

#### 작업 체크리스트
- [ ] 파일 분해 규칙 문서화(`FeatureName+UI`, `+Bind`, `+Action` 등)
- [ ] 공통 로깅 인터페이스 도입
- [ ] Service Protocol 도입 및 직접 `MoyaProvider` 생성 축소
- [ ] 임시/테스트 코드(TODO, test path, debug prints) 제거
- [ ] 리팩토링 이후 동작 동등성 점검(주요 화면 수동 시나리오)

#### 완료 기준 (DoD)
1. 대상 파일 LOC 감소 및 책임 분리가 명확하다.
2. Reactor/View 계층에서 테스트 가능한 단위가 증가한다.
3. 기능 회귀 없이 주요 사용자 흐름이 유지된다.

### Track C. Mock Data 전환
#### 스펙
1. 앱을 `Live`/`Mock` 모드로 전환할 수 있어야 한다.
2. 백엔드 미사용 시에도 주요 화면의 데이터/에러 상태를 재현할 수 있어야 한다.
3. Mock 데이터는 번들 JSON + 코드 상수 조합으로 관리한다.

#### 대상 도메인
1. 홈 당첨 정보/회차 조회
2. 지도 판매점 목록/상세/정렬
3. 당첨 후기 목록/상세
4. 번호 저장(성공/실패 시나리오)

#### 작업 체크리스트
- [ ] `DataMode`(live/mock) 플래그 추가
- [ ] Repository Protocol 정의(`Lottery`, `Map`, `Review`, `Storage`)
- [ ] Mock Repository 구현(성공/실패/지연 시나리오)
- [ ] DI 구성(초기 진입점에서 모드별 주입)
- [ ] 오프라인 모드 수동 검증 시나리오 문서화

#### 완료 기준 (DoD)
1. 백엔드 접속 없이 앱 핵심 화면 렌더링이 가능하다.
2. 에러 상태 UI를 재현 가능하다.
3. Live 전환 시 코드 수정 없이 설정값만으로 동작한다.

### Track D. XCTest
#### 스펙
1. 우선 `순수 로직`과 `Reactor 상태 전이`를 테스트한다.
2. 네트워크는 Mock 주입 기반으로 테스트한다.
3. UI 테스트는 스모크 수준부터 시작한다.

#### 작업 체크리스트
- [ ] `getLotteryTypeValue` 케이스 테스트
- [ ] 당첨 등수 계산 로직 테스트
- [ ] 날짜/회차 계산 로직 테스트
- [ ] QR 파싱 유효/무효 케이스 테스트
- [ ] Home/Map/WinningReview Reactor mutation 테스트
- [ ] DTO decode 테스트(JSON fixture 기반)
- [ ] UI Smoke 테스트(앱 실행, 탭 이동, 핵심 화면 진입)

#### 완료 기준 (DoD)
1. 핵심 로직 테스트가 CI 또는 로컬에서 안정 통과한다.
2. Mock 기반 테스트로 네트워크 비의존 회귀 검출이 가능하다.
3. 실패 시 원인을 빠르게 파악할 수 있는 테스트 구조를 갖춘다.

## 6. 일정 제안 (2주 기준)
1. Day 1-2: Track A (공개 안전화)
2. Day 3-6: Track C (Mock 전환)
3. Day 7-10: Track B (리팩토링 1차)
4. Day 11-14: Track D (테스트 + 문서 마감)

## 6-1. 실행 순서 (이번 작업 기준)
1. 문서 업데이트
2. `Config.xcconfig.example` 생성 및 README 정합화
3. Firebase/Remote Config 의존 제거
4. 민감/개인 파일 정리
5. Mock 전환
6. 리팩토링
7. XCTest 확대

## 7. 산출물 목록
1. 공개 준비 체크리스트 완료 이력
2. 설정 템플릿(`*.example`) 및 실행 가이드
3. Mock 데이터/Repository 구현
4. 리팩토링된 구조 및 변경 기록
5. XCTest 코드 + 테스트 실행 가이드

## 8. PR 운영 규칙
1. Track별로 브랜치/PR 분리
2. PR 당 목적 1개 원칙
3. PR 템플릿에 “보안 영향 / 테스트 결과 / Mock 영향” 필수 기입
4. 대형 리팩토링은 기계적 변경과 로직 변경 PR 분리

## 9. 공개 전 최종 점검 체크리스트 (Master)
- [ ] 민감정보 스캔 완료 및 이슈 0건
- [ ] 개인 환경 파일 추적 해제 완료
- [ ] 로컬 새 클론 기준 빌드 절차 검증 완료
- [ ] Mock 모드 핵심 시나리오 동작 확인
- [ ] XCTest 최소 기준 통과
- [ ] README 및 문서 업데이트 완료
- [ ] 이력서 첨부용 링크/설명 문구 확정
