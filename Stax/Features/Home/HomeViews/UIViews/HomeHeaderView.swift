//
//  HomeHeaderView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 10.03.26.
//

import UIKit
import SnapKit

class HomeHeaderView: UIView {
    //Closures
    var moreButtonOnTapped: (() -> Void)?
    
    private var workoutTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .label
        return label
    }()
    
    private var moreButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        
        config.image = UIImage(systemName: "ellipsis", withConfiguration: imageConfig)
        config.imagePadding = 8
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .label
        
        button.configuration = config
        return button
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "Time"
        return label
    }()

    private let volumeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "Volume"
        return label
    }()
    
    private var timeValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.text = "00:00"
        return label
    }()
    
    private var volumeValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.text = "00"
        return label
    }()
    
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [workoutTitleLabel, moreButton])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var timeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [timeLabel, timeValueLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var volumeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [volumeLabel, volumeValueLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var informationStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [timeStackView, volumeStackView])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleStackView, informationStackView])
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
       addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(16)
        }
        
        mainStackView.isUserInteractionEnabled = true
        
        moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
    }
    
    func configureHomeHeaderView(name: String, time: String, volume: String){
        workoutTitleLabel.text = name
        timeValueLabel.text = time
        volumeValueLabel.text = volume
    }
    
    
    @objc private func moreButtonTapped(){
        
        moreButton.imageView?.addSymbolEffect(.bounce, options: .nonRepeating, animated: true)
        
        moreButtonOnTapped?()
    }
}
