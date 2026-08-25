//
//  WorkoutSessionTableViewCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 04.12.25.
//

import UIKit
import SnapKit

final class WorkoutSessionDurationCell: UICollectionViewCell {
    
    private let duration: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.text = "Duration"
        return label
    }()
    
    private let volume: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.text = "Volume"
        return label
    }()
    
    private let sets: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.text = "Sets"
        return label
    }()
    
    private var timer: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.text = "0s"
        return label
    }()
    
    private var volumeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.text = "0 kg"
        return label
    }()
    
    private var setsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.text = "0"
        return label
    }()
    
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [duration, volume, sets])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var valueStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [timer, volumeLabel, setsLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [labelStackView, valueStackView])
        stackView.axis = .vertical
        stackView.spacing = 8
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
        var background = UIBackgroundConfiguration.listCell()
        background.cornerRadius = 12
        self.backgroundConfiguration = background
        
        contentView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints{ make in
            make.edges.equalToSuperview().inset(16)
        }
       
    }
    
    func configureTime(with time: String) {
        timer.text = time
    }
    
    func updateStats(volume: Double, sets: Int){
        volumeLabel.text = volume.formatWeight()
        setsLabel.text = "\(sets)"
    }
}

