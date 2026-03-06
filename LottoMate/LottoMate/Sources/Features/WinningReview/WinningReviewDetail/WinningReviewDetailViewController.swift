//
//  WinningReviewDetailViewController.swift
//  LottoMate
//
//  Created by Mirae on 9/12/24.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift
import ReactorKit
import Kingfisher

class WinningReviewDetailViewController: BaseViewController, View {
    
    fileprivate var mainView: WinningReviewDetailView {
        return self.view as! WinningReviewDetailView
    }
    
    let viewModel = LottoMateViewModel.shared
    var disposeBag = DisposeBag()
    var reactor = WinningReviewReactor.shared
    
    private lazy var winningReviewDetailView: WinningReviewDetailView = {
        let view = WinningReviewDetailView()
        return view
    }()
    
    private var reviewNo: Int?
    
    convenience init(reviewNo: Int) {
        self.init()
        self.reviewNo = reviewNo
    }
    
    override func loadView() {
        view = winningReviewDetailView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeStatusBarBgColor(bgColor: .commonNavBar)
    }
    
    private let statusBarTag = 987654
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = NavBarConfiguration(
            style: .backButtonWithTitle,
            title: "",
            buttonTintColor: .gray100
        )
        configureNavBar(config)
        
        // 뷰와 리액터 바인딩
        mainView.bind(reactor: reactor)
        bind(reactor: reactor)
        showTappedImage()
        
        // 서버 데이터 fetch
        if let reviewNo = reviewNo {
            reactor.action.onNext(.fetchWinningReviewDetail(reviewNo))
        }
    }
    
    @objc override func leftButtonTapped() {
        navigationController?.popViewController(animated: true)
//        didTapBackButton()
    }
    
    func bind(reactor: WinningReviewReactor) {
        // State - 에러 처리
        reactor.state
            .map { $0.error(for: .reviewDetail) }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.showErrorVC(error: error)
            })
            .disposed(by: disposeBag)
    }
    
    private func showErrorVC(error: Error) {
        let errorVC = CommonErrorVC { [weak self] in
            // 에러 화면에서 "이전 화면으로 돌아가기" 버튼을 눌렀을 때의 동작
            self?.navigationController?.popViewController(animated: true)
        }
        
        // 네비게이션 컨트롤러를 통해 에러 화면으로 이동
        navigationController?.pushViewController(errorVC, animated: true)
    }
    
    func showTappedImage() {
        viewModel.winningReviewFullSizeImgName
            .subscribe(onNext: { name in
                if name != "" {
                    self.changeStatusBarBgColor(bgColor: .clear)
                    self.showFullscreenImage(named: "\(name)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    func showFullscreenImage(named name: String) {
        // 투명한 배경 뷰 추가 (터치 이벤트 차단용)
        let dimmingView = UIView(frame: self.view.bounds)
        dimmingView.backgroundColor = .dimFullScreenImageBackground
        dimmingView.isUserInteractionEnabled = true // 다른 터치를 막기 위해 사용
        
        // 전체 화면 이미지 뷰 설정
        let fullscreenImageView = UIImageView(frame: self.view.bounds)
        fullscreenImageView.contentMode = .scaleAspectFit
        fullscreenImageView.isUserInteractionEnabled = true // 이미지 뷰도 터치 이벤트를 받을 수 있게 설정
        
        // URL인지 로컬 이미지명인지 판단하여 이미지 로드
        if name.hasPrefix("http://") || name.hasPrefix("https://") {
            // URL인 경우 Kingfisher로 로드
            if let url = URL(string: name) {
                fullscreenImageView.kf.setImage(
                    with: url,
                    placeholder: UIImage(named: "ch_reviewPlaceholderImage"),
                    options: [.cacheOriginalImage]
                )
            }
        } else {
            // 로컬 이미지인 경우
            fullscreenImageView.image = UIImage(named: name)
        }
        
        // closeButton 이미지 생성
        if let closeIcon = UIImage(named: "icon_X")?.withRenderingMode(.alwaysTemplate) {
            let closeButton = UIImageView(image: closeIcon)
            closeButton.tintColor = UIColor.white.withAlphaComponent(0.6)
            closeButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            closeButton.isUserInteractionEnabled = true // 버튼처럼 동작하도록 설정
            
            // UIWindowScene을 통해 window 접근
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                
                // status bar height 가져오기
                let statusBarHeight = windowScene.statusBarManager?.statusBarFrame.height ?? 0
                
                // closeButton을 status bar height + 16 아래로 배치
                let closeButtonX = window.frame.width - 24 - 20 // 오른쪽에서 20px 띄움
                let closeButtonY = statusBarHeight + 16 // status bar 아래로 16pt 띄움
                
                closeButton.frame.origin = CGPoint(x: closeButtonX, y: closeButtonY)
                
                // closeButton에 탭 제스처 추가 (전체 화면 이미지 제거 기능)
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
                closeButton.addGestureRecognizer(tapGesture)
            }
            
            // closeButton을 fullscreenImageView에 추가
            fullscreenImageView.addSubview(closeButton)
        }
        
        // dimmingView에 fullscreenImageView를 추가
        dimmingView.addSubview(fullscreenImageView)
        
        // dimmingView를 현재 뷰에 추가
        self.view.addSubview(dimmingView)
    }
    
    @objc func dismissFullscreenImage() {
        if let dimmingView = self.view.subviews.first(where: { $0.backgroundColor == .dimFullScreenImageBackground }) {
            UIView.animate(withDuration: 0.3, animations: {
                dimmingView.alpha = 0
            }) { _ in
                dimmingView.removeFromSuperview()
                self.changeStatusBarBgColor(bgColor: .commonNavBar)
                self.viewModel.winningReviewFullSizeImgName.onNext("")
            }
        }
    }
}

#Preview {
    let view = WinningReviewDetailViewController()
    return view
}
