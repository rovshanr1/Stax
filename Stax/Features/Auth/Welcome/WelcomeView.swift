//
//  WelcomeView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 02.04.26.
//

import UIKit
import SnapKit
import Kingfisher

class WelcomeView: UIView {
    
    var onGetStartedTapped: (() -> Void)?
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "StaxLogo")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let subtitelLabel: UILabel = {
        let label = UILabel()
        label.text = "Elevate your workout. \nTrack your limits."
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let getStartedButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Get Started"
        config.baseBackgroundColor = .activeItems
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 31)
        
        let button = UIButton()
        button.configuration = config
        return button
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [imageView, subtitelLabel, getStartedButton])
        sv.axis = .vertical
        sv.spacing = 32
        sv.alignment = .center
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    private func setupUI() {
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(120)
        }
        
        getStartedButton.snp.makeConstraints { make in
            make.width.equalTo(mainStackView.snp.width)
        }
        
        getStartedButton.addTarget(self, action: #selector(didTapGetStartedButton), for: .touchUpInside)
    }
    
    
    @objc private func didTapGetStartedButton() {
        
        onGetStartedTapped?()
    }
}
