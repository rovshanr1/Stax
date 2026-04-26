//
//  ProfileWorkoutsCell.swift
//  Stax
//
//  Created by Rovshan Rasulov on 19.04.26.
//

import UIKit
import SnapKit

class ProfileWorkoutsCell: UICollectionViewCell {
    
    var menuButtonTapped: (() -> Void)?
    var navigateToDetails: ((String) -> Void)?
    
    private let headerView = HomeHeaderView()
    
    private var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    private var moreExercisesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .tertiaryLabel
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var exerciseStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [headerView, separatorView, exerciseStackView, moreExercisesLabel])
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        handleEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        contentView.addSubview(containerView)
        containerView.addSubview(mainStackView)
        
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8).priority(999)
            make.left.right.equalToSuperview().inset(16)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }
    
    private func handleEvent(){
        headerView.moreButtonOnTapped = { [weak self] in
            self?.menuButtonTapped?()
        }
    }
    
    func configureProfileWorkoutCell(with workout: WorkoutDomainModel){
        let volumeStr = workout.volume.formatWeight()
        let timeStr = workout.duration.formatDuration()
        
        headerView.configureHomeHeaderView(name: workout.name, time: timeStr, volume: volumeStr)
        
        exerciseStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let displayLimit = 3
        let exercisesList = workout.workoutExercises
        
        for (index, exerciseItem) in exercisesList.enumerated(){
            if index < displayLimit{
                let exerciseView = ExerciseInfoView()
                
                exerciseView.configure(title: exerciseItem.exercise?.name ?? "Unknown Exercise", image: exerciseItem.exercise?.exerciseImage ?? "")
                
                exerciseStackView.addArrangedSubview(exerciseView)
            }
        }
        
        if exercisesList.count > displayLimit {
            moreExercisesLabel.text = "+\(exercisesList.count - displayLimit) exercises more..."
            moreExercisesLabel.isHidden = false
        } else {
            moreExercisesLabel.isHidden = true
        }
    }
}
