//
//  ImageContentViewController.swift
//  LottoMate
//
//  Created by Mirae on 9/13/24.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift
import RxGesture
import Kingfisher

// 이미지 콘텐츠를 표시하는 뷰 컨트롤러
class ImageContentViewController: UIViewController {
    let viewModel = LottoMateViewModel.shared
    fileprivate let rootFlexContainer = UIView()
    private let disposeBag = DisposeBag()
    
    var imageView: UIImageView!
    var imageName: String = ""
    var imageURL: String = ""
    var pageIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImageView()
        setupTapGesture()
        setupLayout()
    }
    
    private func setupImageView() {
        // 이미지 뷰 설정
        imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 1.33)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .white // 로딩 중 배경색
        
        // URL이 있으면 서버 이미지 로드, 없으면 로컬 이미지 사용
        if !imageURL.isEmpty {
            loadImageFromURL()
        } else if !imageName.isEmpty {
            imageView.image = UIImage(named: imageName)
        }
    }
    
    private func loadImageFromURL() {
        guard let url = URL(string: imageURL) else { 
            // URL이 유효하지 않으면 플레이스홀더 이미지 사용
            imageView.image = UIImage(named: "ch_reviewPlaceholderImage")
            return 
        }
        
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "ch_reviewPlaceholderImage"),
            options: [
                .transition(.fade(0.3)),
                .cacheOriginalImage
            ]
        )
    }
    
    private func setupTapGesture() {
        // 이미지를 탭하여 전체화면으로 보기
        imageView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                // URL이 있으면 URL을, 없으면 로컬 이미지명을 전달
                let imageIdentifier = !self.imageURL.isEmpty ? self.imageURL : self.imageName
                self.viewModel.winningReviewFullSizeImgName.onNext(imageIdentifier)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupLayout() {
        view.addSubview(rootFlexContainer)
        
        rootFlexContainer.flex.define { flex in
            flex.addItem(imageView)
                .height(UIScreen.main.bounds.width / 1.33)  // 고정된 비율로 높이 설정
                .width(UIScreen.main.bounds.width)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootFlexContainer.pin.all()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
}

#Preview {
    var imageContentVC = ImageContentViewController()
    imageContentVC.imageName = "winning_review_sample_2"
    return imageContentVC
}
