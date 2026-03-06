//
//  RandomNumbersLoadingView.swift
//  LottoMate
//
//  Created by Mirae on 10/29/24.
//

import UIKit
import PinLayout
import FlexLayout
import ReactorKit
import RxSwift
import RxCocoa

// MARK: - UIImageView GIF Extension
extension UIImageView {
    func loadGif(name: String, subdirectory: String? = nil) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            var gifData: Data?
            var foundPath: String = ""
            
            // 여러 방법으로 GIF 파일 찾기
            if let subdirectory = subdirectory,
               let url = Bundle.main.url(forResource: name, withExtension: "gif", subdirectory: subdirectory) {
                gifData = try? Data(contentsOf: url)
                foundPath = url.path
                print("✅ Found GIF with subdirectory: \(url)")
            } else if let url = Bundle.main.url(forResource: name, withExtension: "gif") {
                gifData = try? Data(contentsOf: url)
                foundPath = url.path
                print("✅ Found GIF without subdirectory: \(url)")
            } else {
                print("❌ Failed to find \(name).gif")
                
                // 모든 Bundle의 리소스 출력 (디버깅용)
                if let resourcePath = Bundle.main.resourcePath {
                    print("📁 Bundle resource path: \(resourcePath)")
                }
                
                // 모든 GIF 파일 검색
                if let allGifs = Bundle.main.urls(forResourcesWithExtension: "gif", subdirectory: nil) {
                    print("📋 All GIF files in bundle: \(allGifs)")
                }
                
                if let subdirectory = subdirectory,
                   let allGifsInSubdir = Bundle.main.urls(forResourcesWithExtension: "gif", subdirectory: subdirectory) {
                    print("📋 All GIF files in \(subdirectory): \(allGifsInSubdir)")
                }
                
                // 정적 이미지로 fallback
                DispatchQueue.main.async {
                    // 기본 이미지로 대체 (정적 이미지)
                    if let fallbackImage = UIImage(named: "ch_randomNumbersLoading") {
                        self.image = fallbackImage
                        print("🔄 Fallback to static image")
                    } else {
                        // 컬러 원형 뷰로 대체
                        self.backgroundColor = .systemBlue
                        self.layer.cornerRadius = min(self.frame.width, self.frame.height) / 2
                        print("🔵 Fallback to blue circle")
                    }
                }
                return
            }
            
            guard let data = gifData,
                  let source = CGImageSourceCreateWithData(data as CFData, nil) else {
                print("❌ Failed to create image source from: \(foundPath)")
                return
            }
            
            let frameCount = CGImageSourceGetCount(source)
            var images: [UIImage] = []
            var totalDuration: Double = 0.0
            
            print("🎬 Processing \(frameCount) frames from: \(foundPath)")
            
            for i in 0..<frameCount {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    images.append(UIImage(cgImage: cgImage))
                    
                    // 프레임 지속시간 계산
                    if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                       let gifDict = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any],
                       let delayTime = gifDict[kCGImagePropertyGIFDelayTime as String] as? Double {
                        totalDuration += delayTime
                    } else {
                        totalDuration += 0.1
                    }
                }
            }
            
            DispatchQueue.main.async {
                if !images.isEmpty {
                    self.animationImages = images
                    self.animationDuration = max(totalDuration, 0.5)
                    self.animationRepeatCount = 0
                    self.startAnimating()
                    print("✅ GIF animation started: \(images.count) frames, duration: \(totalDuration)s")
                } else {
                    print("❌ No frames extracted")
                    // 정적 이미지로 fallback
                    if let fallbackImage = UIImage(named: "ch_randomNumbersLoading") {
                        self.image = fallbackImage
                        print("🔄 Fallback to static image")
                    }
                }
            }
        }
    }
}

class RandomNumbersLoadingView: UIView, View {
    var disposeBag = DisposeBag()
    
    fileprivate let rootFlexContainer = UIView()
    
