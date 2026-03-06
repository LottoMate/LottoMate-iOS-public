//
//  SimpleWinningReviewDetailViewController.swift
//  LottoMate
//
//  Created by Mirae on 1/17/25.
//

import UIKit
import RxSwift
import FlexLayout

class NativeWinningReviewDetailViewController: UIViewController {
    private let viewModel = LottoMateViewModel.shared
    
    private let reviewNo: Int
    private let disposeBag = DisposeBag()
    private let apiService = WinningReviewAPIService()
    private var currentData: WinningReviewDetailResponse?
    private let statusBarTag = 987654
    
    // Dynamic constraint for content stack view
    private var contentStackViewTopConstraint: NSLayoutConstraint?
    
    // MARK: - UI Components
    
    // Custom Navigation Bar
    private let customNavBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.8)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "backArrow"), for: .normal)
        button.tintColor = .gray100
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 13, bottom: 10, right: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let navTitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        styleLabel(for: label, fontStyle: .headline1, textColor: .black)
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private let roundLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        styleLabel(for: label, fontStyle: .caption1, textColor: .gray120)
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        styleLabel(for: label, fontStyle: .title3, textColor: .black, alignment: .left)
        return label
    }()
    
    private let dateContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let interviewDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        styleLabel(for: label, fontStyle: .caption2, textColor: .gray80)
        return label
    }()
    
    private let dateSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .gray80
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let reviewDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        styleLabel(for: label, fontStyle: .caption2, textColor: .gray80)
        return label
    }()
    
    // Image Page View Controller
    private lazy var imagePageViewController: ImagePageViewController = {
        let vc = ImagePageViewController()
        return vc
    }()
    
    private let imageContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 28 // Gap between Q&A pairs
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let noticeLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘 본 글은 내일 다시 확인할 수 있어요."
        label.translatesAutoresizingMaskIntoConstraints = false
        styleLabel(for: label, fontStyle: .caption1, textColor: .gray80)
        return label
    }()
    
    private let originalReviewButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSAttributedString(
            string: "원문 보러 가기",
            attributes: Typography.caption1.attributes()
        )
        button.setAttributedTitle(attributedTitle, for: .normal)
        if let image = UIImage(named: "icon_arrow_right_in_button") {
            button.setImage(image, for: .normal)
        }
        button.tintColor = .gray100
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let otherReviewsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "로또 당첨자 후기"
        label.translatesAutoresizingMaskIntoConstraints = false
        styleLabel(for: label, fontStyle: .headline1, textColor: .gray120, alignment: .left)
        return label
    }()
    
    private let otherReviewsSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "역대 로또 당첨자들의 생생한 후기예요."
        label.translatesAutoresizingMaskIntoConstraints = false
        styleLabel(for: label, fontStyle: .label2, textColor: .gray80, alignment: .left)
        return label
    }()
    
    private let horizontalReviewCards: WinningReviewListView = {
        let view = WinningReviewListView(cardSize: .small, showDotIndicator: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bannerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    
    init(reviewNo: Int) {
        self.reviewNo = reviewNo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
        setupActions()
        setupBanner()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeStatusBarBgColor(bgColor: .white.withAlphaComponent(0.8))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeStatusBarBgColor()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update content inset based on actual status bar height
        var statusBarHeight: CGFloat = 0.0
        if let windowScene = view.window?.windowScene {
            statusBarHeight = windowScene.statusBarManager?.statusBarFrame.height ?? 0
        }
        let navBarHeight: CGFloat = 56
        let totalTopHeight = statusBarHeight + navBarHeight
        
        scrollView.contentInset = UIEdgeInsets(top: totalTopHeight, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: totalTopHeight, left: 0, bottom: 0, right: 0)
        
        // FlexLayout 업데이트
        bannerContainer.flex.layout()
    }
    
    private func setupNavigationBar() {
        // Hide default navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Add scrollView first (behind navigation bar)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add custom navigation bar on top (for z-index)
        view.addSubview(customNavBar)
        customNavBar.addSubview(backButton)
        customNavBar.addSubview(navTitleLabel)
        
        view.addSubview(loadingIndicator)
        
        // Add child view controller for images
        addChild(imagePageViewController)
        imagePageViewController.didMove(toParent: self)
        imagePageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews to content view
        contentView.addSubview(roundLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateContainerView)
        contentView.addSubview(imageContainerView)
        contentView.addSubview(contentStackView)
        contentView.addSubview(noticeLabel)
        contentView.addSubview(originalReviewButton)
        contentView.addSubview(separatorView)
        contentView.addSubview(otherReviewsTitleLabel)
        contentView.addSubview(otherReviewsSubtitleLabel)
        contentView.addSubview(horizontalReviewCards)
        contentView.addSubview(bannerContainer)
        
        // Date container subviews
        dateContainerView.addSubview(interviewDateLabel)
        dateContainerView.addSubview(dateSeparator)
        dateContainerView.addSubview(reviewDateLabel)
        
        // Image container
        imageContainerView.addSubview(imagePageViewController.view)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        let navBarHeight: CGFloat = 56
        
        NSLayoutConstraint.activate([
            // Scroll View (full screen, ignoring safe area)
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Custom Navigation Bar (on top of scrollView)
            customNavBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: navBarHeight),
            
            // Back Button
            backButton.leadingAnchor.constraint(equalTo: customNavBar.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Nav Title Label
            navTitleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 10),
            navTitleLabel.trailingAnchor.constraint(equalTo: customNavBar.trailingAnchor, constant: -20),
            navTitleLabel.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Round Label
            roundLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            roundLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            roundLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Date Container View
            dateContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateContainerView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            dateContainerView.heightAnchor.constraint(equalToConstant: 20),
            
            // Interview Date Label
            interviewDateLabel.leadingAnchor.constraint(equalTo: dateContainerView.leadingAnchor),
            interviewDateLabel.centerYAnchor.constraint(equalTo: dateContainerView.centerYAnchor),
            
            // Date Separator
            dateSeparator.leadingAnchor.constraint(equalTo: interviewDateLabel.trailingAnchor, constant: 8),
            dateSeparator.centerYAnchor.constraint(equalTo: dateContainerView.centerYAnchor),
            dateSeparator.widthAnchor.constraint(equalToConstant: 1),
            dateSeparator.heightAnchor.constraint(equalToConstant: 9),
            
            // Review Date Label
            reviewDateLabel.leadingAnchor.constraint(equalTo: dateSeparator.trailingAnchor, constant: 8),
            reviewDateLabel.centerYAnchor.constraint(equalTo: dateContainerView.centerYAnchor),
            reviewDateLabel.trailingAnchor.constraint(lessThanOrEqualTo: dateContainerView.trailingAnchor),
            
            // Image Container View
            imageContainerView.topAnchor.constraint(equalTo: dateContainerView.bottomAnchor, constant: 24),
            imageContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imageContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Image Page View Controller
            imagePageViewController.view.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            imagePageViewController.view.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            imagePageViewController.view.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            imagePageViewController.view.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            
            // Content Stack View (leading and trailing only, top will be set dynamically)
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Notice Label
            noticeLabel.topAnchor.constraint(equalTo: contentStackView.bottomAnchor, constant: 28),
            noticeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            // Original Review Button
            originalReviewButton.centerYAnchor.constraint(equalTo: noticeLabel.centerYAnchor),
            originalReviewButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            originalReviewButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Separator View
            separatorView.topAnchor.constraint(equalTo: noticeLabel.bottomAnchor, constant: 24),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 10),
            
            // Other Reviews Title
            otherReviewsTitleLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 24),
            otherReviewsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            otherReviewsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Other Reviews Subtitle
            otherReviewsSubtitleLabel.topAnchor.constraint(equalTo: otherReviewsTitleLabel.bottomAnchor, constant: 4),
            otherReviewsSubtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            otherReviewsSubtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Horizontal Review Cards
            horizontalReviewCards.topAnchor.constraint(equalTo: otherReviewsSubtitleLabel.bottomAnchor, constant: 10),
            horizontalReviewCards.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            horizontalReviewCards.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            horizontalReviewCards.heightAnchor.constraint(equalToConstant: 220),
//            horizontalReviewCards.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18),
            
            bannerContainer.topAnchor.constraint(equalTo: horizontalReviewCards.bottomAnchor, constant: 20),
            bannerContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bannerContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bannerContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            bannerContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
        
        // Set initial top constraint for contentStackView (will be updated dynamically based on image availability)
        contentStackViewTopConstraint = contentStackView.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 28)
        contentStackViewTopConstraint?.isActive = true
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        originalReviewButton.addTarget(self, action: #selector(originalReviewTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func originalReviewTapped() {
        guard let data = currentData,
              let reviewHref = data.reviewHref,
              reviewHref > 0 else {
            print("⚠️ No review href available")
            return
        }
        
        let urlString = "https://dhlottery.co.kr/winnerInterview.do?method=interview&intrvNo=\(reviewHref)"
        WebViewController.present(from: self, urlString: urlString, title: "당첨 후기 원문")
    }
    
    // MARK: - Content Parsing
    
    struct QAPair {
        let question: String
        let answer: String
    }
    
    private func parseReviewContent(_ content: String) -> [QAPair] {
        var qaPairs: [QAPair] = []
        
        // Split by ▶ to get each Q&A block
        let blocks = content.components(separatedBy: "▶").filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        for block in blocks {
            // Split by -> to separate question and answer
            // Handle both \n\n and \n\n\n as separators before ->
            let parts = block.components(separatedBy: "->")
            
            if parts.count >= 2 {
                let question = parts[0]
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let answer = parts[1]
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !question.isEmpty && !answer.isEmpty {
                    qaPairs.append(QAPair(question: question, answer: answer))
                }
            } else if !parts[0].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                // No -> found, treat entire block as question with empty answer
                let question = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                qaPairs.append(QAPair(question: question, answer: ""))
            }
        }
        
        return qaPairs
    }
    
    private func configureQAContent(qaPairs: [QAPair]) {
        // Clear existing content
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for qaPair in qaPairs {
            // Create container for each Q&A pair
            let qaContainer = UIStackView()
            qaContainer.axis = .vertical
            qaContainer.spacing = 8 // Gap between question and answer
            qaContainer.alignment = .fill
            qaContainer.distribution = .fill
            qaContainer.translatesAutoresizingMaskIntoConstraints = false
            
            // Create question label
            let questionLabel = UILabel()
            questionLabel.text = "Q. " + qaPair.question
            questionLabel.numberOfLines = 0
            questionLabel.translatesAutoresizingMaskIntoConstraints = false
            styleLabel(for: questionLabel, fontStyle: .headline2, textColor: .black, alignment: .left)
            
            // Create answer label
            let answerLabel = UILabel()
            answerLabel.text = qaPair.answer
            answerLabel.numberOfLines = 0
            answerLabel.translatesAutoresizingMaskIntoConstraints = false
            styleLabel(for: answerLabel, fontStyle: .body1, textColor: .black, alignment: .left)
            
            // Add labels to container
            qaContainer.addArrangedSubview(questionLabel)
            if !qaPair.answer.isEmpty {
                qaContainer.addArrangedSubview(answerLabel)
            }
            
            // Add container to main stack view
            contentStackView.addArrangedSubview(qaContainer)
        }
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        showLoading(true)
        
        print("📡 Fetching review detail for reviewNo: \(reviewNo)")
        
        apiService.fetchWinningReviewDetail(reviewNo: reviewNo)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] response in
                    print("✅ Successfully received review detail: \(response)")
                    self?.updateUI(with: response)
                    self?.showLoading(false)
                },
                onError: { [weak self] error in
                    print("❌ Error loading review detail: \(error)")
                    self?.showError(error)
                    self?.showLoading(false)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func updateUI(with data: WinningReviewDetailResponse) {
        self.currentData = data
        
        print("🎨 Updating UI with data:")
        print("   - Title: \(data.reviewTitle ?? "nil")")
        print("   - Round: \(data.lottoDrwNo ?? 0)")
        print("   - Interview Date: \(data.intrvDate ?? "nil")")
        print("   - Review Date: \(data.reviewDate ?? "nil")")
        print("   - Images: \(data.reviewImg?.count ?? 0)")
        print("   - Content length: \(data.reviewCont?.count ?? 0)")
        
        // Round
        if let round = data.lottoDrwNo, round > 0 {
            roundLabel.text = "\(round)회차"
            styleLabel(for: roundLabel, fontStyle: .caption1, textColor: .gray120)
            print("✅ Round set: \(round)회차")
        } else {
            roundLabel.text = ""
            print("⚠️ No round information")
        }
        
        // Title
        if let title = data.reviewTitle, !title.isEmpty {
            titleLabel.text = title
            styleLabel(for: titleLabel, fontStyle: .title3, textColor: .black, alignment: .left)
            print("✅ Title set: \(title)")
        } else {
            titleLabel.text = "제목 없음"
            styleLabel(for: titleLabel, fontStyle: .title3, textColor: .black, alignment: .left)
            print("⚠️ No title available")
        }
        
        // Interview Date
        if let intrvDate = data.intrvDate, !intrvDate.isEmpty {
            interviewDateLabel.text = "인터뷰 \(intrvDate.reformatDate)"
            styleLabel(for: interviewDateLabel, fontStyle: .caption2, textColor: .gray80)
            interviewDateLabel.isHidden = false
            print("✅ Interview date set: \(intrvDate.reformatDate)")
        } else {
            interviewDateLabel.isHidden = true
            print("⚠️ No interview date")
        }
        
        // Review Date
        if let reviewDate = data.reviewDate, !reviewDate.isEmpty {
            reviewDateLabel.text = "작성 \(reviewDate.reformatDate)"
            styleLabel(for: reviewDateLabel, fontStyle: .caption2, textColor: .gray80)
            reviewDateLabel.isHidden = false
            print("✅ Review date set: \(reviewDate.reformatDate)")
        } else {
            reviewDateLabel.isHidden = true
            print("⚠️ No review date")
        }
        
        // Date separator visibility
        dateSeparator.isHidden = interviewDateLabel.isHidden || reviewDateLabel.isHidden
        
        // Images
        if let reviewImages = data.reviewImg, !reviewImages.isEmpty {
            print("✅ Setting up images: \(reviewImages.count) images")
            imagePageViewController.configureWithImageURLs(reviewImages)
            
            // Calculate image container height based on aspect ratio
            let screenWidth = UIScreen.main.bounds.width - 40 // minus padding
            let imageHeight = screenWidth / imagePageViewController.imageAspectRatio + 32 // + page control height
            
            // Update image container height constraint
            imageContainerView.constraints.forEach { constraint in
                if constraint.firstAttribute == .height {
                    constraint.isActive = false
                }
            }
            imageContainerView.heightAnchor.constraint(equalToConstant: imageHeight).isActive = true
            imageContainerView.isHidden = false
            
            // Update contentStackView top constraint to be below imageContainerView
            contentStackViewTopConstraint?.isActive = false
            contentStackViewTopConstraint = contentStackView.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 28)
            contentStackViewTopConstraint?.isActive = true
            
            print("✅ Image container height set to: \(imageHeight)")
        } else {
            imageContainerView.isHidden = true
            // Set height to 0 when no images
            imageContainerView.constraints.forEach { constraint in
                if constraint.firstAttribute == .height {
                    constraint.isActive = false
                }
            }
            imageContainerView.heightAnchor.constraint(equalToConstant: 0).isActive = true
            
            // Update contentStackView top constraint to be directly below dateContainerView
            contentStackViewTopConstraint?.isActive = false
            contentStackViewTopConstraint = contentStackView.topAnchor.constraint(equalTo: dateContainerView.bottomAnchor, constant: 32)
            contentStackViewTopConstraint?.isActive = true
            
            print("⚠️ No images available")
        }
        
        // Content
        if let content = data.reviewCont, !content.isEmpty {
            let qaPairs = parseReviewContent(content)
            configureQAContent(qaPairs: qaPairs)
            contentStackView.isHidden = false
            print("✅ Content set: \(qaPairs.count) Q&A pairs")
        } else {
            contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            contentStackView.isHidden = true
            print("⚠️ No content available")
        }
        
        // Force layout update
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        print("🎨 UI update completed")
    }
    
    private func showLoading(_ show: Bool) {
        if show {
            loadingIndicator.startAnimating()
            scrollView.alpha = 0
        } else {
            loadingIndicator.stopAnimating()
            UIView.animate(withDuration: 0.3) {
                self.scrollView.alpha = 1
            }
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "오류",
            message: "데이터를 불러올 수 없습니다.\n\(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "닫기", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    // MARK: - Status Bar
    
    private func changeStatusBarBgColor(bgColor: UIColor?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            
            if let existingStatusBarView = window.viewWithTag(self.statusBarTag) {
                existingStatusBarView.backgroundColor = bgColor
            } else {
                let statusBarManager = windowScene.statusBarManager
                let statusBarFrame = statusBarManager?.statusBarFrame ?? .zero
                let statusBarView = UIView(frame: statusBarFrame)
                statusBarView.backgroundColor = bgColor
                statusBarView.tag = self.statusBarTag
                window.addSubview(statusBarView)
            }
        }
    }
    
    private func removeStatusBarBgColor() {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        if let existingStatusBarView = window.viewWithTag(statusBarTag) {
            existingStatusBarView.removeFromSuperview()
        }
    }
}

