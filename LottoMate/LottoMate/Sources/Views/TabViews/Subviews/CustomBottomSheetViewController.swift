//
//  Custom BottomSheetViewController.swift
//  LottoMate
//
//  Created by Mirae on 10/14/24.
//

import UIKit
import ReactorKit

enum SheetState: Equatable {
    case collapsed
    case partial
    case expanded
}

protocol CustomBottomSheetDelegate: AnyObject {
    /// 커스텀 바텀 시트의 상태를 전파
    func bottomSheet(_ sheet: CustomBottomSheetViewController, didChangeState state: SheetState)
}

class CustomBottomSheetViewController: UIViewController, UIGestureRecognizerDelegate, View {
    weak var delegate: CustomBottomSheetDelegate?
    var disposeBag = DisposeBag()
    
    let sheetStateChanged = PublishSubject<SheetState>()
    
    var contentViewController: UIViewController
    private let minHeight: CGFloat
    private let midMaxHeight: CGFloat  // 첫 번째 최대 높이 (60%)
    private let fullMaxHeight: CGFloat // 두 번째 최대 높이 (80%)
    
    var currentState: SheetState = .collapsed
    var bottomConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    
    // 드래그 핸들 추가
    private let dragHandleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray30
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(contentViewController: UIViewController, minHeight: CGFloat) {
        self.contentViewController = contentViewController
        self.minHeight = minHeight
        
        let tabBarHeight = contentViewController.tabBarController?.tabBar.frame.height ?? 83
        let availableHeight = UIScreen.main.bounds.height - tabBarHeight
        
        self.midMaxHeight = availableHeight * 0.2512  // 바텀 시트 높이 (화면의 약 25%)
        self.fullMaxHeight = availableHeight * 0.8453  // 화면 높이의 80%
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupDragHandle()
        setupPanGesture()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 32
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        
        // 안전하게 contentViewController 추가
        guard contentViewController.parent == nil else {
            // 이미 부모가 있는 경우 처리
            print("Warning: ContentViewController already has a parent")
            return
        }
        
        addChild(contentViewController)
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentViewController.view)
        
        NSLayoutConstraint.activate([
            contentViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 36), // 드래그 핸들 공간
            contentViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        contentViewController.didMove(toParent: self)
    }
    
    private func setupDragHandle() {
        view.addSubview(dragHandleView)
        
        NSLayoutConstraint.activate([
            dragHandleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            dragHandleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dragHandleView.widthAnchor.constraint(equalToConstant: 40),
            dragHandleView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    private func setupPanGesture() {
        // 드래그 핸들과 상단 영역에만 팬 제스처 추가
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .changed:
            let currentHeight = heightConstraint?.constant ?? 0
            let newHeight = max(minHeight, min(fullMaxHeight, currentHeight - translation.y))
            heightConstraint?.constant = newHeight
            view.superview?.layoutIfNeeded()
        case .ended:
            let velocity = gesture.velocity(in: view)
            let currentHeight = heightConstraint?.constant ?? 0
            
            if velocity.y < -500 {  // 강한 위쪽 스와이프
                if currentState == .collapsed {
                    animateBottomSheet(to: midMaxHeight, state: .partial)
                } else if currentState == .partial {
                    animateBottomSheet(to: fullMaxHeight, state: .expanded)
                }
            } else if velocity.y > 500 {  // 강한 아래쪽 스와이프
                if currentState == .expanded {
                    animateBottomSheet(to: midMaxHeight, state: .partial)
                } else if currentState == .partial {
                    animateBottomSheet(to: minHeight, state: .collapsed)
                }
            } else {
                // 가장 가까운 상태로 스냅
                if currentHeight < (minHeight + midMaxHeight) / 2 {
                    animateBottomSheet(to: minHeight, state: .collapsed)
                } else if currentHeight < (midMaxHeight + fullMaxHeight) / 2 {
                    animateBottomSheet(to: midMaxHeight, state: .partial)
                } else {
                    animateBottomSheet(to: fullMaxHeight, state: .expanded)
                }
            }
        default:
            break
        }
        
        gesture.setTranslation(.zero, in: view)
    }
    
    private func animateBottomSheet(to height: CGFloat, state: SheetState) {
        UIView.animate(withDuration: 0.3) {
            self.heightConstraint?.constant = height
            self.view.superview?.layoutIfNeeded()
        } completion: { _ in
            self.currentState = state
            self.delegate?.bottomSheet(self, didChangeState: state)
//            self.reactor?.action.onNext(.updateSheetState(state))
            self.sheetStateChanged.onNext(state)
        }
    }
    
    func addToParent(_ parentViewController: UIViewController) {
        // 이미 부모가 있는 경우 제거
        if let parent = parent {
            willMove(toParent: nil)
            view.removeFromSuperview()
            removeFromParent()
        }
        
        parentViewController.addChild(self)
        parentViewController.view.addSubview(view)
        didMove(toParent: parentViewController)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        bottomConstraint = view.bottomAnchor.constraint(equalTo: parentViewController.view.bottomAnchor)
        heightConstraint = view.heightAnchor.constraint(equalToConstant: minHeight)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: parentViewController.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: parentViewController.view.trailingAnchor),
            bottomConstraint!,
            heightConstraint!
        ])
    }
    
    // 공개 메서드
    func expandToMidHeight() {
        animateBottomSheet(to: midMaxHeight, state: .partial)
    }
    
    func expandToFullHeight() {
        animateBottomSheet(to: fullMaxHeight, state: .expanded)
    }
    
    func collapse() {
        animateBottomSheet(to: minHeight, state: .collapsed)
    }
    
    deinit {
        // 메모리 정리
        if contentViewController.parent == self {
            contentViewController.willMove(toParent: nil)
            contentViewController.view.removeFromSuperview()
            contentViewController.removeFromParent()
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 드래그 핸들과 상단 영역에서만 제스처 인식
        let touchPoint = touch.location(in: view)
        return touchPoint.y <= 40  // 상단 40px에서만 제스처 인식 (드래그 핸들 + 여유 공간)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 다른 제스처와 동시에 작동하지 않도록 함
        return false
    }
}

extension CustomBottomSheetViewController {
    func bind(reactor: MapViewReactor) {
        sheetStateChanged
            .map { MapViewReactor.Action.updateSheetState($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
