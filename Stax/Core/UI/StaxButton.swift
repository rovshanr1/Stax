//
//  StaxButton.swift
//  Stax
//
//  Created by Rovshan Rasulov on 23.05.26.
//

import UIKit
import SnapKit

class StaxButton: UIButton {

    init(title: String, systemImage: String? = nil){
        super.init(frame: .zero)
        
        var config = UIButton.Configuration.filled()
        config.title = title
        
        if let image = systemImage {
            config.image = UIImage(systemName: image)
            config.imagePadding = 8
        }
        
        config.baseBackgroundColor = .activeItems
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        
        self.configuration = config

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
