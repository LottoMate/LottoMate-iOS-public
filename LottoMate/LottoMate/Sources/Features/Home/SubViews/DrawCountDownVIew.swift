//
//  DrawCountDownVIew.swift
//  LottoMate
//
//  Created by Mirae on 12/13/24.
//

import UIKit
import FlexLayout
import PinLayout

class DrawCountdownView: UIView {
    private var views: [UIView] = []
    private var currentIndex = 0
    private var timer: Timer?
    
    private let lottoDrawDateView: UIView = {
        let view = UIView()
        let icon = CommonImageView(imageName: "icon_lotto")
        let label = UILabel()
        let lottoDrawDateText: NSAttributedString
        let lottoDrawDateFullText = "로또 추첨일은 매주 토요일 오후 8시 45분"
        let attributedString = NSMutableAttributedString(
            string: lottoDrawDateFullText,
            attributes: Typography.body1.attributes(alignment: .left)
        )
        let dateString = "매주 토요일 오후 8시 45분"
        if let range = lottoDrawDateFullText.range(of: dateString) {
            let nsRange = NSRange(range, in: lottoDrawDateFullText)
            attributedString.addAttributes(
                [
                    .font: Typography.custom(
                        weight: "PretendardVariable-Bold",
                        size: 16,
                        lineHeight: 24,
                        letterSpacing: -0.6).font()
                ],
                range: nsRange)
        }
        label.attributedText = attributedString
        view.flex
            .paddingVertical(20)
            .backgroundColor(.blue5)
            .cornerRadius(16)
            .define { flex in
                flex.addItem()
                    .direction(.row)
                    .gap(8)
                    .alignSelf(.center)
                    .define { flex in
                        flex.addItem(icon)
                            .size(24)
                        flex.addItem(label)
                    }
            }
        
        return view
    }()
    
