//
//  MapLoadingView.swift
//  LottoMate
//
//  Created by Mirae on 10/14/24.
//

import UIKit
import PinLayout
import FlexLayout

class MapLoadingView: UIView {
    fileprivate let rootFlexContainer = UIView()
    
    var loadingImage = UIImageView()
    let mainLoadingText = UILabel()
    let secondaryLoadingText = UILabel()
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        // 로띠로 변경 예정
        if let image = UIImage(named: "ch_tempLoadingImage") {
            loadingImage.image = image
            loadingImage.contentMode = .scaleAspectFit
        }
        
        mainLoadingText.text = "행운을 불러오는 중..."
        styleLabel(for: mainLoadingText, fontStyle: .title3, textColor: .white)
        secondaryLoadingText.text = "잠시만 기다려주세요"
        styleLabel(for: secondaryLoadingText, fontStyle: .headline2, textColor: .white)
        
        addSubview(rootFlexContainer)
        rootFlexContainer.flex.direction(.column).alignItems(.center).marginTop(285).define { flex in
            flex.addItem(loadingImage).size(160).marginBottom(12)
            flex.addItem(mainLoadingText)
            flex.addItem(secondaryLoadingText)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.top().horizontally()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }
}

#Preview {
    let view = MapLoadingView()
    return view
}
