//
//  ShimmerEffect.swift
//  Stax
//
//  Created by Rovshan Rasulov on 15.04.26.
//

import UIKit

extension UIView {
    public var isShimmering: Bool {
        get { return self.layer.mask?.animation(forKey: "shimmer") != nil }
        set { newValue ? startShimmering() : stopShimmering() }
    }
    
    private func startShimmering() {
        guard !isShimmering else {return}
        
        self.layoutIfNeeded()
        
        let light = UIColor.white.cgColor
        let alpha = UIColor.white.withAlphaComponent(0.3).cgColor
        
        let gradient = CAGradientLayer()
        
        gradient.colors = [alpha, light, alpha]
        gradient.frame = CGRect(x: -self.bounds.width, y: 0, width: 3 * self.bounds.width, height: self.bounds.height)
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.locations = [0.4, 0.5, 0.6]
        
        self.layer.mask = gradient
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: "shimmer")
        
    }
    
    private func stopShimmering() {
        self.layer.mask?.removeAllAnimations()
        self.layer.mask = nil
    }
}