    private lazy var lottoDrawCountdownView: UIView = {
        let view = UIView()
        let icon = CommonImageView(imageName: "icon_lotto")
        let label = UILabel()
        let daysUntilLotto = calculateDaysUntilNextLotto()
        let fullText = "로또 당첨 발표까지 \(daysUntilLotto)일 남았어요."
        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: Typography.body1.attributes(alignment: .left)
        )
        let dayString = "\(daysUntilLotto)일"
        if let range = fullText.range(of: dayString) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttributes([
                    .foregroundColor: UIColor.blue50Default,
                    .font: Typography.headline2.font()],
                range: nsRange
            )
        }
        label.attributedText = attributedString
        view.flex
            .paddingVertical(20)
            .backgroundColor(.blue5)
            .cornerRadius(16)
            .define { flex in
                flex.addItem()
                    .direction(.row)
                    .gap(8)
                    .alignSelf(.center)
                    .define { flex in
                        flex.addItem(icon)
                            .size(24)
                        flex.addItem(label)
                    }
            }
        
        return view
    }()
    
    private let lottoDrawTodayView: UIView = {
        let view = UIView()
        let icon = CommonImageView(imageName: "icon_lotto")
        let label = UILabel()
        
        let fullText = "로또 당첨 발표는 오늘이에요!"
        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: Typography.body1.attributes(alignment: .left)
        )
        if let range = fullText.range(of: "오늘") {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttributes(
                [
                    .foregroundColor: UIColor.red50Default,
                    .font: Typography.headline2.font()
                ],
                range: nsRange
            )
        }
        label.attributedText = attributedString
        view.flex
            .paddingVertical(20)
            .backgroundColor(.blue5)
            .cornerRadius(16)
            .define { flex in
                flex.addItem()
                    .direction(.row)
                    .gap(8)
                    .alignSelf(.center)
                    .define { flex in
                        flex.addItem(icon)
                            .size(24)
                        flex.addItem(label)
                    }
            }
        
        return view
    }()
    
    private let pensionDrawDateView: UIView = {
        let view = UIView()
        let icon = CommonImageView(imageName: "icon_pensionLottery")
        let label = UILabel()
        
        let fullText = "연금복권 추첨일은 매주 수요일 오후 7시 30분"
        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: Typography.body1.attributes(alignment: .left)
        )
        let pensionDateString = "매주 수요일 오후 7시 30분"
        if let range = fullText.range(of: pensionDateString) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttributes(
                [
                    .font: Typography.custom(
                        weight: "PretendardVariable-Bold",
                        size: 16,
                        lineHeight: 24,
                        letterSpacing: -0.6).font()
                ],
                range: nsRange)
        }
        label.attributedText = attributedString
        view.flex
            .paddingVertical(20)
            .backgroundColor(.blue5)
            .cornerRadius(16)
            .define { flex in
                flex.addItem()
                    .direction(.row)
                    .gap(8)
                    .alignSelf(.center)
                    .define { flex in
                        flex.addItem(icon)
                            .size(24)
                        flex.addItem(label)
                    }
            }
        
        return view
    }()
    
    private let pensionDrawTodayView: UIView = {
        let view = UIView()
        let icon = CommonImageView(imageName: "icon_pensionLottery")
        let label = UILabel()
        
        let fullText = "연금복권 당첨 발표는 오늘이에요!"
        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: Typography.body1.attributes(alignment: .left)
        )
        if let range = fullText.range(of: "오늘") {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttributes(
                [
                    .foregroundColor: UIColor.red50Default,
                    .font: Typography.headline2.font()
                ],
                range: nsRange
            )
        }
        label.attributedText = attributedString
        view.flex
            .paddingVertical(20)
            .backgroundColor(.blue5)
            .cornerRadius(16)
            .define { flex in
                flex.addItem()
                    .direction(.row)
                    .gap(8)
                    .alignSelf(.center)
                    .define { flex in
                        flex.addItem(icon)
                            .size(24)
                        flex.addItem(label)
                    }
            }
        
        return view
    }()
    
    private lazy var pensionDrawCountdownView: UIView = {
        let view = UIView()
        let icon = CommonImageView(imageName: "icon_pensionLottery")
        let label = UILabel()
        let daysUntilPension = calculateDaysUntilNextPension()
        let fullText = "연금복권 당첨 발표까지 \(daysUntilPension)일 남았어요."
        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: Typography.body1.attributes(alignment: .left)
        )
        
        let dayString = "\(daysUntilPension)일"
        if let range = fullText.range(of: dayString) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttributes([
                .foregroundColor: UIColor.blue50Default,
                .font: Typography.headline2.font()
            ], range: nsRange)
        }
        label.attributedText = attributedString
        view.flex
            .paddingVertical(20)
            .backgroundColor(.blue5)
            .cornerRadius(16)
            .define { flex in
                flex.addItem()
                    .direction(.row)
                    .gap(8)
                    .alignSelf(.center)
                    .define { flex in
                        flex.addItem(icon)
                            .size(24)
                        flex.addItem(label)
                    }
            }
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        startRotating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
           let calendar = Calendar.current
           let weekday = calendar.component(.weekday, from: Date())
           
           if weekday == 7 {  // 토요일
               views = [
                   lottoDrawDateView,
                   lottoDrawTodayView,
                   pensionDrawDateView,
                   pensionDrawCountdownView
               ]
           } else if weekday == 4 {
               views = [
                   lottoDrawDateView,
                   lottoDrawCountdownView,
                   pensionDrawDateView,
                   pensionDrawTodayView
               ]
           } else {
               views = [
                   lottoDrawDateView,
                   lottoDrawCountdownView,
                   pensionDrawDateView,
                   pensionDrawCountdownView
               ]
           }
           
           views.forEach { view in
               addSubview(view)
               view.alpha = 0
           }
           views[0].alpha = 1
       }
       
       private func startRotating() {
           timer?.invalidate()
           timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
               self?.rotateViews()
           }
       }
       
       private func rotateViews() {
           let currentView = views[currentIndex]
           let nextIndex = (currentIndex + 1) % views.count
           let nextView = views[nextIndex]
           
           UIView.animate(withDuration: 0.3, animations: {
               currentView.alpha = 0
               nextView.alpha = 1
           })
           
           currentIndex = nextIndex
       }
       
       override func layoutSubviews() {
           super.layoutSubviews()
           
           views.forEach { view in
               view.pin.all()
               view.flex.layout(mode: .adjustHeight)
           }
       }
    
    private func calculateDaysUntilNextLotto() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)
        let daysUntilSaturday = ((7 - weekday) + 7) % 7
        return daysUntilSaturday == 0 ? 7 : daysUntilSaturday
    }
    
    private func calculateDaysUntilNextPension() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)
        let daysUntilWednesday = ((4 - weekday) + 7) % 7
        return daysUntilWednesday == 0 ? 7 : daysUntilWednesday
    }
    
    deinit {
        timer?.invalidate()
    }
}
