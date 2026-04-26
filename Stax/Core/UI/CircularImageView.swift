//
//  CircularImageView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 23.04.26.
//

import UIKit

class CircularImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2
        self.clipsToBounds = true
    }
    
}
