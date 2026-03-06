//
//  CustomTooltip.swift
//  LottoMate
//
//  Created by Mirae on 2/26/25.
//

import UIKit

// 툴팁 화살표 위치를 정의하는 열거형
enum TooltipPosition {
    case top, topRight, right
    case bottom, bottomLeft, left
}

class CustomTooltip: UIView {
    
    // MARK: - Properties
    
    private let contentLabel = UILabel()
    private let verticalPadding: CGFloat = 6.0
    private let horizontalPadding: CGFloat = 4.0
    private let arrowSize: CGFloat = 6.0
    private let arrowRadius: CGFloat = 1.0
    private let cornerRadius: CGFloat = 4.0
    
    private var tooltipPosition: TooltipPosition = .bottom
    private var tooltipText: String = ""
    private var tooltipColor: UIColor = UIColor.black.withAlphaComponent(0.68)
    private var textColor: UIColor = .white
    
    // 자동 숨김 타이머
    private var autoHideTimer: Timer?
    private var isAutoHideEnabled: Bool = true
    private var autoHideDelay: TimeInterval = 3.0
    
    // MARK: - Initialization
    
    init(text: String, position: TooltipPosition, autoHide: Bool = true) {
        super.init(frame: .zero)
        self.tooltipText = text
        self.tooltipPosition = position
        self.isAutoHideEnabled = autoHide
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    deinit {
        cancelAutoHideTimer()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        backgroundColor = .clear
        
        contentLabel.text = tooltipText
        styleLabel(for: contentLabel, fontStyle: .caption1, textColor: .white)
        contentLabel.numberOfLines = 1
        contentLabel.textAlignment = .center
        addSubview(contentLabel)
        
        // 레이블의 최대 너비 설정
        //        contentLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 레이아웃 설정
        updateLayout()
        
        // 기본적으로 숨김 상태로 시작
        isHidden = true
        alpha = 0
    }
    
    private func updateLayout() {
        // 기존 제약 조건 제거
        contentLabel.removeFromSuperview()
        
        // 레이블 다시 추가
        addSubview(contentLabel)
        
        // 툴팁 위치에 따른 패딩 계산
        var topPadding: CGFloat = verticalPadding
        var bottomPadding: CGFloat = verticalPadding
        
        // 화살표 위치에 따라 해당 방향의 패딩 조정 및 중앙점 오프셋 계산
        var centerXOffset: CGFloat = 0
        var centerYOffset: CGFloat = 0
        
        switch tooltipPosition {
        case .top:
            topPadding += arrowSize
            centerYOffset = arrowSize / 2
        case .bottom:
            bottomPadding += arrowSize
            centerYOffset = -arrowSize / 2
        case .left:
            centerXOffset = arrowSize / 2
        case .right:
            centerXOffset = -arrowSize / 2
        case .topRight:
            topPadding += arrowSize
            centerYOffset = arrowSize / 2
        case .bottomLeft:
            bottomPadding += arrowSize
            centerYOffset = -arrowSize / 2
        }
        
        // 레이블 제약 조건 설정 - 콘텐츠 영역 내에서 중앙 정렬
        NSLayoutConstraint.activate([
            // 수직 중앙 정렬 (오프셋 적용)
            contentLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: centerYOffset),
            
            // 수평 중앙 정렬 (오프셋 적용)
            contentLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: centerXOffset),
            
            // 상하 마진 설정 (필요한 경우)
            contentLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: topPadding),
            contentLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -bottomPadding)
        ])
        
        // 레이아웃 업데이트
        setNeedsLayout()
    }
    
    // MARK: - Public Methods
    
    func setText(_ text: String) {
        tooltipText = text
        contentLabel.text = text
        setNeedsDisplay()
    }
    
    func setPosition(_ position: TooltipPosition) {
        tooltipPosition = position
        updateLayout()
        setNeedsDisplay()
    }
    
    func setTooltipColor(_ color: UIColor) {
        tooltipColor = color
        setNeedsDisplay()
    }
    
    func setTextColor(_ color: UIColor) {
        textColor = color
        contentLabel.textColor = color
    }
    
    /// 자동 숨김 설정 변경
    func setAutoHide(enabled: Bool, delay: TimeInterval = 3.0) {
        isAutoHideEnabled = enabled
        autoHideDelay = delay
        
        // 자동 숨김이 비활성화되면 타이머 취소
        if !enabled {
            cancelAutoHideTimer()
        } else if !isHidden && alpha > 0 {
            // 현재 보이는 상태이고 자동 숨김이 활성화되면 타이머 시작
            startAutoHideTimer()
        }
    }
    
    private func startAutoHideTimer() {
        // 이전 타이머 취소
        cancelAutoHideTimer()
        
        // 자동 숨김이 활성화된 경우에만 타이머 시작
        if isAutoHideEnabled {
            autoHideTimer = Timer.scheduledTimer(
                timeInterval: autoHideDelay,
                target: self,
                selector: #selector(autoHideTimerFired),
                userInfo: nil,
                repeats: false
            )
        }
    }
    
    private func cancelAutoHideTimer() {
        autoHideTimer?.invalidate()
        autoHideTimer = nil
    }
    
    @objc private func autoHideTimerFired() {
        // 타이머가 완료되면 페이드 아웃
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
        }, completion: { _ in
            self.isHidden = true
        })
    }
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 배경색 설정
        context.setFillColor(tooltipColor.cgColor)
        
        // 화살표 path 및 말풍선 본체 path 생성
        let path = createTooltipPath(in: rect)
        
        // 경로 채우기
        context.addPath(path.cgPath)
        context.fillPath()
    }
    
    override var isHidden: Bool {
        didSet {
            if !isHidden && oldValue != isHidden {
                // 보이게 될 때 타이머 시작
                startAutoHideTimer()
            } else if isHidden {
                // 숨겨질 때 타이머 취소
                cancelAutoHideTimer()
            }
        }
    }
    
    override var alpha: CGFloat {
        didSet {
            if alpha > 0 && oldValue == 0 {
                // 투명도가 0에서 증가할 때 타이머 시작
                startAutoHideTimer()
            } else if alpha == 0 {
                // 투명도가 0이 되면 타이머 취소
                cancelAutoHideTimer()
            }
        }
    }
    
    private func createTooltipPath(in rect: CGRect) -> UIBezierPath {
        // 패딩을 고려한 콘텐츠 영역
        var contentRect = rect
        
        // 화살표 위치에 따라 콘텐츠 영역 조정
        switch tooltipPosition {
        case .top:
            contentRect.origin.y += arrowSize
            contentRect.size.height -= arrowSize
        case .bottom:
            contentRect.size.height -= arrowSize
        case .left:
            contentRect.origin.x += arrowSize
            contentRect.size.width -= arrowSize
        case .right:
            contentRect.size.width -= arrowSize
        case .topRight:
            contentRect.origin.y += arrowSize
            contentRect.size.height -= arrowSize
        case .bottomLeft:
            contentRect.size.height -= arrowSize
        }
        
        // 말풍선 본체 경로
        let bubblePath = UIBezierPath(roundedRect: contentRect, cornerRadius: cornerRadius)
        
        // 화살표 경로 생성
        let arrowPath = createArrowPath(in: rect)
        
        // 두 경로 결합
        bubblePath.append(arrowPath)
        
        return bubblePath
    }
    
    private func createArrowPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        
        // 더 뭉툭한 화살표를 위해 arrowRadius 값 증가
        let roundedArrowRadius: CGFloat = arrowSize / 6  // 화살표 크기의 절반을 radius로 설정
        
        // 화살표 위치에 따른 좌표 계산
        switch tooltipPosition {
        case .top:
            // 상단 중앙에 화살표
            let arrowStartX = rect.midX - arrowSize
            let tipX = arrowStartX + arrowSize
            let tipY: CGFloat = 0
            
            // 시작점
            path.move(to: CGPoint(x: arrowStartX, y: arrowSize))
            
            // 처음 1/3 지점에서 시작해서 팁으로
            let leftPoint = CGPoint(x: arrowStartX + arrowSize * 0.5, y: arrowSize * 0.5)
            path.addLine(to: leftPoint)
            
            // 왼쪽에서 화살표 끝으로 가는 곡선 (많이 둥글게)
            path.addQuadCurve(to: CGPoint(x: tipX, y: tipY),
                              controlPoint: CGPoint(x: tipX - roundedArrowRadius/2, y: tipY))
            
            // 화살표 끝에서 오른쪽으로 가는 곡선 (많이 둥글게)
            path.addQuadCurve(to: CGPoint(x: arrowStartX + arrowSize * 1.5, y: arrowSize * 0.5),
                              controlPoint: CGPoint(x: tipX + roundedArrowRadius/2, y: tipY))
            
            // 나머지 오른쪽 부분
            path.addLine(to: CGPoint(x: arrowStartX + arrowSize * 2, y: arrowSize))
            
        case .topRight:
            // 상단 오른쪽에 화살표
            let arrowStartX = rect.midX + arrowSize
            let tipX = arrowStartX + arrowSize
            let tipY: CGFloat = 0
            
            // 시작점
            path.move(to: CGPoint(x: arrowStartX, y: arrowSize))
            
            // 처음 1/3 지점에서 시작해서 팁으로
            let leftPoint = CGPoint(x: arrowStartX + arrowSize * 0.5, y: arrowSize * 0.5)
            path.addLine(to: leftPoint)
            
            // 왼쪽에서 화살표 끝으로 가는 곡선 (많이 둥글게)
            path.addQuadCurve(to: CGPoint(x: tipX, y: tipY),
                              controlPoint: CGPoint(x: tipX - roundedArrowRadius/2, y: tipY))
            
            // 화살표 끝에서 오른쪽으로 가는 곡선 (많이 둥글게)
            path.addQuadCurve(to: CGPoint(x: arrowStartX + arrowSize * 1.5, y: arrowSize * 0.5),
                              controlPoint: CGPoint(x: tipX + roundedArrowRadius/2, y: tipY))
            
            // 나머지 오른쪽 부분
            path.addLine(to: CGPoint(x: arrowStartX + arrowSize * 2, y: arrowSize))
            
        case .right:
            // 오른쪽 중앙에 화살표
            let arrowStartY = rect.midY - arrowSize
            let tipX = rect.maxX
            let tipY = arrowStartY + arrowSize
            
            // 시작점
            path.move(to: CGPoint(x: rect.maxX - arrowSize, y: arrowStartY))
            
            // 위쪽 1/3 지점
            let topPoint = CGPoint(x: rect.maxX - arrowSize * 0.5, y: arrowStartY + arrowSize * 0.5)
            path.addLine(to: topPoint)
            
            // 위에서 화살표 끝으로 가는 곡선 (많이 둥글게)
            path.addQuadCurve(to: CGPoint(x: tipX, y: tipY),
                              controlPoint: CGPoint(x: tipX, y: tipY - roundedArrowRadius/2))
            
            // 화살표 끝에서 아래로 가는 곡선 (많이 둥글게)
            path.addQuadCurve(to: CGPoint(x: rect.maxX - arrowSize * 0.5, y: arrowStartY + arrowSize * 1.5),
                              controlPoint: CGPoint(x: tipX, y: tipY + roundedArrowRadius/2))
            
            // 나머지 아래 부분
            path.addLine(to: CGPoint(x: rect.maxX - arrowSize, y: arrowStartY + arrowSize * 2))
            
        case .bottom:
            // 하단 중앙에 화살표
            let arrowStartX = rect.midX - arrowSize
            let tipX = arrowStartX + arrowSize
            let tipY = rect.maxY
            
            // 시작점
            path.move(to: CGPoint(x: arrowStartX, y: rect.maxY - arrowSize))
            
            // 왼쪽 1/3 지점
            let leftPoint = CGPoint(x: arrowStartX + arrowSize * 0.5, y: rect.maxY - arrowSize * 0.5)
            path.addLine(to: leftPoint)
            
            // 왼쪽에서 화살표 끝으로 가는 곡선 (많이 둥글게)
            path.addQuadCurve(to: CGPoint(x: tipX, y: tipY),
                              controlPoint: CGPoint(x: tipX - roundedArrowRadius/2, y: tipY))
            
            // 화살표 끝에서 오른쪽으로 가는 곡선 (많이 둥글게)
            path.addQuadCurve(to: CGPoint(x: arrowStartX + arrowSize * 1.5, y: rect.maxY - arrowSize * 0.5),
                              controlPoint: CGPoint(x: tipX + roundedArrowRadius/2, y: tipY))
            
            // 나머지 오른쪽 부분
            path.addLine(to: CGPoint(x: arrowStartX + arrowSize * 2, y: rect.maxY - arrowSize))
            
        case .bottomLeft:
            // 하단 왼쪽에 화살표
            let arrowStartX = rect.midX - arrowSize * 3
            let tipX = arrowStartX + arrowSize
            let tipY = rect.maxY
            
            // 시작점
            path.move(to: CGPoint(x: arrowStartX, y: rect.maxY - arrowSize))
            
            // 왼쪽 1/3 지점
            let leftPoint = CGPoint(x: arrowStartX + arrowSize * 0.5, y: rect.maxY - arrowSize * 0.5)
            path.addLine(to: leftPoint)
            
            // 왼쪽에서 화살표 끝으로 가는 곡선 (많이 둥글게)
            path.addQuadCurve(to: CGPoint(x: tipX, y: tipY),
                              controlPoint: CGPoint(x: tipX - roundedArrowRadius/2, y: tipY))
            
            // 화살표 끝에서 오른쪽으로 가는 곡선 (많이 둥글게)
            path.addQuadCurve(to: CGPoint(x: arrowStartX + arrowSize * 1.5, y: rect.maxY - arrowSize * 0.5),
                              controlPoint: CGPoint(x: tipX + roundedArrowRadius/2, y: tipY))
            
            // 나머지 오른쪽 부분
            path.addLine(to: CGPoint(x: arrowStartX + arrowSize * 2, y: rect.maxY - arrowSize))
            
        case .left:
            // 왼쪽 중앙에 화살표
            let arrowStartY = rect.midY - arrowSize
            let tipX: CGFloat = 0
            let tipY = arrowStartY + arrowSize
            
            // 시작점
            path.move(to: CGPoint(x: arrowSize, y: arrowStartY))
            
            // 위쪽 1/3 지점
            let topPoint = CGPoint(x: arrowSize * 0.5, y: arrowStartY + arrowSize * 0.5)
            path.addLine(to: topPoint)
            
            // 위에서 화살표 끝으로 가는 곡선 (많이 둥글게)
            path.addQuadCurve(to: CGPoint(x: tipX, y: tipY),
                              controlPoint: CGPoint(x: tipX, y: tipY - roundedArrowRadius/2))
            
            // 화살표 끝에서 아래로 가는 곡선 (많이 둥글게)
            path.addQuadCurve(to: CGPoint(x: arrowSize * 0.5, y: arrowStartY + arrowSize * 1.5),
                              controlPoint: CGPoint(x: tipX, y: tipY + roundedArrowRadius/2))
            
            // 나머지 아래 부분
            path.addLine(to: CGPoint(x: arrowSize, y: arrowStartY + arrowSize * 2))
        }
        
        return path
    }
    
    // MARK: - Size Calculation
    
    override var intrinsicContentSize: CGSize {
        // 텍스트 크기에 맞게 자동 조정되는 사이즈 계산
        let labelSize = contentLabel.sizeThatFits(CGSize(width: 200, height: CGFloat.greatestFiniteMagnitude))
        
        var width = labelSize.width + horizontalPadding * 2
        var height = labelSize.height + verticalPadding * 2
        
        // 화살표 위치에 따라 크기 조정
        switch tooltipPosition {
        case .top, .topRight, .bottom, .bottomLeft:
            height += arrowSize
        case .left, .right:
            width += arrowSize
        }
        
        // 최소 크기 설정
        width = max(width, 50)
        height = max(height, 30)
        
        return CGSize(width: width, height: height)
    }
}

