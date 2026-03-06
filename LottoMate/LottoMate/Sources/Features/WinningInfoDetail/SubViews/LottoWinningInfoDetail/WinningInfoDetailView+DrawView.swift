//
//  WinningInfoDetailView+DrawView.swift
//  LottoMate
//
//  Created by Mirae on 8/8/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

extension LottoWinningInfoView {
    /// 로또 복권 회차 뷰 설정
    func lottoDrawRoundView() {
        styleLabel(for: lotteryDrawRound, fontStyle: .headline1, textColor: .black, alignment: .right)
        styleLabel(for: drawDate, fontStyle: .label2, textColor: .gray_ACACAC, alignment: .left)
        
        lotteryDrawingInfo.isUserInteractionEnabled = true
        
        let previousRoundBtnImage = UIImage(named: "icon_arrow_left_medium")
        previousRoundButton.setImage(previousRoundBtnImage, for: .normal)
        previousRoundButton.tintColor = .primaryGray
        previousRoundButton.frame = CGRect(x: 0, y: 0, width: 4, height: 10)
        let nextRoundBtnImage = UIImage(named: "icon_arrow_right_medium")
        nextRoundButton.setImage(nextRoundBtnImage, for: .normal)
        nextRoundButton.tintColor = .gray40
        nextRoundButton.frame = CGRect(x: 0, y: 0, width: 4, height: 10)
        
        viewModel.currentLottoRound
            .subscribe(onNext: { lottoDrawRound in
                if let round = lottoDrawRound {
                    if round == self.viewModel.latestLotteryResult.value?.the645.drwNum {
                        self.nextRoundButton.tintColor = .gray40
                    } else {
                        self.nextRoundButton.tintColor = .black
                    }
                }
            })
            .disposed(by: disposeBag)
        
        lotteryDrawingInfo.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.drawRoundTapEvent.accept(true)
            })
            .disposed(by: disposeBag)
    }
}
