# 로또메이트 기술 문서 (LottoMate Technical Documentation)

이 문서는 LottoMate 앱의 기술 구현 전반을 다룹니다.

## 목차
1. 아키텍처 개요
2. 핵심 시스템
3. UI 컴포넌트
4. 화면 구조 및 구현
5. 데이터 관리
6. 유틸리티 및 헬퍼
7. 테스트
8. 부록

## 1. 아키텍처 개요
- [[프로젝트 구조|프로젝트-구조]]
- 패턴: ReactorKit + RxSwift
- 의존성 관리: CocoaPods

## 2. 핵심 시스템
- Reactor 상태 관리
- 네트워크 레이어(Moya)
- 로컬 저장소(UserDefaults / Keychain)
- 업데이트 정책(Local config 기반)

## 3. UI 컴포넌트
- [[공통 UI 요소|공통-UI-요소]]
- 배너, 토스트, 버튼 등 공통 컴포넌트

## 4. 화면 구조 및 구현
- 탭 기반 구성
- Home / Storage / WinnerGuide / Map / WinningReview 등 기능별 분리

## 5. 데이터 관리
- mock/live 모드 전환
- DTO 기반 모델 매핑
- 서비스 계층 추상화

## 6. 유틸리티 및 헬퍼
- Extensions
- Manager 계층
- QR 파서 및 공통 유틸

## 7. 테스트
- XCTest 기반 단위 테스트
- Mock sampleData 디코딩 테스트

## 8. 부록
- 사용 기술: [[사용 기술 (Technologies Used)|사용-기술-(Technologies-Used)]]
- 문제 해결 기록: [[문제 해결 과정|문제-해결-과정-(Problem‐Solving-Process)]]
- 리팩토링 기록: [[리팩토링 기록|리팩토링-기록-(Refactoring-Log)]]
