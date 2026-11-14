//
//  LogoLoadingView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 10.11.26.
//

import UIKit
import Lottie
import SnapKit

final class LogoLoadingView: UIView{
    private let animationView: LottieAnimationView = {
        let view = LottieAnimationView(name: "logo-loading")
        view.contentMode = .scaleAspectFit
        view.loopMode = .playOnce
        view.backgroundBehavior = .pauseAndRestore
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(240)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start(completion: (() -> Void)? = nil) {
        guard !UIAccessibility.isReduceMotionEnabled else {
            animationView.currentProgress = 1
            completion?()
            return
        }

        animationView.play { finished in
            if finished { completion?() }
        }
    }

    func stop() { animationView.stop() }
}
