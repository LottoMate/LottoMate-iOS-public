//
//  QRWinningCheckLoadingView.swift
//  LottoMate
//
//  Created by Mirae on 4/28/25.
//

import UIKit
import FlexLayout
import PinLayout

class QRWinningCheckLoadingView: UIView {
    fileprivate let rootFlexContainer = UIView()
    
    // MARK: - UI Elements
    private let loadingImageView = UIImageView()
    private let titleLabel = UILabel()
    
    // MARK: - Stage Resources
    private struct StageResources {
        let imageName: String
        let title: String
    }
    
    private let firstStageResources = StageResources(
        imageName: "ch_announcementWaiting", // ch_waiting으로 이름 변경 필요
        title: "두구두구두구...\r결과는 과연?"
    )
    
    private let secondStageResources = StageResources(
        imageName: "ch_announcementWaiting", // ch_waiting으로 이름 변경 필요
        title: "어라?\r이 느낌은..."
    )
    
    private let statusBarHeight = DeviceMetrics.statusBarHeight
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        // 기본적으로 첫 번째 단계로 설정
        configureForStage(firstStageResources)
        
        loadingImageView.contentMode = .scaleAspectFit
        
        // 텍스트 스타일링
        styleLabel(for: titleLabel, fontStyle: .title2, textColor: .black)
    }
    
    private func setupLayout() {
        addSubview(rootFlexContainer)
        
        let topMargin = (UIScreen.main.bounds.height - statusBarHeight) / 4.5714
        
        rootFlexContainer.flex
            .direction(.column)
            .alignItems(.center)
            .height(UIScreen.main.bounds.height)
            .backgroundColor(.white)
            .define { flex in
                flex.addItem(titleLabel)
                    .marginTop(statusBarHeight + topMargin)
                    .marginBottom(32)
                
                flex.addItem(loadingImageView)
                    .height(UIScreen.main.bounds.width / 1.7857) // 210
                
            }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.all()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
    
    // MARK: - Public Methods
    
    /// 로딩 단계를 설정합니다
    func setStage(_ stage: QRWinningCheckLoadingManager.LoadingStage) {
        switch stage {
        case .none:
            break // 아무 변화 없음
        case .first:
            configureForStage(firstStageResources)
        case .second:
            configureForStage(secondStageResources)
            animateTransition()
        }
    }
    
    // MARK: - Private Methods
    
    /// 지정된 단계에 맞게 UI를 구성합니다
    private func configureForStage(_ resources: StageResources) {
        // 이미지를 설정합니다
        if let image = UIImage(named: resources.imageName) {
            loadingImageView.image = image
        }
        
        // 텍스트를 설정합니다
        titleLabel.text = resources.title
        titleLabel.numberOfLines = 2
        
        setNeedsLayout()
    }
    
    /// 단계 전환 시 애니메이션을 적용합니다
    private func animateTransition() {
        // 텍스트가 자연스럽게 변경되도록 수직 슬라이드 애니메이션 구현
        
        // 현재 텍스트의 스냅샷 생성
        let currentTextSnapshot = titleLabel.snapshotView(afterScreenUpdates: false)
        guard let snapshot = currentTextSnapshot else { return }
        
        // 스냅샷을 현재 텍스트 위치에 추가
        snapshot.frame = titleLabel.frame
        rootFlexContainer.addSubview(snapshot)
        
        // 새 텍스트는 configureForStage에서 이미 설정됨
        
        // 애니메이션 시작 위치 설정
        // 새 텍스트는 아래에서 올라오도록
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        titleLabel.alpha = 0
        
        // 애니메이션 실행
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            // 기존 텍스트는 위로 사라짐
            snapshot.transform = CGAffineTransform(translationX: 0, y: -20)
            snapshot.alpha = 0
            
            // 새 텍스트는 원래 위치로 이동하며 나타남
            self.titleLabel.transform = .identity
            self.titleLabel.alpha = 1
            
        }, completion: { _ in
            // 스냅샷 제거
            snapshot.removeFromSuperview()
        })
    }
}
