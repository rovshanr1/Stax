//
//  LoadingManager.swift
//  Stax
//
//  Created by Rovshan Rasulov on 26.04.26.
//


import UIKit
import SnapKit

final class LoadingManager {
    
    static let shared = LoadingManager()
    
    
    private var overlayView: UIView?
    
    private init() {}
    
    func show() {
        
        guard overlayView == nil else { return }
        
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
        
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .activeItems
        spinner.startAnimating()
        
        
        backgroundView.addSubview(spinner)
        window.addSubview(backgroundView)
        
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        spinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        
        self.overlayView = backgroundView
    }
    
    func hide() {
        DispatchQueue.main.async {
            self.overlayView?.removeFromSuperview()
            self.overlayView = nil
        }
    }
}
