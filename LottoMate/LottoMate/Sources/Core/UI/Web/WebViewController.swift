//
//  WebViewController.swift
//  LottoMate
//
//  Created by AI Assistant
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    // MARK: - Properties
    private let urlString: String
    private let pageTitle: String?
    private let statusBarTag = 987655
    
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
    
    private lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initialization
    
    init(urlString: String, title: String? = nil) {
        self.urlString = urlString
        self.pageTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadURL()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        changeStatusBarBgColor(bgColor: .clear)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeStatusBarBgColor()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        // Add subviews
        view.addSubview(customNavBar)
        customNavBar.addSubview(backButton)
        view.addSubview(webView)
        view.addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Custom Navigation Bar (will be adjusted in viewDidLayoutSubviews)
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 100), // Temporary, will be updated
            
            // Back Button (positioned at bottom of nav bar)
            backButton.leadingAnchor.constraint(equalTo: customNavBar.leadingAnchor),
            backButton.bottomAnchor.constraint(equalTo: customNavBar.bottomAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            // WebView
            webView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update navigation bar height based on actual status bar height
        var statusBarHeight: CGFloat = 0.0
        if let windowScene = view.window?.windowScene {
            statusBarHeight = windowScene.statusBarManager?.statusBarFrame.height ?? 0
        }
        let navBarHeight: CGFloat = 56
        let totalNavHeight = statusBarHeight + navBarHeight
        
        // Update custom nav bar height constraint
        customNavBar.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = totalNavHeight
            }
        }
    }
    
    private func loadURL() {
        guard let url = URL(string: urlString) else {
            print("⚠️ Invalid URL: \(urlString)")
            showErrorAlert()
            return
        }
        
        loadingIndicator.startAnimating()
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    // MARK: - Presentation
    
    /// 오른쪽에서 왼쪽으로 슬라이드하며 WebViewController를 표시합니다
    static func present(from viewController: UIViewController, urlString: String, title: String? = nil) {
        guard let window = WindowManager.findKeyWindow(),
              let rootViewController = window.rootViewController else {
            print("⚠️ Cannot find root view controller")
            return
        }
        
        let webViewController = WebViewController(urlString: urlString, title: title)
        webViewController.view.frame = window.bounds
        
        // Add as child view controller
        rootViewController.addChild(webViewController)
        rootViewController.view.addSubview(webViewController.view)
        
        // Start off-screen to the right
        webViewController.view.transform = CGAffineTransform(translationX: window.bounds.width, y: 0)
        
        // Animate in from the right
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.curveEaseInOut]) {
            webViewController.view.transform = .identity
        } completion: { _ in
            webViewController.didMove(toParent: rootViewController)
        }
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            dismissWithAnimation()
        }
    }
    
    private func dismissWithAnimation() {
        guard let window = WindowManager.findKeyWindow() else {
            removeFromParent()
            view.removeFromSuperview()
            return
        }
        
        // Animate out to the right
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.curveEaseInOut]) {
            self.view.transform = CGAffineTransform(translationX: window.bounds.width, y: 0)
        } completion: { _ in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "오류",
            message: "페이지를 불러올 수 없습니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        print("⚠️ WebView failed to load: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        print("⚠️ WebView provisional navigation failed: \(error.localizedDescription)")
        showErrorAlert()
    }
}

// MARK: - Status Bar

extension WebViewController {
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