    private let statusBarHeight = DeviceMetrics.statusBarHeight
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘의 랜덤 번호를\r뽑는 중이에요"
        label.numberOfLines = 2
        styleLabel(for: label, fontStyle: .title2, textColor: .black)
        return label
    }()
    
    // 로띠 공 아래에 위치되는 이미지
    private let loadingCharacter = CommonImageView(imageName: "ch_randomNumbersLoading")
    
    // GIF 공 애니메이션 (단순화된 버전)
    private let loadingImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        
        // GIF 로드
        imageView.loadGif(name: "randomNumbers", subdirectory: "LottieAnimations")
        
        return imageView
    }()
    
    private let completeImage: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "ch_random_number_complete")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var barView = UIView()
    
    private var pickedRandomNumbers: [Int] = []
    
    let closeButton: StyledButton = {
        let button = StyledButton(
            title: "완료",
            buttonStyle: .solid(.large, .active),
            cornerRadius: 8,
            verticalPadding: 12,
            horizontalPadding: 0)
        button.alpha = 0
        return button
    }()
    
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        
        completeImage.isHidden = true // Hide completeImage initially
        setupLayout()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.updateToRandomNumbersState()
        }
    }
    
    private func setupLayout() {
        addSubview(rootFlexContainer)
        addSubview(completeImage) // Add completeImage to view hierarchy
        
        let topMargin = (UIScreen.main.bounds.height - statusBarHeight) / 4.6158
        let imageWidth = UIScreen.main.bounds.width / 1.431
        
        rootFlexContainer.flex
            .direction(.column)
            .alignItems(.center)
            .define { flex in
                flex.addItem(titleLabel)
                    .marginTop(topMargin + statusBarHeight)
                    .marginBottom(16)
                
                flex.addItem(loadingImage)
                    .width(262)
                    .height(284)
                
                flex.addItem(loadingCharacter)
                    .position(.absolute)
            }
            
        // Position completeImage at the same position as loadingImage
        completeImage.frame = CGRect(x: 0, y: 0, width: imageWidth, height: imageWidth)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.all()
        rootFlexContainer.flex.layout()
        
        let screenWidth = UIScreen.main.bounds.width
        let width = (screenWidth - 40)
        
        closeButton.pin
            .width(width)
            .bottomCenter(37)
            
        // Position completeImage
        let imageWidth = screenWidth / 1.431
        completeImage.pin
            .width(imageWidth)
            .height(imageWidth)
            .below(of: titleLabel, aligned: .center)
            .marginTop(16)
        
        loadingCharacter.pin
            .size(screenWidth / 2.083)
            .below(of: loadingImage, aligned: .center)
            .marginTop(-194)
        
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
    }
    
    func bind(reactor: StorageViewReactor) {
        reactor.state
            .map { $0.temporaryRandomNumbers.last ?? [] }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] lastRandomNumbers in
                self?.pickedRandomNumbers = lastRandomNumbers
            })
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .map { StorageViewReactor.Action.hideLoading }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func showNumberBallsView(_ numbers: [Int]) {
        barView.flex.view?.subviews.forEach { $0.removeFromSuperview() }
        
        numbers.forEach { number in
            barView.flex.direction(.row)
                .gap(8)
                .justifyContent(.center)
                .paddingVertical(16)
                .backgroundColor(.gray10)
                .cornerRadius(30)
                .define { flex in
                    let numberBall = WinningNumberCircleView()
                    let color = colorForNumber(number)
                    numberBall.number = number
                    numberBall.circleColor = color
                    
                    flex.addItem(numberBall).size(28)
                }
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func updateToRandomNumbersState() {
        let adjustedTopMargin = (UIScreen.main.bounds.height - statusBarHeight) / 4.6158 - 56
        let imageWidth = UIScreen.main.bounds.width / 1.431
        
        // 루트 컨테이너 레이아웃 재설정
        rootFlexContainer.flex.markDirty()
        rootFlexContainer.flex
            .direction(.column)
            .alignItems(.center)
            .define { flex in
                flex.addItem(titleLabel)
                    .marginTop(adjustedTopMargin + statusBarHeight)
                    .marginBottom(16)
                flex.addItem(loadingImage)
                    .width(imageWidth)
            }
        
        // 타이틀 레이블 애니메이션
        UIView.transition(with: titleLabel,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
            self?.titleLabel.text = "오늘의 랜덤 번호를\r확인하세요!"
        })
        
        // 로딩 이미지를 완료 이미지로 변경
        loadingImage.stopAnimating()
        UIView.transition(with: loadingImage,
                         duration: 0.2,
                         options: .transitionCrossDissolve,
                         animations: { [weak self] in
            self?.loadingImage.isHidden = true
            self?.loadingCharacter.isHidden = true
            self?.completeImage.isHidden = false
        })
        
        // 번호볼 뷰 추가 및 표시
        rootFlexContainer.flex.addItem(barView)
            .width(UIScreen.main.bounds.width - 40)
            .marginTop(48)
        
        // 번호볼 뷰 표시
        self.showNumberBallsView(self.pickedRandomNumbers)
        
        // 닫기 버튼 추가 및 표시
        rootFlexContainer.flex.addItem(closeButton)
            .position(.absolute)
        
        // 닫기 버튼 애니메이션
        closeButton.alpha = 0
        closeButton.isHidden = false
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .transitionCrossDissolve,
                       animations: { [weak self] in
            self?.closeButton.alpha = 1
        })
        
        ToastView.show(message: "뽑은 번호는 오늘 뽑은 번호에서 확인할 수 있어요", horizontalPadding: 60)
        
        // 레이아웃 업데이트
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // 뷰가 제거될 때 정리 작업 수행
    override func removeFromSuperview() {
        disposeBag = DisposeBag()
        super.removeFromSuperview()
    }
    
    // 뷰가 window에서 제거될 때도 정리
    override func didMoveToWindow() {
        super.didMoveToWindow()
    }
}

#Preview {
    let view = RandomNumbersLoadingView()
    return view
}
