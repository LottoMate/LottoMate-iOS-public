//
//  CommonImageView.swift
//  LottoMate
//
//  Created by Mirae on 11/11/24.
//

import UIKit

class CommonImageView: UIImageView {
    
    init(imageName: String) {
        super.init(frame: .zero)
        self.image = UIImage(named: imageName)
        self.contentMode = .scaleAspectFit
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
