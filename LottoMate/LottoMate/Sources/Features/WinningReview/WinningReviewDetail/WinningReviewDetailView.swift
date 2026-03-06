//
//  WinningReviewDetailView.swift
//  LottoMate
//
//  Created by Mirae on 9/12/24.
/*
 1. 이미지 데이터 개수별 다른 뷰 적용 필요
 2. 동시 당첨 시 달라지는 맨 위 텍스트 뷰 수정 필요
 */

import UIKit
import PinLayout
import FlexLayout
import Kingfisher
import RxSwift
import ReactorKit

class WinningReviewDetailView: UIView, UIScrollViewDelegate, View {
    
    var disposeBag = DisposeBag()
    
    fileprivate let scrollView = UIScrollView()
    fileprivate let rootFlexContainer = UIView()
    
    /// 로딩 상태를 위한 컨테이너 뷰
    private let loadingContainer = UIView()
    /// 로딩 progress view
    private let progressView = UIActivityIndicatorView(style: .medium)
    
    private let topMargin: CGFloat = {
        let topMargin = DeviceMetrics.statusWithNavigationBarHeight
        return topMargin
    }()
        
    /// 당첨 회차 레이블
    let drawRoundLabel = UILabel()
//    let dotLabel = UILabel()
    /// 당첨 복권 타입, 등수, 당첨금 정보 레이블
    let winningLotteryInfoLabel = UILabel()
    /// 당첨 후기 제목 레이블
    let winningReviewDetailTitleLabel = UILabel()
    /// 당첨 후기 인터뷰 날짜 레이블
    let interviewDate = UILabel()
    /// 당첨 후기 작성 날짜 레이블
    let createdDate = UILabel()
    /// 인터뷰 Q/A 부분
    let answerLabel = UILabel()
    /// 안내 레이블 - 오늘 본 글은 내일 다시 확인할 수 있어요.
    let noticeLabel = UILabel()
    /// 원문 보러 가기 버튼
    let goToOriginalReview = UIButton(type: .system)
    /// 다른 당첨 후기 리스트 타이틀
    let otherReviewsTitle = UILabel()
    /// 다른 당첨 후기 리스트 타이틀 아래 나타나는 설명 레이블
    let otherReviewsSecondary = UILabel()
    /// 뷰 하단에 나타나는 작은 리뷰 수평 리스트
    let horizontalReviewCards = WinningReviewListView()
    
    /// 임시 배너
//    let banner = BannerView(bannerBackgroundColor: .yellow5, bannerImageName: "banner_coins", titleText: "행운의 1등 로또\r어디서 샀을까?", bodyText: "당첨 판매점 보러가기")
    
    let imagePageView = ImagePageViewController()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        setLabels()
        setButtons()
        setupLoadingView()
        
        scrollView.addSubview(rootFlexContainer)
        addSubview(scrollView)
        addSubview(loadingContainer)
        
