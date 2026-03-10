//
//  ToggleArrowButton.swift
//  LottoMate
//
//  Created by Mirae on 2/20/25.
//

import UIKit
import RxSwift
import RxGesture

class ToggleArrowButton: UIButton {
    private let arrowDownIcon = UIImageView()
    private let arrowUpIcon = UIImageView()
    private var isExpanded = false
    
    private let disposeBag = DisposeBag()
    var onToggle: ((Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupRxGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupRxGesture()
    }
    
    private func setupViews() {
        // 화살표 이미지 설정
        if let downImage = UIImage(named: "icon_arrow_down")?.withTintColor(.gray100) {
            arrowDownIcon.image = downImage
            arrowDownIcon.contentMode = .scaleAspectFit
        }
        
        if let upImage = UIImage(named: "icon_arrow_up")?.withTintColor(.gray100) {
            arrowUpIcon.image = upImage
            arrowUpIcon.contentMode = .scaleAspectFit
        } else {
            // CommonImageView에서 사용한 방식과 동일하게 설정
            arrowUpIcon.image = UIImage(named: "icon_arrow_up")?.withTintColor(.gray100)
            arrowUpIcon.contentMode = .scaleAspectFit
        }
        
        // 초기 상태 설정
        arrowDownIcon.isHidden = false
        arrowUpIcon.isHidden = true
        
        // 크기 설정
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 20),
            self.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        // 화살표 이미지뷰 추가
        addSubview(arrowDownIcon)
        addSubview(arrowUpIcon)
        
        // 화살표 이미지뷰 레이아웃
        arrowDownIcon.translatesAutoresizingMaskIntoConstraints = false
        arrowUpIcon.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            arrowDownIcon.topAnchor.constraint(equalTo: topAnchor),
            arrowDownIcon.leadingAnchor.constraint(equalTo: leadingAnchor),
            arrowDownIcon.trailingAnchor.constraint(equalTo: trailingAnchor),
            arrowDownIcon.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            arrowUpIcon.topAnchor.constraint(equalTo: topAnchor),
            arrowUpIcon.leadingAnchor.constraint(equalTo: leadingAnchor),
            arrowUpIcon.trailingAnchor.constraint(equalTo: trailingAnchor),
            arrowUpIcon.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupRxGesture() {
        self.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.toggleState()
            })
            .disposed(by: disposeBag)
    }
    
    private func toggleState() {
        isExpanded.toggle()
        
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in
            guard let self = self else { return }
            self.arrowDownIcon.isHidden = self.isExpanded
            self.arrowUpIcon.isHidden = !self.isExpanded
        }, completion: nil)
        
        onToggle?(isExpanded)
    }
    
    // 프로그래밍 방식으로 상태 설정
    func setExpanded(_ expanded: Bool, animated: Bool = true) {
        guard isExpanded != expanded else { return }
        isExpanded = expanded
        
        if animated {
            UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in
                guard let self = self else { return }
                self.arrowDownIcon.isHidden = self.isExpanded
                self.arrowUpIcon.isHidden = !self.isExpanded
            }, completion: nil)
        } else {
            arrowDownIcon.isHidden = isExpanded
            arrowUpIcon.isHidden = !isExpanded
        }
    }
}
