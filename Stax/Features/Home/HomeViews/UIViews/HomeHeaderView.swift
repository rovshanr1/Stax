//
//  HomeHeaderView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 10.03.26.
//

import UIKit
import SnapKit

class HomeHeaderView: UIView {
    
    private var workoutTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .label
        return label
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
        let stackView = UIStackView(arrangedSubviews: [workoutTitleLabel, informationStackView])
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
    }
    
    func configureHomeHeaderView(name: String, time: String, volume: String){
        workoutTitleLabel.text = name
        timeValueLabel.text = time
        volumeValueLabel.text = volume
    }
}
