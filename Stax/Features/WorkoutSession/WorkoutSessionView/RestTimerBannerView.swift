//
//  RestTimerBannerView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 03.09.26.
//

import UIKit
import SnapKit

final class RestTimerBannerView: UIView {
    
    var onBannerTapped: (() -> Void)?
    var onSkipTapped: (() -> Void)?
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "timer"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let skipButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .white.withAlphaComponent(0.2)
        config.baseForegroundColor = .white
        config.title = "Skip"
        config.cornerStyle = .capsule
        return UIButton(configuration: config)
    }()
    
    private let progressBar: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.trackTintColor = .white.withAlphaComponent(0.25)
        progress.progressTintColor = .white
        progress.layer.cornerRadius = 2
        progress.clipsToBounds = true
        return progress
    }()
    
    private lazy var topRowStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconImageView, timeLabel, UIView(), skipButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [topRowStack, progressBar])
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .label
        layer.cornerRadius = 16
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        
        addSubview(mainStack)
        
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        progressBar.snp.makeConstraints { make in
            make.height.equalTo(4)
        }
        
        skipButton.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
    }
    
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }
    
    //MARK: - Configuration
    func configureRunning(timeString: String, progress: Float) {
        timeLabel.text = timeString
        skipButton.isHidden = false
        progressBar.isHidden = false
        progressBar.setProgress(progress, animated: true)
    }
    
    func configureFinished() {
        timeLabel.text = "Rest complete"
        skipButton.isHidden = true
        progressBar.isHidden = true
    }
    
    //MARK: - Actions
    @objc private func handleSkip() {
        onSkipTapped?()
    }
    
    @objc private func handleTap() {
        onBannerTapped?()
    }
}