        rootFlexContainer.flex
            .direction(.column)
            .marginTop(topMargin)
            .define { flex in
                flex.addItem().direction(.column)
                    .paddingHorizontal(20)
                    .paddingBottom(24)
                    .marginTop(12)
                    .define { flex in
                        
                        // 회차, 당첨 등수 / 금액 정보
                        flex.addItem()
                            .direction(.row)
                            .gap(4)
                            .marginBottom(4)
                            .define { flex in
                                flex.addItem(drawRoundLabel)
                                flex.addItem(winningLotteryInfoLabel)
                            }
                        
                        // 당첨 후기 상세 제목
                        flex.addItem(winningReviewDetailTitleLabel)
                            .marginBottom(4)
                        
                        flex.addItem()
                            .direction(.row)
                            .gap(8)
                            .alignItems(.center)
                            .marginBottom(32)
                            .define { flex in
                                flex.addItem(interviewDate)
                                flex.addItem().width(1).height(9).backgroundColor(.gray80)
                                flex.addItem(createdDate)
                            }
                        
                        flex.addItem(imagePageView.view)
                        
                        flex.addItem().direction(.column).marginBottom(16).define { flex in
                            flex.addItem(answerLabel)
                                .marginBottom(28)
                        }
                        flex.addItem().direction(.row).justifyContent(.spaceBetween).define { flex in
                            flex.addItem(noticeLabel)
                            flex.addItem(goToOriginalReview)
                        }
                    }
                // 구분선
                flex.addItem().height(10).backgroundColor(.gray20).marginBottom(24)
                
                flex.addItem().direction(.column).define { flex in
                    flex.addItem(otherReviewsTitle).alignSelf(.start).paddingHorizontal(20)
                    flex.addItem(otherReviewsSecondary).alignSelf(.start).paddingHorizontal(20).marginBottom(10)
                    flex.addItem(horizontalReviewCards).width(100%).height(220).marginBottom(18)
                }
            }
    }
    
    
    func setLabels() {
        // 기본 스타일만 설정, 텍스트는 서버 데이터로 설정
//        styleLabel(for: drawRoundLabel, fontStyle: .label2, textColor: .gray120)
//        dotLabel.text = "•"
//        styleLabel(for: dotLabel, fontStyle: .caption1, textColor: .gray120)
        styleLabel(for: winningLotteryInfoLabel, fontStyle: .label2, textColor: .gray120)
        
        winningReviewDetailTitleLabel.numberOfLines = 0
        winningReviewDetailTitleLabel.lineBreakMode = .byWordWrapping
//        styleLabel(for: winningReviewDetailTitleLabel, fontStyle: .title3, textColor: .black, alignment: .left)
        
        styleLabel(for: interviewDate, fontStyle: .caption1, textColor: .gray80)
        styleLabel(for: createdDate, fontStyle: .caption1, textColor: .gray80)
        
        answerLabel.numberOfLines = 0
        styleLabel(for: answerLabel, fontStyle: .body1, textColor: .black, alignment: .left)
        
        noticeLabel.text = "오늘 본 글은 내일 다시 확인할 수 있어요."
        styleLabel(for: noticeLabel, fontStyle: .caption1, textColor: .gray80)
        
        otherReviewsTitle.text = "로또 당첨자 후기"
        styleLabel(for: otherReviewsTitle, fontStyle: .headline1, textColor: .gray120)
        otherReviewsSecondary.text = "역대 로또 당첨자들의 생생한 후기예요."
        styleLabel(for: otherReviewsSecondary, fontStyle: .label2, textColor: .gray80)
    }
    
    func setButtons() {
        let attributedTitle = NSAttributedString(string: "원문 보러 가기", attributes: Typography.caption1.attributes())
        goToOriginalReview.setAttributedTitle(attributedTitle, for: .normal)
        if let image = UIImage(named: "icon_arrow_right_in_button") {
            let resizedImage = resizeImage(image: image, targetSize: CGSizeMake(14.0, 14.0))
            goToOriginalReview.setImage(resizedImage, for: .normal)
        }
        goToOriginalReview.tintColor = .gray100
        goToOriginalReview.semanticContentAttribute = .forceRightToLeft
        goToOriginalReview.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        goToOriginalReview.titleEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        
        // ReactorKit 바인딩으로 처리하므로 타겟 액션 제거
    }
    
    func setupLoadingView() {
        // 로딩 컨테이너 설정
        loadingContainer.backgroundColor = .white
        
        // Progress view 설정
        progressView.color = .gray100
        progressView.hidesWhenStopped = true
        
        loadingContainer.addSubview(progressView)
        
        // 초기에는 로딩 상태로 설정
        showLoading()
    }
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 스크롤뷰 레이아웃
        scrollView.pin.all()
        rootFlexContainer.pin.top().horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = rootFlexContainer.frame.size
        
        // 로딩 컨테이너 레이아웃 (전체 화면 크기)
        loadingContainer.pin.all()
        
        // Progress view를 중앙에 배치
        progressView.pin.center()
    }
    
    private func showLoading() {
        loadingContainer.isHidden = false
        scrollView.isHidden = true
        progressView.startAnimating()
    }
    
    private func hideLoading() {
        loadingContainer.isHidden = true
        scrollView.isHidden = false
        progressView.stopAnimating()
    }
    
    private func updateLabelsWithAttributedData(data: WinningReviewDetailResponse) {
        // 당첨 회차 정보
        if let lottoDrwNo = data.lottoDrwNo, lottoDrwNo > 0 {
            let lottoDrwNoText = "\(lottoDrwNo)회차"
            drawRoundLabel.textColor = .gray120
            drawRoundLabel.attributedText = NSAttributedString(
                string: lottoDrwNoText,
                attributes: Typography.caption1.attributes()
            )
        }
        
        // 현재 서버에서 내려주는 정보가 없어 주석 처리
        // TODO: 데이터 확인 후 추가하기 ("|" separator bar도 drawRoundLabel, winningLotteryInfoLabel 값이 모두 존재한다면 추가 필요
//        winningLotteryInfoLabel.attributedText = NSAttributedString(
//            string: "로또 1등 당첨",
//            attributes: Typography.label2.attributes()
//        )
        
        // 제목
        if let reviewTitle = data.reviewTitle {
            winningReviewDetailTitleLabel.textColor = .black
            winningReviewDetailTitleLabel.numberOfLines = 0
            winningReviewDetailTitleLabel.lineBreakMode = .byWordWrapping
            winningReviewDetailTitleLabel.attributedText = NSAttributedString(
                string: reviewTitle,
                attributes: Typography.title3.attributes(alignment: .left)
            )
        }
        
        // 인터뷰 날짜
        if let intrvDate = data.intrvDate, !intrvDate.isEmpty {
            let interviewDateText = "인터뷰 \(intrvDate.reformatDate)"
            interviewDate.textColor = .gray80
            interviewDate.attributedText = NSAttributedString(
                string: interviewDateText,
                attributes: Typography.caption2.attributes()
            )
        }
        
        // 작성일
        if let reviewDate = data.reviewDate, !reviewDate.isEmpty {
            let reviewDateText = "작성 \(reviewDate.reformatDate)"
            createdDate.textColor = .gray80
            createdDate.attributedText = NSAttributedString(
                string: reviewDateText,
                attributes: Typography.caption2.attributes()
            )
        }
    }
    
    private func updateImagesWithData(data: WinningReviewDetailResponse) {
        // 이미지 데이터가 있는 경우 ImagePageViewController에 전달
        if let reviewImages = data.reviewImg, !reviewImages.isEmpty {
            imagePageView.configureWithImageURLs(reviewImages)
        }
    }
    
    private func updateQASection(data: WinningReviewDetailResponse) {
        // reviewCont가 있는 경우 파싱하여 Q&A 형태로 표시
        if let reviewContent = data.reviewCont {
            parseAndDisplayQA(content: reviewContent)
        }
    }
    
    private func parseAndDisplayQA(content: String) {
        // Q&A 섹션도 NSAttributedString으로 통일
        answerLabel.attributedText = NSAttributedString(
            string: content,
            attributes: Typography.body1.attributes(alignment: .left)
        )
    }
    
    // MARK: - ReactorKit View Protocol
    
    func bind(reactor: WinningReviewReactor) {
        // Action binding
        // 원문 보러가기 버튼 액션
//        goToOriginalReview.rx.tap
//            .withLatestFrom(reactor.state.map { $0.winningReviewDetail })
//            .compactMap { $0 }
//            .subscribe(onNext: { [weak self] data in
//                guard let self = self,
//                      let reviewHref = data.reviewHref,
//                      reviewHref > 0 else { return }
//                
//                let urlString = "https://dhlottery.co.kr/winnerInterview.do?method=interview&intrvNo=\(reviewHref)"
//                if let url = URL(string: urlString) {
//                    if UIApplication.shared.canOpenURL(url) {
//                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                    }
//                }
//            })
//            .disposed(by: disposeBag)
        
        // 초기 데이터 로드 (필요시)
        // reactor.action.onNext(.loadReviewDetail(reviewId: reviewId))
        
        // State binding - 통합 바인딩으로 모든 UI 요소 업데이트
        reactor.state
            .map { $0.winningReviewDetail }
            .compactMap { $0 }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                
                print("당첨 후기 데이터: \(data)")
                
                self.updateLabelsWithAttributedData(data: data)
                self.updateImagesWithData(data: data)
                self.updateQASection(data: data)
                
                setNeedsLayout()
                layoutIfNeeded()
            })
            .disposed(by: disposeBag)
        
        
        // 로딩 상태 바인딩
        reactor.state
            .map { $0.isLoading(.reviewDetail) }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                print("isLoading winning review: \(isLoading)")
                
                if isLoading {
                    self.showLoading()
                } else {
                    self.hideLoading()
                }
            })
            .disposed(by: disposeBag)
        
        // 오류 상태 바인딩
        reactor.state
            .map { $0.error }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                guard let self = self else { return }
                // 오류 처리
                print("Error loading review detail: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
        
        // 다른 당첨 후기 리스트 바인딩
//        reactor.state
//            .map { $0.otherReviews }
//            .distinctUntilChanged()
//            .skip(1)
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] otherReviews in
//                guard let self = self else { return }
//                self.horizontalReviewCards.configure(with: otherReviews)
//            })
//            .disposed(by: disposeBag)
    }
}

#Preview {
    let view = WinningReviewDetailView()
    return view
}
