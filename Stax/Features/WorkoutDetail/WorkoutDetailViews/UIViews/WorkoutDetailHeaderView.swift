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
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let timeValueLabel = WorkoutDetailHeaderView.makeValueLabel()
    private let volumeValueLabel = WorkoutDetailHeaderView.makeValueLabel()
    private let setsValueLabel = WorkoutDetailHeaderView.makeValueLabel()
    private let caloriesValueLabel = WorkoutDetailHeaderView.makeValueLabel()
 
    private var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    //Stack Views
    
    private lazy var informationStackView: UIStackView = {
         let stackView = UIStackView(arrangedSubviews: [
             Self.makeStat(title: "Time", valueLabel: timeValueLabel),
             Self.makeStat(title: "Volume", valueLabel: volumeValueLabel),
             Self.makeStat(title: "Sets", valueLabel: setsValueLabel),
             Self.makeStat(title: "Calories", valueLabel: caloriesValueLabel)
         ])
         stackView.axis = .horizontal
         stackView.distribution = .fillEqually
         stackView.alignment = .top
         stackView.spacing = 8
         return stackView
     }()
    
    private lazy var mainStackView: UIStackView = {
          let stackView = UIStackView(arrangedSubviews: [workoutTitleLabel,
                                                         descriptionLabel,
                                                         informationStackView,
                                                         separatorView])
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
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }
    
    func configureDetailHeader(title: String, description: String? = nil, time: String, volume: String, sets: String, calories: String? ){
        workoutTitleLabel.text = title
        timeValueLabel.text = time
        volumeValueLabel.text = volume
        setsValueLabel.text = sets
        caloriesValueLabel.text = calories ?? "-"
        
        let trimmed = description?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let hasDescription = !trimmed.isEmpty

        descriptionLabel.text = hasDescription ? trimmed : nil
        descriptionLabel.isHidden = !hasDescription
        
        mainStackView.setCustomSpacing(hasDescription ? 4 : 16, after: workoutTitleLabel)
    }
    
    //MARK: - Factory
    private static func makeValueLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }
    
    private static func makeStat(title: String, valueLabel: UILabel) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = title

        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }
    
}