// MARK: - 사용 예시

class TooltipDemoViewController: UIViewController {
    
    private var tooltip: CustomTooltip?
    private var currentPosition: TooltipPosition = .top
    private var positionButtons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupButtons()
    }
    
    private func setupButtons() {
        // 위치별 데모 버튼 생성
        let positions: [(String, TooltipPosition)] = [
            ("Top", .top),
            ("Top_Right", .topRight),
            ("Right", .right),
            ("Bottom", .bottom),
            ("Bottom_Left", .bottomLeft),
            ("Left", .left)
        ]
        
        // 그리드 배치
        let gridWidth: CGFloat = 3
        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 100
        let spacing: CGFloat = 20
        let startX = (view.bounds.width - (gridWidth * buttonWidth + (gridWidth - 1) * spacing)) / 2
        let startY: CGFloat = 100
        
        for (index, (title, position)) in positions.enumerated() {
            let row = CGFloat(index / Int(gridWidth))
            let col = CGFloat(index % Int(gridWidth))
            
            let x = startX + col * (buttonWidth + spacing)
            let y = startY + row * (buttonHeight + spacing)
            
            let button = UIButton(type: .system)
            button.frame = CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.backgroundColor = .lightGray
            button.layer.cornerRadius = 5
            button.tag = index
            button.addTarget(self, action: #selector(showTooltip(_:)), for: .touchUpInside)
            
            view.addSubview(button)
            positionButtons.append(button)
        }
    }
    
    @objc private func showTooltip(_ sender: UIButton) {
        // 기존 툴팁 제거
        tooltip?.removeFromSuperview()
        
        // 선택된 위치
        let positions: [TooltipPosition] = [.top, .topRight, .right, .bottom, .bottomLeft, .left]
        let position = positions[sender.tag]
        currentPosition = position
        
        // 새 툴팁 생성
        let tooltip = CustomTooltip(text: "tooltip", position: position)
        tooltip.setTooltipColor(UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0))
        view.addSubview(tooltip)
        
        // 툴팁 위치 설정
        tooltip.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
        
        switch position {
        case .top:
            constraints = [
                tooltip.bottomAnchor.constraint(equalTo: sender.topAnchor, constant: -5),
                tooltip.centerXAnchor.constraint(equalTo: sender.centerXAnchor)
            ]
        case .topRight:
            constraints = [
                tooltip.bottomAnchor.constraint(equalTo: sender.topAnchor, constant: -5),
                tooltip.rightAnchor.constraint(equalTo: sender.rightAnchor)
            ]
        case .right:
            constraints = [
                tooltip.leftAnchor.constraint(equalTo: sender.rightAnchor, constant: 5),
                tooltip.centerYAnchor.constraint(equalTo: sender.centerYAnchor)
            ]
        case .bottom:
            constraints = [
                tooltip.topAnchor.constraint(equalTo: sender.bottomAnchor, constant: 5),
                tooltip.centerXAnchor.constraint(equalTo: sender.centerXAnchor)
            ]
        case .bottomLeft:
            constraints = [
                tooltip.topAnchor.constraint(equalTo: sender.bottomAnchor, constant: 5),
                tooltip.leftAnchor.constraint(equalTo: sender.leftAnchor)
            ]
        case .left:
            constraints = [
                tooltip.rightAnchor.constraint(equalTo: sender.leftAnchor, constant: -5),
                tooltip.centerYAnchor.constraint(equalTo: sender.centerYAnchor)
            ]
        }
        
        NSLayoutConstraint.activate(constraints)
        
        // 툴팁 저장
        self.tooltip = tooltip
    }
}
