//
//  WorkoutSessionTableViewCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 04.12.25.
//

import UIKit
import SnapKit

class WorkoutSessionTableViewCell: UITableViewCell {
    static let reuseIdentifier: String = "WorkoutSessionTableViewCell"
    
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
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        contentView.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView).inset(16).priority(999)
        }
    }
    
    func configureTime(with time: String) {
        timer.text = time
    }
    
    //TODO: - volume and set lable changes is here
    
    
}

