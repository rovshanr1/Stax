//
//  WorkoutDetailHeaderView.swift
//  Stax
//
//  Created by Rovshan Rasulov on 24.03.26.
//

import UIKit
import SnapKit

class WorkoutDetailHeaderView: UIView {
    
    //UI Contents
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
    
    private var setsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "Sets"
        return label
    }()
    
    private var caloriesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "Calories"
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
    
    private var setsValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.text = "00"
        return label
    }()
    
    private var caloriesValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.text = "00"
        return label
    }()
 
    private var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    //Stack Views
    
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
    
    private lazy var setsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [setsLabel, setsValueLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var caloriesStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [caloriesLabel, caloriesValueLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var informationStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [timeStackView, volumeStackView, setsStackView])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [workoutTitleLabel, informationStackView, caloriesStackView, separatorView])
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
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }
    
    func configureDetailHeader(title: String, time: String, volume: String, sets: String, calories: String? ){
        workoutTitleLabel.text = title
        timeValueLabel.text = time
        volumeValueLabel.text = volume
        setsValueLabel.text = sets
        caloriesValueLabel.text = calories
    }
    
}