extension NativeWinningReviewDetailViewController: BannerNavigationDelegate {
    private func setupBanner() {
        let banner = BannerManager.shared.createRandomBanner(navigationDelegate: self)
        self.bannerContainer.addSubview(banner)
        
        self.bannerContainer.flex.direction(.column).define { flex in
            flex.addItem(banner)
        }
        
        // 레이아웃 업데이트
        self.bannerContainer.flex.layout()
    }
    
    func navigate(to bannerType: BannerType) {
        switch bannerType {
        case .winningStore:
            showMapViewController()
        
        case .winnerReview:
            print("")
        
        case .getRandomLottoNumbers:
            showStorageRandomNumbersView()
        
        case .expandServicetoMyArea:
            // 내부 브라우저 폼 노출
            print("")
        
        case .winningLottoInfo:
            // 당첨 정보 상세로 이동 (최신 회차, 로또)
            viewModel.selectedLotteryType.onNext(.lotto)
            showLottoWinningInfoView()
        
        case .qrCodeScanner:
            showQrScanner()
        
        case .winnerGuide:
            showWinnerGuide()
        }
    }
    
    func showMapViewController() {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 1
        }
    }
    
    func showStorageRandomNumbersView() {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 2
            
            if let storageViewController = tabBarController.viewControllers?[2] as? StorageViewController {
                storageViewController.reactor.action.onNext(.didSelectrandomNumber)
            }
        }
    }
    
    func showQrScanner() {
        if let window = WindowManager.findKeyWindow() {
            if let rootViewController = window.rootViewController {
                let frameView = QrScannerOverlayView()
                Task {
                    QRScannerManager.shared.presentScanner(
                        from: rootViewController,
                        with: frameView
                    )
                }
            }
        }
    }
    
    func showWinnerGuide() {
        let winnerGuideVC = WinnerGuideVC()
        if let window = WindowManager.findKeyWindow(),
           let rootViewController = window.rootViewController {
            winnerGuideVC.view.frame = window.bounds
            
            rootViewController.addChild(winnerGuideVC)
            rootViewController.view.addSubview(winnerGuideVC.view)
            
            // Start off-screen to the right
            winnerGuideVC.view.transform = CGAffineTransform(translationX: window.bounds.width, y: 0)
            
            // Animate in from the right
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.curveEaseInOut]) {
                winnerGuideVC.view.transform = .identity
            } completion: { _ in
                winnerGuideVC.didMove(toParent: rootViewController)
            }
            
            // Set the status bar background color to match the nav bar
            winnerGuideVC.changeStatusBarBgColor(bgColor: .commonNavBar)
        }
    }
    
    private func showLottoWinningInfoView() {
        let viewController = WinningInfoDetailViewController()
        
        if let window = WindowManager.findKeyWindow() {
            viewController.view.frame = window.bounds
            if let rootViewController = window.rootViewController {
                rootViewController.addChild(viewController)
                rootViewController.view.addSubview(viewController.view)
                viewController.view.transform = CGAffineTransform(translationX: window.bounds.width, y: 0)
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               options: [.curveEaseInOut]) {
                    viewController.view.transform = .identity
                } completion: { _ in
                    viewController.didMove(toParent: rootViewController)
                }
                viewController.changeStatusBarBgColor(bgColor: .commonNavBar)
            }
        }
    }
}

#Preview {
    NativeWinningReviewDetailViewController(reviewNo: 1)
}

